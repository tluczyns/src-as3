package com.bit101.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BigAssCanvas extends Sprite
	{
		protected var _bitmaps:Array;
		private var _width:Number;
		private var _height:Number;
		protected var _transparent:Boolean;
		protected var _color:uint;
		
		
		public function BigAssCanvas(w:Number, h:Number, transparent:Boolean = false, color:uint = 0xffffff)
		{
			_width = Math.round(w);
			_height = Math.round(h);
			_transparent = transparent;
			_color = color;
			makeBitmaps();
		}
		
		private function makeBitmaps():void
		{
			_bitmaps = new Array();
			var h:Number = _height;
			var ypos:Number = 0;
			
			while(h > 0)
			{
				var xpos:Number = 0;
				var w:Number = _width;
				_bitmaps.push([]);
				while(w > 0)
				{
					var bmp:Bitmap = this.createBitmap(w, h);
					bmp.x = xpos;
					bmp.y = ypos;
					addChild(bmp);
					_bitmaps[_bitmaps.length - 1].push(bmp);
					w -= bmp.width;
					xpos += bmp.width;
				}
				ypos += Math.min(2880, h);
				h -= Math.min(2880, h);
			}
		}
		
		protected function createBitmap(w: Number, h: Number): Bitmap {
			return new Bitmap(new BitmapData(Math.min(2880, w), Math.min(2880, h), _transparent, _color), "auto", true);	
		}
		
		public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = true):void
		{
			if(matrix == null) matrix = new Matrix();
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					var temp:Matrix = matrix.clone();
					temp.tx -= bmp.x;
					temp.ty -= bmp.y;
					
					var tempRect:Rectangle;
					if(clipRect != null)
					{
						tempRect = clipRect.clone();
						tempRect.x -= bmp.x;
						tempRect.y -= bmp.y;
					}
					else
					{
						tempRect = null;
					}
					bmp.bitmapData.draw(source, temp, colorTransform, blendMode, tempRect, smoothing);
				}
			}
		}
		
		public function dispose():void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					removeChild(bmp);
					bmp.bitmapData.dispose();
				}
			}
			_bitmaps = [];
		}
		
		public function fillRect(rect:Rectangle, color:uint):void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					var temp:Rectangle = rect.clone();
					temp.x -= bmp.x;
					temp.y -= bmp.y;
					bmp.bitmapData.fillRect(temp, color);
				}
			}
		}
		
		public function getPixel(x:Number, y:Number):uint
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					if(x >= bmp.x && x < bmp.x + bmp.width && y >= bmp.y && y < bmp.y + bmp.height)
					{
						return bmp.bitmapData.getPixel(x - bmp.x, y - bmp.y);
					}
				}
			}
			return 0;
		}
		
		public function setPixel(x:Number, y:Number, color:uint):void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					if(x >= bmp.x && x < bmp.x + bmp.width && y >= bmp.y && y < bmp.y + bmp.height)
					{
						bmp.bitmapData.setPixel(Math.round(x - bmp.x), Math.round(y - bmp.y), color);
					}
				}
			}
		}
		
		public function getPixel32(x:Number, y:Number):uint
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					if(x >= bmp.x && x < bmp.x + bmp.width && y >= bmp.y && y < bmp.y + bmp.height)
					{
						return bmp.bitmapData.getPixel32(x - bmp.x, y - bmp.y);
					}
				}
			}
			return 0;
		}
		
		public function setPixel32(x:Number, y:Number, color:uint):void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					if(x >= bmp.x && x < bmp.x + bmp.width && y >= bmp.y && y < bmp.y + bmp.height)
					{
						bmp.bitmapData.setPixel32(x - bmp.x, y - bmp.y, color);
					}
				}
			}
		}
		
		public function noise(randomSeed:int, low:uint = 0, high:uint = 255, channelOptions:uint = 7, grayScale:Boolean = false):void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					bmp.bitmapData.noise(randomSeed, low, high, channelOptions, grayScale);
				}
			}
		}
		
		public function perlinNoise(baseX:Number, baseY:Number, numOctaves:uint, randomSeed:int, fractalNoise:Boolean, channelOptions:uint = 7, grayScale:Boolean = false):void
		{
			var offsets:Array = new Array();
			for(var i:int = 0; i < numOctaves; i++)
			{
				offsets.push(new Point());
			}
			for (i = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					var temp:Array = new Array();
					for(var k:int = 0; k < offsets.length; k++)
					{
						temp[k] = new Point(offsets[k].x + bmp.x, offsets[k].y + bmp.y);
					}
					bmp.bitmapData.perlinNoise(baseX, baseY, numOctaves, randomSeed, false, fractalNoise, channelOptions, grayScale, temp);
				}
			}
		}
		
		public function lock():void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					bmp.bitmapData.lock();
				}
			}
		}
		
		public function unlock():void
		{
			for (var i:int = 0; i < _bitmaps.length; i++) {
				for(var j:int = 0; j < _bitmaps[i].length; j++)	{
					var bmp:Bitmap = _bitmaps[i][j] as Bitmap;
					bmp.bitmapData.unlock();
				}
			}
		}
	}
}