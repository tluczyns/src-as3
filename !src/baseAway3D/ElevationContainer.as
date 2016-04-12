package baseAway3D {

	import flash.display.Bitmap;
	import away3d.materials.IMaterial;
	import away3d.materials.BitmapMaterial;
	import away3d.extrusions.Elevation;
	import away3d.extrusions.SkinExtrude;
	import away3d.containers.Scene3D;
	import away3d.core.utils.Cast;
	
	public class ElevationContainer {
		private var classMain: * ;
		private var classTextureElevation: Class;
		private var classTextureExtrude: Class;
		private var extrude: SkinExtrude;
		private var scene: Scene3D;
		
		public function ElevationContainer(classMain: *, objInit: Object = null) {
			this.classMain = classMain;
			(objInit == null) ? objInit = {} : null;
			this.scene = objInit.scene;
			this.classTextureElevation = objInit.classTextureElevation;
			this.classTextureExtrude = objInit.classTextureExtrude;
			this.build();
		}
		
		private function build(): void {
			var bmpTextureElevation: Bitmap = new this.classTextureElevation();
			var materialTextureExtrude: IMaterial = new BitmapMaterial(Cast.bitmap(new this.classTextureExtrude()) , { smooth:true } );
			var elevate:Elevation = new Elevation();
			this.extrude = new SkinExtrude(elevate.generate(bmpTextureElevation.bitmapData, "r", 5, 5, 50, 50, 4), {material: materialTextureExtrude, recenter:true, closepath:false, coverall:true, subdivision:1, bothsides:false, flip:true});
			this.extrude.rotationX = 90;
			this.scene.addChild(this.extrude);
		}
		
	}
	
}