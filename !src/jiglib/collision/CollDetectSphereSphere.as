package jiglib.collision
{

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;

	public class CollDetectSphereSphere extends CollDetectFunctor
	{

		public function CollDetectSphereSphere()
		{
			name = "SphereSphere";
			type0 = "SPHERE";
			type1 = "SPHERE";
		}

		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var sphere0:JSphere = info.body0 as JSphere;
			var sphere1:JSphere = info.body1 as JSphere;

			var oldDelta:Vector3D = sphere0.oldState.position.subtract(sphere1.oldState.position);
			var newDelta:Vector3D = sphere0.currentState.position.subtract(sphere1.currentState.position);

			var oldDistSq:Number,newDistSq:Number,radSum:Number,oldDist:Number,depth:Number;
			oldDistSq = oldDelta.lengthSquared;
			newDistSq = newDelta.lengthSquared;
			radSum = sphere0.radius + sphere1.radius;

			if (Math.min(oldDistSq, newDistSq) < Math.pow(radSum + JConfig.collToll, 2))
			{
				oldDist = Math.sqrt(oldDistSq);
				depth = radSum - oldDist;
				if (oldDist > JMath3D.NUM_TINY)
				{
					oldDelta = JNumber3D.getDivideVector(oldDelta, oldDist);
				}
				else
				{
					oldDelta = JMatrix3D.getRotationMatrix(0, 0, 1, 360 * Math.random()).transformVector(Vector3D.Y_AXIS);
				}
				
				var worldPos:Vector3D = sphere1.oldState.position.add(JNumber3D.getScaleVector(oldDelta, sphere1.radius - 0.5 * depth));

				var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(1,true);
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = worldPos.subtract(sphere0.oldState.position);
				cpInfo.r1 = worldPos.subtract(sphere1.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts[0]=cpInfo;
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = oldDelta;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(sphere0.material.restitution + sphere1.material.restitution);
				mat.friction = 0.5*(sphere0.material.friction + sphere1.material.friction);
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