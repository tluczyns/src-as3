package baseAway3D {
	
	import away3d.core.math.Number3D;
	import away3d.primitives.withRB.*;
	import jiglib.collision.CollisionInfo;
	import jiglib.geometry.JBox;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.cof.JConfig;
	import jiglib.math.JMatrix3D;
	import baseAway3D.CameraController;
	import base.KeyboardControls;
	import flash.ui.Keyboard;
	import caurina.transitions.Tweener;
	
	public class ManWalk extends BaseAway3D {
	
		private var cameraController: CameraController;
		protected var keyboardControls: KeyboardControls;
		private var velMovement: Number;
		private var ratioVelResistance: Number;
		private var velCollisionResistance: Number;
		private var velJump: Number;
		private var totalFramesForStandDownUp: uint;
		private var isTweenToCrawl: Boolean;
		private var isStandCrawl: uint, isJump: Boolean, isSprint: Boolean;
		private var dimensionBoxCamera: Object;
		protected var boxCamera: CubeWithRB;
		
		public function ManWalk() {
			this.init();
		}

		override protected function init2d():void {
			this.keyboardControls = new KeyboardControls({listenDisplayObject: this, arrOtherKeys: [Keyboard.SHIFT, Keyboard.CONTROL, Keyboard.SPACE, "X", "G", "C"], onKeyDownFunction: this.checkPressedKey,  onKeyDownScope: this, onKeyUpFunction: this.checkReleasedKey,  onKeyUpScope: this});
		}
		
		private function checkPressedKey(keyCode: uint, isReleased: Boolean = false): void {
			this.checkKeySprint();
			if (!isReleased) {
				this.checkKeyJump(keyCode);
				if (keyCode == "G".charCodeAt()) {
					//	(this.ground.material as TransformBitmapMaterial).debug = !((this.ground.material as TransformBitmapMaterial).debug)
				}
				if (keyCode == "C".charCodeAt()) {
					this.cameraController.selectNextCamera();
					this.cameraController.checkMaterialOnObject(this.boxCamera);
				}
			}
			this.checkKeyCrawl(keyCode, isReleased);
		}
		
		private function checkReleasedKey(keyCode: uint): void {
			this.checkPressedKey(keyCode, true);
		}
		
		private function checkKeySprint(): void {
			var isPressedSprintKey: Boolean =  this.keyboardControls.dictIsPressedKey[Keyboard.SHIFT];
			if (((this.isStandCrawl == 0) && (!this.isJump)) || (!isPressedSprintKey)) {
				this.isSprint = isPressedSprintKey;
			}
		}
		
		private function checkKeyJump(keyCode: uint): void {
			if ((keyCode == Keyboard.SPACE) && (!this.isJump) && (this.isStandCrawl == 0)) {
				this.isJump = true;
				this.boxCamera.rb.AddWorldForce(new JNumber3D(0, this.velJump, 0), this.boxCamera.rb.CurrentState.Position);
			}
		}
		
		private function updateBoxCameraRigidBodyDimensionAndPositionFromModel():void {
			this.boxCamera.updateRigidBodyDimensionAndPositionFromModel();
		}


		private function checkKeyCrawl(keyCode: uint, isReleased: Boolean): void {
			if (!this.isJump) {
				var countFramesForStandDownUp: uint;
				var targetPositionYForStandDownUp: Number; 
				if (keyCode == "X".charCodeAt()) {
					if ((this.isStandCrawl == 0) && (!isReleased)) {
						this.isSprint = false;
						countFramesForStandDownUp = Math.round((Math.abs(this.boxCamera.height - this.dimensionBoxCamera.heightWhenCrawl) / this.dimensionBoxCamera.height) * this.totalFramesForStandDownUp);
						targetPositionYForStandDownUp = this.boxCamera.y - (this.boxCamera.height - this.dimensionBoxCamera.heightWhenCrawl) / 2
						Tweener.addTween(this.boxCamera, {height: this.dimensionBoxCamera.heightWhenCrawl, y: targetPositionYForStandDownUp, time: countFramesForStandDownUp, useFrames: true, transition: "easeOutExpo", onUpdate: this.updateBoxCameraRigidBodyDimensionAndPositionFromModel, onUpdateScope: this});
						this.isStandCrawl = 1;
					} else if ((this.isStandCrawl == 1) && (isReleased)) {
						countFramesForStandDownUp = Math.round((Math.abs(this.dimensionBoxCamera.height - this.boxCamera.height) / this.dimensionBoxCamera.height) * this.totalFramesForStandDownUp);
						targetPositionYForStandDownUp = this.boxCamera.y + (this.dimensionBoxCamera.height - this.boxCamera.height) / 2;
						Tweener.addTween(this.boxCamera, {height: this.dimensionBoxCamera.height, y: targetPositionYForStandDownUp, time: countFramesForStandDownUp, useFrames: true, transition: "easeOutExpo", onUpdate: this.updateBoxCameraRigidBodyDimensionAndPositionFromModel, onUpdateScope: this });
						this.isStandCrawl = 0
					}
				}
			}
		}
		
		override protected function init3d():void {
			this.cameraController = new CameraController(this, { view: this.view, typeCameraToSelect: "cameraFPP", isCameraFPP: true, isCameraTPP: true, isCameraSide: true, isCameraHover: false, arrPointCameraSide: [new Number3D(-1000, 100, -1000), new Number3D(-800, 200, 800), new Number3D(1000, 300, -1000), new Number3D(1000, 400, 1000)] } );
			PhysicsSystem.getInstance().SetDetectCollisionsType("DIRECT");
			PhysicsSystem.getInstance().SetGravity(JNumber3D.multiply(JNumber3D.UP, -100))
			this.createBoxCamera();
		}
		
		private function createBoxCamera(): void {
			this.dimensionBoxCamera = { width: 50, depth: 50, height: 100, heightWhenCrawl: 40 };
			this.boxCamera = new CubeWithRB({segmentsW:1, segmentsH:1, width: this.dimensionBoxCamera.width, depth: this.dimensionBoxCamera.depth, height: this.dimensionBoxCamera.height, x: 300, y: 200, z: 300 }, { "Material.Restitution": 0.0, "Material.StaticFriction": 1000, "Material.DynamicFriction": 10000}, this.scene, true);
			this.isSprint = false;
			this.velMovement = 170;
			this.ratioVelResistance = 1;
			this.velCollisionResistance = this.velMovement * 1.1;
			this.isJump = false;
			this.velJump = 1600;
			this.isStandCrawl = 0;
			this.totalFramesForStandDownUp = 20;
			this.view.clipping.minZ = 10;
			this.cameraController.checkMaterialOnObject(this.boxCamera);
			this.cameraController.bindPositionCameraToObject(this.boxCamera);
		}
		
		private function checkCollisions(): void {
			var isCollisionBaseForJump: Boolean = false;
			if (this.boxCamera.rb.Collisions.length > 0) {
				var i: uint = 0;
				while ((i < this.boxCamera.rb.Collisions.length) && (!isCollisionBaseForJump)) {
					var collision: CollisionInfo = this.boxCamera.rb.Collisions[i];
					//trace(collision.DirToBody.toString())
					if (collision.DirToBody.y > 0) {
						isCollisionBaseForJump = true;
					} else {
						this.boxCamera.rb.AddWorldForce(new JNumber3D( collision.DirToBody.x * this.velCollisionResistance, 0, collision.DirToBody.z * this.velCollisionResistance), this.boxCamera.rb.CurrentState.Position); //hamowanie
					}
					i++;
				}
			}
			this.isJump = !isCollisionBaseForJump;
		}
		
		private function setPositionBoxCameraFromKeys(): void {
			var velMovementIncludingSprint: Number;
			if (this.keyboardControls.dictIsPressedKey[Keyboard.SHIFT]) {
				velMovementIncludingSprint = velMovement * 1.5;
			} else {
				velMovementIncludingSprint = velMovement;
			}
			//trace(this.boxCamera.rb.CurrentState.LinVelocity.toString())
			this.boxCamera.rb.AddWorldForce(new JNumber3D(- this.boxCamera.rb.CurrentState.LinVelocity.x * this.ratioVelResistance, 0, - this.boxCamera.rb.CurrentState.LinVelocity.z * this.ratioVelResistance), this.boxCamera.rb.CurrentState.Position); //hamowanie
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
				/*this.boxCamera.x += addXPosition;
				this.boxCamera.z += addZPosition;
				this.updateBoxCameraRigidBodyDimensionAndPositionFromModel();*/
				this.boxCamera.rb.AddWorldForce(new JNumber3D(addXPosition, 0, addZPosition), this.boxCamera.rb.CurrentState.Position);
			} else {
				//this.boxCamera.rb.ClearForces();
			}
		}

		
		private function setZeroRotationXZBoxCamera(): void {
			this.boxCamera.rotationX = this.boxCamera.rotationZ = 0;
			this.boxCamera.rb.SetOrientation(JMatrix3D.rotationMatrix(0, 1, 0, this.boxCamera.rotationY * this.toRadians));
		}
		
		override protected function processFrame(): void {
			PhysicsSystem.getInstance().ActivateObject(this.boxCamera.rb); //potrzebne aby wykrywał kolizję nawet gdy boxCamera stoi w miejscu
			PhysicsSystem.getInstance().Integrate(0.1);
			//trace("y:" + this.boxCamera.y + ", height:" + this.boxCamera.height)
			this.cameraController.setRotationCameraAndObjectFromMouse(this.boxCamera);
			this.checkCollisions();
			this.setPositionBoxCameraFromKeys();
			this.cameraController.bindPositionCameraToObject(this.boxCamera);
			
			//trace("Orientation:\n"+this.boxCamera.rb.CurrentState.Orientation.toString())
			//trace("LinVelocity:" + this.boxCamera.rb.CurrentState.LinVelocity.toString());
			//trace("RotVelocity:" + this.boxCamera.rb.CurrentState.RotVelocity.toString());
			//trace("Position:" + this.boxCamera.rb.CurrentState.Position.toString());
		}
		
		
	}
	
}