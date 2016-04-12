package base.videoPlayer {
	import flash.display.Loader;
	import flash.system.Security;
	import flash.events.Event;
	import flash.net.URLRequest;
	import com.greensock.TweenNano;
	
	public class VideoYouTube extends Loader {
		
		static public const ON_READY_VIDEO_YOUTUBE: String = "onReadyVideoYoutube";
		
		private var idVideo: String;
		private var widthVideo: Number;
		private var heightVideo: Number;
		private var isPausePlay: uint;
		private var isLoaded: Boolean = false;
		public var player: Object;
		private var metadata: Metadata;
		public var volume: Number;
		
		
		public function VideoYouTube(idVideo: String, widthVideo: Number = 0, heightVideo: Number = 0, isPausePlay: uint = 0, isChromelessEmbedded: uint = 0, isUseProxy: Boolean = false): void {
			Security.allowDomain("youtube.com");
			Security.allowDomain("s.ytimg.com"); 
			this.idVideo = idVideo;
			this.widthVideo = widthVideo;
			this.heightVideo = heightVideo;
			this.isPausePlay = isPausePlay;
			this.contentLoaderInfo.addEventListener(Event.INIT, this.onPlayerLoaded);
			var urlVideo: String = ["http://www.youtube.com/apiplayer?version=3", "http://www.youtube.com/v/" + idVideo + "?version=3"][isChromelessEmbedded];
			if (isUseProxy) urlVideo = "flash_proxy.php?type=application/x-shockwave-flash&url=" + escape(urlVideo);
			this.load(new URLRequest(urlVideo));
		}
		
		private function onPlayerLoaded(event:Event): void {
			this.contentLoaderInfo.removeEventListener(Event.INIT, this.onPlayerLoaded);
			this.content.addEventListener("onReady", this.onPlayerReady);
			this.content.addEventListener("onError", this.onPlayerError);
			this.content.addEventListener("onStateChange", this.onPlayerStateChange);
			//this.content.addEventListener("onPlaybackQualityChange", this.onVideoPlaybackQualityChange);
		}
		
		private function onPlayerReady(event:Event): void {			
			this.player = this.content;
			var isSetSize: Boolean = false;
			if ((this.widthVideo > 0) && (this.heightVideo > 0)) {
				this.player.setSize(this.widthVideo, this.heightVideo);
				isSetSize = true;
			}
			this.addListeners();
			this.player.loadVideoById(this.idVideo);
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
			this.isLoaded = true;
			
			if ((this.isPausePlay == 0)) {
				this.player.cueVideoById(this.idVideo);
			}
			ModelVideoPlayer.isPausePlay = this.isPausePlay;
			this.dispatchEvent(new Event(ON_READY_VIDEO_YOUTUBE));
			this.waitForMetaData();
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
			//trace("isPausePlay:", isPausePlay)
			if (isPausePlay == 0) {
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);
				this.player.pauseVideo();
			} else if (isPausePlay == 1) {
				this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameProgressHandler);
				//trace("this.isLoaded:"+this.isLoaded)
				if (this.isLoaded) this.player.playVideo();
				else {
					//trace("this.idVideo:"+this.idVideo)
					this.player.loadVideoById(this.idVideo);
					this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
					this.isLoaded = true;
				}
			}
		}
	
		private function onEnterFrameProgressHandler(e: Event): void {
			if (this.player.getDuration() > 0) {
				var ratioPlayedTimeStream: Number = this.player.getCurrentTime() / this.player.getDuration();
				ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_PROGRESS, ratioPlayedTimeStream);
			}
		}
		
		private function onEnterFrameLoadHandler(e: Event):void {
			var ratioLoadedStream: Number = this.player.getVideoBytesLoaded() / this.player.getVideoBytesTotal();
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_LOAD, ratioLoadedStream);
			if (ratioLoadedStream == 1) this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
		}
		
		private function onPlayerError(e: Event): void {
			var state: int = int(Object(e).data);
			//trace("error:", state);
		}
		
		
		private function onPlayerStateChange(event:Event):void {
			var state: int = int(Object(event).data);
			//trace("state:", state, ModelVideoPlayer.isPausePlay);
			if (state == 0) ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STOP); 
			//else if (state == 1) this.player.getChildAt(0).getChildAt(0).getChildAt(3).visible = false;
			if (state == 3) ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.BUFFER_EMPTY);
			else ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.BUFFER_FULL, null);
		}
		
		private function stop(e: EventModelVideoPlayer): void {
			ModelVideoPlayer.isPausePlay = 0;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SEEK, 0);
		}
		
		private function volumeChange(e: EventModelVideoPlayer): void {
			var volumeToSet: Number = Number(e.data) * 100;
			this.volume = this.player.getVolume();
			TweenNano.to(this, 20, {volume: volumeToSet, useFrames: true, onUpdate: this.onUpdateVolumeChange});
		}
		
		private function onUpdateVolumeChange(): void {
			this.player.setVolume(this.volume);
		}
		
		private function streamSeek(e: EventModelVideoPlayer): void {
			if (this.isLoaded) {
				var ratioPosVideo: Number = Number(e.data);
				this.player.seekTo(Math.round(this.player.getDuration() * ratioPosVideo));
				if (ModelVideoPlayer.isPausePlay == 0) this.player.pauseVideo();
			}
		}
		
		private function waitForMetaData(): void {
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameWaitForMetaData);			
		}
		
		private function onEnterFrameWaitForMetaData(e: Event): void {
			if (this.player.getDuration() > 0) {
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameWaitForMetaData);
				this.setMetaData();
			}
		}
		
		private function setMetaData(): void {
			this.metadata = new Metadata();
			this.metadata.width = this.player.width;
			this.metadata.height = this.player.height;
			//trace("setMetaData:", this.player.width, this.player.height, this.player.getDuration())
			this.metadata.duration = this.player.getDuration();
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.METADATA_SET, this.metadata);
		}
		
		public function destroy(): void {
			if (!this.isLoaded) {
				if (this.contentLoaderInfo.hasEventListener(Event.INIT)) this.contentLoaderInfo.removeEventListener(Event.INIT, this.onPlayerLoaded);
				else {
					this.content.removeEventListener("onReady", this.onPlayerReady);
					this.content.removeEventListener("onError", this.onPlayerError);
					this.content.removeEventListener("onStateChange", this.onPlayerStateChange);
				}
			} else {
				ModelVideoPlayer.isPausePlay = 0;
				this.removeListeners();	
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameLoadHandler);
			}
		}
		
	}

}