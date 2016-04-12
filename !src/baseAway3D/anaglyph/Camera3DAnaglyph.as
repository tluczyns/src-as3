package baseAway3D.anaglyph {
	import away3d.cameras.Camera3D;

	public class Camera3DAnaglyph extends Object {
		
		internal var arrCamera: Array;
		
		public function Camera3DAnaglyph(arrCamera: Array) {
			this.arrCamera = arrCamera;
		}
		
		public function clone(): Camera3DAnaglyph {
			var arrCameraClone: Array = new Array(this.arrCamera.length);
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				arrCameraClone[i] = camera.clone();
			}
			var newCamera3DAnaglyph = new Camera3DAnaglyph(arrCameraClone);
			return newCamera3DAnaglyph;
		}
		
		public function get x(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.x;
		}
		
		public function get y(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.y;
		}
		
		public function get z(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.z;
		}
		
		public function get rotationX(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.rotationX;
		}
		
		public function get rotationY(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.rotationY;
		}
		
		public function get rotationZ(): Number {
			var firstCamera: Camera3D = this.arrCamera[0];
			return firstCamera.rotationZ;
		}
			
		public function set x(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.x = value;
			}
		}
		
		public function set y(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.y = value;
			}
		}
		
		public function set z(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.z = value;
			}
		}
		
		public function set rotationX(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.rotationX = value;
			}
		}
		
		public function set rotationY(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.rotationY = value;
			}
		}
		
		public function set rotationZ(value:Number): void {
			for (var i: uint = 0; i < this.arrCamera.length; i++) {
				var camera: Camera3D = this.arrCamera[i]
				camera.rotationZ = value;
			}
		}
		
	}
	
}