package baseAway3D.anaglyph {
	import baseAway3D.BaseAway3D;
	import away3d.core.base.Object3D;
	import flash.events.Event;
	import away3d.containers.Scene3D;
	import away3d.core.clip.*;
	import away3d.core.render.Renderer;
	import away3d.primitives.Trident;
	
	public class BaseAway3DAnaglyph extends BaseAway3D {
		
		override protected function initParams(objParamsAnaglyphView: Object = null): Object {
			if (objParamsAnaglyphView == null) objParamsAnaglyphView = {};
			objParamsAnaglyphView.typeDistortion = ((objParamsAnaglyphView.typeDistortion == null) ? 0 : objParamsAnaglyphView.typeDistortion); //0: channel distort; 1: full left and right tint
			objParamsAnaglyphView.isAddViewMain = ((objParamsAnaglyphView.isAddViewMain == null) ? (objParamsAnaglyphView.typeDistortion == 1) : objParamsAnaglyphView.isAddViewMain);
			objParamsAnaglyphView.isPushSceneObjectsLeftRightFromBaseXOnZDepth = ((objParamsAnaglyphView.isPushSceneObjectsLeftRightFromBaseXOnZDepth == null) ? true : objParamsAnaglyphView.isPushSceneObjectsLeftRightFromBaseXOnZDepth);
			objParamsAnaglyphView.isMoveLeftRightCamera = ((objParamsAnaglyphView.isMoveLeftRightCamera == null) ? false : objParamsAnaglyphView.isMoveLeftRightCamera);
			//params when isPushSceneObjectsLeftRightFromBaseXOnZDepth = true
			objParamsAnaglyphView.maxAddSubstractX = ((objParamsAnaglyphView.maxAddSubstractX == null) ? 6 : objParamsAnaglyphView.maxAddSubstractX);
			objParamsAnaglyphView.rangeZObjectAndCamera = ((objParamsAnaglyphView.rangeZObjectAndCamera == null) ? {min: 600, max: 950} : objParamsAnaglyphView.rangeZObjectAndCamera);
			//params when isMoveLeftRightCamera = true
			objParamsAnaglyphView.distanceMoveCameraLeftRight = ((objParamsAnaglyphView.distanceMoveCameraLeftRight == null) ? -17 : objParamsAnaglyphView.distanceMoveCameraLeftRight);
			objParamsAnaglyphView.angleYawCameraLeftRight = ((objParamsAnaglyphView.angleYawCameraLeftRight == null) ? 2 : objParamsAnaglyphView.angleYawCameraLeftRight);
			objParamsAnaglyphView = super.initParams(objParamsAnaglyphView)
			return objParamsAnaglyphView;
		}

		override protected function initAway3D(objParamsAnaglyphView: Object = null): void {
			//this.clipping = new NearfieldClipping({minZ: 20});
			//this.clipping = new FrustumClipping({minZ: 10});
			this.scene = new Scene3D();
			this.view = new View3DAnaglyph({scene: this.scene, clipping: this.clipping, x: objParamsAnaglyphView.dimensionScene.width / 2, y: objParamsAnaglyphView.dimensionScene.height / 2}, objParamsAnaglyphView);
			if (objParamsAnaglyphView.typeDistortion == 0) {
				this.setClippingAndRendererAndAddView3D(this.view.viewMain, objParamsAnaglyphView);
			}
			this.setClippingAndRendererAndAddView3D(this.view.viewLeftRed, objParamsAnaglyphView);
			this.setClippingAndRendererAndAddView3D(this.view.viewRightCyan, objParamsAnaglyphView);
			if (objParamsAnaglyphView.typeDistortion == 1) {
				this.setClippingAndRendererAndAddView3D(this.view.viewMain, objParamsAnaglyphView);
			}
			//var trident: Trident = new Trident(1000);
			//this.scene.addChild(trident)
		}
		
	}

}
