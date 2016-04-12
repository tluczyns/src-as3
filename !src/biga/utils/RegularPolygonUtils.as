package biga.utils 
{
	import biga.shapes2d.RegularPolygon;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class RegularPolygonUtils 
	{
		
		//http://mathworld.wolfram.com/RegularPolygon.html
		static public function edgeDistance( p:Point, polygon:RegularPolygon ):Number
		{
			
			var angle:Number = GeomUtils.angle( polygon, p );
			
			var a:Number = ( angle - polygon.rotation );
			
		 	while( a < 0 ) a += Math.PI * 2;
			
			a = a % polygon.centralAngle;
			
			var piBySide:Number = Math.PI / polygon.sides
			
		 	if ( a <= piBySide )
			{
				a = piBySide - a;
			}
			if ( a > piBySide && a <= Math.PI * 2 / polygon.sides)
			{
				a -= Math.PI * ( 1 / polygon.sides );
			}
			return polygon.inRadius / Math.cos( a );
			
		}
		
		static public function containsPoint( p:Point, polygon:RegularPolygon ):Boolean
		{
			var d:Number = GeomUtils.distance( p, polygon );
			if ( d > polygon.radius ) return false;
			if ( d > edgeDistance( p, polygon ) ) return false;
			return true;
		}
		
		static public function clone( polygon:RegularPolygon ):RegularPolygon
		{
			var p:RegularPolygon = new RegularPolygon( polygon.x, polygon.y, polygon.radius, polygon.sides );
			p.rotation = polygon.rotation;
			return p;
		}
		
		/**
		 * determine si un point est à l'intérieur du polygone
		 * @param	p
		 * @param	points the points of the polygon
		 * @return
		 */
		static public function contains( p:Point, polygon:RegularPolygon ):Boolean
		{
			
			p.x -= polygon.x;
			p.y -= polygon.y;
			
			var points:Vector.<Point> = polygon.points;
			
			var i:int, counter:int = 0;
			var xinters:Number = 0;
			var p1:Point ,p2:Point ;
			var n:int = points.length;
			
			p1 = points[0];
			for (i = 1; i <= n; i++) 
			{
				p2 = points[i % n];
				if ( p.y > ( ( p1.y < p2.y ) ? p1.y : p2.y ) )
				{
					if (p.y <= ( ( p1.y > p2.y ) ? p1.y : p2.y ) )
					{
						if (p.x <= ( ( p1.x > p2.x ) ? p1.x : p2.x ) )
						{
							if ( p1.y != p2.y ) 
							{
								xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
								if (p1.x == p2.x || p.x <= xinters)
								{
									counter++;
								}
							}
						}
					}
				}
				p1 = p2;
			}
			
			if (counter % 2 == 0)
			{
				return false;
			}
			return true;
		}
		
		static public function getClosestAnchor(p:Point, polygon:RegularPolygon):Point
		{
			
			var a:Number = GeomUtils.angle( polygon, p ) - polygon.rotation;
			while( a < 0 ) a += Math.PI * 2;
			var i:int =  int( ( a + polygon.centralAngle / 2 ) / polygon.centralAngle );
			return polygon.points[ i % polygon.points.length ];
			
		}
		
		static public function getClosestEdgeById(p:Point, polygon:RegularPolygon):int
		{
			
			var a:Number = GeomUtils.angle( polygon, p ) - polygon.rotation;
			while( a < 0 ) a += Math.PI * 2;
			return int( a / polygon.centralAngle );
			
		}
		
		static public function getClosestEdge(p:Point, polygon:RegularPolygon):Vector.<Point>
		{
			
			var i:int =  getClosestEdgeById( p, polygon );
			return Vector.<Point>( [
									polygon.points[ i % polygon.points.length ],
									polygon.points[ ( i + 1 ) % polygon.points.length ] 
									] );
			
		}
		
		static public function getClosestPoint( p:Point, polygon:RegularPolygon ):Point
		{
			var angle:Number = GeomUtils.angle( polygon, p );
			var d:Number = edgeDistance( p, polygon );
			return new Point( 	polygon.x + Math.cos( angle ) * d, 
								polygon.y + Math.sin( angle ) * d );
			
		}
		
		
		static public function sideCenters( polygon:RegularPolygon ):Vector.<Point>
		{
			var centers:Vector.<Point> = new Vector.<Point>();
			
			var angle:Number;
			var centralAngle:Number = polygon.centralAngle;
			angle = polygon.rotation + centralAngle / 2;
			for ( var i:int = 0; i < polygon.sides; i++ )
			{
				var p:Point = polygon.points[ i ];
				var np:Point = polygon.points[ ( i + 1 ) % polygon.points.length ];
				centers.push( new Point( p.x + ( np.x - p.x ) * .5, p.y + ( np.y - p.y ) * .5 ) );
			}
			return centers;
			
		}
		
		static public function spawn( poly:RegularPolygon, sides:int, ...args ):Vector.<RegularPolygon>
		{
			var polys:Vector.<RegularPolygon> = new Vector.<RegularPolygon>();
			
			var centers:Vector.<Point> = RegularPolygonUtils.sideCenters( poly );
			
			for ( var i:int = 0; i < poly.sides; i++ )
			{
				
				if ( args.length == 0 || args.lastIndexOf( i ) != -1 )
				{
					
					polys.push( spawnFromEdge( poly, i, sides ) );
					
				}
			}
			return polys;
		}
		
		static public function spawnFromEdge( poly:RegularPolygon, edgeId:int, sides:int, ...args ):RegularPolygon
		{
			
			var p:RegularPolygon = new RegularPolygon( poly.x, poly.y, poly.inRadius, sides );
			
			p.sideLength = poly.sideLength;
			
			p.x = poly.x + Math.cos( edgeId * ( poly.rotation + poly.centralAngle ) + ( poly.centralAngle * .5 ) ) * ( poly.inRadius + p.inRadius );// * poly.scaleX );
			p.y = poly.y + Math.sin( edgeId * ( poly.rotation + poly.centralAngle ) + ( poly.centralAngle * .5 ) ) * ( poly.inRadius + p.inRadius );// * poly.scaleY );
			var center:Point = getSideCenterById( edgeId, poly );
			
			p.rotation = GeomUtils.angle( poly, p );
			if ( p.sides % 2 == 0 ) p.rotation += p.centralAngle * .5;
			
			return p;
			
		}
		
		static private function getSideCenterById( id:int, polygon:RegularPolygon ):Point 
		{
			
			var p0:Point = polygon.points[ id % polygon.points.length ];
			var p1:Point = polygon.points[ ( id + 1 ) % polygon.points.length ];
			
			return new Point( GeomUtils.map( .5, 0, 1, p0.x, p1.x ), GeomUtils.map( .5, 0, 1, p0.y, p1.y ) );
			
		}
		
	}

}