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
package treemap.layouts
{
	import treemap.TreeMapItem;
	import flash.geom.Point;
	import flash.geom.Rectangle;
    
    public class LayoutManager implements ILayoutManager
	{
		
		private var position:Point = new Point();
		
		private var _items:Vector.<TreeMapItem> = new Vector.<TreeMapItem>();
        
        public function getOccupiedRect():Rectangle
		{
			if ( items.length == 0 ) return null;
			
            var r:Rectangle = items[ 0 ].rect;
            for each( var tr:TreeMapItem in  items )
			{
                r = r.union( tr.rect );
            }
            return r;
        }
		
		
		//overridden
		public function createMap( list:Vector.<TreeMapItem> ):Vector.<TreeMapItem> { return null;  }
		
		
		public function get items():Vector.<TreeMapItem> { return _items; }
		public function set items(value:Vector.<TreeMapItem>):void 
		{
			_items = value;
		}
		
		public function get x():Number{ return position.x; }
		public function set x( value:Number ):void
		{
			position.x = value;
		}
		
		public function get y():Number{ return position.y; }
		public function set y( value:Number ):void
		{
			position.y = value;
		}
		
    }
}