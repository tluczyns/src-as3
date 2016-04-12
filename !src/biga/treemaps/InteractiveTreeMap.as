package 
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import treemap.TreemapConstants;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
    
    public class InteractiveTreeMap extends Sprite
	{
		private var values:Vector.<TreeMapItem>;
    	
		public function InteractiveTreeMap()
		{
            
            var map:TreeMap = new TreeMap( new Rectangle( 10, 10, 480, 480 ) );
			
            values = new Vector.<TreeMapItem>;
			
			for  (var i:int = 0; i < 30; i++ ) 
			{
				var item:TreeMapItem = new TreeMapItem( Math.random() );
				
				//stores the color as the data param of the item
				item.data = 0x808080 + Math.random() * 0x808080;
				
				values.push( item );
			}
			
			values = map.compute( values, TreemapConstants.SORT_WEIGHT_DESCENDING );
			
			addEventListener( Event.ENTER_FRAME, update );
			
		}
		
		private function update(e:Event):void 
		{
			graphics.clear();
			graphics.lineStyle( 0, 0xCCCCCC );
			
			for each( var item:TreeMapItem in values )
			{
				//default color http://en.nicoptere.net/?p=1568
				graphics.beginFill( 0x333333 );
				
				//simple Rectangle.contains( X, Y ) to check if the mouse is inside an item
				if ( item.rect.contains( mouseX, mouseY ) )
				{
					//swaps color to the item color ( stored in data ) 
					graphics.beginFill( item.data );
				}
				
				graphics.drawRect( item.rect.x, item.rect.y, item.rect.width, item.rect.height );
				graphics.endFill();
				
			}
		}
    }
}