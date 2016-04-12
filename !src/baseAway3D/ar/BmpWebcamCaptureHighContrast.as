package baseAway3D.ar {
	import base.webcam.BmpWebcamCaptureTransformed;
	import flash.filters.ColorMatrixFilter;
	
	public class BmpWebcamCaptureHighContrast extends BmpWebcamCaptureTransformed {
		
		public function BmpWebcamCaptureHighContrast(width: uint, height: uint, fps: uint = 30): void {
			var mc: Number = 2;
			var co: Number = -128;
			var mtx:Array = [
				mc,	0,	0, 	0, co,
				0,	mc,	0, 	0, co,
				0,	0,	mc,	0, co,
				0,  0, 	0, 	1,  0
			];
			super(width, height, new ColorMatrixFilter(mtx), fps);
		}
		
	}

}