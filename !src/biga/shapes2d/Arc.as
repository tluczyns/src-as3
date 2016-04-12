package biga.shapes2d 
{
	
	import biga.utils.GeomUtils;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class Arc extends Circle 
	{
		private var pi:Number = Math.PI;
		private var pi_4:Number = pi / 4;
		
		
		private var _startAngle:Number = 0;
		private var _arcLength:Number = 0;
		
		
		private var _segment:Boolean = false;
		private var _sector:Boolean = false;
		
		public function Arc( x:Number, y:Number, radius:Number, startAngle:Number = Math.PI, arcLength:Number = Math.PI/3 ) 
		{
			
			super( x, y, radius );
			this._arcLength = arcLength;
			this._startAngle = startAngle;
			
		}
		
		//http://www.experts-exchange.com/Software/Photos_Graphics/Web_Graphics/Macromedia_Flash/ActionScript/Q_25121879.html
		override public function draw( graphics:Graphics ):void
		{
			
			var start:Number = startAngle;
			var end:Number = arcLength;
			
			var difference:Number = Math.abs( start + ( end - start ) );
			
			var divisions:Number = int( difference / pi_4 ) + 1;
			var span:Number = difference / ( 2 * divisions );
			var controlRadius:Number = radius / Math.cos(span);
		   
			var controlPoint:Point;
			var anchorPoint:Point;
			
			if ( sector ) 
			{
				graphics.moveTo( x, y );
				graphics.lineTo( x + Math.cos( start ) * radius, y + Math.sin( start ) * radius );
			}
			
			graphics.moveTo( x + Math.cos( start ) * radius, y + Math.sin( start ) * radius );
			
			for ( var i:int = 0; i < divisions; i++ )
			{
				
				end    	= start + span;
				start  	= end + span;
				
				controlPoint 	= new Point(x + Math.cos(end) * controlRadius, y + Math.sin(end) * controlRadius);
				anchorPoint 	= new Point(x + Math.cos(start) * radius, y + Math.sin(start) * radius);
				
				graphics.curveTo(controlPoint.x, controlPoint.y, anchorPoint.x, anchorPoint.y);
				
			}
			
			if ( sector ) 
			{
				graphics.lineTo( x, y );
			}
			if ( segment )
			{
				graphics.lineTo( x + Math.cos( startAngle ) * radius, y + Math.sin( startAngle ) * radius );
			}
			
		};
		/**
		 * returns a series of points corresponding to the discretized arc
		 * @param	steps number of subdivisions
		 * @return a list of points
		 */
		public function subdivide( steps:int ):Vector.<Point>
		{
			var points:Vector.<Point> = new Vector.<Point>();
			
			for ( var i:int = 0; i <= steps; i++ )
			{
				points.push( getPointAt( i / steps ) );
			}
			
			return points;
		}
		
		/**
		 * gets a point on the arc at 0 > t > 1 
		 * @param	t
		 * @return
		 */
		public function getPointAt( t:Number, p:Point = null ):Point
		{
			
			p ||= new Point();
			var angle:Number = t * arcLength;
			p.x = x + Math.cos( startAngle + angle ) * radius;
			p.y = y + Math.sin( startAngle + angle ) * radius;
			return p;
			
		}
		
		
		public function get startAngle():Number { return _startAngle; }
		public function set startAngle(value:Number):void 
		{
			_startAngle = value;
		}
		
		public function get arcLength():Number { return _arcLength; }
		public function set arcLength(value:Number):void 
		{
			_arcLength = value;
		}
		
		public function get segment():Boolean { return _segment; }
		public function set segment(value:Boolean):void 
		{
			_segment = value;
		}
		
		public function get sector():Boolean { return _sector; }
		public function set sector(value:Boolean):void 
		{
			_sector = value;
		}
		
	}

}