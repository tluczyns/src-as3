package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import customitems.CustomItem;
	import treemap.TreemapConstants;
	import treemap.ITreeMapItem;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class CustomItemSample extends Sprite 
	{
		private var values:Vector.<TreeMapItem>;
		public function CustomItemSample() 
		{
			
			//create a map, passes the rectangle where we want to draw
            var map:TreeMap = new TreeMap( new Rectangle( 10, 10, 480, 480 ) );
			
			//create values
            values = new Vector.<TreeMapItem>;
			
			//populate the values with basics items
			var item:CustomItem;
			for  (var i:int = 0; i < 50; i++ ) 
			{
				item = new CustomItem( Math.random(), this, 'abc_' + i );
				values.push( item );
			}
			
			//compute the map
			values = map.compute( values );
			
			//render
			renderCustomItems()
			
			//listen for a click
			stage.addEventListener( MouseEvent.MOUSE_DOWN, getCustomMessage );
			
		}
		private function renderCustomItems():void 
		{
			for each ( var item:ITreeMapItem in values )
			{
				( item as CustomItem ).render( graphics );
			}
		}
		private function getCustomMessage(e:MouseEvent):void 
		{
			graphics.clear();
			for each ( var item:ITreeMapItem in values )
			{
				if ( item.rect.contains( mouseX, mouseY ) )
				{
					trace( 'item clicked message -> ', ( item as CustomItem ).message );
					( item as CustomItem ).color = 0xFFFFFF;
				}
				( item as CustomItem ).render( graphics );
			}
		}
	}
}