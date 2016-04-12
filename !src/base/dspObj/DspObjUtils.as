package base.dspObj {
	import base.types.Singleton;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	
	public class DspObjUtils extends Singleton {
		
		public function DspObjUtils(): void {}
		
		static public function skew(target: DisplayObject, _x:Number, _y:Number):void {
			var mtx: Matrix = new Matrix();
			mtx.b = _y * Math.PI/180;
			mtx.c = _x * Math.PI/180;
			mtx.concat(target.transform.matrix);
			target.transform.matrix = mtx;
		}
		
	}

}