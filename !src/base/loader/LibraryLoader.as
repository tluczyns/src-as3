package base.loader {
	import flash.display.Sprite;
	import base.loader.LoadContentQueue;
	import base.loader.progress.LoaderProgress;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
	
    public class LibraryLoader extends Sprite {
		
		private static const TIME_HIDE_SHOW: Number = 0.2;
		
		private var loaderProgress: LoaderProgress;
		protected var loadContentQueue: LoadContentQueue;
		private var arrIndSwfLib: Array;
		protected var isAllLibrariesLoaded: Boolean;
		public var arrSwfLib: Array;
		
		function LibraryLoader(arrFilenameSwfLib: Array): void {
			this.createAndInitLoaderProgress();
			this.prepareLoadContentQueue(arrFilenameSwfLib);
		}
		
		protected function createLoaderProgress(): LoaderProgress {
			return new LoaderProgress();
		}
		
		private function createAndInitLoaderProgress(): void {
			this.loaderProgress = this.createLoaderProgress();
			this.addChild(this.loaderProgress);
			TweenNano.from(this.loaderProgress, LibraryLoader.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.startLoading});
		}
		
		private function prepareLoadContentQueue(arrFilenameSwfLib: Array): void {
			this.loadContentQueue = new LoadContentQueue(this.onContentLoadCompleteHandler, this, this.loaderProgress);
			this.loadContent(arrFilenameSwfLib);
		}
		
		protected function loadContent(arrFilenameSwfLib: Array): void {
			this.arrIndSwfLib = [];
			for (var i:uint = 0; i < arrFilenameSwfLib.length; i++) {
				this.arrIndSwfLib.push(this.loadContentQueue.addToLoadQueue(String(arrFilenameSwfLib[i])));
			}
		}
		
		private function startLoading(): void {
			this.loadContentQueue.startLoading();
		}
		
		protected function onContentLoadCompleteHandler(arrContent: Array): void {
			this.isAllLibrariesLoaded = true;
			this.arrSwfLib = new Array(this.arrIndSwfLib.length);
			for (var i:uint = 0; i < this.arrIndSwfLib.length; i++) {
				var objSwfLib: Object = arrContent[this.arrIndSwfLib[i]];
				if (objSwfLib.isLoaded) {
					if (objSwfLib.type == LoadContentQueue.SWF) {
						this.arrSwfLib[i] = objSwfLib.content;
						Library.addSwf(DisplayObject(objSwfLib.content));
					}
				} else this.isAllLibrariesLoaded = false;
			}
			this.hideLoaderProgress();
		}
		
		private function hideLoaderProgress(): void {
			TweenNano.to(this.loaderProgress, LibraryLoader.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.onHideLoaderProgress});
		}
		
		private function removeLoaderProgress(): void {
			this.loaderProgress.destroy();
			this.removeChild(this.loaderProgress);
			this.loaderProgress = null;
		}
		
		protected function onHideLoaderProgress(): void {
			this.removeLoaderProgress();
			if (this.isAllLibrariesLoaded) this.dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.LIBRARIES_LOAD_SUCCESS));
			else this.dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.LIBRARIES_LOAD_ERROR));
		}
		
	}
}
