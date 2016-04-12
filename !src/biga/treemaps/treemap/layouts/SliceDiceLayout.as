package treemap.layouts 
{
	import treemap.TreemapConstants;
	import treemap.TreeMapItem;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class SliceDiceLayout extends LayoutManager 
	{
		private var _direction:String;
		private var offset:Number;
		private var _rect:Rectangle;
		private var _totalWeight:Number;
		
		public function SliceDiceLayout( rect:Rectangle, totalWeight:Number ) 
		{
			this.rect = rect;
			offset = 0;
			_totalWeight = totalWeight;
		}
		
        
        override public function createMap( list:Vector.<TreeMapItem> ):Vector.<TreeMapItem>
		{
			var results:Vector.<TreeMapItem> = new Vector.<TreeMapItem>();
			var mapItem:TreeMapItem;
			if( direction == TreemapConstants.DIRECTION_HORIZONTAL )
			{
				for each( mapItem in list )
				{
					var height:Number = ( mapItem.weight / _totalWeight ) * _rect.height;
					
					mapItem.rect = new Rectangle( _rect.x, _rect.y + offset, _rect.width, height );
					
					offset += height;
					
					results.push( mapItem );
				}
			}
			else
			{
				
				for each( mapItem in list )
				{
					var width:Number = ( mapItem.weight / _totalWeight ) * _rect.width;
					
					mapItem.rect = new Rectangle( _rect.x + offset, _rect.y, width, _rect.height );
					
					offset += width;
					
					results.push( mapItem );
				}
			}
			return results
        }
		
		public function get direction():String { return _direction; }
		public function set direction(value:String):void 
		{
			_direction = value;
		}
		
		public function get rect():Rectangle { return _rect; }
		public function set rect(value:Rectangle):void 
		{
			_rect = value;
		}
	}

}