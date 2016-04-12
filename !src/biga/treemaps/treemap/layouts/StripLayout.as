package treemap.layouts 
{
	import treemap.TreemapConstants;
	import treemap.TreeMapItem;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class StripLayout extends LayoutManager 
	{
		private var _direction:String;
		private var _rect:Rectangle;
		
		private var totalSize:Number = 0; 

		public function StripLayout( rect:Rectangle ) 
		{
			
			this.rect = rect;
			
		}
        
        override public function createMap( list:Vector.<TreeMapItem> ):Vector.<TreeMapItem>
		{
			
			if ( direction == TreemapConstants.DIRECTION_HORIZONTAL )
			{
				layoutHorizontal( list, rect );
			}
			else
			{
				layoutVertical( list, rect );
			}
			
			return list;
			
        }
		
		
		public function get rect():Rectangle { return _rect; }
		public function set rect(value:Rectangle):void 
		{
			_rect = value;
		}
		
		public function get direction():String { return _direction; }
		public function set direction(value:String):void 
		{
			_direction = value;
		}
		
		public function layoutHorizontal( list:Vector.<TreeMapItem>, bounds:Rectangle):void
		{
			items = list.concat();
			
			var i:int;
			for (i = 0; i < items.length; i++) totalSize += items[i].area;

			var area:Number = bounds.width * bounds.height;
			var scaleFactor:Number = Math.sqrt( area / totalSize );

			var finishedIndex:int = 0;
			var numItems:int = 0;
			var height:Number;
			var yoffset:Number = 0;
			
			var box:Rectangle = bounds.clone();
			box.x /= scaleFactor;
			box.y /= scaleFactor;
			box.width /= scaleFactor;
			box.height /= scaleFactor;
			
			while ( finishedIndex < items.length)
			{
				
				numItems = layoutStrip( box, finishedIndex );
				
				if( (finishedIndex + numItems) < items.length )
				{
					var numItems2:int;
					var ar2a:Number;
					var ar2b:Number;
					
					numItems2 = layoutStrip( box, finishedIndex + numItems);
					ar2a = computeAverageAspectRatio(finishedIndex, numItems + numItems2);
					
					computeHorizontalBoxLayout(box, finishedIndex, numItems + numItems2);
					ar2b = computeAverageAspectRatio(finishedIndex, numItems + numItems2);
					
					if (ar2b < ar2a) 
					{
						numItems += numItems2;
					}
					else 
					{
						computeHorizontalBoxLayout( box, finishedIndex, numItems );
					}
				}

				for ( i = finishedIndex; i < (finishedIndex + numItems); i++)
				{
					items[i].rect.y = yoffset;
				}
				
				height = items[ finishedIndex ].rect.height;
				yoffset += height;
				
				box.y += height;
				box.height -= height;
				
				finishedIndex += numItems;
				
			}
			
			var rect:Rectangle;
			for (i = 0; i < items.length; i++)
			{
				
				rect = items[i].rect;
				
				rect.x *= scaleFactor;
				rect.y *= scaleFactor;
				rect.width *= scaleFactor;
				rect.height *= scaleFactor;
				
				rect.x += bounds.x;
				rect.y += bounds.y;
				
			}
			
			totalSize = 0;
			for ( i = finishedIndex - numItems; i < items.length; i++ ) 
			{
				totalSize += items[ i ].weight;
			}
			height = ( bounds.y + bounds.height ) - rect.y;
			var ox:int = bounds.x;
			for ( i = finishedIndex - numItems; i < items.length; i++ ) 
			{
				items[ i ].rect.width = items[ i ].weight * ( bounds.width / totalSize );
				items[ i ].rect.x = ox;
				ox += items[ i ].rect.width;
				items[ i ].rect.height = height;
			}
			
		}

		public function layoutVertical( list:Vector.<TreeMapItem>, bounds:Rectangle):void
		{
			items = list.concat();
			
			var i:int;
			for (i = 0; i < items.length; i++) totalSize += items[i].area;

			var area:Number = bounds.width * bounds.height;
			var scaleFactor:Number = Math.sqrt( area / totalSize );

			var finishedIndex:int = 0;
			var numItems:int = 0;
			
			var width:Number;
			var xoffset:Number = 0;
			
			var box:Rectangle = bounds.clone();
			box.x /= scaleFactor;
			box.y /= scaleFactor;
			box.width /= scaleFactor;
			box.height /= scaleFactor;
			
			while ( finishedIndex < items.length)
			{
				
				numItems = layoutStrip( box, finishedIndex );
				
				if( (finishedIndex + numItems) < items.length )
				{
					var numItems2:int;
					var ar2a:Number;
					var ar2b:Number;
					
					numItems2 = layoutStrip( box, finishedIndex + numItems);
					ar2a = computeAverageAspectRatio(finishedIndex, numItems + numItems2);
					
					computeVerticalBoxLayout(box, finishedIndex, numItems + numItems2);
					ar2b = computeAverageAspectRatio(finishedIndex, numItems + numItems2);
					
					if (ar2b < ar2a) 
					{
						numItems += numItems2;
					}
					else 
					{
						computeVerticalBoxLayout( box, finishedIndex, numItems );
					}
				}

				for ( i = finishedIndex; i < (finishedIndex + numItems); i++)
				{
					items[i].rect.x = xoffset;
				}
				
				width = items[ finishedIndex ].rect.width;
				xoffset += width;
				
				box.x += width;
				box.width -= width;
				
				finishedIndex += numItems;
				
			}
			
			var rect:Rectangle;
			for (i = 0; i < items.length; i++)
			{
				
				rect = items[i].rect;
				
				rect.x *= scaleFactor;
				rect.y *= scaleFactor;
				rect.width *= scaleFactor;
				rect.height *= scaleFactor;
				
				rect.x += bounds.x;
				rect.y += bounds.y;
				
			}
			
			totalSize = 0;
			for ( i = finishedIndex - numItems; i < items.length; i++ ) 
			{
				totalSize += items[ i ].weight;
			}
			
			width = ( bounds.x + bounds.width ) - rect.x;
			var oy:int = bounds.y;
			for ( i = finishedIndex - numItems; i < items.length; i++ ) 
			{
				items[ i ].rect.height = items[ i ].weight * ( bounds.height / totalSize );
				items[ i ].rect.y = oy;
				oy += items[ i ].rect.height;
				items[ i ].rect.width = width;
			}
		}
		
		protected function layoutStrip( box:Rectangle, index:int ):int
		{
			var numItems:int = 0;
			var prevAR:Number = Number.MAX_VALUE;
			var ar:Number = Number.MAX_VALUE;
			
			do{
				
				prevAR = ar;
				numItems++;
				ar = computeAverageAspectRatio( index, numItems );
				
			}while ((ar < prevAR) && ((index + numItems) < items.length))
			
			if (ar >= prevAR)
			{
				numItems--;
				ar = computeAverageAspectRatio(index, numItems);
			}
			
			return numItems;
			
		}

		protected function computeHorizontalBoxLayout( box:Rectangle, index:int, numItems:int ):Number
		{
			var i:int;
			var totalSize:Number = computeSize( index, numItems );
			var height:Number = totalSize / box.width;
			
			var x:Number = 0;
			var width:Number;

			for (i = 0; i < numItems; i++)
			{
				
				width = items[i + index].area / height;
				
				items[i + index].rect = new Rectangle(x, 0, width, height);
				
				x += width;
				
			}

			return height;
		}

		protected function computeVerticalBoxLayout( box:Rectangle, index:int, numItems:int ):Number
		{
			var i:int;
			var totalSize:Number = computeSize( index, numItems );
			var width:Number = totalSize / box.height;
			
			var y:Number = 0;
			var height:Number;

			for (i = 0; i < numItems; i++)
			{
				
				height = items[i + index].area / width;
				
				items[i + index].rect = new Rectangle( 0, y, width, height);
				
				y += height;
				
			}

			return width;
		}

		private function computeSize( index:int, num:int ):Number 
		{
			var size:Number = 0;
			
			for ( var i:int = 0; i < num; i++)
			{
				size += items[ i + index ].area;
			}
			
			return size;
		}

		private function computeAverageAspectRatio( index:int, numItems:int ):Number
		{
			var tar:Number = 0;
			var i:int;
			for (i = 0; i < numItems; i++) 
			{
				tar += computeAspectRatio( i );
			}
			return tar / numItems;
		}

		private function computeAspectRatio( index:int ):Number
		{
			
			var w:Number = items[index].rect.width;
			var h:Number = items[index].rect.height;
			return Math.min( (w / h), (h / w) );
			
		}
		
	}

}