package net.nicoptere.stroke
{
	import flash.geom.Point;
	/**
	 * @author nicoptere
	 */
	public class Quad 
	{
		
		public var id:int = -1;
		public var u0:Number = 0;
		public var u1:Number = 0;
		public var vectors:Vector.<Point>;
		
		public function Quad( v0:Point, v1:Point, v2:Point, v3:Point, _u0:Number = 0, _u1:Number = 0 ) 
		{
			
			vectors = Vector.<Point>( [ v0, v1, v2, v3 ] );
			u0 = _u0;
			u1 = _u1;
			
		}
	}
}