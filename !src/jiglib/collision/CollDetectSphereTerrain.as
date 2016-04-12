package jiglib.collision
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.data.TerrainData;
	import jiglib.geometry.JSphere;
	import jiglib.geometry.JTerrain;
	import jiglib.math.JNumber3D;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;
	
	public class CollDetectSphereTerrain extends CollDetectFunctor
	{
		
		public function CollDetectSphereTerrain() 
		{
			name = "SphereTerrain";
			type0 = "SPHERE";
			type1 = "TERRAIN";
		}
		
		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var tempBody:RigidBody;
			if (info.body0.type == "TERRAIN")
			{
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}

			var sphere:JSphere = info.body0 as JSphere;
			var terrain:JTerrain = info.body1 as JTerrain;
						
			var obj:TerrainData = terrain.getHeightAndNormalByPoint(sphere.currentState.position);
			if (obj.height < JConfig.collToll + sphere.radius) {
				var dist:Number = terrain.getHeightByPoint(sphere.oldState.position);
				var depth:Number = sphere.radius - dist;
				
				var Pt:Vector3D = sphere.oldState.position.subtract(JNumber3D.getScaleVector(obj.normal, sphere.radius));
				
				var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(1,true);
				var cpInfo:CollPointInfo = new CollPointInfo();
				cpInfo.r0 = Pt.subtract(sphere.oldState.position);
				cpInfo.r1 = Pt.subtract(terrain.oldState.position);
				cpInfo.initialPenetration = depth;
				collPts[0]=cpInfo;
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = obj.normal;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(sphere.material.restitution + terrain.material.restitution);
				mat.friction = 0.5*(sphere.material.friction + terrain.material.friction);
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