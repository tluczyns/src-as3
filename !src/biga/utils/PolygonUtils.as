package biga.utils 
{
	import biga.shapes2d.RegularPolygon;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class PolygonUtils 
	{
		
		
		
		/*
		static public function closestPointOnPoly( polygon:Point, p:Point):Point 
		{
			
			var a:Number = GeomUtils.angle( polygon, p );
			var d:Number = getCenterToEdgeDistance( a );
			return new Point(  	x + Math.cos( a ) * d,
								y + Math.sin( a ) * d  	);
			
		}
		//http://mathworld.wolfram.com/RegularPolygon.html
		static public function getEdgeDistance( angle:Number, polygon:RegularPolygon ):Number
		{
			if ( polygon.sides == 1) return polygon.radius;
			
			angle -= polygon.rotation;
		 	var a:Number = ( angle - ( polygon.rotation / 180 * Math.PI ) );
		 	while (a < 0 ) a += Math.PI * 2;
			
			var pibySides:Number = Math.PI / polygon.sides;
			var pi2bySides:Number =  Math.PI * 2 / polygon.sides;
			
			a = a % pi2bySides;
		 	
			if (a >= 0 && a <= pibySides ) a = pibySides - a;
			
			if (a > Math.PI / polygon.sides && a <= pi2bySides ) a = a - Math.PI * 1 / polygon.sides;
		 	
			return _radius * Math.cos( Math.PI / polygon.sides ) / Math.cos( a );
			
		}
		*/
		/**
		 * determine si un point est à l'intérieur du polygone
		 * @param	p
		 * @param	points the points of the polygon
		 * @return
		 */
		/*
		static public function contains( p:Point, points:Vector.<Point> ):Boolean
		{
			p.x -= x;
			p.y -= y;
			var i:int, counter:int = 0;
			var xinters:Number = 0;
			var p1:Point ,p2:Point ;
			var n:int = _points.length;
			
			p1 = _points[0];
			for (i = 1; i <= n; i++) 
			{
				p2 = _points[i % n];
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
		*/
		static public function convexHull( original:Vector.<Point> ):Vector.<Point>
		{
			var points:Vector.<Point> = original.concat();
			points.sort( xSort );
			
			var angle:Number = Math.PI / 2;
			
			var point:Point = points[ 0 ];
			
			var hull:Array = [];
			
			
			while ( point != hull[ 0 ] )
			{
				
				hull.push( point );
				
				var bestAngle:Number = Number.MAX_VALUE;
				var bestIndex:int;
				
				for (var i:int = 0; i < points.length; i++)
				{
					
					var testPoint:Point = points[i] as Point;
					if (testPoint == point)
					{
						continue;
					}
					
					var dx:Number = testPoint.x - point.x;
					var dy:Number = testPoint.y - point.y;
					
					var testAngle:Number = Math.atan2(dy,dx);
					testAngle -= angle;
					while (testAngle < 0)
					{
						testAngle += Math.PI * 2;
					}
					
					if ( testAngle < bestAngle ) 
					{
						bestAngle = testAngle;
						bestIndex = i;
					}
					
				}
				point = points[bestIndex];
				angle += bestAngle;
				
			}
			
			return Vector.<Point>( hull );
		}
		
		static private function xSort( a:Point, b:Point):Number
		{
			return a.x < b.x ? -1 : 1;
		}

		
	}

}