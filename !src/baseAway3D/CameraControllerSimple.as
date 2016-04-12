package baseAway3D {
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.HoverCamera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cube;
	import base.types.ArrayExt;
	import base.types.MathExt;
	import away3d.primitives.Cube;
	
	public class CameraControllerSimple {
		
		private var classMain: *;
		private var arrCamera: ArrayExt;
		private var currentIndCamera: int;
		public var cameraFPP: Camera3D;
		private var cameraTPP: Camera3D;
		private var cameraSide: Camera3D;
		private var cameraHover: HoverCamera3D;
		private var isCameraFPP: Boolean, isCameraTPP: Boolean, isCameraSide: Boolean, isCameraHover: Boolean;
		private var view: View3D;
		private var arrNamesCamera: Array = ["cameraFPP", "cameraTPP", "cameraSide", "cameraHover"];
		private var toRadians:Number = Math.PI / 180;
		
		private var velRotationCamera: Number;
		private var startVerticalRotationForCamera: Number;
		private var cameraTPPPlaneDistanceToObject: Number;
		private var cameraTPPAngleXToObject: Number;

		public function CameraControllerSimple(classMain: *, objInit: Object = null) {
			this.classMain = classMain;
			this.startVerticalRotationForCamera = 0;
			this.velRotationCamera = 4;
			(objInit == null) ? objInit = {} : null;
			this.view = objInit.view;
			this.arrCamera = new ArrayExt();
			this.isCameraFPP = (objInit.isCameraFPP != null) ? objInit.isCameraFPP : true;
			if (this.isCameraFPP) {this.createCameraFPP(objInit);}
			this.isCameraTPP = (objInit.isCameraTPP != null) ? objInit.isCameraTPP : true;
			if (this.isCameraTPP) {this.createCameraTPP(objInit);}
			this.isCameraSide = (objInit.isCameraSide != null) ? objInit.isCameraSide : true;
			if (this.isCameraSide) {this.createCameraSide(objInit);}
			this.isCameraHover = (objInit.isCameraHover != null) ? objInit.isCameraHover : false;
			if (this.isCameraHover) {this.createCameraHover(objInit);}
			this.currentIndCamera = -1;
			if (objInit.typeCameraToSelect == null) {
				objInit.typeCameraToSelect = "cameraFPP"	
			}
			this.selectSpecificCamera(objInit.typeCameraToSelect);
		}

		private function createCameraFPP(objInit: Object = null): void {
			this.cameraFPP = new Camera3D({zoom:6, focus:100});
			this.cameraFPP.lens = new PerspectiveLens();
			this.arrCamera.push(this.cameraFPP);
		}

		private function createCameraTPP(objInit: Object = null): void {
			this.cameraTPPPlaneDistanceToObject = (objInit.cameraTPPPlaneDistanceToObject != null) ? objInit.cameraTPPPlaneDistanceToObject : 500;
			this.cameraTPPAngleXToObject = (objInit.cameraTPPAngleXToObject != null) ? objInit.cameraTPPAngleXToObject : 20;
			this.cameraTPP = new Camera3D({ zoom:6, focus:100});
			this.cameraTPP.lens = new PerspectiveLens();
			this.arrCamera.push(this.cameraTPP);
		}
		
		private function createCameraSide(objInit: Object = null): void {
			this.cameraSide = new Camera3D( { zoom:6, focus:100, x:-800, y:100, z:-800, lookat:"center" } );
			this.cameraSide.lens = new PerspectiveLens();
			this.arrCamera.push(this.cameraSide);
		}
		
		private function createCameraHover(objInit: Object = null): void {
			this.cameraHover = new HoverCamera3D({zoom:10, focus:50, x:100, y:100, z:100, lookat:"center"});
			this.cameraHover.distance = 800;
			this.cameraHover.maxTiltAngle = 20;
			this.cameraHover.minTiltAngle = 0;
			this.cameraHover.panAngle = -140;
			this.cameraHover.tiltAngle = 4;	
			this.arrCamera.push(this.cameraHover);
		}
	
		public function selectNextCamera(): void {
			if (this.arrCamera.length > 0) {
				this.currentIndCamera++;
				if (this.currentIndCamera == this.arrCamera.length) {
					this.currentIndCamera = 0;
				}
				this.view.camera = this.arrCamera[this.currentIndCamera];
			}
		}
		
		public function selectSpecificCamera(typeCamera: String): void {
			var formerIndCamera: Number = this.currentIndCamera;
			switch (typeCamera) {
				case this.arrNamesCamera[0]: if (this.isCameraFPP) { this.currentIndCamera = this.arrCamera.getElementIndex(this.cameraFPP) }; break;
				case this.arrNamesCamera[1]: if (this.isCameraTPP) { this.currentIndCamera = this.arrCamera.getElementIndex(this.cameraTPP) }; break;
				case this.arrNamesCamera[2]: if (this.isCameraSide) { this.currentIndCamera = this.arrCamera.getElementIndex(this.cameraSide) }; break;
				case this.arrNamesCamera[3]: if (this.isCameraHover) {this.currentIndCamera = this.arrCamera.getElementIndex(this.cameraHover)}; break;
			}
			if (this.currentIndCamera != -1) {
				this.view.camera = this.arrCamera[this.currentIndCamera];
			} else {
				this.currentIndCamera = formerIndCamera;
			}
		}
		
		public function getCurrentCameraName(): String {
			var typeCamera: String;
			if (this.view.camera == this.cameraFPP) {
				typeCamera = this.arrNamesCamera[0];
			} else if (this.view.camera == this.cameraTPP) {
				typeCamera = this.arrNamesCamera[1];
			} else if (this.view.camera == this.cameraSide) {
				typeCamera = this.arrNamesCamera[2];
			} else if (this.view.camera == this.cameraHover) {
				typeCamera = this.arrNamesCamera[3];
			}
			return typeCamera;
		}
		
		public function checkMaterialOnObject(object: Object3D): void {
			if (this.view.camera == this.cameraFPP) {
				(object as Cube).material = new ColorMaterial(0x000000, {alpha: 0});
			} else {
				(object as Cube).material = null;
			}
		}
		
		public function setRotationCameraAndObjectFromMouse(object: Object3D): void {
			var ratioVerticalRotationMouse: Number = - (this.view.stage.mouseX - this.view.width / 2) / (this.view.width / 2);
			ratioVerticalRotationMouse = Math.max(-1, Math.min(ratioVerticalRotationMouse, 1));
			var maxVerticalRotationForCamera: Number = 60;
			var ratioLimiterWhenChangeCameraRotationY: Number = 0.8;
			if (ratioVerticalRotationMouse > ratioLimiterWhenChangeCameraRotationY) {
				this.startVerticalRotationForCamera = ((this.startVerticalRotationForCamera - this.velRotationCamera) + 360) % 360
			} else if (ratioVerticalRotationMouse < -ratioLimiterWhenChangeCameraRotationY) {
				this.startVerticalRotationForCamera = ((this.startVerticalRotationForCamera + this.velRotationCamera) + 360) % 360
			}
			var newVerticalRotationForCamera: Number = ((this.startVerticalRotationForCamera - ratioVerticalRotationMouse * maxVerticalRotationForCamera) + 360) % 360
			
			var ratioHorizontalRotationMouse: Number = - (this.view.stage.mouseY - this.view.height / 2) / (this.view.height / 2);
			ratioHorizontalRotationMouse = Math.max(-1, Math.min(ratioHorizontalRotationMouse, 1));
			ratioHorizontalRotationMouse = Math.pow(ratioHorizontalRotationMouse, 2) * MathExt.getSign(ratioHorizontalRotationMouse);
			var maxHorizontalRotationForCamera: Number = 80;
			var newHorizontalRotationForCamera: Number = (ratioHorizontalRotationMouse * maxHorizontalRotationForCamera) % 360
			if (this.view.camera == this.cameraFPP) {
				this.cameraFPP.rotationX = 0//newHorizontalRotationForCamera;
				this.cameraFPP.rotationY = newVerticalRotationForCamera;
				this.cameraFPP.rotationZ = 0
			} else if (this.view.camera == this.cameraTPP) {
				this.cameraTPP.rotationX = -this.cameraTPPAngleXToObject;
				this.cameraTPP.rotationY = newVerticalRotationForCamera;
				this.cameraFPP.rotationZ = 0
			}
			object.rotationX = 0;//newHorizontalRotationForCamera
			object.rotationY = newVerticalRotationForCamera;;
			object.rotationZ = 0;
		}
		
		public function bindPositionCameraToObject(object: Object3D): void {
			if (this.currentIndCamera != -1) {
				var currentCamera: Camera3D = this.arrCamera[this.currentIndCamera];
				if (currentCamera == this.cameraFPP) {
					this.bindPositionCameraFPPToObject(object);
				} else if (currentCamera == this.cameraTPP) {
					this.bindPositionCameraTPPToObject(object);
				}
			}
		}
		
		private function bindPositionCameraFPPToObject(object: Object3D): void {
			this.cameraFPP.x = object.x + Math.sin(object.rotationY * this.toRadians) * ((object as Cube).width / 2 - 10) ;
			this.cameraFPP.y = object.y + (object as Cube).height / 2 + 20;
			this.cameraFPP.z = object.z + Math.cos(object.rotationY * this.toRadians) * ((object as Cube).depth / 2 - 10) ; 
		}

		private function bindPositionCameraTPPToObject(object: Object3D): void {
			this.cameraTPP.x = object.x - Math.sin(object.rotationY * this.toRadians) * this.cameraTPPPlaneDistanceToObject;
			this.cameraTPP.y = object.y + (object as Cube).height / 2 + Math.tan(this.cameraTPPAngleXToObject * this.toRadians) * this.cameraTPPPlaneDistanceToObject;
			this.cameraTPP.z = object.z - Math.cos(object.rotationY * this.toRadians) * this.cameraTPPPlaneDistanceToObject; 
		}
		
	}
	
}