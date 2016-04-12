package base.videoPlayer {
	import flash.display.Sprite;
	import base.dspObj.DoOperations;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	import flash.events.MouseEvent;
	
	public class VideoCover extends ControllerVideoPlayer {
		
		public var imgSplash: Sprite;
		public var markPausePlay: ControllerPausePlay;
		
		public var isOver: Boolean = false;
		
		public function VideoCover(): void {
			if (this.imgSplash != null) {
				ModelVideoPlayer.addEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.hideImgSplashWhenPlay);
				ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STOP, this.showImgSplashWhenStop);	
			}
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.hideShowMarkPausePlayFromEvent);
			this.markPausePlay.alpha = 0;
		}
		
		override public function removeMouseEvents(): void {
			if (this.imgSplash != null) {
				ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.hideImgSplashWhenPlay);
				ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STOP, this.showImgSplashWhenStop);	
			}
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.hideShowMarkPausePlayFromEvent);
			this.markPausePlay.removeMouseEvents();
			super.removeMouseEvents();
		}
		
		private function hideImgSplashWhenPlay(e: EventModelVideoPlayer): void {
			var isPlay: Boolean = Boolean(uint(e.data));
			if (isPlay) DoOperations.hideShow(this.imgSplash, 0, 5);
		}
		
		private function showImgSplashWhenStop(e: EventModelVideoPlayer): void {
			DoOperations.hideShow(this.imgSplash, 1, 5);
		}
		
		private function hideShowMarkPausePlay(isHideShow: uint, isFromMouseOrEvent: uint): void {
			TweenNano.killTweensOf(this.markPausePlay);
			TweenNano.to(this.markPausePlay, 5, {alpha: isHideShow * [0.3, 1][isFromMouseOrEvent], ease: Linear.easeNone, delay: [0, 5][uint((isFromMouseOrEvent == 1) && (isHideShow == 1))], useFrames: true});
		}
		
		private function hideShowMarkPausePlayFromEvent(e: EventModelVideoPlayer): void {
			var isPausePlay: uint = uint(e.data);
			if ((!this.isOver) || (isPausePlay == 0)) {
				this.hideShowMarkPausePlay(1 - isPausePlay, 1);
			}
		}
		
		override protected function onMouseOverHandler(event: MouseEvent): void {
			this.isOver = true;
			this.hideShowMarkPausePlay(1, 0);
		}
		
		override protected function onMouseOutHandler(event: MouseEvent): void {
			this.isOver = false;
			if (ModelVideoPlayer.isPausePlay == 1) this.hideShowMarkPausePlay(0, 0);
		}
		
		override protected function onClickHandler(event: MouseEvent): void {
			if (this.alpha > 0) this.markPausePlay.hit.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		override public function destroy(): void {
			this.removeMouseEvents();
			super.destroy();
		}
		
	}

}