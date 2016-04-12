package jiglib.collision
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.data.CollOutData;
	import jiglib.data.EdgeData;
	import jiglib.data.SpanData;
	import jiglib.geometry.JBox;
	import jiglib.geometry.JIndexedTriangle;
	import jiglib.geometry.JSegment;
	import jiglib.geometry.JTriangle;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.math.JNumber3D;
	import jiglib.math.JMath3D;
	import jiglib.physics.MaterialProperties;
	import jiglib.physics.RigidBody;
	
	public class CollDetectBoxMesh extends CollDetectFunctor
	{
		public function CollDetectBoxMesh()
		{
			name = "BoxMesh";
			type0 = "BOX";
			type1 = "TRIANGLEMESH";
		}
		
		private function disjoint(out:SpanData, axis:Vector3D, box:JBox, triangle:JTriangle):Boolean
		{
			var obj0:SpanData = box.getSpan(axis);
			var obj1:SpanData = triangle.getSpan(axis);
			var obj0Min:Number=obj0.min,obj0Max:Number=obj0.max,obj1Min:Number=obj1.min,obj1Max:Number=obj1.max,tiny:Number=JMath3D.NUM_TINY;
			
			if (obj0Min > (obj1Max + JConfig.collToll + tiny) || obj1Min > (obj0Max + JConfig.collToll + tiny))
			{
				out.flag = true;
				return true;
			}
			if ((obj0Max > obj1Max) && (obj1Min > obj0Min))
			{
				out.depth = Math.min(obj0Max - obj1Min, obj1Max - obj0Min);
			}
			else if ((obj1Max > obj0Max) && (obj0Min > obj1Min))
			{
				out.depth = Math.min(obj1Max - obj0Min, obj0Max - obj1Min);
			}
			else
			{
				out.depth = Math.min(obj0Max, obj1Max);
				out.depth -= Math.max(obj0Min, obj1Min);
			}
			out.flag = false;
			return false;
		}
		
		private function addPoint(contactPoints:Vector.<Vector3D>, pt:Vector3D, combinationDistanceSq:Number):Boolean
		{
			for each (var contactPoint:Vector3D in contactPoints)
			{
				if (contactPoint.subtract(pt).lengthSquared < combinationDistanceSq)
				{
					contactPoint = JNumber3D.getScaleVector(contactPoint.add(pt), 0.5);
					return false;
				}
			}
			contactPoints.push(pt);
			return true;
		}
		
		private function getBoxTriangleIntersectionPoints(pts:Vector.<Vector3D>,box:JBox,triangle:JTriangle,combinationDistanceSq:Number):uint{
			var edges:Vector.<EdgeData>=box.edges;
			var boxPts:Vector.<Vector3D>=box.getCornerPoints(box.currentState);
			
			var data:CollOutData;
			var edge:EdgeData;
			var seg:JSegment;
			for(var i:uint=0;i<12;i++){
				edge=edges[i];
				data=new CollOutData();
				seg=new JSegment(boxPts[edge.ind0],boxPts[edge.ind1].subtract(boxPts[edge.ind0]));
				if(triangle.segmentTriangleIntersection(data,seg)){
					addPoint(pts,seg.getPoint(data.frac),combinationDistanceSq);
					if(pts.length>8) return pts.length;
				}
			}
			
			var pt0:Vector3D,pt1:Vector3D;
			for(i=0;i<3;i++){
				pt0=triangle.getVertex(i);
				pt1=triangle.getVertex((i+1)%3);
				data=new CollOutData();
				if(box.segmentIntersect(data,new JSegment(pt0,pt1.subtract(pt0)),box.currentState)){
					addPoint(pts,data.position,combinationDistanceSq);
					if(pts.length>8) return pts.length;
				}
				if(box.segmentIntersect(data,new JSegment(pt1,pt0.subtract(pt1)),box.currentState)){
					addPoint(pts,data.position,combinationDistanceSq);
					if(pts.length>8) return pts.length;
				}
			}
			return pts.length;
		}
		
		private function doOverlapBoxTriangleTest(box:JBox,triangle:JIndexedTriangle,mesh:JTriangleMesh,info:CollDetectInfo,collArr:Vector.<CollisionInfo>):Boolean{
			
			var triEdge0:Vector3D,triEdge1:Vector3D,triEdge2:Vector3D,triNormal:Vector3D,D:Vector3D,N:Vector3D,boxOldPos:Vector3D,boxNewPos:Vector3D,meshPos:Vector3D,delta:Vector3D;
			var dirs0:Vector.<Vector3D>=box.currentState.getOrientationCols();
			var tri:JTriangle=new JTriangle(mesh.octree.getVertex(triangle.getVertexIndex(0)),mesh.octree.getVertex(triangle.getVertexIndex(1)),mesh.octree.getVertex(triangle.getVertexIndex(2)));
			triEdge0=tri.getVertex(1).subtract(tri.getVertex(0));
			triEdge0.normalize();
			triEdge1=tri.getVertex(2).subtract(tri.getVertex(1));
			triEdge1.normalize();
			triEdge2=tri.getVertex(0).subtract(tri.getVertex(2));
			triEdge2.normalize();
			triNormal=triangle.plane.normal.clone();
			
			var numAxes:uint=13;
			var axes:Vector.<Vector3D> = Vector.<Vector3D>([triNormal,dirs0[0],dirs0[1],dirs0[2],
															dirs0[0].crossProduct(triEdge0),
															dirs0[0].crossProduct(triEdge1),
															dirs0[0].crossProduct(triEdge2),
															dirs0[1].crossProduct(triEdge0),
															dirs0[1].crossProduct(triEdge1),
															dirs0[1].crossProduct(triEdge2),
															dirs0[2].crossProduct(triEdge0),
															dirs0[2].crossProduct(triEdge1),
															dirs0[2].crossProduct(triEdge2)]);
			
			var overlapDepths:Vector.<SpanData>=new Vector.<SpanData>(numAxes,true);
			for(var i:uint=0;i<numAxes;i++){
				overlapDepths[i]=new SpanData();
				if(disjoint(overlapDepths[i],axes[i],box,tri)){
					return false;
				}
			}
			
			var minAxis:int=-1;
			var tiny:Number=JMath3D.NUM_TINY,minDepth:Number=JMath3D.NUM_HUGE,l2:Number,invl:Number,depth:Number,combinationDist:Number,oldDepth:Number;

			for(i = 0; i < numAxes; i++){
				l2=axes[i].lengthSquared;
				if (l2 < tiny){
					continue;
				}
				
				invl=1/Math.sqrt(l2);
				axes[i].scaleBy(invl);
				overlapDepths[i].depth*=invl;
				
				if (overlapDepths[i].depth < minDepth){
					minDepth = overlapDepths[i].depth;
					minAxis=i;
				}
			}
			
			if (minAxis == -1) return false;
			
			D=box.currentState.position.subtract(tri.getCentre());
			N=axes[minAxis];
			depth=overlapDepths[minAxis].depth;
			
			if(D.dotProduct(N)<0){
				N.negate();
			}
			
			boxOldPos=box.oldState.position;
			boxNewPos=box.currentState.position;
			meshPos=mesh.currentState.position;
			
			var pts:Vector.<Vector3D>=new Vector.<Vector3D>();
			combinationDist=depth+0.05;
			getBoxTriangleIntersectionPoints(pts,box,tri,combinationDist*combinationDist);
			
			delta=boxNewPos.subtract(boxOldPos);
			oldDepth=depth+delta.dotProduct(N);
			
			var numPts:uint = pts.length;
			var collPts:Vector.<CollPointInfo> = new Vector.<CollPointInfo>(numPts,true);
			if(numPts>0){
				var cpInfo:CollPointInfo;
				for (i=0; i<numPts; i++){
					cpInfo = new CollPointInfo();
					cpInfo.r0=pts[i].subtract(boxNewPos);
					cpInfo.r1=pts[i].subtract(meshPos);
					cpInfo.initialPenetration=oldDepth;
					collPts[i]=cpInfo;
				}
				
				var collInfo:CollisionInfo = new CollisionInfo();
				collInfo.objInfo = info;
				collInfo.dirToBody = N;
				collInfo.pointInfo = collPts;
				
				var mat:MaterialProperties = new MaterialProperties();
				mat.restitution = 0.5*(box.material.restitution + mesh.material.restitution);
				mat.friction = 0.5*(box.material.friction + mesh.material.friction);
				collInfo.mat = mat;
				collArr.push(collInfo);
				info.body0.collisions.push(collInfo);
				info.body1.collisions.push(collInfo);
				info.body0.addCollideBody(info.body1);
				info.body1.addCollideBody(info.body0);
				return true;
			}else {
				info.body0.removeCollideBodies(info.body1);
				info.body1.removeCollideBodies(info.body0);
				return false;
			}
		}
		
		private function collDetectBoxStaticMeshOverlap(box:JBox,mesh:JTriangleMesh,info:CollDetectInfo,collArr:Vector.<CollisionInfo>):Boolean{
			var boxRadius:Number=box.boundingSphere;
			var boxCentre:Vector3D=box.currentState.position;
			
			var potentialTriangles:Vector.<uint> = new Vector.<uint>();
			var numTriangles:uint=mesh.octree.getTrianglesIntersectingtAABox(potentialTriangles,box.boundingBox);
			
			var collision:Boolean=false;
			var dist:Number;
			var meshTriangle:JIndexedTriangle;
			for (var iTriangle:uint = 0 ; iTriangle < numTriangles ; ++iTriangle) {
				meshTriangle=mesh.octree.getTriangle(potentialTriangles[iTriangle]);
				
				dist=meshTriangle.plane.pointPlaneDistance(boxCentre);
				if (dist > boxRadius || dist < 0){
					continue;
				}
				
				if(doOverlapBoxTriangleTest(box,meshTriangle,mesh,info,collArr)){
					collision = true;
				}
			}
			
			return collision;
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
			var box:JBox = info.body0 as JBox;
			var mesh:JTriangleMesh = info.body1 as JTriangleMesh;
			
			collDetectBoxStaticMeshOverlap(box,mesh,info,collArr);
		}
	}
}