package jiglib.collision
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;

	public class CollDetectBoxPlane extends CollDetectFunctor
	{

		public function CollDetectBoxPlane()
		{
			name = "BoxPlane";
			type0 = "BOX";
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

			var box:JBox = info.body0 as JBox;
			var plane:JPlane = info.body1 as JPlane;

			var centreDist:Number = plane.pointPlaneDistance(box.currentState.position);
			if (centreDist > box.boundingSphere + JConfig.collToll)
				return;

			var newPts:Vector.<Vector3D> = box.getCornerPoints(box.currentState);
			var oldPts:Vector.<Vector3D> = box.getCornerPoints(box.oldState);
			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			var cpInfo:CollPointInfo;
			var newPt:Vector3D,oldPt:Vector3D;
			var newDepth:Number,oldDepth:Number;
			var newPts_length:int = newPts.length;
			
			for (var i:int = 0; i < newPts_length; i++)
			{
				newPt = newPts[int(i)];
				oldPt = oldPts[int(i)];
				newDepth = -1 * plane.pointPlaneDistance(newPt);
				oldDepth = -1 * plane.pointPlaneDistance(oldPt);
				
				if (Math.max(newDepth, oldDepth) > -JConfig.collToll)
				{
					cpInfo = new CollPointInfo();
					cpInfo.r0 = oldPt.subtract(box.oldState.position);
					cpInfo.r1 = oldPt.subtract(plane.oldState.position);
					cpInfo.initialPenetration = oldDepth;
					collPts.push(cpInfo);
				}
			}
			
			if (collPts.length > 0)
			{
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = plane.normal.clone();
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(box.material.restitution + plane.material.restitution);
				mat.friction = 0.5*(box.material.friction + plane.material.friction);
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
