package jiglib.geometry 
{
	import flash.geom.Vector3D;
	
	import jiglib.data.PlaneData;
	import jiglib.math.JNumber3D;
	
	/// Support for an indexed triangle - assumes ownership by something that 
	/// has an array of vertices and an array of tIndexedTriangle
	public class JIndexedTriangle
	{
		public var counter:int;
		
		private var _vertexIndices:Vector.<uint>;
		private var _plane:PlaneData;
		private var _boundingBox:JAABox;
		
		public function JIndexedTriangle() 
		{
			counter = 0;
			_vertexIndices = new Vector.<uint>(3, true);
			_vertexIndices[0] = -1;
			_vertexIndices[1] = -1;
			_vertexIndices[2] = -1;
			_plane = new PlaneData();
			_boundingBox = new JAABox();
		}
		
		/// Set the indices into the relevant vertex array for this triangle. Also sets the plane and bounding box
		public function setVertexIndices(i0:uint, i1:uint, i2:uint, vertexArray:Vector.<Vector3D>):void {
			_vertexIndices[0] = i0;
			_vertexIndices[1] = i1;
			_vertexIndices[2] = i2;
			
			_plane.setWithPoint(vertexArray[i0], vertexArray[i1], vertexArray[i2]);
			
			_boundingBox.clear();
			_boundingBox.addPoint(vertexArray[i0]);
			_boundingBox.addPoint(vertexArray[i1]);
			_boundingBox.addPoint(vertexArray[i2]);
		}
		
		public function updateVertexIndices(vertexArray:Vector.<Vector3D>):void{
			var i0:uint,i1:uint,i2:uint;
			i0=_vertexIndices[0];
			i1=_vertexIndices[1];
			i2=_vertexIndices[2];
			
			_plane.setWithPoint(vertexArray[i0], vertexArray[i1], vertexArray[i2]);
			
			_boundingBox.clear();
			_boundingBox.addPoint(vertexArray[i0]);
			_boundingBox.addPoint(vertexArray[i1]);
			_boundingBox.addPoint(vertexArray[i2]);
		}
		
		// Get the indices into the relevant vertex array for this triangle.
		public function get vertexIndices():Vector.<uint> {
			return _vertexIndices;
		}
		
		// Get the vertex index association with iCorner (which should be 0, 1 or 2)
		public function getVertexIndex(iCorner:uint):uint {
			return _vertexIndices[iCorner];
		}
		
		// Get the triangle plane
		public function get plane():PlaneData {
			return _plane;
		}
		
		public function get boundingBox():JAABox {
			return _boundingBox;
		}
	}
}