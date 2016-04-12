package biga.utils 
{
	import biga.shapes2d.Circle;
	import biga.shapes2d.Edge;
	import biga.shapes2d.Triangle;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class TriangleUtils 
	{
		
		public function TriangleUtils(){}
		
		static public function bissector( triangle:Triangle, id:int ):Edge
		{
			
			var e:Edge;
			var angle:Number;
			var p0:Point, p1:Point;
			
			switch( id )
			{
				case 0:
				p0 = triangle.p0;
				angle = ( GeomUtils.angle( p0, triangle.p2 ) + GeomUtils.angle( p0, triangle.p1 ) ) * .5;
				break;
				
				case 1: 
				p0 = triangle.p1;
				angle = ( GeomUtils.angle( p0, triangle.p0 ) + GeomUtils.angle( p0, triangle.p2 ) ) * .5;
				break;
				
				case 2: 
				p0 = triangle.p2;
				angle = ( GeomUtils.angle( p0, triangle.p1 ) + GeomUtils.angle( p0, triangle.p0 ) ) * .5;
				break;
				
			}
			
			e = triangle.edges[ ( id + 1 ) % 3 ];//opposite side
			
			p1 = new Point( p0.x + Math.cos( angle ),
							p0.y + Math.sin( angle )	);
			
			return new Edge( p0, GeomUtils.lineIntersectLine( p0, p1, e.p0, e.p1, false, false ) );
			
		}
		
		static public function incircle( triangle:Triangle ):Circle
		{
			
			var a:Edge = bissector( triangle, 0 );
			var b:Edge = bissector( triangle, 1 );
			var c:Edge = bissector( triangle, 2 );
			
			var ip:Point = GeomUtils.lineIntersectLine( a.p0, a.p1, b.p0, b.p1 );
			
			var p0:Point = GeomUtils.project( ip, triangle.p0, triangle.p1 );
			var p1:Point = GeomUtils.project( ip, triangle.p1, triangle.p2 );
			var p2:Point = GeomUtils.project( ip, triangle.p2, triangle.p0 );
			
			var r0:Number = GeomUtils.distance( ip, p0 );
			var r1:Number = GeomUtils.distance( ip, p1 );
			var r2:Number = GeomUtils.distance( ip, p2 );
			
			return new Circle( ip.x, ip.y, Math.min( r0, r1, r2 ) );
			
		}
		
		
		static public function median( triangle:Triangle, id:int ):Edge
		{
			
			switch( id )
			{
				case 0: return new Edge( triangle.p0, triangle.edges[1].center );
				case 1: return new Edge( triangle.p1, triangle.edges[2].center );
				case 2: return new Edge( triangle.p2, triangle.edges[0].center );
			}
			return null;
			
		}
		
		static public function centroid( triangle:Triangle ):Point
		{
			return new Point( 	( triangle.p0.x + triangle.p1.x + triangle.p2.x ) * 1 / 3, 
								( triangle.p0.y + triangle.p1.y + triangle.p2.y ) * 1 / 3 );
			
		}
		// =
		static public function gravityCenter( triangle:Triangle ):Point
		{
			
			var a:Edge = median( triangle, 0 );
			var b:Edge = median( triangle, 1 );
			return GeomUtils.lineIntersectLine( a.p0, a.p1, b.p0, b.p1, false, false );
			
		}
		
		static public function altitude( triangle:Triangle, id:int ):Edge
		{
			
			switch( id )
			{
				case 0: return new Edge( triangle.p0, GeomUtils.project( triangle.p0, triangle.p1, triangle.p2 )  );
				case 1: return new Edge( triangle.p1, GeomUtils.project( triangle.p1, triangle.p0, triangle.p2 )  );
				case 2: return new Edge( triangle.p2, GeomUtils.project( triangle.p2, triangle.p0, triangle.p1 )  );
			}
			return null;
			
		}
		
		static public function orthocenter(triangle:Triangle):Point 
		{
			
			var a:Edge = altitude( triangle, 0 );
			var b:Edge = altitude( triangle, 1 );
			return GeomUtils.lineIntersectLine( a.p0, a.p1, b.p0, b.p1, false, false );
			
		}
		
		static public function circumcircle( triangle:Triangle ):Circle 
		{
			/*
			var e0:Edge = new Edge( triangle.edges[ 0 ].center,  triangle.p1 ).leftNormal;
			var e1:Edge = new Edge( triangle.edges[ 1 ].center,  triangle.p2 ).leftNormal;
			var ce:Point =  GeomUtils.lineIntersectLine( e0.p0, e0.p1, e1.p0, e1.p1, false, false );
			if ( ce != null ) return new Circle( ce.x, ce.y, GeomUtils.distance( ce, triangle.p0 ) );
			return null;
			//*/
			
			// upgraded version after
			// http://www.lafabrick.com/blog
			
			var a:Point = triangle.p0;
			var b:Point = triangle.p1;
			var c:Point = triangle.p2;
			
			var A:Number = b.x - a.x;
			var B:Number = b.y - a.y;
			var C:Number = c.x - a.x;
			var D:Number = c.y - a.y;
			
			var E:Number = A * (a.x + b.x) + B * (a.y + b.y);
			var F:Number = C * (a.x + c.x) + D * (a.y + c.y);
			var G:Number = 2.0 * (A * (c.y - b.y) - B * (c.x - b.x));
			
			var ce:Point = new Point( (D * E - B * F) / G, (A * F - C * E) / G );
			
			return new Circle( ce.x, ce.y, GeomUtils.distance( ce, a ) );
			
		}
		
		static public function eulerLine( triangle:Triangle ):Edge
		{
			
			var c:Circle = circumcircle( triangle );
			if ( c == null ) return null;
			var a:Point = new Point( c.x, c.y );
			var b:Point = orthocenter( triangle );
			
			return new Edge( a, b );
			
		}
		
		static public function eulerCircle( triangle:Triangle ):Circle 
		{
			
			var a:Point = altitude( triangle, 0 ).p1;
			var b:Point = altitude( triangle, 1 ).p1;
			var c:Point = altitude( triangle, 2 ).p1;
			
			return circumcircle( new Triangle( a, b, c ) );
			
		}
		
		static public function excircle( triangle:Triangle, id:int ):Circle 
		{
			var t:Triangle;
			var p:Point = triangle.edges[ id ].getPointAt( 2 );
			var b0:Edge = bissector( triangle, id );
			switch( id )
			{
				case 0:
				t = new Triangle( triangle.p1, p, triangle.p2 );
				break;
				
				case 1:
				t = new Triangle( triangle.p2, p, triangle.p0 );
				break;
				
				case 2:
				t = new Triangle( triangle.p0, p, triangle.p1 );
				break;
			}
			var b1:Edge = bissector( t, 0 );
			var ip:Point = GeomUtils.lineIntersectLine( b0.p0, b0.p1, b1.p0, b1.p1, false, false );
			var c:Circle = new Circle( ip.x, ip.y );
			
			c.radius = GeomUtils.distance( ip, GeomUtils.project( ip, t.p0, t.p1 ) );
			return c;
			
			
		}
		
		static public function angle( triangle:Triangle, id:int = 0 ):Number
		{
			
			var d0:Number = GeomUtils.distance( triangle.p0, triangle.p1 );
			var d1:Number = GeomUtils.distance( triangle.p1, triangle.p2 );
			var d2:Number = GeomUtils.distance( triangle.p2, triangle.p0 );
			
			switch( id )
			{
				//^A = arccos( (b² +c² -a²) / (2bc) )
				case 0:			return Math.acos( ( d1 * d1 + d2 * d2 - d0 * d0 ) / ( 2 * d1 * d2 ) );
				
				//^B = arccos( (a² +c² -b²) / (2ac) )
				case 1:			return Math.acos( ( d0 * d0 + d2 * d2 - d1 * d1 ) / ( 2 * d0 * d2 ) );
				
				//^C = arccos( (a² + b² -c²) / (2ab) )
				case 2:			return Math.acos( ( d0 * d0 + d1 * d1 - d2 * d2 ) / ( 2 * d0 * d1 ) );
				
			}
			
			return NaN;
		}
		
		static public function angles( triangle:Triangle ):Vector.<Number>
		{
			var d0:Number = GeomUtils.distance( triangle.p0, triangle.p1 );
			var d1:Number = GeomUtils.distance( triangle.p1, triangle.p2 );
			var d2:Number = GeomUtils.distance( triangle.p2, triangle.p0 );
			
			//^A = arccos( (b² +c² -a²) / (2bc) )
			var a:Number = Math.acos( ( d1 * d1 + d2 * d2 - d0 * d0 ) / ( 2 * d1 * d2 ) );
			
			//^B = arccos( (a² +c² -b²) / (2ac) )
			var b:Number = Math.acos( ( d0 * d0 + d2 * d2 - d1 * d1 ) / ( 2 * d0 * d2 ) );
			
			//^C = arccos( (a² + b² -c²) / (2ab) )
			var c:Number = Math.acos( ( d0 * d0 + d1 * d1 - d2 * d2 ) / ( 2 * d0 * d1 ) );
			
			return Vector.<Number>( [ a,b,c ] );
		}
		
		static public function lengths( triangle:Triangle ):Vector.<Number>
		{
			return Vector.<Number>( [ 
										GeomUtils.distance( triangle.p0, triangle.p1 ),
										GeomUtils.distance( triangle.p1, triangle.p2 ),
										GeomUtils.distance( triangle.p2, triangle.p0 )
									] );
		}
	}

}