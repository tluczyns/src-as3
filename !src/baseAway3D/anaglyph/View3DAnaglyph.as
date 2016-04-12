package baseAway3D.anaglyph {
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.Number3D;
	import base.types.ObjectExt;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import fl.motion.Color;
	import away3d.core.base.Object3D;
	import flash.display.BlendMode;
	import flash.utils.*;
	
	public class View3DAnaglyph extends Object {
		
		private var typeDistortion: uint;
		private var isAddViewMain: Boolean;
		private var isPushSceneObjectsLeftRightFromBaseXOnZDepth: Boolean;
		private var isMoveLeftRightCamera: Boolean;
		public var maxAddSubstractX: Number;
		public var rangeZObjectAndCamera: Object;
		private var _distanceMoveCameraLeftRight: Number;
		private var _angleYawCameraLeftRight: Number;
		
		public var viewMain: View3D;
		public var viewLeftRed: View3D;
		public var viewRightCyan: View3D;
		public var scene: Scene3D;
		private var arrSceneChildren: Array, arrSceneChildrenOriginX: Array;
		private var camera3DAnaglyph: Camera3DAnaglyph;
		
		public function View3DAnaglyph(parInit: Object, objParamsAnaglyphView: Object): void {
			var init: ObjectExt = new ObjectExt(parInit);
			this.typeDistortion = ((objParamsAnaglyphView.typeDistortion == null) ? 0 : objParamsAnaglyphView.typeDistortion); //0: channel distort; 1: full left and right tint
			this.isAddViewMain = ((objParamsAnaglyphView.isAddViewMain == null) ? (objParamsAnaglyphView.typeDistortion == 1) : objParamsAnaglyphView.isAddViewMain);
			this.isPushSceneObjectsLeftRightFromBaseXOnZDepth = ((objParamsAnaglyphView.isPushSceneObjectsLeftRightFromBaseXOnZDepth == null) ? true : objParamsAnaglyphView.isPushSceneObjectsLeftRightFromBaseXOnZDepth);
			this.isMoveLeftRightCamera = ((objParamsAnaglyphView.isMoveLeftRightCamera == null) ? false : objParamsAnaglyphView.isMoveLeftRightCamera);
			//params when isPushSceneObjectsLeftRightFromBaseXOnZDepth = true
			this.maxAddSubstractX = ((objParamsAnaglyphView.maxAddSubstractX == null) ? 6 : objParamsAnaglyphView.maxAddSubstractX);
			this.rangeZObjectAndCamera = ((objParamsAnaglyphView.rangeZObjectAndCamera == null) ? {min: 600, max: 950} : objParamsAnaglyphView.rangeZObjectAndCamera);
			//params when isMoveLeftRightCamera = true
			this._distanceMoveCameraLeftRight = ((objParamsAnaglyphView.distanceMoveCameraLeftRight == null) ? -17 : objParamsAnaglyphView.distanceMoveCameraLeftRight);
			this._angleYawCameraLeftRight = ((objParamsAnaglyphView.angleYawCameraLeftRight == null) ? 2 : objParamsAnaglyphView.angleYawCameraLeftRight);
			
			this.scene = init.scene;
			this.viewMain = new View3D(init);
			init = new ObjectExt(parInit);
			this.viewLeftRed = new View3D(init);
			init = new ObjectExt(parInit);
			this.viewRightCyan = new View3D(init);
			this.scene.autoUpdate = false;
			this.colorAnaglyphRedCyanView(0);
			this.colorAnaglyphRedCyanView(1);
		}
		
		private function colorAnaglyphRedCyanView(isRedCyan: uint): void {
			var viewToColor: View3D = [this.viewLeftRed, this.viewRightCyan][isRedCyan]
			if (this.typeDistortion == 0) {
				viewToColor.transform.colorTransform = new ColorTransform([1, 0][isRedCyan], [0, 1][isRedCyan], [0, 1][isRedCyan], 1);
				if (isRedCyan == 1) {
					viewToColor.blendMode = BlendMode.SCREEN;
				}
			} else if (this.typeDistortion == 1) {
				var clrTint: Color = new Color();
				clrTint.setTint([0x00FFFF, 0xFF0000][isRedCyan], 1);
				viewToColor.transform.colorTransform = clrTint;
				viewToColor.alpha = 0.8;
			}
		}
		
		///////////////////////////////////////////////////render wszystkich widoków////////////////////////////////////////////
		
		private function prepareArrSceneChildren(): void {
			this.arrSceneChildren = new Array()
			this.arrSceneChildrenOriginX = new Array();
			for each (var object:Object in this.scene.children) {
            	if (object is Object3D) {
					this.arrSceneChildren.push(object);
					this.arrSceneChildrenOriginX.push(object.x);
				}
			}
		}
		
		//korekcja pozycji x w zależności od pozycji z obiektów w widoku lewym czerwonym i prawym cyan (aby paski po obu stronach były znacznie szersze, gdy odległość do kamery jest mniejsza)
		//i powrót do oryginalnej pozycji dla normalnego widoku
		//założenie - kamera jest zwrócona wzdłuż osi Z
		private function pushSceneObjectsLeftRightFromBaseXOnZDepth(isBackToOriginalSubstractAddX: int): void {
			var cameraLeftRight: Camera3D = [this.viewMain.camera, this.viewLeftRed.camera, this.viewRightCyan.camera][isBackToOriginalSubstractAddX]
			var valueBackToOriginalSubstractAddX: Number = [0, -1, 1][isBackToOriginalSubstractAddX];
			for (var i: uint = 0; i <  this.arrSceneChildren.length; i++) {
				var object3D: Object3D = this.arrSceneChildren[i];
				if (valueBackToOriginalSubstractAddX != 0) {
					var diffZObjectAndCamera: Number = object3D.z - cameraLeftRight.z;
					var ratioDiffZToRangeZObjectAndCamera: Number = 1 - ((Math.min(Math.max(diffZObjectAndCamera, this.rangeZObjectAndCamera.min), this.rangeZObjectAndCamera.max) - this.rangeZObjectAndCamera.min) / (this.rangeZObjectAndCamera.max - this.rangeZObjectAndCamera.min));
					//trace(ratioDiffZToRangeZObjectAndCamera, diffZObjectAndCamera, this.rangeZObjectAndCamera.min, this.rangeZObjectAndCamera.max)
					ratioDiffZToRangeZObjectAndCamera = Math.min(Math.max(ratioDiffZToRangeZObjectAndCamera, 0), 1);
					//ratioDiffZToRangeZObjectAndCamera = Math.pow(ratioDiffZToRangeZObjectAndCamera, 0.5)
					var valueAddSubstractX: Number = - this.maxAddSubstractX + 2 * this.maxAddSubstractX * ratioDiffZToRangeZObjectAndCamera;
					//trace(isBackToOriginalSubstractAddX, valueAddSubstractX)
					object3D.x = this.arrSceneChildrenOriginX[i] + (valueAddSubstractX * valueBackToOriginalSubstractAddX);
				} else {
					object3D.x = this.arrSceneChildrenOriginX[i];
				}
			}
		}
		
		public function render():void {
			this.scene.update();
			if (this.isPushSceneObjectsLeftRightFromBaseXOnZDepth) {
				this.prepareArrSceneChildren();
			}
			if (this.isAddViewMain) {
				this.viewMain.render();
			}
			if (this.isPushSceneObjectsLeftRightFromBaseXOnZDepth) {
				this.pushSceneObjectsLeftRightFromBaseXOnZDepth(2);
				this.scene.update();
			}
			this.viewLeftRed.render();
			if (this.isPushSceneObjectsLeftRightFromBaseXOnZDepth) {
				this.pushSceneObjectsLeftRightFromBaseXOnZDepth(1);
				this.scene.update();
			}
			this.viewRightCyan.render();
			if (this.isPushSceneObjectsLeftRightFromBaseXOnZDepth) {
				this.pushSceneObjectsLeftRightFromBaseXOnZDepth(0);
			}
		}
		
		public function set distanceMoveCameraLeftRight(value: Number): void {
			this._distanceMoveCameraLeftRight = value;
			this.setParamsAnaglyphLeftRightCamera(0);
			this.setParamsAnaglyphLeftRightCamera(1);
		}
		
		public function get distanceMoveCameraLeftRight(): Number {
			return this._distanceMoveCameraLeftRight;
		}

		public function set angleYawCameraLeftRight(value: Number): void {
			this._angleYawCameraLeftRight = value;
			this.setParamsAnaglyphLeftRightCamera(0);
			this.setParamsAnaglyphLeftRightCamera(1);
		}
		
		public function get angleYawCameraLeftRight(): Number {
			return this._angleYawCameraLeftRight;
		}

		private function setParamsAnaglyphLeftRightCamera(isLeftRight: uint): void {
			var cameraLeftRight: Camera3D = [this.viewLeftRed.camera, this.viewRightCyan.camera][isLeftRight]
			cameraLeftRight.lens = new PerspectiveLens();
			if (this.isMoveLeftRightCamera) {
				cameraLeftRight.position = this.viewMain.camera.position;
				/*cameraLeftRight.position.x = this.viewMain.camera.position.x;
				cameraLeftRight.position.y = this.viewMain.camera.position.y;
				cameraLeftRight.position.z = this.viewMain.camera.position.z;*/
				cameraLeftRight.moveRight([this._distanceMoveCameraLeftRight, -this._distanceMoveCameraLeftRight][isLeftRight]);
				cameraLeftRight.rotationX = this.viewMain.camera.rotationX;
				cameraLeftRight.rotationY = this.viewMain.camera.rotationY;
				cameraLeftRight.rotationZ = this.viewMain.camera.rotationZ;
				cameraLeftRight.yaw([-this._angleYawCameraLeftRight, this._angleYawCameraLeftRight][isLeftRight]);
			}
		}
		
		public function cloneCameraForViews(cameraValue: Camera3D): void {
			this.viewLeftRed.camera = new Camera3D(cameraValue.clone());
			this.viewRightCyan.camera = new Camera3D(cameraValue.clone());
			this.viewMain.camera = cameraValue;	
		}
		
		public function set camera(cameraValue: * ): void { 
			var nameClassCamera3D: String = "away3d.cameras::Camera3D";
			if ((getQualifiedClassName(cameraValue) == nameClassCamera3D) || (getQualifiedSuperclassName(cameraValue) == nameClassCamera3D)) {
				this.cloneCameraForViews(cameraValue)
			} else {
				//Camera3DAnaglyph
				this.viewLeftRed.camera = cameraValue.arrCamera[0];
				this.viewRightCyan.camera = cameraValue.arrCamera[1];
				this.viewMain.camera = cameraValue.arrCamera[2];
			}
			this.viewMain.camera.lens = new PerspectiveLens();
			this.setParamsAnaglyphLeftRightCamera(0);
			this.setParamsAnaglyphLeftRightCamera(1);
			this.camera3DAnaglyph = new Camera3DAnaglyph([this.viewLeftRed.camera, this.viewRightCyan.camera, this.viewMain.camera])
        }
		
		public function get camera(): * {
			return this.camera3DAnaglyph;
		}

	}
	
}