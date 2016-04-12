/**
 * Pixel Perfect Collision Detection
 * ---------------------
 * VERSION: 1.0.1
 * DATE: 8/23/2011
 * AS3
 * UPDATES AND DOCUMENTATION AT: http://www.FreeActionScript.com
 **/
package com.freeactionscript 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CollisionTest 
	{
		// vars
		private var _returnValue:Boolean;
		
		private var _onePoint:Point;
		private var _twoPoint:Point;
		
		private var _oneRectangle:Rectangle;
		private var _twoRectangle:Rectangle;
		
		private var _oneClipBmpData:BitmapData;
		private var _twoClipBmpData:BitmapData;
		
		private var _oneOffset:Matrix;
		private var _twoOffset:Matrix;
		
		/**
		 * Simple collision test. Use this for objects that are not rotated.
		 * @param	clip1	Takes DisplayObjectContainer as argument. Can be a Sprite, MovieClip, etc.
		 * @param	clip2	Takes DisplayObjectContainer as argument. Can be a Sprite, MovieClip, etc.
		 * @return	Collision True/False
		 */
		public function simple(clip1:DisplayObjectContainer, clip2:DisplayObjectContainer):Boolean
		{
			_returnValue = false;
			
			_oneRectangle = clip1.getBounds(clip1);
			_oneClipBmpData = new BitmapData(_oneRectangle.width, _oneRectangle.height, true, 0);
			_oneClipBmpData.draw(clip1);
			
			_twoRectangle = clip2.getBounds(clip2);
			_twoClipBmpData = new BitmapData(_twoRectangle.width, _twoRectangle.height, true, 0);
			_twoClipBmpData.draw(clip2);
			
			_onePoint = new Point(clip1.x, clip1.y)
			_twoPoint =  new Point(clip2.x, clip2.y)
			
			if (_oneClipBmpData.hitTest(_onePoint, 255, _twoClipBmpData, _twoPoint, 255))
			{
				_returnValue = true;
			}
			
			return _returnValue;
		}
		
		/**
		 * Complex collision test. Use this for objects that are rotated, scaled, skewed, etc
		 * @param	clip1	Takes DisplayObjectContainer as argument. Can be a Sprite, MovieClip, etc.
		 * @param	clip2	Takes DisplayObjectContainer as argument. Can be a Sprite, MovieClip, etc.
		 * @return	Collision True/False
		 */
		public function complex(clip1:DisplayObjectContainer, clip2:DisplayObjectContainer):Boolean
		{
			_returnValue = false;
			
			_twoRectangle = clip1.getBounds(clip1);
			_oneOffset = clip1.transform.matrix;
			_oneOffset.tx = clip1.x - clip2.x;
			_oneOffset.ty = clip1.y - clip2.y;	
			
			_twoClipBmpData = new BitmapData(_twoRectangle.width, _twoRectangle.height, true, 0);
			_twoClipBmpData.draw(clip1, _oneOffset);		
			
			_oneRectangle = clip2.getBounds(clip2);
			_oneClipBmpData = new BitmapData(_oneRectangle.width, _oneRectangle.height, true, 0);
			
			_twoOffset = clip2.transform.matrix;
			_twoOffset.tx = clip2.x - clip2.x;
			_twoOffset.ty = clip2.y - clip2.y;	
			
			_oneClipBmpData.draw(clip2, _twoOffset);
			
			_onePoint = new Point(_oneRectangle.x, _oneRectangle.y);
			_twoPoint = new Point(_twoRectangle.x, _twoRectangle.y);
			
			if(_oneClipBmpData.hitTest(_onePoint, 255, _twoClipBmpData, _twoPoint, 255))
			{
				_returnValue = true;
			}
			
			_twoClipBmpData.dispose();
			_oneClipBmpData.dispose();
			
			return _returnValue;
		}
		
	}

}