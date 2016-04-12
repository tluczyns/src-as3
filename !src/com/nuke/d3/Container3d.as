package com.nuke.d3
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Bartłomiej JERZY
	 */
	public class Container3d extends Sprite
	{
		public var _items3d:Array
		
		public function Container3d($fov:Number = 300) 
		{
		}
		
		public function sort() {
			
			
			var _sortTable:Array = _items3d.slice()
			_sortTable.sortOn( "zz", Array.DESCENDING | Array.NUMERIC );
			
			for (var i:int = 0; i < _sortTable.length; i++) {
				
				this.setChildIndex(_sortTable[i], i);
				
			}
			
		}
		
	}
	
}