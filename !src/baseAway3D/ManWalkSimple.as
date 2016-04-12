package baseAway3D {
	
	import away3d.primitives.*;
	import flash.events.Event;
	import baseAway3D.CameraController;
	import base.KeyboardControls;
	import flash.ui.Keyboard;
	
	public class ManWalkSimple extends BaseAway3D {
		
		public var cameraController: CameraControllerSimple;
		private var keyboardControls: KeyboardControls;
		private var velMovement: Number;
		private var isNoneGoUpDown: uint;
		private var dimensionBoxCamera: Object;
		public var boxCamera: Cube;
		
		public function ManWalkSimple() {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		protected function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.init();
		}
		
		override protected function init2d():void {
			this.keyboardControls = new KeyboardControls({listenDisplayObject: this, arrOtherKeys: [Keyboard.SHIFT, Keyboard.CONTROL, Keyboard.SPACE, "X", "G", "C", "R", "F"], onKeyDownFunction: this.checkPressedKey,  onKeyDownScope: this, onKeyUpFunction: this.checkReleasedKey,  onKeyUpScope: this});
		}
		
		private function checkPressedKey(keyCode: uint, isReleased: Boolean = false): void {
			if (!isReleased) {
				if (keyCode == "G".charCodeAt()) {
					//	(this.ground.material as TransformBitmapMaterial).debug = !((this.ground.material as TransformBitmapMaterial).debug)
				}
				if (keyCode == "C".charCodeAt()) {
					this.cameraController.selectNextCamera();
					this.cameraController.checkMaterialOnObject(this.boxCamera);
				}
			}
		}
		
		private function checkReleasedKey(keyCode: uint): void {
			this.checkPressedKey(keyCode, true);
		}
		
		override protected function init3d():void {
			this.cameraController = new CameraControllerSimple(this, { view: this.view, typeCameraToSelect: "cameraFPP", isCameraFPP: true, isCameraTPP: true, isCameraSide: true, isCameraHover: false } );
			this.createBoxCamera();
		}
		
		private function createBoxCamera(): void {
			this.dimensionBoxCamera = { width: 50, depth: 50, height: 100 };
			this.boxCamera = new Cube({ segmentsW:1, segmentsH:1, width: this.dimensionBoxCamera.width, depth: this.dimensionBoxCamera.depth, height: this.dimensionBoxCamera.height, x: 0, y: 0, z: -700 });
			this.scene.addChild(this.boxCamera);
			this.velMovement = 30;
			this.view.clipping.minZ = 10;
			this.cameraController.checkMaterialOnObject(this.boxCamera);
			this.cameraController.bindPositionCameraToObject(this.boxCamera);
		}
		
		private function setPositionBoxCameraFromKeys(): void {
			var velMovementIncludingSprint: Number;
			if (this.keyboardControls.dictIsPressedKey[Keyboard.SHIFT]) {
				velMovementIncludingSprint = velMovement * 2;
			} else {
				velMovementIncludingSprint = velMovement;
			}
			if ((this.keyboardControls.isNoneLeftRight > -1) || (this.keyboardControls.isNoneUpDown > -1)) {
				var isSubstractAdd: Number;
				var angleYForKamera: Number = this.boxCamera.rotationY;
				var angleYForKameraEngagingRotationZ: Number = [180 - angleYForKamera, angleYForKamera][Number(this.boxCamera.rotationZ == 0)];
				var addXPosition: Number = 0;
				var addZPosition: Number = 0;
				if (this.keyboardControls.isNoneLeftRight > -1) {
					isSubstractAdd = [ -1, 1][this.keyboardControls.isNoneLeftRight];
					addXPosition = Math.cos(angleYForKameraEngagingRotationZ * this.toRadians) * velMovementIncludingSprint * isSubstractAdd;
					addZPosition = -Math.sin(angleYForKameraEngagingRotationZ * this.toRadians) * velMovementIncludingSprint * isSubstractAdd;
				}
				if (this.keyboardControls.isNoneUpDown > -1) {
					isSubstractAdd = [ -1, 1][this.keyboardControls.isNoneUpDown];
					addXPosition -= Math.sin(angleYForKameraEngagingRotationZ * this.toRadians) * velMovementIncludingSprint * isSubstractAdd;
					addZPosition -= Math.cos(angleYForKameraEngagingRotationZ * this.toRadians) * velMovementIncludingSprint * isSubstractAdd;
				}
				this.boxCamera.x += addXPosition;
				this.boxCamera.z += addZPosition;
			}
			if (this.keyboardControls.dictIsPressedKey["R".charCodeAt()]) {
				this.boxCamera.y += 10;
			} else if (this.keyboardControls.dictIsPressedKey["F".charCodeAt()]) {
				this.boxCamera.y -= 10;
			}
		}
		
		override protected function processFrame(): void {
			this.cameraController.setRotationCameraAndObjectFromMouse(this.boxCamera);
			this.setPositionBoxCameraFromKeys();
			this.cameraController.bindPositionCameraToObject(this.boxCamera);
		}	
		
	}
	
}