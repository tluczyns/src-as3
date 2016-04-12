package biga.utils 
{
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * @website http://en.nicoptere.net
	 */
	public class Voronoi 
	{
		private var delaunay:Delaunay;
		
		public function compute( points:Vector.<Point> ):Vector.<Vector.<Point>>
		{
			delaunay ||= new Delaunay();
			
			var indices:Vector.<int> = delaunay.compute( points );
			var circles:Vector.<Number> = delaunay.circles;
			
			var i:int, j:int, k:int;
			
			var triangles:Vector.<Triangle> = new Vector.<Triangle>();
			var polygons:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
			var polygon:Vector.<Point> = new Vector.<Point>();
			
			for ( i = 0; i < indices.length; i+=3 ) 
			{
				
				triangles.push( new Triangle( indices[ i ], indices[ i + 1 ], indices[ i + 2 ], i ) );
				
			}
			
			for ( i = 0; i < points.length; i++ )
			{
				
				polygon.length = 0;
				
				for each (var t:Triangle in triangles ) 
				{
					if ( t.contains( i ) )
					{
						polygon.push( new Point( circles[ t.circleId ], circles[ t.circleId + 1 ] ) );
					}
				}
				
				if ( polygon.length < 2 ) continue;
				//computing the angles of the adjacent triagnles' circumcenters
				var angles:Vector.<Number> = new Vector.<Number>();
				for ( j = 0; j < polygon.length; j++) 
				{
					
					angles.push( Math.atan2( polygon[j].y - points[ i ].y, polygon[j].x - points[ i ].x ) + Math.PI * 2 );
					
				}
				//sorting the points of the voronoi cell clockwise
				for ( j = 0; j < polygon.length - 1; j++)
				{
					for ( k = 0; k < polygon.length - 1 - j; k++)
					{
						if (angles[k] > angles[k + 1] )
						{
							var polygon1:Point = polygon[k]; 
							polygon[k] = polygon[k + 1]; 
							polygon[k + 1] = polygon1;
							
							var tmp_angle:Number = angles[k]; 
							angles[k] = angles[k + 1]; 
							angles[k+1] = tmp_angle;
						}
					}
				}
				polygons.push( polygon.concat() );
				//renderPoly( graphics, polygon, 0x0066DD  );
			}
			return polygons;
		}
		
		public function render(graphics:Graphics, polygons:Vector.<Vector.<Point>> ):void 
		{
			var i:int, j:int;
			for ( i = 0; i < polygons.length; i++) 
			{
				var polygon:Vector.<Point> = polygons[ i ];
				graphics.moveTo( polygon[0].x, polygon[0].y );
				for ( j = 0; j < polygon.length; j++ )
				{
					graphics.lineTo( polygon[ j ].x, polygon[ j ].y );
				}
				graphics.lineTo( polygon[0].x, polygon[0].y );
			}
		}
		
	}

}

class Triangle
{
	public var id0:int;
	public var id1:int;
	public var id2:int;
	public var circleId:int;
	public function Triangle( id0:int, id1:int, id2:int, circleId:int )
	{
		this.id0 = id0;
		this.id1 = id1;
		this.id2 = id2;
		this.circleId = circleId;
	}
	public function contains(i:int):Boolean
	{
		return id0 == i || id1 == i || id2 == i;
	}
	
}