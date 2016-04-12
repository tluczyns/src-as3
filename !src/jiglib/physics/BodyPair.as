package jiglib.physics
{
	import flash.geom.Vector3D;

	public class BodyPair
	{

		public var body0:RigidBody;
		public var body1:RigidBody;
		public var r:Vector3D;

		public function BodyPair(_body0:RigidBody, _body1:RigidBody, r0:Vector3D, r1:Vector3D)
		{

			var id1:int = -1;
			if (_body1 != null) id1 = _body1.id;
			
			if (_body0.id > id1)
			{
				this.body0 = _body0;
				this.body1 = _body1;
				this.r = r0;
			}
			else
			{
				this.body0 = _body1;
				this.body1 = _body0;
				this.r = r1;
			}
		}
	}
}