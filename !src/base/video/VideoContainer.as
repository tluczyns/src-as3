package base.video {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import flash.net.NetStream;
	import flash.media.Video;
		
	public class VideoContainer extends Sprite implements IVideoContainer {
		
		protected var classVideoLoader: VideoLoader;
		internal var video: Video;
		
		public function VideoContainer(classVideoLoader: VideoLoader = null) {
			if (classVideoLoader != null) {
				this.init(classVideoLoader);
			}
		}
	
		internal function init(classVideoLoader: VideoLoader): void {
			this.classVideoLoader = classVideoLoader;
			this.video = new Video();
			this.video.smoothing = true;
			this.addChild(this.video);
			this.video.attachNetStream(this.classVideoLoader.ns);
			this.setVideoDimensionAndPosition();
			//this.cover._alpha = 0;
			//this.control._alpha = 0;
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
		}
		
		private function checkAndCopyStreamDimensionToVideoDimensionWhenDefaultDimensionApplied(): Boolean {
			var isDimensionChanged: Boolean = false;
			if ((this.classVideoLoader.objFlv.isWidthVideoDefaultApplied) && ((!isNaN(this.video.videoWidth)) && (this.video.videoWidth != 0))) { 
				this.classVideoLoader.objFlv.width = this.video.videoWidth;
				this.classVideoLoader.objFlv.isWidthVideoDefaultApplied = false;
				isDimensionChanged = true;
			}
			if ((this.classVideoLoader.objFlv.isHeightVideoDefaultApplied) && ((!isNaN(this.video.videoHeight)) && (this.video.videoHeight != 0))) {
				this.classVideoLoader.objFlv.height = this.video.videoHeight;
				this.classVideoLoader.objFlv.isHeightVideoDefaultApplied = false;
				isDimensionChanged = true;
			}
			if (isDimensionChanged) {
				this.setVideoDimensionAndPosition();
			}
			return isDimensionChanged;
		}
		
		protected function setVideoDimensionAndPosition(): void {
			this.video.width = /*this.cover._width = this.btn._width = */ this.classVideoLoader.objFlv.width;
			this.video.height = /*this.cover._height = this.btn._height =*/ this.classVideoLoader.objFlv.height;
			this.video.x = this.classVideoLoader.objFlv.x;
			this.video.y = this.classVideoLoader.objFlv.y;
			if (this.classVideoLoader.objFlv.addMask) {
				this.classVideoLoader.addVideoMask();
			}
			//this.control._x = (this.video._width - this.control._width) / 2
			//this.control._y = (this.video._height - this.control._height) / 2
		}
		
		protected function onEnterFrameHandler(e: Event): void {
			var isDimensionChanged: Boolean = this.checkAndCopyStreamDimensionToVideoDimensionWhenDefaultDimensionApplied();
			/*if (isDimensionChanged) {
			}*/
		}
		
		/*
		public function showControls() {
			this.control.setVisibilityControlsPausePlay = function(isPausePlay) {
				this.hitPlay._visible = Boolean(1 - isPausePlay);
				this.hitPause._visible = Boolean(isPausePlay);
			}
			this.addBtnEvents();
		}
		
		private function addBtnEvents() {
			this.btn.classVideoContainer = this;
			this.btn.onRollOver = function() {
				if (this.classVideoContainer.isPausePlay == 1) {
					this.classVideoContainer.showVideoControlAndCover();	
				}
			}
			this.btn.onRollOut = this.btn.onReleaseOutside = function() {
				if (this.classVideoContainer.isPausePlay == 1) {
					this.classVideoContainer.hideVideoControlAndCover();
				}
			}
			this.btn.onRelease = function() {
				this.classVideoContainer.streamPausePlay(1 - this.classVideoContainer.isPausePlay);
			}
		}

		private function showVideoControlAndCover() {
			this.cover.pokaz(10);
			this.control.pokaz(10);
			this.control.setVisibilityControlsPausePlay(this.isPausePlay);
		}

		private function hideVideoControlAndCover() {
			this.cover.znikaj(10);
			this.control.znikaj(10);
		}
		
		public function streamPausePlay(isPausePlay: Number) {
			this.isPausePlay = isPausePlay;
			this.ns.pause(Boolean(1 - isPausePlay))	
			if (isPausePlay == 0) {
				this.showVideoControlAndCover();
			} else if (isPausePlay == 1) {
				this.hideVideoControlAndCover();
				
			}
		} 
		 */
				
	}
	
}