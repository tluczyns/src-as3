package jiglib.plugin.away3d4 
{
	import flash.geom.Vector3D;
	import flash.display.BitmapData;
	
	import away3d.extrusions.Elevation;
	import away3d.materials.MaterialBase;
	
	import jiglib.plugin.ITerrain;
	
	public class Away3D4Terrain extends Elevation implements ITerrain
	{
		
		//Min of coordinate horizontally;
		private var _minW:Number;
		
		//Min of coordinate vertically;
		private var _minH:Number;
		
		//Max of coordinate horizontally;
		private var _maxW:Number;
		
		//Max of coordinate vertically;
		private var _maxH:Number;
		
		//The horizontal length of each segment;
		private var _dw:Number;
		
		//The vertical length of each segment;
		private var _dh:Number;
		
		//the heights of all vertices
		private var _heights:Array;
		
		private var _segmentsW:int;
		private var _segmentsH:int;
		private var _maxHeight:Number;
		
		public function Away3D4Terrain(material : MaterialBase, heightMap : BitmapData, width : Number = 1000, height : Number = 100, depth : Number = 1000, segmentsW : uint = 30, segmentsH : uint = 30, maxElevation:uint = 255, minElevation:uint = 0, smoothMap:Boolean = false)
		{
			super(material, heightMap, width, height, depth, segmentsW, segmentsH, maxElevation, minElevation, smoothMap);
			
			_segmentsW = segmentsW;
			_segmentsH = segmentsH;
			_maxHeight = maxElevation;
			
			var textureX:Number = width / 2;
			var textureY:Number = depth / 2;
			
			_minW = -textureX;
			_minH = -textureY;
			_maxW = textureX;
			_maxH = textureY;
			_dw = width / segmentsW;
			_dh = depth / segmentsH;
			
			_heights = [];
			for ( var ix:int = 0; ix <= _segmentsW; ix++ )
			{
				_heights[ix] = [];
				for ( var iy:int = 0; iy <= _segmentsH; iy++ )
				{
					_heights[ix][iy] = this.getHeightAt(_minW + (_dw * ix), _minH + (_dh * iy));
				}
			}
		}
		
		public function get minW():Number {
			return _minW;
		}
		public function get minH():Number {
			return _minH;
		}
		public function get maxW():Number {
			return _maxW;
		}
		public function get maxH():Number {
			return _maxH;
		}
		public function get dw():Number {
			return _dw;
		}
		public function get dh():Number {
			return _dh;
		}
		public function get sw():int {
			return _segmentsW;
		}
		public function get sh():int {
			return _segmentsH;
		}
		public function get heights():Array {
			return _heights;
		}
		public function get maxHeight():Number{
			return _maxHeight;
		}
		
	}
}