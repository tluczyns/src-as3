package jiglib.geometry
{
	import flash.geom.Vector3D;
	
	import jiglib.math.*;

	public class JRay
	{
		public var origin:Vector3D;
		public var dir:Vector3D;

		public function JRay(_origin:Vector3D, _dir:Vector3D)
		{
			this.origin = _origin;
			this.dir = _dir;
		}

		public function getOrigin(t:Number):Vector3D
		{
			return origin.add(JNumber3D.getScaleVector(dir, t));
		}
	}
}