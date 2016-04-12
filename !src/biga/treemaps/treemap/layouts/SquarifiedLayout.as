package treemap.layouts 
{
	import treemap.TreemapConstants;
	import treemap.TreeMapItem;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class SquarifiedLayout extends LayoutManager 
	{
		
        private var h:Number;
        private var w:Number;
		
        private var currentHeight:Number = 0;
        private var currentWidth:Number = 0;
		private var currDiff:Number;
		private var currsor:int;
		
		//true: HORIZONTAL / false: VERTICAL
		private var _direction:String;
		private var _rect:Rectangle;
		private var _itemList:Vector.<TreeMapItem>;
		private var _results:Vector.<TreeMapItem>;
		private var cursor:int;
		
		public function SquarifiedLayout( rect:Rectangle ) 
		{
			
			cursor = 0;
			this.rect = rect;
			
		}
		
        override public function createMap( list:Vector.<TreeMapItem> ):Vector.<TreeMapItem>
		{
			cursor = 0;
			
			_itemList = list;
			
			items = new Vector.<TreeMapItem>();
			
			results = new Vector.<TreeMapItem>();
			
			addBlock();
			
			return results;
		}
		
		private function addBlock():void
		{
		
            if ( cursor == _itemList.length )
			{
				offsetItemRectangles();
				return;
            }
			
			var added:Boolean = addTreeMapItem( _itemList[ cursor ] );
			if ( added )
			{
                cursor++;
                addBlock();
            }
            else
			{
				changeDirection();
	        }
            
        }
        
		public function addTreeMapItem( mapItem:TreeMapItem ):Boolean
		{
			
			if ( w == 0 || h == 0 )
			{
				return false;
			}
			
			var area:Number = mapItem.area;
			var tmpRect:Rectangle;
			var item:TreeMapItem;
			var diff:Number = 0, rectX:Number = 0, rectY:Number = 0;
			
			if ( direction == TreemapConstants.DIRECTION_HORIZONTAL )
			{
				
				var heightAddition:Number = area / w;
				var newHeight:Number = currentHeight + heightAddition;
				var newAreaWidth:Number = area / newHeight;
				
				diff = Math.abs( newAreaWidth - newHeight );
				
				if ( !isNaN( currDiff ) && diff > currDiff )	return false;
				
				currDiff = diff;
				currentHeight = newHeight;
				
				for each( item in items )
				{
					
					tmpRect = item.rect;
					
					tmpRect.width = ( tmpRect.width * tmpRect.height ) / ( tmpRect.height + heightAddition );
					tmpRect.height += heightAddition;
					tmpRect.x = rectX;
					rectX += tmpRect.width;
					
				}
				
				mapItem.rect = new Rectangle( rectX, 0, newAreaWidth, newHeight );
				
			}
			else
			{
				
				var widthAddition:Number = area / h;
				
				var newWidth:Number = currentWidth + widthAddition;
				
				var newAreaHeight:Number = area / newWidth;
				
				diff = Math.abs( newAreaHeight - newWidth );
				
				if ( !isNaN( currDiff ) && diff > currDiff )	return false;
				
				currDiff = diff;
				currentWidth = newWidth;
				
				for each( item in items )
				{
					
					tmpRect = item.rect;
					tmpRect.height = (tmpRect.width * tmpRect.height) / ( tmpRect.width + widthAddition );
					tmpRect.width += widthAddition;
					tmpRect.y = rectY;
					rectY += tmpRect.height;
					
				}
				
				mapItem.rect = new Rectangle( 0, rectY, newWidth, newAreaHeight );
			}
			
			items.push( mapItem );
			
			return true;
			
        }
		
        /**
         * This method is called when the current layout manager declares that
         * it has been packed to the maximum efficiency and cannot accept the
         * next TreeMapItem. The TreeMap then looks at the remaining area and 
         * recomputes the best layout manager for the space left.
         */ 
        private function changeDirection():void
		{
			offsetItemRectangles();
			
            var gotRect:Rectangle = getOccupiedRect();
			
			//no item added by createMap: invalid zoneRect ( width or height == 0 )
			if ( gotRect == null )
			{
				return;
			}
			
            var usedRect:Rectangle = new Rectangle( 	x, 
														y,
														gotRect.width, 
														gotRect.height	);
			
			usedRect = approximateRects( rect, usedRect );
			
            var tmpRect:Rectangle = getDifferenceRect( rect, usedRect );
			
			//getDifferenceRect failed and reutrned a null area
			if ( tmpRect == null )return;
			rect = tmpRect;
			
			direction = ( direction == TreemapConstants.DIRECTION_HORIZONTAL ) ? TreemapConstants.DIRECTION_VERTICAL : TreemapConstants.DIRECTION_HORIZONTAL;
			
			currDiff = Number.MAX_VALUE;
			currentWidth = currentHeight = 0;
			items.length = 0;
			addBlock();
			
        }
        
        /**
         * Approximates the Rectangle coordinates to their nearest whole numbers
         */
        private function approximateRects(def:Rectangle, used:Rectangle):Rectangle
		{
			
            if (Math.abs(def.x - used.x) <= 1)
			{
                used.x = def.x;
            }
			
            if (Math.abs(def.y - used.y) <= 1)
			{
                used.y = def.y;
            }
			
            if (Math.abs(def.width - used.width) <= 1)
			{
                used.width = def.width;
            }
			
            if (Math.abs(def.height - used.height) <= 1)
			{
                used.height = def.height;
            }
            return used;
        }
        
		
        private function getDifferenceRect( containerRect:Rectangle, containedRect:Rectangle ):Rectangle
		{
			
			var rect:Rectangle = containerRect.clone();
			
            if (containerRect.bottom != containedRect.bottom)
			{
				rect.y += containedRect.height;
				rect.bottom -= containedRect.height;
                return rect;
            }
            else if (containerRect.left != containedRect.left)
			{
                rect.width -= containedRect.width;
				return rect;
            }
            else if (containerRect.right != containedRect.right)
			{
                rect.x += containedRect.width;
				rect.width -= containedRect.width;
				return rect;
            }
            else if (containerRect.top != containedRect.top)
			{
				rect.bottom -= containedRect.height;
				return rect;
            }
            else return null;
        }
        
		
		
		/**
		 * assigns the absolute position of the items rectangles and pushes them in the results list
		 * */
        private function offsetItemRectangles():void
		{
			for ( var i:int = 0; i < items.length; i++ )
			{
				var tr:TreeMapItem = items[ i ];
				tr.rect.x += x;
				tr.rect.y += y;
				results.push( tr );
			}
			
        }
		
		
		
		
		
		
		/**
		 * 
		 * */
		
		
		
		public function get direction():String { return _direction; }
		public function set direction(value:String):void 
		{
			_direction = value;
		}
		
		public function get rect():Rectangle { return _rect; }
		public function set rect(value:Rectangle):void 
		{
			
			_rect = value;
			
			reset();
			
		}
		
		public function get results():Vector.<TreeMapItem> { return _results; }
		public function set results(value:Vector.<TreeMapItem>):void 
		{
			_results = value;
		}
		
		private function reset():void 
		{
			
			x = rect.x;
			y = rect.y;
			w = rect.width;
			h = rect.height;
			
			//items.length = 0;
			//
			//currDiff = 0;0;
			//currentWidth = currentHeight = 0;
			//
		}
		
	}
}