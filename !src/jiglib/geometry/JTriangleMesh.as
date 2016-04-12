package jiglib.geometry 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.data.CollOutData;
	import jiglib.data.TriangleVertexIndices;
	import jiglib.math.*;
	import jiglib.physics.PhysicsState;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.ISkin3D;
	
	public class JTriangleMesh extends RigidBody
	{
		private var _octree:JOctree;
		private var _maxTrianglesPerCell:int;
		private var _minCellSize:Number;
		private var _skinVertices:Vector.<Vector3D>;
		
		public function JTriangleMesh(skin:ISkin3D, initPosition:Vector3D, initOrientation:Matrix3D, maxTrianglesPerCell:int = 10, minCellSize:Number = 10)
		{
			super(skin);
			
			currentState.position=initPosition.clone();
			currentState.orientation=initOrientation.clone();
			_maxTrianglesPerCell = maxTrianglesPerCell;
			_minCellSize = minCellSize;
			
			this.movable = false;
			
			if(skin){
				_skinVertices=skin.vertices;
				createMesh(_skinVertices,skin.indices);
				
				_boundingBox=_octree.boundingBox().clone();
				skin.transform = JMatrix3D.getAppendMatrix3D(currentState.orientation, JMatrix3D.getTranslationMatrix(currentState.position.x, currentState.position.y, currentState.position.z));
			}
			
			_type = "TRIANGLEMESH";
		}
		
		/*Internally set up and preprocess all numTriangles. Each index
		 should, of course, be from 0 to numVertices-1. Vertices and
		 triangles are copied and stored internally.*/
		private function createMesh(vertices:Vector.<Vector3D>, triangleVertexIndices:Vector.<TriangleVertexIndices>):void {
			
			var len:uint=vertices.length;
			var vts:Vector.<Vector3D>=new Vector.<Vector3D>(len,true);
			
			var transform:Matrix3D = JMatrix3D.getTranslationMatrix(currentState.position.x, currentState.position.y, currentState.position.z);
			transform = JMatrix3D.getAppendMatrix3D(currentState.orientation, transform);
			
			var i:uint = 0;
			for each (var _point:Vector3D in vertices){
				vts[i++] = transform.transformVector(_point);
			}
			
			_octree = new JOctree();
			
			_octree.addTriangles(vts, vts.length, triangleVertexIndices, triangleVertexIndices.length);
			_octree.buildOctree(_maxTrianglesPerCell, _minCellSize);
			
		}
		
		public function get octree():JOctree {
			return _octree;
		}
		
		override public function segmentIntersect(out:CollOutData, seg:JSegment, state:PhysicsState):Boolean
		{
			var segBox:JAABox = new JAABox();
			segBox.addSegment(seg);
			
			var potentialTriangles:Vector.<uint> = new Vector.<uint>();
			var numTriangles:uint = _octree.getTrianglesIntersectingtAABox(potentialTriangles, segBox);
			
			var bestFrac:Number = JMath3D.NUM_HUGE;
			var tri:JTriangle;
			var meshTriangle:JIndexedTriangle;
			for (var iTriangle:uint = 0 ; iTriangle < numTriangles ; iTriangle++) {
				meshTriangle = _octree.getTriangle(potentialTriangles[iTriangle]);
				
				tri = new JTriangle(_octree.getVertex(meshTriangle.getVertexIndex(0)), _octree.getVertex(meshTriangle.getVertexIndex(1)), _octree.getVertex(meshTriangle.getVertexIndex(2)));
				
				if (tri.segmentTriangleIntersection(out, seg)) {
					if (out.frac < bestFrac) {
						bestFrac = out.frac;
						out.position = seg.getPoint(bestFrac);
						out.normal = meshTriangle.plane.normal;
					}
				}
			}
			out.frac = bestFrac;
			if (bestFrac < JMath3D.NUM_HUGE) {
				return true;
			}else {
				return false;
			}
		}
		
		override protected function updateState():void
		{
			super.updateState();
			
			var len:uint=_skinVertices.length;
			var vts:Vector.<Vector3D>=new Vector.<Vector3D>(len,true);
			
			var transform:Matrix3D = JMatrix3D.getTranslationMatrix(currentState.position.x, currentState.position.y, currentState.position.z);
			transform = JMatrix3D.getAppendMatrix3D(currentState.orientation, transform);
			
			var i:uint = 0;
			for each (var _point:Vector3D in _skinVertices){
				vts[i++] = transform.transformVector(_point);
			}
			
			_octree.updateTriangles(vts);
			_octree.buildOctree(_maxTrianglesPerCell, _minCellSize);
			
			_boundingBox=_octree.boundingBox().clone();
		}
		
		/*
		override public function getInertiaProperties(m:Number):Matrix3D
		{
			return new Matrix3D();
		}
		
		override protected function updateBoundingBox():void {
		}*/
	}
}