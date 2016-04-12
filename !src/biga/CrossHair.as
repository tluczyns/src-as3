package biga 
{
	import biga.utils.GeomUtils;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class CrossHair extends Shape 
	{
		
		static private var crossHairs:Vector.<CrossHair> = new Vector.<CrossHair>();
		static private var instance:CrossHair;
		static private var closest:CrossHair;
		static private var friction:Number = .2;
		private var _fixed:Boolean;
		
		private var _point:Point = new Point();
		
		public function CrossHair( color:uint = 0, size:Number = 24 ) 
		{
			graphics.lineStyle( 0, color );
			graphics.moveTo( -size / 2, 0 );
			graphics.lineTo(  size / 2, 0 );
			graphics.moveTo( 0, -size / 2 );
			graphics.lineTo( 0,  size / 2 );
			graphics.drawCircle( 0, 0,  size / 2 );
			
			crossHairs.push( this );
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			
			if ( instance == null )
			{
				instance = this;
				instance.addEventListener( Event.ENTER_FRAME, update );
			}
			
		}
		
		private function update(e:Event):void 
		{
			if ( closest != null )
			{
				closest.x += ( stage.mouseX - closest.x ) * friction;
				closest.y += ( stage.mouseY - closest.y ) * friction;
			}
		}
		
		private function addedToStage(e:Event):void 
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseHandler );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseHandler );
			
		}
		
		private function onMouseHandler(e:MouseEvent):void 
		{
			switch( e.type) 
			{
				case MouseEvent.MOUSE_DOWN:
					if ( !( e.target is Stage ) ) return;
					var mouse:Point = new Point( stage.mouseX, stage.mouseY );
					var dist:Number;
					var minDist:Number = Number.POSITIVE_INFINITY;
					for each( var c:CrossHair in crossHairs )
					{
						if ( c.fixed ) continue;
						
						dist = GeomUtils.distance( mouse, c.point );
						if ( dist < minDist ) 
						{
							closest = c;
							minDist = dist;
						}
					}
				break;
				
				case MouseEvent.MOUSE_UP: 
					closest = null; 
				break;
			}
		}
		
		public function get point():Point 
		{
			_point.x = x;
			_point.y = y;
			return _point; 
		}
		
		public function set point( p:Point ):void
		{ 
			x = _point.x = p.x;
			y = _point.y = p.y;
		}
		
		public function get fixed():Boolean { return _fixed; }
		public function set fixed(value:Boolean):void 
		{
			_fixed = value;
		}
	}

}