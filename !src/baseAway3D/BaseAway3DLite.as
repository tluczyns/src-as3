package baseAway3D {
	import flash.display.Sprite;
	import away3dlite.core.base.Object3D;
	import flash.events.Event;
	import away3dlite.containers.View3D;
	import away3dlite.containers.Scene3D;
	import away3dlite.core.clip.*;
	import away3dlite.core.render.BasicRenderer;
	import away3dlite.cameras.Camera3D;
	import away3dlite.cameras.lenses.PerspectiveLens;
	import away3dlite.primitives.Trident;
	
	public class BaseAway3DLite extends Sprite {
		public var scene: Scene3D;
		public var view: *;
		public var camera: Camera3D;
		protected var clipping: Clipping;
		public var toRadians:Number = Math.PI / 180;
		public var toDegrees:Number = 180 / Math.PI;
		public var assetsPath: String = "../../assets/";
		private var dontRender: Boolean;
		
		public function BaseAway3DLite(): void {}
		
		public function init(objParams: Object = null): void {
			objParams = this.initParams(objParams);
			this.initAway3D(objParams);
			this.init3d();
			this.init2d();
			this.initEvents();
		}
		
		protected function initParams(objParams: Object = null): Object {
			if (objParams == null) objParams = { };
			if (objParams.dimensionScene == null) objParams.dimensionScene = {};
			if ((objParams.dimensionScene.width == null) || (isNaN(uint(objParams.dimensionScene.width)))) objParams.dimensionScene.width = this.stage.stageWidth;
			if ((objParams.dimensionScene.height == null) || (isNaN(uint(objParams.dimensionScene.height)))) objParams.dimensionScene.height = this.stage.stageHeight;
			if (objParams.dontRender == null) objParams.dontRender = false;
			if (objParams.renderer == null) objParams.renderer = new BasicRenderer();
			if (objParams.dontClip == null) objParams.dontClip = false;
			if (objParams.stats == null) objParams.stats = false;
			return objParams;
		}
		
		protected function setClippingAndRendererAndAddView3D(view: View3D, objParams: Object): void {
			if (!objParams.dontClip) {
				view.clipping.minX = - objParams.dimensionScene.width / 2;
				view.clipping.minY = - objParams.dimensionScene.height / 2;
				view.clipping.maxX = objParams.dimensionScene.width / 2;
				view.clipping.maxY = objParams.dimensionScene.height / 2;
			}
			view.renderer = objParams.renderer;
			this.addChild(view);
		}
		
		protected function initAway3D(objParams: Object = null): void {
			//this.clipping = new NearfieldClipping({minZ: 0});
			//this.clipping = new FrustumClipping({minZ: 10});
			this.dontRender = objParams.dontRender;
			this.scene = new Scene3D();
			this.view = new View3D(this.scene);
			//this.view.clipping = this.clipping;
			this.view.x = objParams.dimensionScene.width / 2;
			this.view.y = objParams.dimensionScene.height / 2;
			this.setClippingAndRendererAndAddView3D(this.view, objParams);
			this.camera = new Camera3D(6, 100);
			//this.camera.lens = new PerspectiveLens();
			this.view.camera = this.camera;
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

		public function clear(): void {
			if (this.contains(this.view)) {
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