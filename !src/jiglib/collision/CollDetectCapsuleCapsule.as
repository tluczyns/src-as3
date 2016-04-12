package jiglib.collision
{

	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;

	public class CollDetectCapsuleCapsule extends CollDetectFunctor
	{

		public function CollDetectCapsuleCapsule()
		{
			name = "CapsuleCapsule";
			type0 = "CAPSULE";
			type1 = "CAPSULE";
		}

		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var capsule0:JCapsule = info.body0 as JCapsule;
			var capsule1:JCapsule = info.body1 as JCapsule;

			if (!capsule0.hitTestObject3D(capsule1))
			{
				return;
			}
			
			if (!capsule0.boundingBox.overlapTest(capsule1.boundingBox)) {
				return;
			}

			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			var cpInfo:CollPointInfo;

			var averageNormal:Vector3D = new Vector3D();
			var oldSeg0:JSegment,newSeg0:JSegment,oldSeg1:JSegment,newSeg1:JSegment;
			oldSeg0 = new JSegment(capsule0.getEndPos(capsule0.oldState), JNumber3D.getScaleVector(capsule0.oldState.getOrientationCols()[1], -capsule0.length));
			newSeg0 = new JSegment(capsule0.getEndPos(capsule0.currentState), JNumber3D.getScaleVector(capsule0.currentState.getOrientationCols()[1], -capsule0.length));
			oldSeg1 = new JSegment(capsule1.getEndPos(capsule1.oldState), JNumber3D.getScaleVector(capsule1.oldState.getOrientationCols()[1], -capsule1.length));
			newSeg1 = new JSegment(capsule1.getEndPos(capsule1.currentState), JNumber3D.getScaleVector(capsule1.currentState.getOrientationCols()[1], -capsule1.length));

			var radSum:Number = capsule0.radius + capsule1.radius;

			var oldObj:Vector.<Number> = new Vector.<Number>(2, true);
			var oldDistSq:Number = oldSeg0.segmentSegmentDistanceSq(oldObj, oldSeg1);
			var newObj:Vector.<Number> = new Vector.<Number>(2, true);
			var newDistSq:Number = newSeg0.segmentSegmentDistanceSq(oldObj, newSeg1);

			if (Math.min(oldDistSq, newDistSq) < Math.pow(radSum + JConfig.collToll, 2))
			{
				var pos0:Vector3D = oldSeg0.getPoint(oldObj[0]);
				var pos1:Vector3D = oldSeg1.getPoint(oldObj[1]);

				var delta:Vector3D = pos0.subtract(pos1);
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

				var worldPos:Vector3D = pos1.add(JNumber3D.getScaleVector(delta, capsule1.radius - 0.5 * depth));
				averageNormal = averageNormal.add(delta);

				cpInfo = new CollPointInfo();
				cpInfo.r0 = worldPos.subtract(capsule0.oldState.position);
				cpInfo.r1 = worldPos.subtract(capsule1.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts[0]=cpInfo;
			}

			if (collPts.length > 0)
			{
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = averageNormal;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(capsule0.material.restitution + capsule1.material.restitution);
				mat.friction = 0.5*(capsule0.material.friction + capsule1.material.friction);
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
