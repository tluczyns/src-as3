package jiglib.data 
{
	import flash.geom.Vector3D;
	import jiglib.geometry.JAABox;
	import jiglib.math.JNumber3D;
	
	public class OctreeCell
	{
		
		public static var NUM_CHILDREN:uint = 8;
		
		// indices of the children (if not leaf). Will be -1 if there is no child
		public var childCellIndices:Vector.<int>;
		// indices of the triangles (if leaf)
		public var triangleIndices:Vector.<int>;
		// Bounding box for the space we own
		public var AABox:JAABox;
		
		private var _points:Vector.<Vector3D>;
		private var _egdes:Vector.<EdgeData>;
		
		public function OctreeCell(aabox:JAABox)
		{
			childCellIndices = new Vector.<int>(NUM_CHILDREN, true);
			triangleIndices = new Vector.<int>();
			
			clear();
			
			if(aabox){
				AABox = aabox.clone();
			}else {
				AABox = new JAABox();
			}
			_points = AABox.getAllPoints();
			_egdes = AABox.edges;
		}
		
		// Indicates if we contain triangles (if not then we should/might have children)
		public function isLeaf():Boolean {
			return childCellIndices[0] == -1;
		}
		
		public function clear():void {
			for (var i:uint = 0; i < NUM_CHILDREN; i++ ) {
				childCellIndices[i] = -1;
			}
			triangleIndices.splice(0, triangleIndices.length);
		}
		
		public function get points():Vector.<Vector3D> {
			return _points;
		}
		public function get egdes():Vector.<EdgeData> {
			return _egdes;
		}
	}

}