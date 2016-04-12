package biga.shapes2d
{
	import biga.utils.GeomUtils;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class Triangle
	{
		
		private var _p0:Point;
		private var _p1:Point;
		private var _p2:Point;
		
		private var _edges:Vector.<Edge>;
		
		public function Triangle( p0:Point = null, p1:Point = null, p2:Point = null ) 
		{
			
			_p0 = ( p0 == null ) ? new Point() : p0;
			_p1 = ( p1 == null ) ? new Point() : p1;
			_p2 = ( p2 == null ) ? new Point() : p2;
			
			_edges = Vector.<Edge>( [	new Edge( p0, p1 ),
										new Edge( p1, p2 ),
										new Edge( p2, p0 ) 	] );
			
		}
		
		public function contains( p:Point ):Boolean
		{
			
			return (	    GeomUtils.isLeft( p, p0, p1 ) 
						== 	GeomUtils.isLeft( p, p1, p2 )
						== 	GeomUtils.isLeft( p, p2, p0 )
						== 	culling  );
			
		}
		
		public function get culling():Boolean 
		{ 
			return GeomUtils.determinant( p0, p1, p2 ) >= 0; 
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
		
		public function get p2():Point { return _p2; }
		
		public function set p2(value:Point):void 
		{
			_p2 = value;
		}
		
		public function get edges():Vector.<Edge> 
		{
			return _edges; 
		}
		
		public function set edges(value:Vector.<Edge>):void 
		{
			_edges = value;
		}
		
		public function draw( graphics:Graphics = null ):void 
		{ 
			
			graphics.drawTriangles( Vector.<Number>( [ p0.x, p0.y, p1.x, p1.y, p2.x, p2.y ] ) );
			
		}
		
	}

}