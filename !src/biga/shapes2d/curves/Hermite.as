package biga.shapes2d.curves 
{
	import flash.geom.Point;
	
	
    /** 
    * Catmull-Rom spline through N vertices.
    * @author makc
    * @license WTFPLv2, http://sam.zoy.org/wtfpl/
    */ 
    public class Hermite implements ICurve2D
    {
        
		static private var _precision:Number = .1;
		static private var _loop:Boolean = false;
		static private var _vertices:Vector.<Point>;
		
		static private var p0:Point;
		static private var p1:Point;
		static private var p2:Point;
		static private var p3:Point;
		
		public function Hermite( precision:Number = .1, loop:Boolean = false )
		{
			_precision = precision;
			_loop = loop;
		}
		
        static public function compute( vertices:Vector.<Point>, precision:Number = .1, loop:Boolean = false, target:Vector.<Point> = null, start:Number = 0, end:Number = 1 ):Vector.<Point>
		{
			Hermite.vertices = vertices;
			_precision = precision;
			_loop = loop;
			
			var i:int, t:Number;
			
            target ||= new Vector.<Point>();
			target.length = 0;
			
			var increment:Number = precision / vertices.length;
			for ( t = Math.min( start, end ); t < Math.max( start, end ); t+= increment ) 
			{
				target.push( getPointAt( t ) );
			}
			if ( loop ) target.push( target[ 0 ] );
			return target;
			
        }
		
		static public function getPointAt( t:Number, p:Point = null ):Point 
		{
			if ( vertices == null ) return null;
			
			p ||= new Point();
			
			var i:int = int( vertices.length * t );
			var delta:Number = 1 / ( vertices.length );
			t = ( t - ( i * delta ) ) / delta;
			
			if ( !_loop )
			{
				p0 = vertices [Math.max( 0,(i - 1))];
				p1 = vertices [ i ];
				p2 = vertices [ Math.min( i + 1, vertices.length -1 ) ];
				p3 = vertices [ Math.min( i + 2, vertices.length -1 ) ];
			}
			else
			{
				p0 = vertices [ (i - 1) < 0 ? ( vertices.length - 1 ) : (i - 1) ];
				p1 = vertices [ i ];
				p2 = vertices [ ( i + 1 ) % vertices.length ];
				p3 = vertices [ ( i + 2 ) % vertices.length ];
			}
			
			var t1:Number = t * t;
			var t2:Number = t1 * t;
		   
			p.x = (2 * t2  - 3 * t1 + 1) * p1.x +(t2 - 2 * t1 + t) * p0.x + (-2 * t2 + 3 * t1) * p2.x + (t2 - t1) * p3.x;
			p.y = (2 * t2  - 3 * t1 + 1) * p1.y +(t2 - 2 * t1 + t) * p0.y + (-2 * t2 + 3 * t1) * p2.y + (t2 - t1) * p3.y;
			
			return p;
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
			return Hermite.compute( vertices, precision, loop, target );
		}
		
        public function getPointAt( t:Number, p:Point = null ):Point
		{
			
			return Hermite.getPointAt( t, p ); 
			
		}
		
		public function range( start:Number, end:Number, target:Vector.<Point> = null ):Vector.<Point> 
		{
			target = Hermite.compute( vertices, precision, loop, target, start, end );
			if ( loop ) target.pop();
			return target;
		}
		
    }

}