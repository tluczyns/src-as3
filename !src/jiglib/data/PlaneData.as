package jiglib.data
{
	import flash.geom.Vector3D;
	import jiglib.math.JNumber3D;
	import jiglib.math.JMath3D;

	public class PlaneData
	{

		private var _position:Vector3D;
		private var _normal:Vector3D;
		private var _distance:Number;

		public function PlaneData()
		{
			_position = new Vector3D();
			_normal = new Vector3D(0, 1, 0);
			_distance = 0;
		}

		public function get position():Vector3D
		{
			return _position;
		}

		public function get normal():Vector3D
		{
			return _normal;
		}

		public function get distance():Number
		{
			return _distance;
		}

		public function pointPlaneDistance(pt:Vector3D):Number
		{
			return _normal.dotProduct(pt) - _distance;
		}
		
		public function setWithNormal(pos:Vector3D, nor:Vector3D):void {
			_position = pos.clone();
			_normal = nor.clone();
			_distance = pos.dotProduct(nor);
		}
		public function setWithPoint(pos0:Vector3D, pos1:Vector3D, pos2:Vector3D):void {
			_position = pos0.clone();
			
			var dr1:Vector3D = pos1.subtract(pos0);
			var dr2:Vector3D = pos2.subtract(pos0);
			_normal = dr1.crossProduct(dr2);
			
			var nLen:Number = _normal.length;
			if (nLen < JMath3D.NUM_TINY) {
				_normal = new Vector3D(0, 1, 0);
				_distance = 0;
			}else {
				_normal.scaleBy(1 / nLen);
				_distance = pos0.dotProduct(_normal);
			}
		}
	}
}