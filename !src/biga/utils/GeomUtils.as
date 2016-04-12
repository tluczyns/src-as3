package biga.utils 
{
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class GeomUtils
	{
		static private var ip:Point = new Point();
		
		/**
		 * returns the angle between p0 and p1
		 * @param	p0
		 * @param	p1
		 * @return
		 */
		static public function angle( p0:Point, p1:Point ):Number
		{
			
			return Math.atan2( p1.y - p0.y, p1.x - p0.x );
			
		}
		
		/**
		 * returns the difference between two angles
		 * @param	a0 first angle
		 * @param	a1 second angle
		 * @return
		 */
		static public function angleDifference( a0:Number, a1:Number ):Number
		{
			
			var difference:Number = a1 - a0;
			while (difference < -Math.PI ) difference += Math.PI * 2;
			while (difference > Math.PI ) difference -= Math.PI * 2;
			return difference;
			
		}
		
		/**
		 * returns the slope between p0 and p1
		 * @param	p0
		 * @param	p1
		 * @return
		 */
		static public function slope( p0:Point, p1:Point ):Number
		{
			
			return ( p1.y - p0.y ) / ( p1.x - p0.x );
			
		}
		
		/**
		 * returns the distance between p0 & p1
		 * @param	p0
		 * @param	p1
		 * @return
		 */
		static public function distance( p0:Point, p1:Point ):Number
		{
			
			return Math.sqrt( squareDistance( p0.x, p0.y, p1.x, p1.y ) );
			
		}
		
		/**
		 * returns the square distance between 2 sets of x / y values
		 * @param	x0
		 * @param	y0
		 * @param	x1
		 * @param	y1
		 * @return
		 */
		static public function squareDistance( x0:Number, y0:Number, x1:Number, y1:Number ):Number
		{
			
			return ( x0 - x1 ) * ( x0 - x1 ) + ( y0 - y1 ) * ( y0 - y1 );
			
		}
		
		/**
		 * returns the value with a floating point the length of step
		 * @param	value 
		 * @param	step : number of figures after the point. 10 - .1, 100-0.01 etc
		 * @return
		 */
		static public function toFixed( value:Number, step:Number = 10 ):Number
		{
			return int( ( value * step ) ) / step ;
		}
		
		/**
		 * reutrn the value number of times the step fits entirely into the value without returning a float
		 * @param	value 
		 * @param	step 
		 * @return
		 */
		static public function snap( value:Number, step:Number ):Number
		{
			return int( value / step ) * step;
		}
		
		/**
		 * clamps a value between 2 values min / max
		 * @param	value
		 * @param	min
		 * @param	max
		 * @return
		 */
		static public function clamp( value:Number, min:Number, max:Number ):Number
		{
			return value < min ? min : ( value > max ? max : value );
		}
		
		/**
		 * linear interpolation of T between 2 values A and B
		 * @param	t
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function lerp( t:Number, a:Number, b:Number ):Number
		{
			
			var min:Number = ( a < b ) ? a : b;
			var max:Number = ( a > b ) ? a : b;
			return min + ( max - min ) * t;
			
		}
		
		/**
		 * normalizes the value between A and B
		 * @param	value
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function normalize( value:Number, a:Number, b:Number ):Number
		{
			
			var min:Number = ( a < b ) ? a : b;
			var max:Number = ( a > b ) ? a : b;
			return (value - min) / (max - min);
			
		}
		
		/**
		 * original function by Keith Paters: maps a value between 2 sets of values
		 * @param	value
		 * @param	min1
		 * @param	max1
		 * @param	min2
		 * @param	max2
		 * @return
		 */
		static public function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number
		{
			
			return lerp( normalize( value, min1, max1 ), min2, max2 );
			
		}
		
		/**************************************************************
		
				VECTOR UTILS
		
		**************************************************************/
		
		static public function determinant( p:Point, a:Point, b:Point ):Number
		{
			return ( ( a.x - b.x ) * ( p.y - b.y ) ) - ( ( p.x - b.x ) * ( a.y - b.y ) );
		}
		
		static public function isLeft( p:Point, a:Point, b:Point ):Boolean
		{
			return determinant( p, a, b ) >= 0;
		}
		
		static public function isRight( p:Point, a:Point, b:Point ):Boolean
		{
			return determinant( p, a, b ) <= 0;
		}
		
		static public function normalizeVector( p:Point ):Point
		{
			
			return new Point( p.x / p.length, p.y / p.length );
			
		}
		
		static public function dotProduct( u:Point, v:Point ):Number
		{
			
			return ( u.x * v.x + u.y * v.y );
			
		}
		
		static public function crossProduct( u:Point, v:Point ):Number
		{
			
			return ( u.x * v.y - u.y * v.x );
			
		}
		
		static public function center( p0:Point, p1:Point ):Point
		{
			return new Point( p0.x + ( p1.x - p0.x ) / 2, p0.y + ( p1.y - p0.y ) / 2 );
		}
		
		static public function leftNormal( p0:Point, p1:Point ):Point
		{
			return new Point( p0.x + ( p1.y - p0.y ), p0.y - ( p1.x - p0.x ) );
		}
		
		static public function rightNormal( p0:Point, p1:Point ):Point
		{
			return new Point( p0.x - ( p1.y - p0.y ), p0.y + ( p1.x - p0.x ) );
		}
		
		static public function project( p:Point, a:Point, b:Point ):Point
		{
			/*
			// fast & furious projection method
			// http://www.vcskicks.com/code-snippet/point-projection.php
			
			//	/!\	can return Null point... /!\	
			
			var m:Number = ( b.y - a.y ) / ( b.x - a.x );
			var m2:Number = m * m;
			var i:Number = a.y - ( m * a.x );
			
			return new Point( 	( m * p.y + p.x - m * i)  / ( m2 + 1), 
								( m2 * p.y + m * p.x + i) / ( m2 + 1)	 );
			*/
			
			// upgraded version by Fabien Bizot 
			// http://www.lafabrick.com/blog
			var len:Number = distance( a, b );
			var r:Number = (((a.y - p.y) * (a.y - b.y)) - ((a.x - p.x) * (b.x - a.x))) / (len * len);

			var px:Number = a.x + r * (b.x - a.x);
			var py:Number = a.y + r * (b.y - a.y);

			return new Point(px, py);
		}
		
		/**
		 * retrieves and returns the closest point in a point's list from a given point P
		 * @param	p		the point to test
		 * @param	list	the points list
		 * @return the closest point from P in the list 
		 */
		
		static public function getClosestPointInList( p:Point, list:Vector.<Point> ):Point
		{
			if ( list.length <= 0 ) return null;
			if ( list.length == 1 ) return list[ 0 ];
			
			var dist:Number;
			var min:Number = Number.POSITIVE_INFINITY;
			var closest:Point;
			for each ( var item:Point in list) 
			{
				if ( item == p )continue;
				if ( item.equals( p ) ) return item;
				dist = squareDistance( p.x, p.y, item.x, item.y );
				if ( dist < min ) 
				{
					min = dist;
					closest = item;
				}
			}
			return closest;
		}
		
		/*
		---------------------------------------------------------------------------
		http://keith-hair.net/blog/
		
		Returns the closest Point on Line "AB" to Point "p":
		p			-Point, the Point to constrain to the line.
		A			-Point, beginning Point of Line.
		B			-Point, ending Point of Line.
		as_seg	-Boolean, limits return Point between endpoints of A and B.
		
		----------------------------------------------------------------------------
		*/
		static public function constrain( p:Point, a:Point, b:Point ):Point
		{
			
			var dx:Number = b.x - a.x;
			var dy:Number = b.y - a.y;
			
			if (dx == 0 && dy == 0) 
			{
				return a;
			}
			else
			{
				var t:Number = ( (p.x - a.x) * dx + (p.y - a.y) * dy) / (dx * dx + dy * dy);
				
				t = Math.min( Math.max( 0, t ), 1 );
				
				return new Point(	a.x + t * dx, a.y + t * dy	);
				
			}
			
			return null;
			
		}
		
		
		/*
		---------------------------------------------------------------
		http://keith-hair.net/blog/
		
		Checks for intersection of Segment if as_seg is true.
		Checks for intersection of Line if as_seg is false.
		Return intersection of Segment AB and Segment EF as a Point
		Return null if there is no intersection
		
		---------------------------------------------------------------
		*/
		static public function lineIntersectLine (	A : Point, B : Point,
													E : Point, F : Point,
													ABasSeg : Boolean = true, EFasSeg : Boolean = true ) : Point
		{
			
			var a1:Number, a2:Number, b1:Number, b2:Number, c1:Number, c2:Number;
		 
			a1= B.y-A.y;
			b1= A.x-B.x;
			a2= F.y-E.y;
			b2= E.x-F.x;
		 
			var denom:Number=a1*b2 - a2*b1;
			if (denom == 0)
			{
				return null;
			}
			
			c1= B.x*A.y - A.x*B.y;
			c2 = F.x * E.y - E.x * F.y;
			
			ip = new Point();
			ip.x=(b1*c2 - b2*c1)/denom;
			ip.y=(a2*c1 - a1*c2)/denom;
			
			if ( A.x == B.x )
				ip.x = A.x;
			else if ( E.x == F.x )
				ip.x = E.x;
			if ( A.y == B.y )
				ip.y = A.y;
			else if ( E.y == F.y )
				ip.y = E.y;
			
			if ( ABasSeg )
			{
				if ( ( A.x < B.x ) ? ip.x < A.x || ip.x > B.x : ip.x > A.x || ip.x < B.x )
					return null;
				if ( ( A.y < B.y ) ? ip.y < A.y || ip.y > B.y : ip.y > A.y || ip.y < B.y )
					return null;
			}
			if ( EFasSeg )
			{
				if ( ( E.x < F.x ) ? ip.x < E.x || ip.x > F.x : ip.x > E.x || ip.x < F.x )
					return null;
				if ( ( E.y < F.y ) ? ip.y < E.y || ip.y > F.y : ip.y > E.y || ip.y < F.y )
					return null;
			}
			return ip;
		}
		
	}
}