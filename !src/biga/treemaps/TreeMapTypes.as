package 
{
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import treemap.TreemapConstants;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
    
    public class TreeMapTypes extends Sprite
	{
    	
		public function TreeMapTypes()
		{
            
			var rect:Rectangle = new Rectangle( 10, 10, 480, 480 );
			
            var map:TreeMap = new TreeMap( rect );
			
			//specifies a LAYOUT_SLICE_DICE layout to the treemap
			
				//map.layoutType = TreemapConstants.LAYOUT_SLICE_DICE;
				
				map.layoutType = TreemapConstants.LAYOUT_SQUARIFIED;
				
				//map.layoutType = TreemapConstants.LAYOUT_STRIP;
			
			//specifies a HORIZONTAL direction
			
				map.layoutDirection = TreemapConstants.DIRECTION_HORIZONTAL;
				
				//map.layoutDirection = TreemapConstants.DIRECTION_VERTICAL;
			
			
			var item:TreeMapItem;
            var values:Vector.<TreeMapItem> = new Vector.<TreeMapItem>;
			for  (var i:int = 0; i < 50; i++ ) 
			{
				item = new TreeMapItem( Math.random() );
				values.push( item );
			}
			
			//sorting methods ( default none )
				
				map.compute( values );
				
				//map.compute( values, TreemapConstants.SORT_RANDOM );
				
				//map.compute( values, TreemapConstants.SORT_WEIGHT_ASCENDING );
				
				//map.compute( values, TreemapConstants.SORT_WEIGHT_DESCENDING );
				
			
			for each( item in map.items )
			{
				graphics.beginFill( 0x808080 + Math.random() * 0x808080 );
				graphics.drawRect( item.rect.x, item.rect.y, item.rect.width, item.rect.height );
			}
			
		}
    }
}