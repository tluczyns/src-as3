package treemap 
{
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class TreemapConstants 
	{
		static public const DIRECTION_VERTICAL:String = "directionVertical";
		
		static public const DIRECTION_HORIZONTAL:String = "directionHorizontal";
		
		
		static public const LAYOUT_SLICE_DICE:String = "layoutSliceDice";
		
		static public const LAYOUT_SQUARIFIED:String = "layoutSquarified";
		
		static public const LAYOUT_STRIP:String = "layoutStrip";
		
		
		
		static public function SORT_RANDOM( a:TreeMapItem, b:TreeMapItem ):Number
		{ 
			return Math.random() > .5 ? - 1 : 1;
		}
		
		static public function SORT_WEIGHT_ASCENDING( a:TreeMapItem, b:TreeMapItem ):Number
		{ 
			return a.weight <= b.weight ? -1 : 1;
		}
		
		static public function SORT_WEIGHT_DESCENDING( a:TreeMapItem, b:TreeMapItem ):Number
		{ 
			return a.weight >= b.weight ? -1 : 1;
		}
		
	}

}