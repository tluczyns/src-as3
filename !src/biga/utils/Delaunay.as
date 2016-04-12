package biga.utils
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * @website http://en.nicoptere.net
	 */
	public class Delaunay	
	{
		static public var EPSILON:Number = Number.MIN_VALUE;
		static public var SUPER_TRIANGLE_RADIUS:Number = 1000000000;
		
		private var indices:Vector.<int>;
		private var _circles:Vector.<Number>;
		
		public function Delaunay()
		{
		}
		public function compute( points:Vector.<Point> ):Vector.<int>
		{
			var nv:int = points.length;
			if (nv < 3) return null;
			
			var d:Number = SUPER_TRIANGLE_RADIUS;
			points.push( 	new Point( 0, -d ), new Point( d, d ), new Point( -d, d )	);
			
			indices = Vector.<int>( [ points.length-3, points.length-2, points.length-1 ] );
			circles = Vector.<Number>( [ 0, 0, d ] );
			
			var edgeIds:Vector.<int> = new Vector.<int>();
			var i:int, j:int, k:int, id0:int, id1:int, id2:int;
			for ( i = 0; i < nv; i++)
			{
				
				//if point tested is inside existing triangle
				for ( j = 0; j < indices.length; j+=3 )
				{
					if ( 	circles[ j + 2 ] > EPSILON 		&& 		circleContains( j, points[ i ] )	)
					{
						id0 = indices[ j ];
						id1 = indices[ j + 1 ];
						id2 = indices[ j + 2 ];
						edgeIds.push( id0, id1, id1, id2, id2, id0 );
						
						indices.splice( j, 3 );
						circles.splice( j, 3 );
						j -= 3;
					}
				}
				
				//removes duplicate edges
				for ( j = 0; j < edgeIds.length; j+=2 )
				{
					for ( k = j + 2; k < edgeIds.length; k+=2 )
					{
						if(	(	edgeIds[ j ] == edgeIds[ k ] && edgeIds[ j + 1 ] == edgeIds[ k + 1 ]	)
						||	(	edgeIds[ j + 1 ] == edgeIds[ k ] && edgeIds[ j ] == edgeIds[ k + 1 ]	)	)
						{
							edgeIds.splice( k, 2 );
							edgeIds.splice( j, 2 );
							j -= 2;
							k -= 2;
							if ( j < 0 ) break;
							if ( k < 0 ) break;
						}
					}
				}
				for ( j = 0; j < edgeIds.length; j+=2 )
				{
					indices.push( edgeIds[ j ], edgeIds[ j + 1 ], i );
					computeCircle( points, edgeIds[ j ], edgeIds[ j + 1 ], i );
				}
				edgeIds.length = 0;
				
			}
			id0 = points.length - 3;
			id1 = points.length - 2;
			id2 = points.length - 1;
			for ( i = 0; i < indices.length; i+= 3 )
			{
				if ( indices[ i ] == id0 || indices[ i ] == id1 || indices[ i ] == id2 
				||	 indices[ i + 1 ] == id0 || indices[ i + 1 ] == id1 || indices[ i + 1 ] == id2 
				||	 indices[ i + 2 ] == id0 || indices[ i + 2 ] == id1 || indices[ i + 2 ] == id2 )
				{
					indices.splice( i, 3 );
					circles.splice( i, 3 );
					i-=3;
					continue;
				}
			}
			
			points.pop();
			points.pop();
			points.pop();
			return indices;
		}
		
		private function circleContains( circleId:int, p:Point ):Boolean 
		{
			var dx:Number = circles[ circleId ] - p.x;
			var dy:Number = circles[ circleId + 1 ] - p.y;
			return circles[ circleId + 2 ] > dx * dx + dy * dy;
		}
		
		private function computeCircle( points:Vector.<Point>, id0:int, id1:int, id2:int ):void
		{
			var p0:Point = points[ id0 ];
			var p1:Point = points[ id1 ];
			var p2:Point = points[ id2 ];
			var A:Number = p1.x - p0.x;
			var B:Number = p1.y - p0.y;
			var C:Number = p2.x - p0.x;
			var D:Number = p2.y - p0.y;
			var E:Number = A * (p0.x + p1.x) + B * (p0.y + p1.y);
			var F:Number = C * (p0.x + p2.x) + D * (p0.y + p2.y);
			var G:Number = 2.0 * (A * (p2.y - p1.y) - B * (p2.x - p1.x));
			
			var x:Number = (D * E - B * F) / G;
			circles.push( x );
			
			var y:Number = (A * F - C * E) / G;
			circles.push( y );
			
			x -= p0.x;
			y -= p0.y;
			circles.push( x * x + y * y );
		}
		
		public function render( graphics:Graphics, points:Vector.<Point>, indices:Vector.<int> ):void
		{
			var id0:uint, id1:uint, id2:uint;
			for ( var i:int = 0; i < indices.length; i+=3 ) 
			{
				
				id0 = indices[ i ];
				id1 = indices[ i + 1 ];
				id2 = indices[ i + 2 ];
				graphics.moveTo( points[ id0 ].x, points[ id0 ].y );
				graphics.lineTo( points[ id1 ].x, points[ id1 ].y );
				graphics.lineTo( points[ id2 ].x, points[ id2 ].y );
				graphics.lineTo( points[ id0 ].x, points[ id0 ].y );
				
			}
		}
		
		public function get circles():Vector.<Number> 
		{
			return _circles;
		}
		
		public function set circles(value:Vector.<Number>):void 
		{
			_circles = value;
		}
		
	}
}
