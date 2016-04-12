package biga.utils 
{
	import biga.shapes2d.Arc;
	import biga.shapes2d.Circle;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class ArcUtils 
	{
		static public const EPSILON:Number = .0001;
		
		static private var pi:Number = Math.PI;
		static private var pi2:Number = pi * 2;
		static private var pi_2:Number = pi / 2;
		static private var pi_4:Number = pi / 4;
		/**
		 * initialises an arc after 2 points
		 * @param	arc
		 * @param	p0
		 * @param	p1
		 * @param	circle if not null, will clone the circles properties
		 */
		static public function init( arc:Arc, p0:Point, p1:Point, circle:Circle = null ):void
		{
			if ( circle != null )
			{
				arc.x = circle.x;
				arc.y = circle.y;
				arc.radius = circle.radius;
			}
			
			var a0:Number = GeomUtils.angle( arc, p0 );
			var a1:Number = GeomUtils.angle( arc, p1 );
			
			var max:Number = Math.max( a0, a1 );
			
			arc.startAngle = Math.min( a0, a1 );
			arc.arcLength = max - arc.startAngle;
			
			if ( arc.arcLength > pi + EPSILON )
			{
				invert( arc );
			}
			
		}
		/**
		 * returns a boolean to specify wether the point is on the arc segment
		 * @param	p
		 * @param	arc
		 * @return
		 */
		static public function isPointOnArc( p:Point, arc:Arc ):Boolean
		{
			var a:Number = GeomUtils.angle( arc, p );
			var b:Number = ( arc.startAngle + arc.arcLength );
			
			if ( a < 0  )a += pi2;
			if ( a >= arc.startAngle && a <= b ) return true;
			if( b >= pi2 && ( a >= 0 && a <= ( b-pi2 ) )  ) return true;
			
			return false;
		}
		/**
		 * inverts the arc 
		 * @param	arc
		 */
		static public function invert( arc:Arc ):void
		{
			var a:Number = arc.startAngle;
			arc.startAngle = ( arc.startAngle + arc.arcLength ) % pi2;
			arc.arcLength = pi2 - arc.arcLength;
			
		}
		
		static public function length( radius:Number, angle:Number ):Number { return radius * angle; }
		static public function angle( radius:Number, length:Number ):Number { return length / radius; }
		static public function radius( angle:Number, length:Number ):Number { return length / angle; }
		
	}

}