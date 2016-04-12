package biga.shapes2d 
{
	import biga.utils.GeomUtils;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public final class Edge
	{
		private var _p0:Point;
		private var _p1:Point;
		private var _id:int;
		private var _angle:Number;
		private var _length:Number;
		
		public function Edge( p0:Point = null, p1:Point = null, id:int = -1 ) 
		{
			
			this.p0 = p0;
			this.p1 = p1;
			this.id = id;
			
			if ( p0 != null && p1 != null )
			{
				_angle = GeomUtils.angle( p0, p1 );
				_length = GeomUtils.distance( p0, p1 );
			}
		}
		
		public function get p0():Point { return _p0; }
		public function set p0(value:Point):void 
		{
			_p0 = value;
		}
		
		public function get p1():Point { return _p1; }
		public function set p1(value:Point):void 
		{
			_p1 = value;
		}
		
		public function get id():int { return _id; }
		public function set id(value:int):void 
		{
			_id = value;
		}
		
		public function intersect( e:Edge, asSegment0:Boolean = true, asSegment1:Boolean = true ):Point
		{
			
			return GeomUtils.lineIntersectLine( p0, p1, e.p0, e.p1, asSegment0, asSegment1 );
			
		}
		
		public function equals( e:Edge, sameDirection:Boolean = true ):Boolean
		{
			if ( sameDirection ) return p0.equals( e.p0 ) && p1.equals( e.p1 );
			
			return ( ( p0 == e.p0 && p1 == e.p1 ) || ( p0 == e.p1 && p1 == e.p0 ) );
		}
		
		public function getPointAt( t:Number ):Point
		{
			return new Point(	p0.x + Math.cos( angle ) * length * t, 
								p0.y + Math.sin( angle ) * length * t 	);
		}
		
		public function get center():Point
		{
			return new Point( p0.x + width * .5, p0.y + height * .5);
		}
		
		public function get angle():Number 
		{ 
			return GeomUtils.angle( p0, p1 ); 
		}
		
		public function get squareLength():Number
		{ 
			return GeomUtils.squareDistance( p0.x, p0.y, p1.x, p1.y ); 
		}
		
		public function get length():Number
		{ 
			return GeomUtils.distance( p0, p1 ); 
		}
		
		public function get width():Number 
		{	
			return p1.x - p0.x;		
		}
		
		public function get height():Number 
		{	
			return p1.y - p0.y;		
		}
		
		public function get leftNormal():Edge
		{ 
			
			return new Edge( p0, new Point( p0.x + height, p0.y - width ) );
			
		}
		
		public function get rightNormal():Edge
		{ 
			
			return new Edge( p0, new Point( p0.x - height, p0.y + width ) );
			
		}
		
		public function draw( graphics:Graphics = null ):void 
		{ 
			graphics.moveTo( p0.x, p0.y );
			graphics.lineTo( p1.x, p1.y );
		}
		
	}

}