package biga.shapes2d 
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class Circle extends Point 
	{
		private var _radius:Number;
		
		/**
		 * data holder for a circle
		 * @param	x
		 * @param	y
		 * @param	radius
		 */
		public function Circle( x:Number = 0, y:Number = 0, radius:Number = 1 ) 
		{
			
			super( x, y );
			this._radius = radius;
			
		}
		
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void 
		{
			_radius = value;
		}
		
		public function draw( graphics:Graphics ):void
		{
			graphics.drawCircle( x, y, radius );
		}
		
	}

}