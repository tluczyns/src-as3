package biga.utils 
{
	import biga.shapes2d.Circle;
	import biga.shapes2d.Triangle;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class ApolloniusCircles 
	{
		
		//http://en.wikipedia.org/wiki/Problem_of_Apollonius
		//http://mathworld.wolfram.com/ApolloniusProblem.html
		static public function apolloniusCircles( c0:Circle, c1:Circle, c2:Circle ):Vector.<Circle> 
		{
			
			var v:Vector.<Point>;
			var homotheticCenters:Vector.<Point> = new Vector.<Point>();
			
			v = CircleUtils.homotheticCenters( c0, c1 );
			if ( v != null ) homotheticCenters.push( v[0], v[1] );
			
			v = CircleUtils.homotheticCenters( c1, c2 );
			if ( v != null )homotheticCenters.push( v[0], v[1] );
			
			v = CircleUtils.homotheticCenters( c2, c0 );
			if ( v != null )homotheticCenters.push( v[0], v[1] );
			
			if ( homotheticCenters.length != 6 ) return null;//erf... 2 tangents are coincident
			
			var p:Point;
			var t0:Triangle, t1:Triangle;
			var angle:Number, dist0:Number, dist1:Number = 0, i:int, c:Circle;
			var radicalCenter:Point = CircleUtils.radicalCenter( c0, c1, c2 );
			var innerTangents:Vector.<Point> = new Vector.<Point>();
			var outerTangents:Vector.<Point> = new Vector.<Point>();
			var apolloniusCircles:Vector.<Circle> = new Vector.<Circle>();
			
			var lines:Vector.<Point> = Vector.<Point>( [	homotheticCenters[ 1 ], homotheticCenters[ 2 ],
															homotheticCenters[ 2 ], homotheticCenters[ 5 ],
															homotheticCenters[ 3 ], homotheticCenters[ 4 ],
															homotheticCenters[ 1 ], homotheticCenters[ 3 ]		] );
			
			for ( i = 0; i < lines.length; i+=2 )
			{
				p = CircleUtils.inversionPointFromPole( lines[ i ], lines[ i + 1 ], c0 );
				v = CircleUtils.lineCircleIntersection( p, radicalCenter, c0 );
				if ( v != null )
				{
					if ( v.length == 1 )
					{
						innerTangents.push( v[ 0 ] );
						outerTangents.push( v[ 0 ] );
					}
					else
					{
						dist0 = GeomUtils.distance( radicalCenter, v[ 0 ] );
						dist1 = GeomUtils.distance( radicalCenter, v[ 1 ] );
						innerTangents.push( ( dist0 < dist1 ) ? v[ 0 ] : v[ 1 ] );
						outerTangents.push( ( dist0 >= dist1 ) ? v[ 0 ] : v[ 1 ] );
					}
				}
				
				p = CircleUtils.inversionPointFromPole( lines[ i ], lines[ i + 1 ], c1 );
				v = CircleUtils.lineCircleIntersection( p, radicalCenter, c1 );
				if ( v != null )
				{
					if ( v.length == 1 )
					{
						innerTangents.push( v[ 0 ] );
						outerTangents.push( v[ 0 ] );
					}
					else
					{
						dist0 = GeomUtils.distance( radicalCenter, v[ 0 ] );
						dist1 = GeomUtils.distance( radicalCenter, v[ 1 ] );
						innerTangents.push( ( dist0 < dist1 ) ? v[ 0 ] : v[ 1 ] );
						outerTangents.push( ( dist0 >= dist1 ) ? v[ 0 ] : v[ 1 ] );
					}
				}
				
				p = CircleUtils.inversionPointFromPole( lines[ i ], lines[ i + 1 ], c2 );
				v = CircleUtils.lineCircleIntersection( p, radicalCenter, c2 );
				if ( v != null )
				{
					if ( v.length == 1 )
					{
						innerTangents.push( v[ 0 ] );
						outerTangents.push( v[ 0 ] );
					}
					else
					{
						dist0 = GeomUtils.distance( radicalCenter, v[ 0 ] );
						dist1 = GeomUtils.distance( radicalCenter, v[ 1 ] );
						innerTangents.push( ( dist0 < dist1 ) ? v[ 0 ] : v[ 1 ] );
						outerTangents.push( ( dist0 >= dist1 ) ? v[ 0 ] : v[ 1 ] );
					}
				}				
			}
			
			for ( i = 0; i < innerTangents.length; i += 3 )
			{
				switch( int( i/3 ) )
				{
					case 0:
						t0 = new Triangle( innerTangents[i], innerTangents[i+1], outerTangents[i+2] );
						t1 = new Triangle( outerTangents[i], outerTangents[i + 1], innerTangents[i + 2] );
					break;
					
					case 1:
						t0 = new Triangle( innerTangents[ i ], outerTangents[ i + 1 ], innerTangents[ i + 2 ] );
						t1 = new Triangle( outerTangents[ i ], innerTangents[ i + 1 ], outerTangents[ i + 2 ] );
					break;
					
					case 2:
						t0 = new Triangle( innerTangents[ i ], outerTangents[ i + 1 ], outerTangents[ i + 2 ] );
						t1 = new Triangle( outerTangents[ i ], innerTangents[ i + 1 ], innerTangents[ i + 2 ] );
					break;
					
					case 3:
						t0 = new Triangle( innerTangents[ i ], innerTangents[ i + 1 ], innerTangents[ i + 2 ] );
						t1 = new Triangle( outerTangents[ i ], outerTangents[ i + 1 ], outerTangents[ i + 2 ] );
					break;
					
				}
				try
				{
					c = TriangleUtils.circumcircle( t0 );
					if ( c != null ) apolloniusCircles.push( c );
				}catch( err:Error ) {}
				
				try
				{	
					c = TriangleUtils.circumcircle( t1 );
					if( c != null ) apolloniusCircles.push( c );
				}catch( err:Error ) {}
			}
			return apolloniusCircles;
		}
	}
}