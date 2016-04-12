package 
{
	
	import treemap.TreemapConstants;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
    
    public class NestedTreeMap extends Sprite
	{
		private var rect:Rectangle;
		private var map:TreeMap;
		private var values:Vector.<TreeMapItem>;
		private var timer:Timer;
		private var startStop:Boolean;
    	
		public function NestedTreeMap()
		{
            
			rect = new Rectangle( 10, 10, 480, 480 );
			
            map = new TreeMap( rect );
			
            values = new Vector.<TreeMapItem> ;
			
			timer = new Timer( 0 );
			timer.addEventListener( TimerEvent.TIMER, onTick );
			onTick( null );
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseHandler );
			
		}
		
		private function mouseHandler(e:MouseEvent):void 
		{
			
			startStop = !startStop ? true : false;
			if( startStop ) timer.start();
			else timer.stop();
			
		}
		
		private function onTick(e:Event):void 
		{
			//creates a first treemap
			map.rect = new Rectangle( 10, 10, 480, 480 );
			map.layoutType = TreemapConstants.LAYOUT_SQUARIFIED;
			
			for  (var i:int = 0; i < 20; i++ ) 
			{
				var item:TreeMapItem = new TreeMapItem( Math.random() );
				values.push( item );
			}
			
			
			var colors:Array = [ 
								0x3F2A31, 0x56393D, 0x805243, 0xC6926A, 0xDFE5E3,
								0xC2A87C, 0xA88262, 0xCF8869, 0x82463C, 0x572527
								];
			var col:int = 0;
			
			//computes and render the first treemap
			var items:Vector.<TreeMapItem> = map.compute( values );
			graphics.clear();
			for each( item in items )
			{
				
				graphics.lineStyle( 2,0xFFFFFF );
				graphics.beginFill( colors[ col++ % colors.length ] );// 0x808080 + Math.random() * 0x808080 );
				graphics.drawRect( item.rect.x, item.rect.y, item.rect.width, item.rect.height );
				graphics.endFill();
				
				//uses each rect to create a new treemap
				map.rect = item.rect;
				values.length = 0;
				var count:int = 2 + Math.random() * 20;
				for( i = 0; i < count; i++ ) 
				{
					var subItem:TreeMapItem = new TreeMapItem( Math.random() );
					values.push( subItem );
				}
				
				//computes and render the sub treemaps
				map.compute( values );
				
				i = 0;
				graphics.lineStyle( 0,0x333333 );
				for each( subItem in map.items )
				{
					graphics.beginFill( 0, i/map.items.length );
					graphics.drawRect( subItem.rect.x, subItem.rect.y, subItem.rect.width, subItem.rect.height );
					i++;
				}
			}
			//draws a clean border
			graphics.endFill();
			graphics.lineStyle( 2,0xFFFFFF );
			graphics.drawRect( 10, 10, 480, 480 );
		}
    }
}