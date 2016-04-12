package baseAway3D {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import away3d.containers.View3D;
	import away3d.containers.Scene3D;
	import away3d.core.render.DefaultRenderer;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.debug.Trident;
	
	public class BaseAway3D extends Sprite {
		public var scene: Scene3D;
		public var view: *;
		public var toRadians:Number = Math.PI / 180;
		public var toDegrees:Number = 180 / Math.PI;
		public var assetsPath: String = "../../assets/";
		protected var dontRender: Boolean;
		
		public function BaseAway3D(): void {}
		
		public function init(objParams: Object = null): void {
			objParams = this.initParams(objParams);
			this.initAway3D(objParams);
			this.init3d();
			this.init2d();
			this.initEvents();
		}
		
		protected function initParams(objParams: Object = null): Object {
			if (objParams == null) objParams = { };
			if (objParams.dimensionScene == null) objParams.dimensionScene = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			if ((objParams.dimensionScene.width == null) || (isNaN(uint(objParams.dimensionScene.width)))) objParams.dimensionScene.width = this.stage.stageWidth;
			if ((objParams.dimensionScene.height == null) || (isNaN(uint(objParams.dimensionScene.height)))) objParams.dimensionScene.height = this.stage.stageHeight;
			if (objParams.dontRender == null) objParams.dontRender = false;
			if (objParams.renderer == null) objParams.renderer = DefaultRenderer;
			if (objParams.stats == null) objParams.stats = false;
			return objParams;
		}
				
		protected function initAway3D(objParams: Object = null): void {
			this.dontRender = objParams.dontRender;
			this.scene = new Scene3D();
			//x: objParams.dimensionScene.width / 2, y: objParams.dimensionScene.height / 2, width: objParams.dimensionScene.width, height: objParams.dimensionScene.height,stats: objParams.stats
			this.view = new View3D(this.scene, null, objParams.renderer);
			this.addChild(view);
			var trident: Trident = new Trident(1000, true);
			this.scene.addChild(trident)
		}
		
		protected function init3d(): void {}

		protected function init2d(): void {}

		protected function initEvents(): void {
			this.removeAddEnterFrameListener(1);
		}

		protected function processFrame(): void {}

		private function onEnterFrameHandler(event: Event): void {
			this.processFrame();
			if (!this.dontRender) {
				this.view.render();
			}
		}

		public function destroy(): void {
			if ((this.view != null) && (this.contains(this.view))) {
				this.removeChild(this.view);
			}
			this.scene = null;
			this.removeAddEnterFrameListener(0);
		}
		
		public function removeAddEnterFrameListener(isRemoveAdd: uint): void {
			if (isRemoveAdd == 0) {
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			} else if (isRemoveAdd == 1) {
				this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			}
		}
		
	}

}