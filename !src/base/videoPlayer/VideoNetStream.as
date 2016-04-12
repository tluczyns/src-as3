package base.videoPlayer {
	import flash.net.NetStream;
	import flash.display.MovieClip;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VolumePlugin;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.events.Event;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	
	public class VideoNetStream extends NetStream {
		
		private var _urlVideo: String;
		private var isLoop: Boolean;
		private var isGoToBeginWhenStop: Boolean;
		private var metadata: Metadata;
		public var isLoaded: Boolean;
		private var mcEF: MovieClip;
		
		public function VideoNetStream(urlVideo: String, isPausePlay: uint = 0, isLoop: Boolean = false, inBufferSeek: Boolean = false, isGoToBeginWhenStop: Boolean = true, bufferTime: Number = 2): void {
			TweenPlugin.activate([VolumePlugin])
			this.isLoop = isLoop;
			this.inBufferSeek = true;
			this.isGoToBeginWhenStop = isGoToBeginWhenStop;
			var nc: NetConnection = new NetConnection();
			nc.connect(null);
			super(nc);
			this._urlVideo = urlVideo;
			this.configStream(bufferTime);
			this.addListeners();
			TweenLite.to(this, 0, {volume: ModelVideoPlayer._volume});
			ModelVideoPlayer.isPausePlay = isPausePlay;
		}

		private function configStream(bufferTime: Number = 2): void {
			this.isLoaded = false;
			this.metadata = new Metadata();
			this.metadata.onMetaData = this.onMetaDataHandler;
			this.client = this.metadata;
			this.bufferTime = bufferTime;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SET, this);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.VIDEO_CONTAINER_ADDED, this.assignStreamToVideoContainer);
			this.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusHandler);
			this.mcEF = new MovieClip();
		}
		
		public function get urlVideo(): String {
			return this._urlVideo;
		}
		
		public function set urlVideo(value: String): void {
			this.close();
			this._urlVideo = value;
			this.isLoaded = false;
			this.metadata.duration = NaN;
		}

		
		private function assignStreamToVideoContainer(e: EventModelVideoPlayer): void {
			var videoContainer: VideoContainer = VideoContainer(e.data);
			videoContainer.video.attachNetStream(this);
			if (getDefinitionByName(getQualifiedClassName(e.data)) == VideoContainerResizable)
				ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.METADATA_SET, this.metadata);
		}
		
		private function addListeners(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.pauseOrPlay);	
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STOP, this.stop);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.volumeChange);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STREAM_SEEK, this.streamSeek);
		}
		
		private function removeListeners(): void {
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.pauseOrPlay);	
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STOP, this.stop);
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.volumeChange);
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STREAM_SEEK, this.streamSeek);
		}
		
		private function pauseOrPlay(e: EventModelVideoPlayer): void {
			var isPausePlay: uint = uint(e.data);
			if (isPausePlay == 0) {
				this.mcEF.dispatchEvent(new Event(Event.ENTER_FRAME));
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);
				this.pause();
			} else if (isPausePlay == 1) {
				ModelVideoPlayer.isStop = false;
				this.mcEF.addEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);
				this.mcEF.dispatchEvent(new Event(Event.ENTER_FRAME));
				if (this.isLoaded) this.resume();
				else {
					this.play(this.urlVideo);
					this.resume();
					this.mcEF.addEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
					this.isLoaded = true;
				}
			}
		}

		private function onEnterFrameProgressHandler(e: Event): void {
			if ((this.metadata != null) && (!isNaN(this.metadata.duration))) {
				var ratioPlayedTimeStream: Number = this.time / this.metadata.duration;
				ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_PROGRESS, ratioPlayedTimeStream);
			}
		}
		
		private function onEnterFrameLoadHandler(e: Event):void {
			var ratioLoadedStream: Number = this.bytesLoaded / this.bytesTotal;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_LOAD, ratioLoadedStream);
			if (ratioLoadedStream == 1) this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
		}
		
		private function stop(e: EventModelVideoPlayer): void {
			ModelVideoPlayer.isStop = true;
			ModelVideoPlayer.isPausePlay = 0;
			if (this.isGoToBeginWhenStop) ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SEEK, 0);
		}
		
		private function volumeChange(e: EventModelVideoPlayer): void {
			var volume: Number = Number(e.data);
			TweenLite.to(this, 0.8, {volume: volume, ease: Linear.easeNone});
		}
		
		private function streamSeek(e: EventModelVideoPlayer): void {
			if (this.isLoaded) {
				var ratioPosVideo: Number = Number(e.data);
				this.seek(Math.round(ratioPosVideo * [this.metadata.duration, 1][uint(ratioPosVideo > 1)]));
				ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_PROGRESS, ratioPosVideo);
			}
		}
		
		/*-------------------------------videoHandlers--------------------------------*/
		
		private function onNetStatusHandler(event: NetStatusEvent): void {
			//trace("code:"+event.info.code);
			switch(event.info.code) {
				case 'NetStream.Play.Start':
					break;
				case 'NetStream.Play.Stop':
					if (!this.isLoop) ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STOP, null); 
					else ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SEEK, 0);
					break;
				case 'NetStream.FileStructureInvalid':				
					break;
				case 'NetStream.Play.StreamNotFound':
					break;
				case 'NetStream.Seek.Notify':
					break;
				case 'NetStream.Buffer.Empty':
					ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.BUFFER_EMPTY, null); 
					break;
				case 'NetStream.Buffer.Full':
					ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.BUFFER_FULL, null); 
					break;
			}
		}
		
		private function onMetaDataHandler(objMetaData: Object): void {
			this.metadata.width = objMetaData.width;
			this.metadata.height = objMetaData.height;
			this.metadata.seekPoints = objMetaData.seekpoints;
			this.metadata.frameRate = objMetaData.videoframerate;
			this.metadata.duration = objMetaData.duration;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.METADATA_SET, this.metadata); 
		}
		
		public function destroy(): void {
			this.removeListeners();
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.VIDEO_CONTAINER_ADDED, this.assignStreamToVideoContainer);	
			this.removeEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusHandler);
			if (this.mcEF) {
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);	
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
			}
			this.close();
		}
		
	}

}