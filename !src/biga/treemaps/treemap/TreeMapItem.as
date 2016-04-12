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
	
	import flash.geom.Rectangle;
    
    /** 
     * Wrapper for objects that are drawn out
     * by the layout-managers
     */
     
    public class TreeMapItem implements ITreeMapItem
	{
        private var _weight:Number;
        private var _area:Number;
        private var _rect:Rectangle;
		
        private var _data:*;
		
		public function TreeMapItem( weight:Number = NaN, data:* = null )
		{
			this.weight = weight;
			this.data = data;
		}
		
		public function clone():ITreeMapItem
		{
			var tmi:TreeMapItem = new TreeMapItem( weight, data );
			tmi.area = area;
			if ( rect != null )
			{
				tmi.rect = rect.clone();
			}
			else
			{
				tmi.rect = new Rectangle();
			}
			return tmi;
		}
		
		public function get weight():Number { return _weight; }
		public function set weight(value:Number):void 
		{
			_weight = value;
		}
        
		public function get area():Number { return _area; }
		public function set area(value:Number):void 
		{
			_area = value;
		}
		
		public function get rect():Rectangle { return _rect; }
		public function set rect(value:Rectangle):void 
		{
			_rect = value;
		}
		
		public function get data():* { return _data; }
		public function set data(value:*):void 
		{
			_data = value;
		}
		
    }
}