package base.videoPlayerIsolated {
	import flash.net.NetStream;
	import flash.display.MovieClip;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.events.Event;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	
	public class VideoNetStream extends NetStream {
		
		private var urlVideo: String;
		private var isLoop: Boolean;
		private var metadata: Metadata;
		private var isLoaded: Boolean = false;
		private var mcEF: MovieClip;
		private var _isPausePlay: uint;
		public var isStop: Boolean = true;
		
		public function VideoNetStream(urlVideo: String, isPausePlay: uint = 0, isLoop: Boolean = false, inBufferSeek: Boolean = false): void {
			TweenPlugin.activate([VolumePlugin]);
			this.urlVideo = urlVideo;
			this.isLoop = isLoop;
			this.inBufferSeek = true;
			var nc: NetConnection = new NetConnection();
			nc.connect(null);
			super(nc);
			this.configStream();
			this.addListeners();
			this.isPausePlay = isPausePlay;
		}
		
		private function configStream(): void {
			this.metadata = new Metadata();
			this.metadata.onMetaData = this.onMetaDataHandler;
			this.client = this.metadata;
			this.bufferTime = 2;
			this.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusHandler);
			this.mcEF = new MovieClip();
		}
		
		private function addListeners(): void {
			this.addEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.pauseOrPlay);	
			this.addEventListener(EventModelVideoPlayer.STOP, this.stop);
			this.addEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.volumeChange);
			this.addEventListener(EventModelVideoPlayer.STREAM_SEEK, this.streamSeek);
		}
		
		private function removeListeners(): void {
			this.removeEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.pauseOrPlay);	
			this.removeEventListener(EventModelVideoPlayer.STOP, this.stop);
			this.removeEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.volumeChange);
			this.removeEventListener(EventModelVideoPlayer.STREAM_SEEK, this.streamSeek);
		}
		
		public function get isPausePlay(): uint {
			return this._isPausePlay;
		}
		
		public function set isPausePlay(value: uint): void {
			this._isPausePlay = value;
			this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.PAUSE_PLAY, value));
		}
		
		private function pauseOrPlay(e: EventModelVideoPlayer): void {
			var isPausePlay: uint = uint(e.data);
			if (isPausePlay == 0) {
				this.mcEF.dispatchEvent(new Event(Event.ENTER_FRAME));
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);
				this.pause();
			} else if (isPausePlay == 1) {
				this.isStop = false;
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
				this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STREAM_PROGRESS, ratioPlayedTimeStream));
			}
		}
		
		private function onEnterFrameLoadHandler(e: Event):void {
			var ratioLoadedStream: Number = this.bytesLoaded / this.bytesTotal;
			this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STREAM_LOAD, ratioLoadedStream));
			if (ratioLoadedStream == 1) this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
		}
		
		private function stop(e: EventModelVideoPlayer): void {
			this.isStop = true;
			this.isPausePlay = 0;
			this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STREAM_SEEK, 0));
		}
		
		private function volumeChange(e: EventModelVideoPlayer): void {
			var volume: Number = Number(e.data.volume);
			var time: Number = Number(e.data.time) || 0.3;
			TweenLite.to(this, time, {volume: volume});
		}
		
		private function streamSeek(e: EventModelVideoPlayer): void {
			if (this.isLoaded) {
				var ratioPosVideo: Number = Number(e.data);
				this.seek(Math.round(ratioPosVideo * [this.metadata.duration, 1][uint(ratioPosVideo > 1)]));
				this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STREAM_PROGRESS, ratioPosVideo));
			}
		}
		
		/*-------------------------------videoHandlers--------------------------------*/
		
		private function onNetStatusHandler(event: NetStatusEvent): void {
			//trace("code:"+event.info.code);
			switch(event.info.code) {
				case 'NetStream.Play.Start':
					break;
				case 'NetStream.Play.Stop':
					if (!this.isLoop) this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STOP, null));
					else this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.STREAM_SEEK, 0));
					break;
				case 'NetStream.FileStructureInvalid':				
					break;
				case 'NetStream.Play.StreamNotFound':
					break;
				case 'NetStream.Seek.Notify':
					break;
				case 'NetStream.Buffer.Empty':
					this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.BUFFER_EMPTY, null));
					break;
				case 'NetStream.Buffer.Full':
					this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.BUFFER_FULL, null));
					break;
			}
		}
		
		private function onMetaDataHandler(objMetaData: Object): void {
			this.metadata.width = objMetaData.width;
			this.metadata.height = objMetaData.height;
			this.metadata.seekPoints = objMetaData.seekpoints;
			this.metadata.frameRate = objMetaData.videoframerate;
			this.metadata.duration = objMetaData.duration;
			this.dispatchEvent(new EventModelVideoPlayer(EventModelVideoPlayer.METADATA_SET, this.metadata)); 
		}
		
		public function destroy(): void {
			this.removeListeners();
			this.removeEventListener(NetStatusEvent.NET_STATUS, this.onNetStatusHandler);
			if (this.mcEF) {
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);	
				this.mcEF.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
			}
			this.close();
		}
		
	}

}