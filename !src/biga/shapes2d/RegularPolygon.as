package biga.shapes2d 
{
	import biga.utils.GeomUtils;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class RegularPolygon extends Point
	{
		private var _points:Vector.<Point>;
		
		private var _radius:Number = 50;
		private var _sides:Number = 5;
		private var _sideLength:Number = ( 2 * _radius ) * Math.sin( Math.PI / _sides );
		
		private var _rotation:Number = 0;
		private var _inRadius:Number = _radius  * Math.cos( Math.PI / _sides );
		private var _centralAngle:Number = 0;
		private var _internalAngle:Number = 0;
		private var _externalAngle:Number = 0;
		
		private var _offset:Point = new Point();
		private var _offsetAngle:Number = 0;
		private var _offsetLength:Number = 0;
		
		public function RegularPolygon( x:Number = 0, y:Number = 0, radius:Number = 50, sides:int = 5 ) 
		{
			super( x, y );
			_points = new Vector.<Point>();
			_radius = radius;
			_sides = sides < 3 ? 3 : sides;
			resetShape();
		}
		
		private function resetShape():void
		{
			
			points.length = 0;
			
			var i:int = 0;
			var angle:Number = _rotation;
			
			_inRadius = _radius * Math.cos( Math.PI / _sides );
			
			_sideLength = ( 2 * _radius ) * Math.sin( Math.PI / _sides )
			
			_centralAngle = ( Math.PI * 2 ) / _sides;
			
			_internalAngle = ( 1 - 2 / sides ) * Math.PI;
			
			_externalAngle = Math.PI - _internalAngle;
			
			for ( i = 0; i < sides; i++ )
			{
				var p:Point = new Point( 	x + Math.cos( angle ) * radius, 
											y + Math.sin( angle ) * radius )
				
				angle += centralAngle;
				points.push( p );
			}
			
		}
		
		public function translate( anchor:Point ):void
		{
			
			var p:Point;
			x += anchor.x;
			y += anchor.y;
			for each( p in points )
			{
				p.x += anchor.x;
				p.y += anchor.y;
			}
		}
		
		public function rotate( anchor:Point, angle:Number ):void
		{
			
			rotatePoint( this, anchor, angle );
			
			var p:Point;
			
			for each( p in points )
			{
				
				rotatePoint( p, anchor, angle );
				
			}
			
			_rotation = angle;
			
		}
		
		private function rotatePoint( p:Point, anchor:Point, angle:Number ):Point
		{
			
			var a:Number, d:Number;
			a = GeomUtils.angle( anchor, p ) + angle;
			d = GeomUtils.distance( anchor, p );
			p.x = anchor.x + Math.cos( a ) * d;
			p.y = anchor.y + Math.sin( a ) * d;
			return p;
			
		}
		
		
		public function reflect( anchor0:Point, anchor1:Point ):void
		{
			
			var p:Point;
			
			reflectPoint( this, anchor0, anchor1 );
			
			for each( p in points )
			{
				reflectPoint( p, anchor0, anchor1 );
			}
			
		}
		
		private function reflectPoint( p:Point, p0:Point, p1:Point ):void
		{
			
			var pp:Point = GeomUtils.project( p, p0, p1 );
			if( isNaN( pp.x ) || isNaN( pp.y ) ) pp = GeomUtils.constrain( p, p0, p1 );
			
			p.x += ( pp.x - p.x ) * 2;
			p.y += ( pp.y - p.y ) * 2;
			
		}
		
		public function glide( anchor0:Point, anchor1:Point = null ):void
		{
			
			if ( anchor1 == null ) anchor1 = this.clone();
			
			translate( anchor0.subtract( anchor1 ) );
			
			reflect( anchor0, anchor1 );
			
		}
		
		
		public function get points():Vector.<Point> { return _points; }
		
		
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void 
		{
			_radius = value;
			resetShape();
		}
		
		public function get sides():Number { return _sides; }
		public function set sides(value:Number):void 
		{
			if ( _sides == value || value < 3 ) return;
			_sides = value;
			resetShape();
		}
		
		public function get rotation():Number { return _rotation; }
		public function set rotation(value:Number):void 
		{
			_rotation = value;
			resetShape();
		}
		
		public function get sideLength():Number{ return _sideLength; }
		public function set sideLength( value:Number ):void 
		{ 
			
			_radius = value / ( 2 * Math.sin( Math.PI / _sides ) );
			resetShape();
			
		} 
		
		public function get inRadius():Number { return _inRadius; }
		public function get apothem():Number { return inRadius; }
		
		public function get centralAngle():Number { return _centralAngle; }
		
		public function get internalAngle():Number { return _internalAngle; }
		
		public function get externalAngle():Number { return _externalAngle; }
		
		public function get center():Point
		{
			
			return new Point( 	( x + Math.cos( rotation + _offsetAngle )* -_offsetLength ),
								( y + Math.sin( rotation + _offsetAngle ) * -_offsetLength )	);
			
		}
		
		
		//public function set inRadius(value:Number):void 
		//{
			//_radius = value / Math.cos( Math.PI / sides );
			//resetShape();
		//}
		//
		//public function get sagitta():Number 
		//{
			//var sin:Number = Math.sin( Math.PI / sides * 2 )
			//return 2 * radius * ( sin * sin );
		//}
		
		public function draw( graphics:Graphics = null ):void
		{
			
			var p:Point = points[ 0 ];
			
			graphics.moveTo( p.x, p.y );
			//graphics.drawCircle( p.x, p.y, 5 );
			for each( p in points )
			{
				graphics.lineTo( p.x, p.y );
			}
			graphics.lineTo( points[ 0 ].x, points[ 0 ].y );
			
		}
		
		
	}

}