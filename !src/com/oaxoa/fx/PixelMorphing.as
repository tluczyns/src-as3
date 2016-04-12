/**
 * PixelMorphing Class
 * AS3 Class to morph a picture to another by reusing (moving/recoloring) pixels 
 * of another picture
 * 
 * @author		Pierluigi Pesenti
 * @version		1.0
 *
 * Comments
 *
 * Feel free to experiment with different bitmap lock/unlock combinations, inside or outside for loops etc.
 * I didn't find big performance improvements. The bottleneck here is not the bitmap drawing (at least on small images)
 */

/*
Licensed under the MIT License

Copyright (c) 2008 Pierluigi Pesenti

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

http://blog.oaxoa.com/
*/
package com.oaxoa.fx{

	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import caurina.transitions.Tweener;

	public class PixelMorphing extends Sprite {

		private var w:uint;
		private var h:uint;

		private var pic1:DisplayObject;
		private var pic2:DisplayObject;

		private var array1:Array;
		private var array2:Array;
		private var movingPixels:Array;
		private var startI:int;
		private var startCI:int;
		private var endI:int;
		private var endCI:int;
		private var firstIndex:uint;
		private var point:Point;

		private var bd1:BitmapData;
		private var bd2:BitmapData;
		private var bd3:BitmapData;
		private var bmp1:Bitmap;
		private var bmp2:Bitmap;
		private var bmp3:Bitmap;
		
		// public changable vars
		
		public var slowFx:Number;
		public var tolerance:Number;
		public var particlesPerFrameMove:Number;
		public var particlesPerFrameColor:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		
		// constructor, first 2 parameters needed

		public function PixelMorphing(pic1_p:DisplayObject, pic2_p:DisplayObject, offsetX_p:Number=0, offsetY_p:Number=0, particlesPerFrameMove_p:Number=1000, particlesPerFrameColor_p:Number=1200, slowFx_p:Number=3) {
			pic1=pic1_p;
			pic2=pic2_p;

			w=pic1.width;
			h=pic1.height;
			tolerance=.1;

			slowFx=slowFx_p;
			particlesPerFrameMove=particlesPerFrameMove_p;
			particlesPerFrameColor=particlesPerFrameColor_p;
			offsetX=offsetX_p;
			offsetY=offsetY_p;

			pic1.visible=false;
			pic2.visible=false;

			reset();
		}
		public function reset():void {
			removeEventListener(Event.ENTER_FRAME, movePixels);
			removeEventListener(Event.ENTER_FRAME, moveColors);

			array1=analyzePicture(pic1);
			array2=analyzePicture(pic2);

			movingPixels=new Array();
			for (var i:uint=0; i<array1.length; i++) {
				movingPixels.push(0);
			}
			startI=endI=startCI=endCI=array1.length;
			startI-=firstIndex;
			point=new Point(0, 0);

			for (i=1; i<=3; i++) {
				if (this["bmp"+i]) {
					removeChild(this["bmp"+i]);
					this["bmp"+i]=null;
				}
				if (this["bd"+i]) {
					this["bd"+i]=null;
				}
			}
			bd1=new BitmapData(w+offsetX,h+offsetY,true, 0x00000000);
			bd1.draw(pic1);

			bmp1=new Bitmap(bd1);
			addChild(bmp1);
		}

		private function analyzePicture(picture:DisplayObject):Array {
			picture.alpha=.5;
			var bd:BitmapData=new BitmapData(w,h,true, 0x00000000);
			var outputArray:Array=new Array();

			var avg:uint;
			var rgb:Object;
			var col:Number;
			var i:uint;
			var j:uint;
			var o1:PixelInfo;

			bd.draw(picture);
			for (i=0; i<w; i++) {
				for (j=0; j<h; j++) {
					col=bd.getPixel32(i, j);
					rgb=hexa2rgba(col);
					avg = rgb.r + rgb.g + rgb.b;
					//if (col != 0xFFFFFFFF) {
					//if (rgb.a == 0) {
						o1=new PixelInfo(rgb.a, col, i, j, avg);
						outputArray.push(o1);
					//}
				}
			}
			outputArray.sortOn("alpha", Array.NUMERIC);
			for (var k:uint=0; k<outputArray.length; k++) {
				if(outputArray[k].alpha!=0) {
					firstIndex=k;
					break;
				}
			}
			outputArray.sortOn("avg", Array.NUMERIC | Array.DESCENDING);
			bd.dispose();

			picture.alpha=1;
			return outputArray;
		}

		private function hexa2rgba(hex:Number):Object {
			var a:Number, r:Number, g:Number, b:Number;
			a = (0xFF000000 & hex) >> 24;
			r = (0x00FF0000 & hex) >> 16;
			g = (0x0000FF00 & hex) >> 8;
			b = (0x000000FF & hex);
			return {a:a,r:r,g:g,b:b};
		}

		public function start():void {
			bd2=new BitmapData(w+offsetX,h+offsetY,true, 0x00000000);
			bd3=new BitmapData(w+offsetX,h+offsetY,true, 0x00000000);

			bmp2=new Bitmap(bd2);
			bmp3=new Bitmap(bd3);

			addChild(bmp2);
			addChild(bmp3);

			addEventListener(Event.ENTER_FRAME, movePixels);

		}

		private function movePixels(event:Event):void {
			bd2.fillRect(bd2.rect, 0x00000000);
			var col:Number, ox:Number, oy:Number, tx:Number, ty:Number, dx:Number, dy:Number, ttx:uint, tty:uint;
			for (var i:uint=startI; i<endI; i++) {
				if (movingPixels[i]==0) {
					bd1.setPixel32(array1[i].x, array1[i].y, 0x00ffffff);
					movingPixels[i]=1;
				}
				ox=array1[i].x;
				oy=array1[i].y;
				tx=array2[i].x+offsetX;
				ty=array2[i].y+offsetY;
				dx=(tx-ox);
				dy=(ty-oy);
				if (dx<tolerance && dx>-tolerance && dy<tolerance && dy>-tolerance) {
					endI=i;
					if (endI<=0) {
						addEventListener(Event.ENTER_FRAME, moveColors);
						removeEventListener(Event.ENTER_FRAME, movePixels);
						bmp1.visible=bmp2.visible=false;
						bd1.dispose();
						bd2.dispose();
						return;
					}
				}
				if(array1[i].alpha==0) {
					array1[i].x=tx;
					array1[i].y=ty;
					endI=i;
				} else {
					array1[i].x+=dx/slowFx;
					array1[i].y+=dy/slowFx;
				}
				
				ttx=array1[i].x;
				tty=array1[i].y;
				
				bd2.setPixel32(ttx, tty, array1[i].color);
			}
			startI-=particlesPerFrameMove;
			if (startI<=0) {
				startI=0;
			}
			updateMovingPixels();
		}
		private function updateMovingPixels():void {
			for (var j:uint=startI; j<endI; j++) {
				bd3.setPixel32(array2[j].x+offsetX, array2[j].y+offsetY, array1[j].color);
			}
		}
		private function moveColors(event:Event):void {
			for (var i:uint=startCI; i<endCI; i++) {
				bd3.lock();
				bd3.setPixel32(array2[i].x+offsetX, array2[i].y+offsetY, array2[i].color);
				bd3.unlock();
			}
			endCI=startCI;
			startCI-=1000;
			if (startCI<=0) {
				startCI=0;
			}
			if (endCI<=0) {
				removeEventListener(Event.ENTER_FRAME, moveColors);
			}
		}
	}
}
class PixelInfo {
	public var alpha:uint;
	public var avg:uint;
	public var x:Number;
	public var y:Number;
	public var color:uint;
	function PixelInfo(palpha:uint, pcolor:uint, px:Number, py:Number, pavg:uint) {
		alpha=palpha;
		color=pcolor;
		x=px;
		y=py;
		avg=pavg;
	}
}