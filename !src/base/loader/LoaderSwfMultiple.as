package base.loader {
	import flash.display.Sprite;
	import base.loader.progress.LoaderProgress;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
	import base.loader.Library;
	
	public class LoaderSwfMultiple extends Sprite {
		
		static public var TIME_HIDE_SHOW: Number = 0.4
		static public var TIME_SHOW_SWF: Number = 0.4;
		
		private var pathAssets: String;
		private var arrPathSwf: Array;
		private var loaderProgress: LoaderProgress;
		private var numSwfApplication: int;
		private var arrWeightSwf: Array;
		private var classLibrary: Class;
		private var loadContentQueue: LoadContentQueue;
		private var arrIndSwf: Array;
		private var isAllSwfsLoaded: Boolean;
		protected var arrSwf: Array;
		protected var swfApplication: *;
		
		public function LoaderSwfMultiple(pathAssets: String, arrNameSwf: Array, addToPathSwf: String = "swf/", numSwfApplication: int = 0, arrWeightSwf: Array = null, classLibrary: Class = null): void {
			this.pathAssets = pathAssets;
			this.arrPathSwf = new Array(arrNameSwf.length);
			for (var i: uint = 0; i < arrNameSwf.length; i++)
				this.arrPathSwf[i] = pathAssets + addToPathSwf + arrNameSwf[i];
			this.numSwfApplication = numSwfApplication;
			if (!this.arrWeightSwf) {
				this.arrWeightSwf = new Array(this.arrPathSwf.length);
				for (i = 0; i < this.arrPathSwf.length; i++)
					this.arrWeightSwf[i] = 1;
			}
			this.classLibrary = classLibrary || base.loader.Library;
			this.createAndInitLoaderProgress();
			this.prepareLoadContentQueue();
		}
		
		protected function createLoaderProgress(): LoaderProgress {
			return new LoaderProgress(null, this.isTLOrCenterAnchorPointWhenCenterOnStage);
		}
		
		protected function get isTLOrCenterAnchorPointWhenCenterOnStage(): uint {
			return 0;
		}
		
		private function createAndInitLoaderProgress(): void {
			this.loaderProgress = this.createLoaderProgress();
			this.addChild(this.loaderProgress);
			TweenNano.from(this.loaderProgress, LoaderOneSwf.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.startLoading});
		}
		
		private function prepareLoadContentQueue(): void {
			this.loadContentQueue = new LoadContentQueue(this.onContentLoadCompleteHandler, this, this.loaderProgress);
			this.arrIndSwf = [];
			for (var i: uint = 0; i < this.arrPathSwf.length; i++)
				this.arrIndSwf.push(this.loadContentQueue.addToLoadQueue(String(this.arrPathSwf[i]), this.arrWeightSwf[i]));
		}
		
		protected function startLoading(): void {
			this.loadContentQueue.startLoading();
		}
		
		private function onContentLoadCompleteHandler(arrContent: Array): void {
			this.isAllSwfsLoaded = true;
			this.arrSwf = new Array(this.arrIndSwf.length);
			for (var i: uint = 0; i < this.arrIndSwf.length; i++) {
				var objSwf: Object = arrContent[this.arrIndSwf[i]];
				if ((objSwf.isLoaded) && (objSwf.type == LoadContentQueue.SWF)) {
					var swf: DisplayObject = objSwf.content;
					if (i == this.numSwfApplication) this.swfApplication = swf;
					this.classLibrary["addSwf"](swf);
					this.arrSwf[i] = swf;
				} else this.isAllSwfsLoaded = false;
			}
			this.hideLoaderProgressAndShowSwf();
		}
		
		protected function hideLoaderProgressAndShowSwf(): void {
			TweenNano.to(this.loaderProgress, LoaderOneSwf.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.removeLoaderProgressAndShowSwf});
		}
		
		private function removeLoaderProgress(): void {
			this.loaderProgress.destroy();
			this.removeChild(this.loaderProgress);
			this.loaderProgress = null;
		}

		private function removeLoaderProgressAndShowSwf(): void {
			this.removeLoaderProgress();
			this.showSwf();
		}
		
		protected function initSwfVariables(): void {
			//np: this.swf.content["login"] = (root.loaderInfo.parameters.login) ? String(root.loaderInfo.parameters.login) : "";
		}
		
		protected function get isTweenShow(): Boolean {
			return true;
		}
		
		protected function showSwf(): void {
			this.initSwfVariables();
			this.addChild(this.swfApplication);
			this.swfApplication.alpha = 1;
			if (!this.isTweenShow) TweenNano.from(this.swfApplication, LoaderSwfMultiple.TIME_SHOW_SWF, {alpha: 0, ease: Linear.easeNone, onComplete: this.initSwf});
			else this.initSwf();
		}
		
		protected function initSwf(): void {
			this.destroy();
			if (this.swfApplication.init) this.swfApplication.init(this.pathAssets);
		}
		
		protected function destroy(): void {}
		
	}

}