package jiglib.collision
{
	import flash.geom.Vector3D;

	import jiglib.math.*;

	public class CollPointInfo
	{
		public var initialPenetration:Number;
		public var r0:Vector3D;
		public var r1:Vector3D;
		public var position:Vector3D;

		public var minSeparationVel:Number = 0;
		public var denominator:Number = 0;

		public var accumulatedNormalImpulse:Number = 0;
		public var accumulatedNormalImpulseAux:Number = 0;
		public var accumulatedFrictionImpulse:Vector3D = new Vector3D();
	}
}