package baseAway3D {
	
	import away3d.cameras.Camera3D;
	//import away3d.cameras.HoverCamera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import flash.geom.Vector3D;
	import away3d.materials.ColorMaterial;
	import base.types.ArrayExt;
	import base.math.MathExt;
	import away3d.primitives.Cube;
	import baseAway3D.Utils;
	
	
	public class CameraController {
		
		private var classMain: *;
		private var arrCamera: ArrayExt;
		private var currentIndCamera: int;
		private var cameraFPP: Camera3D;
		private var cameraTPP: Camera3D;
		private var cameraSide: Camera3D;
		private var cameraHover: Camera3D;//HoverCamera3D;
		private var isCameraFPP: Boolean, isCameraTPP: Boolean, isCameraSide: Boolean, isCameraHover: Boolean;
		private var view: View3D;
		private var arrNamesCamera: Array = ["cameraFPP", "cameraTPP", "cameraSide", "cameraHover"];
		private var toRadians:Number = Math.PI / 180;
		private var velRotationCamera: Number;
		private var startVerticalRotationForCamera: Number;
		private var cameraTPPDistanceToObject: Number;
		private var arrPointCameraSide: Array;

		public function CameraController(classMain: *, objInit: Object = null) {
			this.classMain = classMain;
			this.startVerticalRotationForCamera = 0;
			this.velRotationCamera = 4;
			(objInit == null) ? objInit = { } : null;
			objInit.lens = objInit.lens || new PerspectiveLens();
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
			this.cameraFPP = new Camera3D(objInit.lens);
			this.arrCamera.push(this.cameraFPP);
		}

		private function createCameraTPP(objInit: Object = null): void {
			this.cameraTPPDistanceToObject = (objInit.cameraTPPDistanceToObject != null) ? objInit.cameraTPPDistanceToObject : 500;
			this.cameraTPP = new Camera3D(objInit.lens);
			this.arrCamera.push(this.cameraTPP);
		}
		
		private function createCameraSide(objInit: Object = null): void {
			this.arrPointCameraSide = (objInit.arrPointCameraSide != null) ? objInit.arrPointCameraSide : ([new Vector3D(-1000, 100, -1000)]);
			this.cameraSide = new Camera3D(objInit.lens);
			this.arrCamera.push(this.cameraSide);
		}
		
		private function createCameraHover(objInit: Object = null): void {
			this.cameraHover = new Camera3D(objInit.lens);
			/*this.cameraHover = new HoverCamera3D({zoom:10, focus:50, x:100, y:100, z:100, lookat:"center"});
			this.cameraHover.distance = 800;
			this.cameraHover.maxTiltAngle = 20;
			this.cameraHover.minTiltAngle = 0;
			this.cameraHover.panAngle = -140;
			this.cameraHover.tiltAngle = 4;	*/
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
		
		public function checkMaterialOnObject(object: Cube): void {
			if (this.view.camera == this.cameraFPP) {
				object.material = new ColorMaterial(0x000000, 0);
			} else {
				//(object as Cube).material = (object as Cube).defaultMaterial;
			}
		}
		
		public function setRotationCameraAndObjectFromMouse(object: Cube): void {
			var ratioVerticalRotationMouse: Number = - (this.view.stage.mouseX - this.classMain.stage.width / 2) / (this.view.stage.width / 2);
			ratioVerticalRotationMouse = Math.max(-1, Math.min(ratioVerticalRotationMouse, 1));
			var maxVerticalRotationForCamera: Number = 60;
			var ratioLimiterWhenChangeCameraRotationY: Number = 0.8;
			if (ratioVerticalRotationMouse > ratioLimiterWhenChangeCameraRotationY) {
				this.startVerticalRotationForCamera = (this.startVerticalRotationForCamera - this.velRotationCamera) % 360
			} else if (ratioVerticalRotationMouse < -ratioLimiterWhenChangeCameraRotationY) {
				this.startVerticalRotationForCamera = (this.startVerticalRotationForCamera + this.velRotationCamera) % 360
			}
			var newVerticalRotationForCamera: Number = (this.startVerticalRotationForCamera - ratioVerticalRotationMouse * maxVerticalRotationForCamera) % 360
			var maxHorizontalRotationForFPPCamera: Number = 80;
			var minHorizontalRotationForTPPCamera: Number = -20;
			var maxHorizontalRotationForTPPCamera: Number = 60;
			
			
			var ratioHorizontalRotationMouse: Number = - (this.view.stage.mouseY - this.classMain.stage.height / 2) / (this.view.stage.height / 2);
			ratioHorizontalRotationMouse = Math.max(-1, Math.min(ratioHorizontalRotationMouse, 1));
			ratioHorizontalRotationMouse = Math.pow(ratioHorizontalRotationMouse, 2) * MathExt.getSign(ratioHorizontalRotationMouse);
			if (this.view.camera == this.cameraFPP) {
				this.cameraFPP.rotationX = (ratioHorizontalRotationMouse * maxHorizontalRotationForFPPCamera) % 360;
				this.cameraFPP.rotationY = newVerticalRotationForCamera;
				this.cameraFPP.rotationZ = 0
			} else if (this.view.camera == this.cameraTPP) {
				this.cameraTPP.rotationX = -(minHorizontalRotationForTPPCamera + ((ratioHorizontalRotationMouse + 1) / 2 * (maxHorizontalRotationForFPPCamera - minHorizontalRotationForTPPCamera))) % 360
				this.cameraTPP.rotationY = newVerticalRotationForCamera;
				this.cameraFPP.rotationZ = 0
			}
			object.rotationX = 0;//newHorizontalRotationForCamera
			object.rotationY = newVerticalRotationForCamera;
			object.rotationZ = 0;
			//(object as CubeWithRB).updateRigidBodyRotationFromModel();
		}
		
		public function bindPositionCameraToObject(object: Cube): void {
			if (this.currentIndCamera != -1) {
				var currentCamera: Camera3D = this.arrCamera[this.currentIndCamera];
				if (currentCamera == this.cameraFPP) {
					this.bindPositionCameraFPPToObject(object);
				} else if (currentCamera == this.cameraTPP) {
					this.bindPositionCameraTPPToObject(object);
				} else if (currentCamera == this.cameraSide) {
					this.bindPositionCameraSideToObject(object);
				}
			}
		}
		
		private function bindPositionCameraFPPToObject(object: Cube): void {
			this.cameraFPP.x = object.x + Math.sin(object.rotationY * this.toRadians) * ((object as Cube).width / 2 - 15) ;
			this.cameraFPP.y = object.y + object.height / 2;
			this.cameraFPP.z = object.z + Math.cos(object.rotationY * this.toRadians) * ((object as Cube).depth / 2 - 15) ; 
		}

		private function bindPositionCameraTPPToObject(object: Cube): void {
			var cameraTPPPlaneDistanceToObject: Number = this.cameraTPPDistanceToObject * Math.cos(this.cameraTPP.rotationX * this.toRadians);
			this.cameraTPP.x = object.x - Math.sin(object.rotationY * this.toRadians) * cameraTPPPlaneDistanceToObject;
			this.cameraTPP.y = object.y + object.height / 2 + Math.tan(-this.cameraTPP.rotationX * this.toRadians) * cameraTPPPlaneDistanceToObject;
			this.cameraTPP.z = object.z - Math.cos(object.rotationY * this.toRadians) * cameraTPPPlaneDistanceToObject;
		}
		
		private function bindPositionCameraSideToObject(object: Cube): void {
			var indPointCameraSide: uint = 0;
			var minDistanceBetweenPointCameraSideAndObject: Number = Vector3D.distance(object.position, this.arrPointCameraSide[0]);
			var distanceBetweenPointCameraSideAndObject: Number;
			for (var i: uint = 1; i < this.arrPointCameraSide.length; i++) {
				distanceBetweenPointCameraSideAndObject = Vector3D.distance(object.position, this.arrPointCameraSide[i]);
				if (distanceBetweenPointCameraSideAndObject < minDistanceBetweenPointCameraSideAndObject) {
					minDistanceBetweenPointCameraSideAndObject = distanceBetweenPointCameraSideAndObject;
					indPointCameraSide = i;
				}
			}
			var currentPointCameraSide: Vector3D = this.arrPointCameraSide[indPointCameraSide];
			this.cameraSide.x = currentPointCameraSide.x;
			this.cameraSide.y = currentPointCameraSide.y;
			this.cameraSide.z = currentPointCameraSide.z;
			var positionTopObject: Vector3D = new Vector3D(0, object.height / 2, 0);
			positionTopObject.add(object.position);
			this.cameraSide.lookAt(positionTopObject);
		}
		
	}
	
}