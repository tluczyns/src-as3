package com.nuke.utils 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Bartłomiej JERZY
	 */
	public class Draw 
	{
		
		public static function dotLine(mc:Shape,sx:Number,sy:Number,x:Number,y:Number,color:uint=0xffffff,alpha:Number = 1,dotSize:Number = 1,gap:Number = 2):void {
			
			var __length:Number = Math.sqrt((sx - x) * (sx - x) + (sy - y) * (sy - y))
			var __angleRad:Number = Math.atan2(x - sx, y - sy)
			
			
			var __dx:int = Math.round(gap*Math.sin(__angleRad))
			var __dy:int = Math.round(gap*Math.cos(__angleRad))
			
			mc.graphics.beginFill(color)
			
			var xx:int = sx
			var yy:int = sy
			
			var _xlimit:int = x - sx
			var _ylimit:int = y - sy
			var _xDir:int
			var _yDir:int
			
			if (_xlimit > 0) {
				 _xDir = 1
			}else if (_xlimit == 0){
				 _xDir = 0
			}else {
				 _xDir = -1
			}
			
			if (_ylimit > 0) {
				 _yDir = 1
			}else if (_ylimit == 0){
				 _yDir = 0
			}else {
				 _yDir = -1
				
			}
		
			var _i1:int = Math.round(Math.abs(_xlimit)/Math.abs(dotSize*_xDir+__dx))
			var _i2:int = Math.round(Math.abs(_ylimit) / Math.abs(dotSize*_yDir + __dy))
			var _i:int
			if (_i1 > _i2) {
				_i = _i1
			}else {
				_i = _i2
			}
			
			for (var j:int = 0; j < _i;j++)
			{
				mc.graphics.drawRect(xx, yy,dotSize,dotSize)
				xx += dotSize*_xDir+__dx
				yy += dotSize*_yDir+__dy
				
			}	
			mc.graphics.endFill()
		}
	}
}