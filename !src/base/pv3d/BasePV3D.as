package base.pv3d {
	import flash.display.Sprite;
	import flash.events.Event;
	import org.papervision3d.render.LazyRenderEngine;
	
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.render.AbstractRenderEngine;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.objects.primitives.Arrow;
	import org.papervision3d.view.stats.StatsView;
	
	public class BasePV3D extends Sprite {
		public var scene: Scene3D;
		public var viewport: Viewport3D;
		public var camera: Camera3D;
		private var renderer: AbstractRenderEngine;
		public var toRadians:Number = Math.PI / 180;
		public var toDegrees:Number = 180 / Math.PI;
		public var assetsPath: String = "../../assets/";
		private var dontRender: Boolean;
		private var stats :StatsView;
		
		
		public function BasePV3D(): void {}
		
		public function init(objParams: Object = null): void {
			objParams = this.initParams(objParams);
			this.initPV3D(objParams);
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
			if (objParams.typeRenderer == null) objParams.typeRenderer = BasicRenderEngine;
			if (objParams.autoClipping == null) objParams.autoClipping = true;
			if (objParams.stats == null) objParams.stats = false;
			return objParams;
		}
		
		protected function initPV3D(objParams: Object = null): void {
			this.dontRender = objParams.dontRender;
			this.scene = new Scene3D();
			this.viewport = new Viewport3D(objParams.dimensionScene.width, objParams.dimensionScene.height, false, true, objParams.autoClipping);
			this.viewport.x = 0;
			this.viewport.y = 0;
			this.addChild(this.viewport);
			this.camera = new Camera3D();
			if (objParams.typeRenderer == LazyRenderEngine) this.renderer = new LazyRenderEngine(this.scene, this.camera, this.viewport);
			else this.renderer = new objParams.typeRenderer();
			if (objParams.stats) {
				this.stats = new StatsView(this.renderer);
				this.addChild(this.stats);
			}
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
				if (this.stats) this.stats.updatePolyCount(this.scene);
				this.renderer.renderScene(this.scene, this.camera, this.viewport);
			}
		}

		public function clear(): void {
			if (this.contains(this.viewport)) {
				this.removeChild(this.viewport);
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
