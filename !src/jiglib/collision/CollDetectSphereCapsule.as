package jiglib.collision
{

	import flash.geom.Vector3D;

	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;

	public class CollDetectSphereCapsule extends CollDetectFunctor
	{

		public function CollDetectSphereCapsule()
		{
			name = "SphereCapsule";
			type0 = "SPHERE";
			type1 = "CAPSULE";
		}

		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var tempBody:RigidBody;
			if (info.body0.type == "CAPSULE")
			{
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}

			var sphere:JSphere = info.body0 as JSphere;
			var capsule:JCapsule = info.body1 as JCapsule;

			if (!sphere.hitTestObject3D(capsule))
			{
				return;
			}
			
			if (!sphere.boundingBox.overlapTest(capsule.boundingBox)) {
				return;
			}

			var oldSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.oldState), JNumber3D.getScaleVector(capsule.oldState.getOrientationCols()[1], capsule.length));
			var newSeg:JSegment = new JSegment(capsule.getBottomPos(capsule.currentState), JNumber3D.getScaleVector(capsule.currentState.getOrientationCols()[1], capsule.length));
			var radSum:Number = sphere.radius + capsule.radius;

			var oldObj:Vector.<Number> = new Vector.<Number>(1, true);
			var oldDistSq:Number = oldSeg.pointSegmentDistanceSq(oldObj, sphere.oldState.position);
			var newObj:Vector.<Number> = new Vector.<Number>(1, true);
			var newDistSq:Number = newSeg.pointSegmentDistanceSq(newObj, sphere.currentState.position);

			if (Math.min(oldDistSq, newDistSq) < Math.pow(radSum + JConfig.collToll, 2))
			{
				var segPos:Vector3D = oldSeg.getPoint(oldObj[0]);
				var delta:Vector3D = sphere.oldState.position.subtract(segPos);

				var dist:Number = Math.sqrt(oldDistSq);
				var depth:Number = radSum - dist;

				if (dist > JMath3D.NUM_TINY)
				{
					delta = JNumber3D.getDivideVector(delta, dist);
				}
				else
				{
					delta = JMatrix3D.getRotationMatrix(0, 0, 1, 360 * Math.random()).transformVector(Vector3D.Y_AXIS);
				}

				var worldPos:Vector3D = segPos.add(JNumber3D.getScaleVector(delta, capsule.radius - 0.5 * depth));

				var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(1,true);
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = worldPos.subtract(sphere.oldState.position);
				cpInfo.r1 = worldPos.subtract(capsule.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts[0]=cpInfo;
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = delta;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(sphere.material.restitution + capsule.material.restitution);
				mat.friction = 0.5*(sphere.material.friction + capsule.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				info.body0.collisions.push(collInfo);
				info.body1.collisions.push(collInfo);
				info.body0.addCollideBody(info.body1);
				info.body1.addCollideBody(info.body0);
			}else {
				info.body0.removeCollideBodies(info.body1);
				info.body1.removeCollideBodies(info.body0);
			}
		}
	}

}
