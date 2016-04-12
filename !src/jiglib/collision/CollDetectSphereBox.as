package jiglib.collision
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.*;
	import jiglib.math.*;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;
	
	public class CollDetectSphereBox extends CollDetectFunctor
	{
		public function CollDetectSphereBox()
		{
			name = "SphereBox";
			type0 = "SPHERE";
			type1 = "BOX";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var tempBody:RigidBody;
			if (info.body0.type == "BOX")
			{
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}
			
			var sphere:JSphere = info.body0 as JSphere;
			var box:JBox = info.body1 as JBox;
			
			if (!sphere.hitTestObject3D(box))
			{
				return;
			}
			if (!sphere.boundingBox.overlapTest(box.boundingBox))
			{
				return;
			}
			
			//var spherePos:Vector3D = sphere.oldState.position;
			//var boxPos:Vector3D = box.oldState.position;
			
			var oldBoxPoint:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D()]);
			var newBoxPoint:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D()]);
			
			var oldDist:Number,newDist:Number,oldDepth:Number,newDepth:Number,tiny:Number=JMath3D.NUM_TINY;
			oldDist = box.getDistanceToPoint(box.oldState, oldBoxPoint, sphere.oldState.position);
			newDist = box.getDistanceToPoint(box.currentState, newBoxPoint, sphere.currentState.position);
			
			var _oldBoxPosition:Vector3D = oldBoxPoint[0];
			
			oldDepth = sphere.radius - oldDist;
			newDepth = sphere.radius - newDist;
			if (Math.max(oldDepth, newDepth) > -JConfig.collToll)
			{
				var dir:Vector3D;
				var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(1,true);
				if (oldDist < -tiny)
				{
					dir = _oldBoxPosition.subtract(sphere.oldState.position).subtract(_oldBoxPosition);
					dir.normalize();
				}
				else if (oldDist > tiny)
				{
					dir = sphere.oldState.position.subtract(_oldBoxPosition);
					dir.normalize();
				}
				else
				{
					dir = sphere.oldState.position.subtract(box.oldState.position);
					dir.normalize();
				}
				
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = _oldBoxPosition.subtract(sphere.oldState.position);
				cpInfo.r1 = _oldBoxPosition.subtract(box.oldState.position);
				cpInfo.initialPenetration = oldDepth;
				collPts[0]=cpInfo;
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = dir;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(sphere.material.restitution + box.material.restitution);
				mat.friction = 0.5*(sphere.material.friction + box.material.friction);
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