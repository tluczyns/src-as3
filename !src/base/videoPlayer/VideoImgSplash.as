package base.videoPlayer {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import base.loader.LoadContentQueue;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	public class VideoImgSplash extends Sprite {
		
		private var dimension: Metadata;
		private var indImgSplashInArrContent: uint;
		protected var bmpImgSplashContent: Bitmap;
		private var isHideShow: uint;
		
		public function VideoImgSplash(filenameImgSplash: String, dimension: Metadata): void {
			this.dimension = dimension.clone();
			this.loadImgSplash(filenameImgSplash);
		}
		
		private function loadImgSplash(filenameImgSplash: String): void {
			this.isHideShow = 1;
			var loadContentQueue: LoadContentQueue = new LoadContentQueue(this.onContentLoadCompleteHandler, this);
			this.indImgSplashInArrContent = loadContentQueue.addToLoadQueue(filenameImgSplash);
			loadContentQueue.startLoading();
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.PAUSE_PLAY, this.onPlay);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STOP, this.onStop);
		}
		
		protected function onContentLoadCompleteHandler(arrContent: Array): void {
			var objImgSplashContent: Object = arrContent[this.indImgSplashInArrContent];
			if ((objImgSplashContent.isLoaded) && (objImgSplashContent.type == LoadContentQueue.IMAGE)) {
				this.bmpImgSplashContent = Bitmap(objImgSplashContent.content);
				this.bmpImgSplashContent.smoothing = true;
				this.bmpImgSplashContent.alpha = 0;
				this.bmpImgSplashContent.visible = false;
				this.addChild(this.bmpImgSplashContent);
				if (this.dimension != null) {
					this.bmpImgSplashContent.width = this.dimension.width;
					this.bmpImgSplashContent.height = this.dimension.height;
				}
			}
			if (this.isHideShow == 1) this.hideShow(1);
		}
		
		private function onPlay(e: EventModelVideoPlayer): void {
			if (uint(e.data) == 1) this.hideShow(0);
		}
		
		private function onStop(e: EventModelVideoPlayer): void {
			this.hideShow(1);
		}
		
		protected function hideShow(isHideShow: uint): void {
			this.isHideShow = isHideShow;
			if (this.bmpImgSplashContent) TweenMax.to(this.bmpImgSplashContent, 8, {autoAlpha: isHideShow, ease: Linear.easeNone, useFrames: true});
		}
		
		public function destroy(): void {
			if (this.bmpImgSplashContent) this.bmpImgSplashContent.bitmapData.dispose();
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STOP, this.onStop)
		}
		
	}

}