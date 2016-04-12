package biga.shapes2d.curves 
{
	import flash.geom.Point;
	
	
    /** 
    * Catmull-Rom spline through N vertices.
    * @author makc
    * @license WTFPLv2, http://sam.zoy.org/wtfpl/
    */ 
    public class Cubic implements ICurve2D
    {
        
		static private var _precision:Number = .1;
		static private var _loop:Boolean = false;
		static private var _vertices:Vector.<Point>;
		
		static private var p0:Point;
		static private var p1:Point;
		static private var p2:Point;
		static private var t0:Number, t1:Number, t2:Number, t3:Number;
		
		public function Cubic( precision:Number = .1, loop:Boolean = false )
		{
			_precision = precision;
			_loop = loop;
		}
		
        static public function compute( vertices:Vector.<Point>, precision:Number = .1, loop:Boolean = false, target:Vector.<Point> = null, start:Number = 0, end:Number = 1 ):Vector.<Point>
		{
			Cubic.vertices = vertices;
			_precision = precision;
			_loop = loop;
			
            target ||= new Vector.<Point>();
			target.length = 0;
			
			var increment:Number = precision / vertices.length;
			var i:int, t:Number;
			for ( t = Math.min( start, end ); t < Math.max( start, end ); t+= increment ) 
			{
				
				target.push( getPointAt( t ) );
				
			}
			if ( _loop ) target.push( target[ 0 ].clone() );
			return target;
			
        }
		
		static public function getPointAt( t:Number, p:Point = null ):Point 
		{
			if ( vertices == null ) return null;
			
			p ||= new Point();
			
			var i:int = int( vertices.length * t );
			var delta:Number = 1 / ( vertices.length );
			t = ( t - ( i * delta ) ) / delta;
			
			p1 = vertices [ i ];
			
			if ( _loop )
			{
				
				p0 = midPoint( ( i - 1 ) < 0 ? vertices[ vertices.length - 1 ] : vertices[ ( i - 1 ) ], p1 );
				p2 = midPoint( p1, ( i + 1 ) < vertices.length ? vertices[ ( i + 1 ) ] : vertices[ 0 ] );
				
			}
			else
			{
				
				p0 = midPoint( ( i - 1 ) < 0 ? vertices[ 0 ] : vertices[ ( i - 1 ) ], p1 );
				p2 = midPoint( p1, ( i + 1 ) < vertices.length ? vertices[ ( i + 1 ) ] : vertices[ vertices.length - 1 ] );
				
			}
			
			
			t0 = 1 - t;
			t1 = t0 * t0;
			t2 = 2 * t * t0;
			t3 = t * t;
			
			p.x = t1 * p0.x + t2 * p1.x + t3 * p2.x;
			p.y = t1 * p0.y + t2 * p1.y + t3 * p2.y;
			
			return p;
		}
		
		
		static private function midPoint( p0:Point, p1:Point, dest:Point = null ) :Point
		{
			dest ||= new Point();
			dest.x = p0.x + ( p1.x - p0.x ) / 2;
			dest.y = p0.y + ( p1.y - p0.y ) / 2;
			return dest;
		}
		
		/* INTERFACE triga.curves.shapes.ICurve2D */
		
		public function set precision(value:Number):void 
		{
			_precision = value;
		}
		
		public function get precision():Number 
		{
			return _precision;
		}
		
		public function set loop(value:Boolean):void 
		{
			_loop = value;
		}
		
		public function get loop():Boolean 
		{
			return _loop;
		}
		
		static public function get vertices():Vector.<Point> 
		{
			return _vertices;
		}
		
		static public function set vertices(value:Vector.<Point>):void 
		{
			_vertices = value;
		}
		
		public function compute( vertices:Vector.<Point>, target:Vector.<Point> = null ):Vector.<Point> 
		{
			return Cubic.compute( vertices, _precision, _loop, target );
		}
		
        public function getPointAt( t:Number, p:Point = null ):Point
		{
			
			return Cubic.getPointAt( t, p ); 
			
		}
		
		public function range( start:Number, end:Number, target:Vector.<Point> = null ):Vector.<Point> 
		{
			target = Cubic.compute( vertices, _precision, _loop, target, start, end );
			if ( loop ) target.pop();
			return target;
		}
		
    }

}