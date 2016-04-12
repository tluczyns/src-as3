package jiglib.collision
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import jiglib.data.CollOutBodyData;
	import jiglib.geometry.JSegment;
	import jiglib.math.JNumber3D;
	import jiglib.math.JMath3D;
	import jiglib.physics.RigidBody;
	
	public class CollisionSystemAbstract
	{
		public var detectionFunctors:Dictionary;
		public var collBody:Vector.<RigidBody>;
		public var _numCollisionsChecks:uint = 0;
		
		public var startPoint:Vector3D;//for grid system
		
		public function CollisionSystemAbstract()
		{
			collBody = new Vector.<RigidBody>();
			detectionFunctors = new Dictionary(true);
			detectionFunctors["BOX_BOX"] = new CollDetectBoxBox();
			detectionFunctors["BOX_SPHERE"] = new CollDetectSphereBox();
			detectionFunctors["BOX_CAPSULE"] = new CollDetectCapsuleBox();
			detectionFunctors["BOX_PLANE"] = new CollDetectBoxPlane();
			detectionFunctors["BOX_TERRAIN"] = new CollDetectBoxTerrain();
			detectionFunctors["BOX_TRIANGLEMESH"] = new CollDetectBoxMesh();
			detectionFunctors["SPHERE_BOX"] = new CollDetectSphereBox();
			detectionFunctors["SPHERE_SPHERE"] = new CollDetectSphereSphere();
			detectionFunctors["SPHERE_CAPSULE"] = new CollDetectSphereCapsule();
			detectionFunctors["SPHERE_PLANE"] = new CollDetectSpherePlane();
			detectionFunctors["SPHERE_TERRAIN"] = new CollDetectSphereTerrain();
			detectionFunctors["SPHERE_TRIANGLEMESH"] = new CollDetectSphereMesh();
			detectionFunctors["CAPSULE_CAPSULE"] = new CollDetectCapsuleCapsule();
			detectionFunctors["CAPSULE_BOX"] = new CollDetectCapsuleBox();
			detectionFunctors["CAPSULE_SPHERE"] = new CollDetectSphereCapsule();
			detectionFunctors["CAPSULE_PLANE"] = new CollDetectCapsulePlane();
			detectionFunctors["CAPSULE_TERRAIN"] = new CollDetectCapsuleTerrain();
			detectionFunctors["PLANE_BOX"] = new CollDetectBoxPlane();
			detectionFunctors["PLANE_SPHERE"] = new CollDetectSpherePlane();
			detectionFunctors["PLANE_CAPSULE"] = new CollDetectCapsulePlane();
			detectionFunctors["TERRAIN_SPHERE"] = new CollDetectSphereTerrain();
			detectionFunctors["TERRAIN_BOX"] = new CollDetectBoxTerrain();
			detectionFunctors["TERRAIN_CAPSULE"] = new CollDetectCapsuleTerrain();
			detectionFunctors["TRIANGLEMESH_SPHERE"] = new CollDetectSphereMesh();
			detectionFunctors["TRIANGLEMESH_BOX"] = new CollDetectBoxMesh();
		}

		public function addCollisionBody(body:RigidBody):void
		{
			if (collBody.indexOf(body) < 0)
				collBody.push(body);
		}
		
		public function removeCollisionBody(body:RigidBody):void
		{
			if (collBody.indexOf(body) >= 0)
				collBody.splice(collBody.indexOf(body), 1);
		}

		public function removeAllCollisionBodies():void
		{
			collBody.length=0;
		}
		
		// Detects collisions between the body and all the registered collision bodies
		public function detectCollisions(body:RigidBody, collArr:Vector.<CollisionInfo>):void
		{
			if (!body.isActive)
				return;
			
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			
			for each (var _collBody:RigidBody in collBody)
			{
				if (body == _collBody)
				{
					continue;
				}
				if (checkCollidables(body, _collBody) && detectionFunctors[body.type + "_" + _collBody.type] != undefined)
				{
					info = new CollDetectInfo();
					info.body0 = body;
					info.body1 = _collBody;
					fu = detectionFunctors[info.body0.type + "_" + info.body1.type];
					fu.collDetect(info, collArr);
				}
			}
		}
		
		// Detects collisions between the all bodies
		public function detectAllCollisions(bodies:Vector.<RigidBody>, collArr:Vector.<CollisionInfo>):void
		{
		}

		public function collisionSkinMoved(colBody:RigidBody):void
		{
			// used for grid
		}
		
		public function segmentIntersect(out:CollOutBodyData, seg:JSegment, ownerBody:RigidBody):Boolean
		{
			out.frac = JMath3D.NUM_HUGE;
			out.position = new Vector3D();
			out.normal = new Vector3D();
			
			var obj:CollOutBodyData = new CollOutBodyData();
			for each (var _collBody:RigidBody in collBody)
			{
				if (_collBody != ownerBody && segmentBounding(seg, _collBody))
				{
					if (_collBody.segmentIntersect(obj, seg, _collBody.currentState))
					{
						if (obj.frac < out.frac)
						{
							out.position = obj.position;
							out.normal = obj.normal;
							out.frac = obj.frac;
							out.rigidBody = _collBody;
						}
					}
				}
			}
			
			if (out.frac > 1)
				return false;
			
			if (out.frac < 0)
			{
				out.frac = 0;
			}
			else if (out.frac > 1)
			{
				out.frac = 1;
			}
			
			return true;
		}
		
		public function segmentBounding(seg:JSegment, obj:RigidBody):Boolean
		{
			var pos:Vector3D = seg.getPoint(0.5);
			var r:Number = seg.delta.length / 2;
			
			var num1:Number = pos.subtract(obj.currentState.position).length;
			var num2:Number = r + obj.boundingSphere;
			
			if (num1 <= num2)
				return true;
			else
				return false;
		}

		public function get numCollisionsChecks():uint
		{
			return _numCollisionsChecks;	
		}
		
		protected function checkCollidables(body0:RigidBody, body1:RigidBody):Boolean
		{
			if (body0.nonCollidables.length == 0 && body1.nonCollidables.length == 0)
				return true;
			
			if(body0.nonCollidables.indexOf(body1) > -1)
				return false;
			
			if(body1.nonCollidables.indexOf(body0) > -1)
				return false;
			
			return true;
		}

		
	}
}