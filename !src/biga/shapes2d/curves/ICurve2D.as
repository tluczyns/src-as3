package biga.shapes2d.curves 
{
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public interface ICurve2D
	{
		
		function set precision( value:Number ):void;
		function get precision():Number;
		
		function set loop( value:Boolean ):void;
		function get loop():Boolean;
		
		function compute( vertices:Vector.<Point>, target:Vector.<Point> = null ):Vector.<Point>;
		function getPointAt( t:Number, p:Point = null ):Point;
		function range( start:Number, end:Number, target:Vector.<Point> = null ):Vector.<Point>;
		
	}
	
}