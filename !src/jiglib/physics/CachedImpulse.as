package jiglib.physics
{

	import flash.geom.Vector3D;

	public class CachedImpulse
	{

		public var normalImpulse:Number;
		public var normalImpulseAux:Number;
		public var frictionImpulse:Vector3D;

		public function CachedImpulse(_normalImpulse:Number, _normalImpulseAux:Number, _frictionImpulse:Vector3D)
		{
			this.normalImpulse = _normalImpulse;
			this.normalImpulseAux = _normalImpulseAux;
			this.frictionImpulse = _frictionImpulse;
		}
	}
}