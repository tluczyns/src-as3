package jiglib.collision
{
	import jiglib.physics.RigidBody;

	/**
	 * <code>CollisionSystemBrute</code> checks every rigidbody against each other. 
	 * For small scenes this is	as fast or even faster as CollisionSystemGrid.
	 * 
	 */	
	public class CollisionSystemBrute extends CollisionSystemAbstract
	{
		
		public function CollisionSystemBrute()
		{
			super();
		}
		
		// Detects collisions between the all bodies
		override public function detectAllCollisions(bodies:Vector.<RigidBody>, collArr:Vector.<CollisionInfo>):void
		{
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			var bodyID:int;
			var bodyType:String;
			_numCollisionsChecks = 0;
			for each (var _body:RigidBody in bodies)
			{
				if(!_body.isActive)continue;
				
				bodyID = _body.id;
				bodyType = _body.type;
				for each (var _collBody:RigidBody in collBody)
				{
					if (_body == _collBody)
					{
						continue;
					}
					
					if (_collBody.isActive && bodyID > _collBody.id)
					{
						continue;
					}
					
					if (checkCollidables(_body, _collBody) && detectionFunctors[bodyType + "_" + _collBody.type] != undefined)
					{
						info = new CollDetectInfo();
						info.body0 = _body;
						info.body1 = _collBody;
						fu = detectionFunctors[info.body0.type + "_" + info.body1.type];
						fu.collDetect(info, collArr);
						_numCollisionsChecks += 1;
					}
				}
			}
		}
	}
}