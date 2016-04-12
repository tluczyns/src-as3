package treemap.layouts 
{
	import treemap.TreeMapItem;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public interface ILayoutManager 
	{
		
		function getOccupiedRect():Rectangle;
		
		function createMap( list:Vector.<TreeMapItem> ):Vector.<TreeMapItem>;
		
		function get items():Vector.<TreeMapItem>;
		function set items(value:Vector.<TreeMapItem>):void;
		
		function get x():Number;
		function set x( value:Number ):void;
		
		function get y():Number;
		function set y( value:Number ):void;
		
		
	}
	
}