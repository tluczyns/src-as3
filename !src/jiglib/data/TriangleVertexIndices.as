package jiglib.data 
{
	// structure used to set up the mesh
	public class TriangleVertexIndices
	{
		
		public var i0:uint;
		public var i1:uint;
		public var i2:uint;
		
		public function TriangleVertexIndices(_i0:uint, _i1:uint, _i2:uint)
		{
			this.i0 = _i0;
			this.i1 = _i1;
			this.i2 = _i2;
		}
	}
}