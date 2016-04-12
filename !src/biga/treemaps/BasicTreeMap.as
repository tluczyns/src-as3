package treemaps
{
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import treemap.TreemapConstants;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
    
    public class BasicTreeMap extends Sprite
	{
    	
		public function BasicTreeMap()
		{
			//create a map, passes the rectangle where we want to draw
			var map:TreeMap = new TreeMap( new Rectangle( 10, 10, 480, 480 ) );

			//create values
			var values:Vector.<TreeMapItem> = new Vector.<TreeMapItem>;

			//populate the values with basics items
			var item:TreeMapItem;
			for  (var i:int = 0; i < 150; i++ ) 
			{
				item = new TreeMapItem( Math.random() );
				values.push( item );
			}

			//compute the map
			values = map.compute( values, TreemapConstants.SORT_WEIGHT_DESCENDING );

			//render
			for each( item in values )
			{
				graphics.beginFill( 0x808080 + Math.random() * 0x808080 );
				graphics.drawRect( item.rect.x, item.rect.y, item.rect.width, item.rect.height );
			}

		}
    }
}