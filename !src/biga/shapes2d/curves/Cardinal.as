package biga.shapes2d.curves 
{
	import flash.geom.Point;
	
	// forked from makc3d's Cardinal Splines Part 4
    
    /**
     * Exploring formula in Jim Armstrong "Cardinal Splines Part 4"
     * @see http://algorithmist.wordpress.com/2009/10/06/cardinal-splines-part-4/
     */
    public class Cardinal implements ICurve2D
    {
        
		static private var _precision:Number = .1;
		static private var _loop:Boolean = false;
		static private var _tension:Number = 1;
		static private var _vertices:Vector.<Point>;
		
		static private var p0:Point;
		static private var p1:Point;
		static private var p2:Point;
		static private var p3:Point;
		static private var t0:Number, t1:Number, t2:Number;
		
		public function Cardinal( precision:Number = .1, tension:Number = .1,loop:Boolean = false )
		{
			_precision = precision;
			_tension = tension;
			_loop = loop;
		}
		
        static public function compute( vertices:Vector.<Point>, precision:Number = .1, tension:Number = 1, loop:Boolean = false, target:Vector.<Point> = null, start:Number = 0, end:Number = 1 ):Vector.<Point>
		{
			Cardinal.vertices = vertices;
			_precision = precision;
			_tension = tension;
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
			
			
			
			t0 = ( -t * t * t + 2 * t * t - t);
			t1 = ( -t * t * t + t * t);
			t2 = (2 * t * t * t - 3 * t * t + 1);
			
            p.x = _tension * t0 * p0.x + _tension * t1 * p1.x + t2 * p1.x + _tension * (t * t * t - 2 * t * t + t) * p2.x + ( -2 * t * t * t + 3 * t * t) * p2.x +_tension * (t * t * t - t * t) * p3.x;
			p.y = _tension * t0 * p0.y + _tension * t1 * p1.y + t2 * p1.y + _tension * (t * t * t - 2 * t * t + t) * p2.y + ( -2 * t * t * t + 3 * t * t) * p2.y +_tension * (t * t * t - t * t) * p3.y;
			
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
		
		public function get tension():Number 
		{
			return _tension;
		}
		
		public function set tension(value:Number):void 
		{
			_tension = value;
		}
		
		public function compute( vertices:Vector.<Point>, target:Vector.<Point> = null ):Vector.<Point> 
		{
			return Cardinal.compute( vertices, precision, tension, loop, target );
		}
		
        public function getPointAt( t:Number, p:Point = null ):Point
		{
			
			return Cardinal.getPointAt( t, p ); 
			
		}
		
		public function range( start:Number, end:Number, target:Vector.<Point> = null ):Vector.<Point> 
		{
			target = Cardinal.compute( vertices, precision, tension, loop, target, start, end );
			if ( loop ) target.pop();
			return target;
		}
		
    }

}