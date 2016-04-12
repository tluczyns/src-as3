package com.li.as3bend.vector
{
	import flash.geom.*;
	
	public class PathCommand
	{
		public var pStart:Point;
		public var pControl:Point;
		public var pEnd:Point;
		public var type:int;
		
		public function PathCommand(type:int, pStart:Point = null, pControl:Point = null, pEnd:Point = null)
		{
			this.type = type;
			this.pStart = pStart;
			this.pControl = pControl;
			this.pEnd = pEnd;
		}
	}
}