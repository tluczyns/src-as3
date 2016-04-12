package base.loader {
	import flash.display.Sprite;
	import base.app.InitUtils;
	import flash.events.Event;
	import base.loader.progress.LoaderProgress;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	
	public class LoaderOneSwf extends Sprite {
		
		static public var TIME_HIDE_SHOW: Number = 0.4
		static public var TIME_SHOW_SWF: Number = 0.4;
		
		protected var pathSwf: String;
		protected var loaderProgress: LoaderProgress;
		protected var swf: *;
		
		public function LoaderOneSwf(pathSwf: String, scaleMode: String = "noScale"): void {
			this.pathSwf = pathSwf;
			InitUtils.initApp(this, scaleMode);
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		protected function onAddedToStage(e: Event = null): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.createAndInitLoaderProgress();
		}
		
		protected function createLoaderProgress(): LoaderProgress {
			return new LoaderProgress(null, this.isTLOrCenterAnchorPointWhenCenterOnStage);
		}
		
		protected function get isTLOrCenterAnchorPointWhenCenterOnStage(): uint {
			return 0;
		}
		
		private function createAndInitLoaderProgress(): void {
			this.loaderProgress = this.createLoaderProgress();
			this.loaderProgress.addWeightContent(1);
			this.addChild(this.loaderProgress);
			TweenNano.from(this.loaderProgress, LoaderOneSwf.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.loadSwf});
		}
		
		protected function loadSwf(): void {
			this.swf = new LoaderExt({url: this.pathSwf, onLoadComplete: this.onLoadComplete, onLoadProgress: this.loaderProgress.onLoadProgress});
			this.swf.alpha = 0;
			this.loaderProgress.initNextLoad();
		}
			
		private function onLoadComplete(event:Event): void {
			this.loaderProgress.setLoadProgress(1);
			this.hideLoaderProgressAndShowSwf();
		}
		
		protected function hideLoaderProgressAndShowSwf(): void {
			TweenNano.to(this.loaderProgress, LoaderOneSwf.TIME_HIDE_SHOW, {alpha: 0, ease: Linear.easeNone, onComplete: this.removeLoaderProgressAndShowSwf});
		}
		
		protected function initSwfVariables(): void {
			//np: this.swf.content["login"] = (root.loaderInfo.parameters.login) ? String(root.loaderInfo.parameters.login) : "";
		}
		
		protected function removeLoaderProgressAndShowSwf(): void {
			this.removeLoaderProgress();
			this.showSwf(false);
		}
		
		private function removeLoaderProgress(): void {
			this.loaderProgress.destroy();
			this.removeChild(this.loaderProgress);
			this.loaderProgress = null;
		}
		
		protected function showSwf(isTweenShow: Boolean): void {
			this.initSwfVariables();
			this.addChild(this.swf);
			this.swf.alpha = 1;
			if (!isTweenShow) LoaderOneSwf.TIME_SHOW_SWF = 0;
			TweenNano.from(this.swf.content, LoaderOneSwf.TIME_SHOW_SWF, {alpha: 0, ease: Linear.easeNone, onComplete: this.initSwf});
		}
		
		protected function initSwf(): void {
			this.destroy();
			if (this.swf.content.init) this.swf.content.init();
		}
		
		protected function destroy(): void {}
		
	}

}