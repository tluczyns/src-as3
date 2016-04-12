package biga.utils 
{
	import biga.shapes2d.Circle;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class CircleUtils 
	{
		
		static private var pi:Number = Math.PI;
		static private var pi2:Number = pi * 2;
		static private var halfPi:Number = pi / 2;
		static private var pi4:Number = pi / 4;
		
		
		/**
		 * returns a true if the point is incside the circle, false otherwise
		 * @param	p	
		 * @param	circle
		 * @return
		 */
		static public function containsPoint( p:Point, circle:Circle ):Boolean
		{
			return GeomUtils.distance( circle, p ) < circle.radius;
		}
		
		/**
		 * returns a true if circle0 is incside circle1, false otherwise
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function containsCircle( circle0:Circle, circle1:Circle ):Boolean
		{
			var R:Number = Math.max( circle0.radius, circle1.radius );
			var r:Number = Math.min( circle0.radius, circle1.radius );
			
			return GeomUtils.distance( circle0, circle1 ) < ( R - r );
		}
		
		/**
		 * returns the closest point to P on the circle circle
		 * @param	p
		 * @param	circle
		 * @return
		 */
		static public function closestPointOnCircle( p:Point, circle:Circle ):Point
		{
			
			var angle:Number = GeomUtils.angle( circle, p );
			return setPointAtAngle( angle, circle );
			
		}
		/**
		 * places a point at a given angle on the circle
		 * @param	angle
		 * @param	circle
		 * @return
		 */
		static public function setPointAtAngle( angle:Number, circle:Circle ):Point
		{
			
			return new Point( 	circle.x + Math.cos( angle ) * circle.radius, 
								circle.y + Math.sin( angle ) * circle.radius	);
			
		}
		/**
		 * returns the distance between 2 circles
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function circlesDistance( circle0:Circle, circle1:Circle ):Number
		{
			
			var d:Number = GeomUtils.distance( circle0, circle1 ) - ( circle0.radius + circle1.radius );
			return d;
			
		}
		/**
		 * returns the two end points of the distance segment between 2 circles
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function circlesDistanceSegment( circle0:Circle, circle1:Circle ):Vector.<Point>
		{
			
			var angle:Number = GeomUtils.angle( circle0, circle1 );
			return Vector.<Point>( [ 	closestPointOnCircle( circle0, circle1 ),
										closestPointOnCircle( circle1, circle0 ) ] );
			
		}
		
		// http://htmlcoderhelper.com/find-a-tangent-point-on-circle/
		/**
		 * returns 0, 1 or 2 points of tangency of a given point P onto the circle
		 * @param	p
		 * @param	circle
		 * @return
		 */
		static public function tangentsToPoint( p:Point, circle:Circle ):Vector.<Point>
		{
			
			var angle:Number = GeomUtils.angle( circle, p );
			var distance:Number = GeomUtils.distance( circle, p );
			
			if ( distance < circle.radius )
			{
				return null;
			}
			else if ( distance == circle.radius )
			{
				return Vector.<Point>( [ new Point( circle.x + Math.cos( angle ) * distance, circle.y + Math.sin( angle ) * distance ) ] );
			}
			else
			{
				
				var alpha:Number = angle + halfPi - Math.asin( circle.radius / distance );
				var beta:Number  = angle - halfPi + Math.asin( circle.radius / distance );
				
				return Vector.<Point>( [ 	new Point( 	circle.x + Math.cos( alpha ) * circle.radius, 
														circle.y + Math.sin( alpha ) * circle.radius ),
														
											new Point( 	circle.x + Math.cos( beta ) * circle.radius, 
														circle.y + Math.sin( beta ) * circle.radius	)	] );
				
			}
			return null;
		}
		
		//http://mathworld.wolfram.com/Circle-CircleTangents.html
		//http://mathworld.wolfram.com/EyeballTheorem.html
		/**
		 * return 2 sets of 2 points located on the tangency points of the circle0 onto circle1. 
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function tangentsToCircle( circle0:Circle, circle1:Circle ):Vector.<Point>
		{
			
			var R:Number = Math.max( circle0.radius, circle1.radius );
			var r:Number = Math.min( circle0.radius, circle1.radius );
			
			var p0:Point, p1:Point;
			var alpha:Number, beta:Number;
			
			if ( R == r ) //circles have same size: tangents are parallel
			{
				
				p0 = circle0;
				p1 = circle1;
				alpha = beta = GeomUtils.angle( p0, p1 );
				alpha -= halfPi;
				beta += halfPi;
				
			}
			else
			{
				var dr:Number = ( R - r );
				
				p0 = R == circle0.radius ? circle0 : circle1;
				p1 = r == circle0.radius ? circle0 : circle1;
				
				var c:Circle = new Circle( p0.x, p0.y, dr );
				
				var projection:Vector.<Point> = tangentsToPoint( p1, c );
				
				if ( projection == null ) return null;
				
				alpha 	= GeomUtils.angle( c, projection[ 0 ] );
				beta	= GeomUtils.angle( c, projection[ 1 ] );
				
			}
			
			return Vector.<Point>( [ 	new Point( 	p0.x + Math.cos( alpha ) * R, p0.y + Math.sin( alpha ) * R ),
													
										new Point( 	p1.x + Math.cos( alpha ) * r, p1.y + Math.sin( alpha ) * r ),
													
										new Point( 	p0.x + Math.cos( beta ) * R, p0.y + Math.sin( beta ) * R ),
													
										new Point( 	p1.x + Math.cos( beta ) * r, p1.y + Math.sin( beta ) * r )		] );
				
			
		}
		
		//http://mathworld.wolfram.com/Circle-CircleIntersection.html
		/**
		 * return the chord of the circle-circle intersection between circle0 and circle1
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function circlesIntersection( circle0:Circle, circle1:Circle ):Vector.<Point>
		{
			
			var R:Number = circle0.radius;
			var r:Number = circle1.radius;
			var d:Number = GeomUtils.distance( circle0, circle1 );
			
			if ( d > ( R + r ) ) return null;
			
			var baseRadius:Number = ( ( d * d ) - ( r * r ) + ( R * R ) ) / ( 2 * d );
			
			var radius:Number = 1 / d * Math.sqrt( ( -d + r - R ) * ( -d - r + R ) * ( -d + r + R ) * ( d + r + R ) ) * .5;
			
			if ( radius <= 0 ) return null;
			
			var angle:Number = GeomUtils.angle( circle0, circle1 );
			
			return Vector.<Point>( [ 	new Point( 	circle0.x + Math.cos( angle ) * baseRadius + Math.cos( angle + halfPi ) * radius, 
													circle0.y + Math.sin( angle ) * baseRadius + Math.sin( angle + halfPi ) * radius	),
														
										new Point( 	circle0.x + Math.cos( angle ) * baseRadius + Math.cos( angle - halfPi ) * radius, 
													circle0.y + Math.sin( angle ) * baseRadius + Math.sin( angle - halfPi ) * radius	) ] );
			
			return null;
		}
		
		
		//http://mathworld.wolfram.com/Circle-LineIntersection.html
		/**
		 * returns 0, 1 or 2 points of intersection between the line defined by startPoint/endPoint and the circle
		 * @param	startPoint
		 * @param	endPoint
		 * @param	circle
		 * @return
		 */
		static public function lineCircleIntersection( startPoint:Point, endPoint:Point, circle:Circle ):Vector.<Point>
		{
			
			var p0:Point = new Point( startPoint.x - circle.x, startPoint.y - circle.y );
			var p1:Point = new Point( endPoint.x - circle.x, endPoint.y - circle.y );
			
			var r:Number = circle.radius;
			var dx:Number = p1.x - p0.x;
			var dy:Number = p1.y - p0.y;
			
			var dr:Number = Math.sqrt( dx * dx + dy * dy );
			var dr2:Number = dr * dr;
			var D:Number = ( p0.x * p1.y ) - ( p1.x * p0.y );
			var discriminant:Number = ( r * r ) * dr2 - ( D * D );
			
			if ( discriminant < 0 ) return null;
			
			var sqrtDiscriminant:Number = Math.sqrt( discriminant );
			
			var x:Number = (  D * dy + ( ( dy < 0 ) ? -1 : 1 ) * dx * sqrtDiscriminant ) / dr2;
			var y:Number = ( -D * dx + ( ( dy < 0 ) ? -dy : dy ) * sqrtDiscriminant ) / dr2;
			
			var ips:Vector.<Point> = Vector.<Point>( [ new Point( x + circle.x, y + circle.y ) ] );
			
			if ( discriminant == 0 ) return ips;
			
			if ( discriminant > 0 )
			{
				x = (  D * dy - ( ( dy < 0 ) ? -1 : 1 ) * dx * sqrtDiscriminant ) / dr2;
				y = ( -D * dx - ( ( dy < 0 ) ? -dy : dy ) * sqrtDiscriminant ) / dr2;
				ips.push( new Point( x + circle.x, y + circle.y ) );
			}
			
			return ips;
		}
		
		
		//http://www.experts-exchange.com/Programming/Game/AI_Physics/Q_24977935.html
		/**
		 * returns 0, 1 or 2 points of intersection between the segment defined by startPoint/endPoint and the circle
		 * @param	startPoint
		 * @param	endPoint
		 * @param	circle
		 * @return
		 */
		static public function segmentCircleIntersection( startPoint:Point, endPoint:Point, circle:Circle ) :Vector.<Point>
		{
			
			var ips:Vector.<Point> = new Vector.<Point>();
			var a:Number, b:Number, c:Number, bb4ac:Number;
			
			var dp:Point = new Point( endPoint.x - startPoint.x, endPoint.y - startPoint.y );
			
			a = dp.x * dp.x + dp.y * dp.y;
			b = 2 * (dp.x * (startPoint.x - circle.x) + dp.y * (startPoint.y - circle.y));
			c = circle.x * circle.x + circle.y * circle.y;
			c += startPoint.x * startPoint.x + startPoint.y * startPoint.y;
			c -= 2 * (circle.x * startPoint.x + circle.y * startPoint.y);
			c -= circle.radius * circle.radius;
			
			bb4ac = b * b - 4 * a * c;

			if ( ( ( a < 0 ) ? -a : a ) < Number.MIN_VALUE || bb4ac < 0 ) return null;
			
			var mu1:Number, mu2:Number;
			mu1 = (-b + Math.sqrt(bb4ac)) / (2 * a);
			mu2 = (-b - Math.sqrt(bb4ac)) / (2 * a);
			
			if ((mu1 < 0 || mu1 > 1) && (mu2 < 0 || mu2 > 1)) return null;
			
			var p1:Point = new Point( startPoint.x + ((endPoint.x - startPoint.x ) * mu1), startPoint.y + ((endPoint.y - startPoint.y) * mu1) );
			var p2:Point = new Point( startPoint.x + ((endPoint.x - startPoint.x ) * mu2), startPoint.y + ((endPoint.y - startPoint.y) * mu2) );
			
			if (mu1 > 0 && mu1 < 1 && (mu2 < 0 || mu2 > 1)) 
			{
				ips.push( p1 );
				return ips;
			}
			if (mu2 > 0 && mu2 < 1 && (mu1 < 0 || mu1 > 1)) 
			{
				ips.push( p2 );
				return ips;
			}
			if (mu1 > 0 && mu1 < 1 && mu2 > 0 && mu2 < 1)
			{
				if (mu1 == mu2)
				{
					ips.push( p1 );
				}
				else
				{
					ips.push(  p1, p2 );
				}
				return ips;
			}
			
			return null;
		}
		
		//http://mathworld.wolfram.com/HomotheticCenter.html
		/**
		 * return the homothetic centers of 2 circles
		 * @param	circle0
		 * @param	circle1
		 * @return
		 */
		static public function homotheticCenters( circle0:Circle, circle1:Circle ):Vector.<Point>
		{
			
			var p0:Point = circle0.clone();
			var p1:Point = circle1.clone();
			
			p0.x += circle0.radius;
			p1.x += circle1.radius;
			var externalCenter:Point = GeomUtils.lineIntersectLine( circle0, circle1, p0, p1, false, false );
			
			p0.x -= circle0.radius * 2;
			var internalCenter:Point = GeomUtils.lineIntersectLine( circle0, circle1, p0, p1, false, false );
			
			if ( internalCenter == null || externalCenter == null ) return null;
			return Vector.<Point>( [ internalCenter, externalCenter ] );
			
		}
		
		//http://mathworld.wolfram.com/RadicalLine.html
		/**
		 * computes the radical line of 2 circles, length is for decoration purpose
		 * @param	circle0
		 * @param	circle1
		 * @param	length
		 * @return
		 */
		static public function radicalLine( circle0:Circle, circle1:Circle, length:Number = -1 ) :Vector.<Point>
		{
			var r0:Number = circle0.radius;
			var r1:Number = circle1.radius;
			var d:Number = GeomUtils.distance( circle0, circle1 );
			var angle:Number = GeomUtils.angle( circle0, circle1 );
			
			var d0:Number = ( ( d * d ) + ( r0 * r0 ) - ( r1 * r1 ) ) / ( d * 2 );
			
			if ( length < 0 ) length = d0;
			
			var p:Point =	new Point(  circle0.x + Math.cos( angle ) * d0, 
										circle0.y + Math.sin( angle ) * d0 );
			return Vector.<Point>( [
										new Point(  p.x + Math.cos( angle + Math.PI /2 ) * length, 
													p.y + Math.sin( angle + Math.PI /2 ) * length ),
										new Point(  p.x + Math.cos( angle - Math.PI /2 ) * length, 
													p.y + Math.sin( angle - Math.PI /2 ) * length )
									] );
		}
		
		//http://mathworld.wolfram.com/RadicalCenter.html
		/**
		 * returns the radical center ; the intersection point of 2 of the radical lines
		 * @param	circle0
		 * @param	circle1
		 * @param	circle2
		 * @return
		 */
		static public function radicalCenter( circle0:Circle, circle1:Circle, circle2:Circle ) :Point
		{
			
			var rl0:Vector.<Point> = radicalLine( circle0, circle1 );
			var rl1:Vector.<Point> = radicalLine( circle0, circle2 );
			return GeomUtils.lineIntersectLine( rl0[0], rl0[1], rl1[0], rl1[1], false, false );
			
		}
		
		//http://mathworld.wolfram.com/Inversion.html
		/**
		 * find the inverse point of a point onto the circle
		 * @param	p
		 * @param	circle
		 * @return
		 */
		static public function inversionPoint( p:Point, circle:Circle ):Point
		{
			
			var s:Number = GeomUtils.distance( circle, p );
			var a:Number = GeomUtils.angle( circle, p );
			var radius:Number = ( circle.radius * circle.radius ) / s;
			
			return new Point( 	circle.x + Math.cos( a ) * radius,
								circle.y + Math.sin( a ) * radius	);
			
			
		}
		
		//http://mathworld.wolfram.com/Polar.html
		/**
		 * returns the 2 anchors of the pole line from a given point onto a circle. length is for decoration purpose
		 * @param	p
		 * @param	circle
		 * @param	length
		 * @return
		 */
		static public function poleFromPoint( p:Point, circle:Circle, length:Number = 1 ):Vector.<Point>
		{
			
			var angle:Number = GeomUtils.angle( circle, p );
			var d:Number = GeomUtils.distance( circle, p );
			var p:Point =	new Point(  circle.x + Math.cos( angle ) * d, 
										circle.y + Math.sin( angle ) * d );
			return Vector.<Point>( [
										new Point(  p.x + Math.cos( angle + Math.PI /2 ) * length, 
													p.y + Math.sin( angle + Math.PI /2 ) * length ),
										new Point(  p.x + Math.cos( angle - Math.PI /2 ) * length, 
													p.y + Math.sin( angle - Math.PI /2 ) * length )
									] );
			
		}
		
		//http://mathworld.wolfram.com/Polar.html
		/**
		 * returns the inverse point of the orthoProjection of the center of the circle onto the pole
		 * @param	p0
		 * @param	p1
		 * @param	circle
		 * @return
		 */
		static public function inversionPointFromPole( p0:Point, p1:Point, circle:Circle ):Point
		{
			
			var ip:Point = GeomUtils.project( circle, p0, p1 );
			if ( containsPoint( ip, circle ) )return ip;
			return inversionPoint( ip, circle );
			
		}
		
		
		static public function circumference( radius:Number ):Number { return pi2 * radius; }
		
	}

}