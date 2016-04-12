package jiglib.collision
{

	import flash.geom.Vector3D;

	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;

	public class CollDetectSpherePlane extends CollDetectFunctor
	{

		public function CollDetectSpherePlane()
		{
			name = "SpherePlane";
			type0 = "SPHERE";
			type1 = "PLANE";
		}

		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var tempBody:RigidBody;
			if (info.body0.type == "PLANE")
			{
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}

			var sphere:JSphere = info.body0 as JSphere;
			var plane:JPlane = info.body1 as JPlane;

			var oldDist:Number,newDist:Number,depth:Number;
			oldDist = plane.pointPlaneDistance(sphere.oldState.position);
			newDist = plane.pointPlaneDistance(sphere.currentState.position);

			if (Math.min(newDist, oldDist) > sphere.boundingSphere + JConfig.collToll)
			{
				info.body0.removeCollideBodies(info.body1);
				info.body1.removeCollideBodies(info.body0);
				return;
			}

			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(1,true);
			var cpInfo:CollPointInfo;
			depth = sphere.radius - oldDist;

			var worldPos:Vector3D = sphere.oldState.position.subtract(JNumber3D.getScaleVector(plane.normal, sphere.radius));
			cpInfo = new CollPointInfo();
			cpInfo.r0 = worldPos.subtract(sphere.oldState.position);
			cpInfo.r1 = worldPos.subtract(plane.oldState.position);
			cpInfo.initialPenetration = depth;
			collPts[0]=cpInfo;
			
			var collInfo:CollisionInfo = new CollisionInfo();
			collInfo.objInfo = info;
			collInfo.dirToBody = plane.normal.clone();
			collInfo.pointInfo = collPts;
			
			var mat:MaterialProperties = new MaterialProperties();
			mat.restitution = 0.5*(sphere.material.restitution + plane.material.restitution);
			mat.friction = 0.5*(sphere.material.friction + plane.material.friction);
			collInfo.mat = mat;
			collArr.push(collInfo);
			info.body0.collisions.push(collInfo);
			info.body1.collisions.push(collInfo);
			info.body0.addCollideBody(info.body1);
			info.body1.addCollideBody(info.body0);
		}
	}
}