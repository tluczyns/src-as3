package jiglib.collision 
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.geometry.JIndexedTriangle;
	import jiglib.geometry.JSphere;
	import jiglib.geometry.JTriangle;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.math.JNumber3D;
	import jiglib.math.JMath3D;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;
	
	
	public class CollDetectSphereMesh extends CollDetectFunctor
	{
		public function CollDetectSphereMesh() 
		{
			name = "SphereMesh";
			type0 = "SPHERE";
			type1 = "TRIANGLEMESH";
		}
		
		private function collDetectSphereStaticMeshOverlap(sphere:JSphere, mesh:JTriangleMesh, info:CollDetectInfo, collTolerance:Number, collArr:Vector.<CollisionInfo>):void {
			var body0Pos:Vector3D = info.body0.oldState.position;
			var body1Pos:Vector3D = info.body1.oldState.position;
			
			var sphereTolR:Number = collTolerance + sphere.radius;
			var sphereTolR2:Number = sphereTolR * sphereTolR;
			
			var collNormal:Vector3D = new Vector3D();
			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>();
			
			var potentialTriangles:Vector.<uint> = new Vector.<uint>();
			var numTriangles:uint = mesh.octree.getTrianglesIntersectingtAABox(potentialTriangles, sphere.boundingBox);
			
			var newD2:Number,distToCentre:Number,oldD2:Number,dist:Number,depth:Number,tiny:Number=JMath3D.NUM_TINY;
			var meshTriangle:JIndexedTriangle;
			var vertexIndices:Vector.<uint>;
			var arr:Vector.<Number>;
			var triangle:JTriangle;
			for (var iTriangle:uint = 0 ; iTriangle < numTriangles ; ++iTriangle) {
				meshTriangle = mesh.octree.getTriangle(potentialTriangles[iTriangle]);
				distToCentre = meshTriangle.plane.pointPlaneDistance(sphere.currentState.position);
				if (distToCentre <= 0) continue;
			    if (distToCentre >= sphereTolR) continue;
				
				vertexIndices = meshTriangle.vertexIndices;
				triangle = new JTriangle(mesh.octree.getVertex(vertexIndices[0]), mesh.octree.getVertex(vertexIndices[1]), mesh.octree.getVertex(vertexIndices[2]));
				arr = new Vector.<Number>(2, true);
				newD2 = triangle.pointTriangleDistanceSq(arr, sphere.currentState.position);
				
				if (newD2 < sphereTolR2) {
					// have overlap - but actually report the old intersection
				    oldD2 = triangle.pointTriangleDistanceSq(arr, sphere.oldState.position);
				    dist = Math.sqrt(oldD2);
				    depth = sphere.radius - dist;
				    var collisionN:Vector3D = (dist > tiny) ? (sphere.oldState.position.subtract(triangle.getPoint(arr[0], arr[1]))) : triangle.normal.clone();
					collisionN.normalize();
				    // since impulse get applied at the old position
				    var pt:Vector3D = sphere.oldState.position.subtract(JNumber3D.getScaleVector(collisionN, sphere.radius));
					
					var cpInfo:CollPointInfo = new CollPointInfo();
					cpInfo.r0 = pt.subtract(body0Pos);
					cpInfo.r1 = pt.subtract(body1Pos);
					cpInfo.initialPenetration = depth;
					collPts.push(cpInfo);
					collNormal = collNormal.add(collisionN);
					collNormal.normalize();
				}
			}
			if(collPts.length>0){
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = collNormal;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(sphere.material.restitution + mesh.material.restitution);
				mat.friction = 0.5*(sphere.material.friction + mesh.material.friction);
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
		
		override public function collDetect(info:CollDetectInfo, collArr:Vector.<CollisionInfo>):void
		{
			var tempBody:RigidBody;
			if (info.body0.type == "TRIANGLEMESH")
			{
				tempBody = info.body0;
				info.body0 = info.body1;
				info.body1 = tempBody;
			}
			
			var sphere:JSphere = info.body0 as JSphere;
			var mesh:JTriangleMesh = info.body1 as JTriangleMesh;
			
			collDetectSphereStaticMeshOverlap(sphere, mesh, info, JConfig.collToll, collArr);
		}
	}

}