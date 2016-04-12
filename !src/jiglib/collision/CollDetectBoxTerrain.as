package jiglib.collision
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.data.TerrainData;
	import jiglib.geometry.JBox;
	import jiglib.geometry.JTerrain;
	import jiglib.math.JNumber3D;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;
	
	public class CollDetectBoxTerrain extends CollDetectFunctor
	{
		
		public function CollDetectBoxTerrain() 
		{
			name = "BoxTerrain";
			type0 = "BOX";
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
			
			var box:JBox = info.body0 as JBox;
			var terrain:JTerrain = info.body1 as JTerrain;
						
			var oldPts:Vector.<Vector3D> = box.getCornerPoints(box.oldState);
			var newPts:Vector.<Vector3D> = box.getCornerPoints(box.currentState);
			var collNormal:Vector3D = new Vector3D();
			
			var obj:TerrainData;
			var dist:Number;
			var newPt:Vector3D;
			var oldPt:Vector3D;
			
			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			var cpInfo:CollPointInfo;
			
			for (var i:int = 0; i < 8; i++ ) {
				newPt = newPts[i];
				obj = terrain.getHeightAndNormalByPoint(newPt);
				
				if (obj.height < JConfig.collToll) {
					oldPt = oldPts[i];
					dist = terrain.getHeightByPoint(oldPt);
					collNormal = collNormal.add(obj.normal);
					cpInfo = new CollPointInfo();
					cpInfo.r0 = oldPt.subtract(box.oldState.position);
					cpInfo.r1 = oldPt.subtract(terrain.oldState.position);
					cpInfo.initialPenetration = -dist;
					collPts.push(cpInfo);
				}
			}
			
			if (collPts.length > 0) {
				collNormal.normalize();
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = collNormal;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(box.material.restitution + terrain.material.restitution);
				mat.friction = 0.5*(box.material.friction + terrain.material.friction);
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