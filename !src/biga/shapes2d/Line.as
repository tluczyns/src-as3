package biga.shapes2d 
{
	import biga.utils.GeomUtils;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class Line
	{
		
		private var _strokeWidth:Number = 0;
		private var _strokeColor:Number = 0x808080;
		private var _strokeAlpha:Number = 1;
		
		private var _start:Number = 0;
		private var _end:Number = 0;
		
		private var _angle:Number;
		private var _length:Number;
		private var _p0:Point;
		private var _p1:Point;
		
		public function Line( p0:Point, p1:Point ) 
		{
			this.p0 = p0;
			this.p1 = p1;
		}
		
		public function draw( graphics:Graphics ):void
		{
			
			graphics.moveTo( 	p0.x + Math.cos( angle ) * ( length * start ), 
								p0.y + Math.sin( angle ) * ( length * start ) );
			
			graphics.lineTo( 	p1.x + Math.cos( angle ) * ( length * end ), 
								p1.y + Math.sin( angle ) * ( length * end ) );
			
		}
		
		public function get p0():Point { return _p0; }
		
		public function set p0(value:Point):void 
		{
			_p0 = value;
			if ( p1 != null )
			{
				
				angle = GeomUtils.angle( p0, p1 );
				length = GeomUtils.distance( p0, p1 );
				
			}
		}
		
		public function get p1():Point { return _p1; }
		
		public function set p1(value:Point):void 
		{
			_p1 = value;
			if ( p1 != null )
			{
				
				angle = GeomUtils.angle( p0, p1 );
				length = GeomUtils.distance( p0, p1 );
				
			}
		}
		/**
		 * retourne un point de la ligne situe à T : 0 <= T <= 1 = sur le segment, T < 0 avant A, T > 1 apres B
		 * @param	t
		 * @return
		 */
		public function getPointAt( t:Number ):Point
		{
			return new Point( 	p0.x + Math.cos( angle ) * ( length * t ), 
								p0.y + Math.sin( angle ) * ( length * t ) );
		}
		
		
		public function get start():Number { return _start; }
		
		public function set start(value:Number):void 
		{
			_start = value;
		}
		
		public function get end():Number { return _end; }
		
		public function set end(value:Number):void 
		{
			_end = value;
		}
		
		public function get angle():Number { return _angle; }
		
		public function set angle(value:Number):void 
		{
			_angle = value;
		}
		
		public function get length():Number { return _length; }
		
		public function set length(value:Number):void 
		{
			_length = value;
		}
		
	}

}