/*
Copyright (c) 2006 Arpit Mathur

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, 
publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


package treemap
{
    
	import treemap.layouts.*;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
    /**
     * The TreeMap class accepts a series of ITreeData items
     * and represents them in a series of Rectangle objects, 
     * the width and height of each of them proportional to 
     * their relative <code>weight</code> property.
     */ 
     
    public class TreeMap
	{
		//maintains a list of treemapitems
        private var _itemList:Vector.<TreeMapItem>;
		
        private var zoneRect:Rectangle;
        private var _x:Number = 0;
        private var _y:Number = 0;
        private var _width:Number = 1;
        private var _height:Number = 1;
		
        private var currentLayoutManager:ILayoutManager;
        
		private var _layoutDirection:String = TreemapConstants.DIRECTION_HORIZONTAL;
		private var _layoutType:String = TreemapConstants.LAYOUT_SQUARIFIED;
		
		private var totalWeight:Number;
        
        /**
         * Constructor
         */ 
        public function TreeMap( rect:Rectangle = null ) 
		{
			if ( rect != null ) 
			{
				this.rect = rect;
			}
		}
        
        /**
         * Set an array of ITreeMapData items
         * as the dataProvider for this instance
         */ 
        public function compute( values:Vector.<TreeMapItem>, sortMethod:Function = null ):Vector.<TreeMapItem>
		{
			//_itemList = new Vector.<TreeMapItem>();
			
            zoneRect = new Rectangle( x, y, width, height );
			
			if ( zoneRect == null ) return null;
			
			// the vector is empty
			
            if ( values.length == 0 )
			{
                return null;
            }
			
			//if there's only one entry in the item vector, return one item with the whole area
			
			if ( values.length == 1 )
			{
				
				var tmi:ITreeMapItem = values[ 0 ].clone();
				tmi.rect = zoneRect.clone();
				_itemList = Vector.<TreeMapItem>( [ tmi ] );
				return items;
				
            }
			
			_itemList = values;
			
			//computes area for each item
			
            processValues( _itemList );
			
			//sort items in a givent order
			
			if ( sortMethod != null )
			{
				values.sort( sortMethod );
			}
			
			//assigns the manager
            getLayoutManager( zoneRect );
			
			//processes the layout
			_itemList = currentLayoutManager.createMap( _itemList );
			
			return _itemList;
			
        }
		
        /**
         * initializes with the area required by each TreeMapItem and saves the total weight of all weights
         */ 
        private function processValues( _itemList:Vector.<TreeMapItem> ):void
		{
			var item:TreeMapItem;
			
            totalWeight = 0;
			for each( item in _itemList)
			{
				
                totalWeight += item.weight; 
				
            }
			
           var surfaceRatio:Number = ( width * height ) / totalWeight;
			
            for each( item in _itemList)
            {
                item.area = item.weight * surfaceRatio;
				
				var size:Number = Math.sqrt( item.area );
				item.rect = new Rectangle( zoneRect.x, zoneRect.y, size, size );
				
			}
			
        }
		
        private function getLayoutManager( zoneRect:Rectangle ):void
		{
			
			if ( layoutType == TreemapConstants.LAYOUT_SLICE_DICE )
			{
				currentLayoutManager = new SliceDiceLayout( zoneRect, totalWeight );
				( currentLayoutManager as SliceDiceLayout ).direction = layoutDirection;
			}
			
			if ( layoutType == TreemapConstants.LAYOUT_SQUARIFIED )
			{
				currentLayoutManager = new SquarifiedLayout( zoneRect );
				( currentLayoutManager as SquarifiedLayout ).direction = ( zoneRect.width < zoneRect.height ) ? TreemapConstants.DIRECTION_HORIZONTAL : TreemapConstants.DIRECTION_VERTICAL;
			}
			
			if ( layoutType == TreemapConstants.LAYOUT_STRIP )
			{
				currentLayoutManager = new StripLayout( zoneRect );
				( currentLayoutManager as StripLayout ).direction = layoutDirection;
			}
			
        }
        
		/************************************************
		
		
		GETTERS / SETTERS
		
		
		************************************************/
		
		
		public function get x():Number { return _x; }
		public function set x(value:Number):void 
		{
			_x = value;
		}
		
		public function get y():Number { return _y; }
		public function set y(value:Number):void 
		{
			_y = value;
		}
		
        public function get width():Number { return _width; }
        public function set width( value:Number ):void
		{
            _width = value;
        }
        public function get height():Number { return _height; }
        public function set height( value:Number ):void
		{
            _height = value;
        }
		
		public function get rect():Rectangle { return new Rectangle( x, y, width, height ); }
		public function set rect(value:Rectangle):void 
		{
			x = value.x;
			y = value.y;
			width = value.width;
			height = value.height;
		}
		
		public function get layoutDirection():String { return _layoutDirection; }
		public function set layoutDirection(value:String):void 
		{
			_layoutDirection = value;
		}
		
		public function get layoutType():String { return _layoutType; }
		public function set layoutType(value:String):void 
		{
			_layoutType = value;
		}
		
		public function get items():Vector.<TreeMapItem> { return _itemList; }
		
    }
}