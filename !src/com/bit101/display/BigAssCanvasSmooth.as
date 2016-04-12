package com.bit101.display {
	import flash.display.Bitmap;
	import base.bitmap.BitmapSmooth;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	public class BigAssCanvasSmooth extends BigAssCanvas {
		
		public function BigAssCanvasSmooth(w:Number, h:Number, transparent:Boolean = false, color:uint = 0xffffff): void {
			super(w, h, transparent, color);
		}
		
		override protected function createBitmap(w: Number, h: Number): Bitmap {
			return new BitmapSmooth(new BitmapData(Math.min(2880, w), Math.min(2880, h), _transparent, _color));	
		}
		
		override public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void {
			super.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
			//this.setBmpDataOriginFromBmpData();
		}
		
		override public function set width(value: Number): void {
			var scaleWidth: Number = value / this.width;
			for (var i: uint = 0; i < _bitmaps.length; i++) {
				var sumWidth: Number = 0;	
				for (var j: uint = 0; j < _bitmaps[i].length; j++)	{
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.width = Math.round(bmp.width * scaleWidth);
				}
			}
			this.arrangePosXBmps();
		}
		
		override public function set height(value: Number): void {
			var scaleHeight: Number = value / this.height;
			for (var j: uint = 0; j < _bitmaps[0].length; j++)	{
				for (var i: uint = 0; i < _bitmaps.length; i++) {
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.height = Math.round(bmp.height * scaleHeight);
				}
			}
			this.arrangePosYBmps();
		}

		override public function get scaleX(): Number {
			return BitmapSmooth(_bitmaps[0][0]).scaleX;
		}
		
		override public function set scaleX(value: Number): void {
			for (var i: uint = 0; i < _bitmaps.length; i++) {
				for (var j: uint = 0; j < _bitmaps[i].length; j++)	{
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.width = Math.round(bmp.bmpDataOrigin.width * value);
				}
			}
			this.arrangePosXBmps();
		}
		
		override public function get scaleY(): Number {
			return BitmapSmooth(_bitmaps[0][0]).scaleY;
		}

		override public function set scaleY(value: Number): void {
			var scaleHeight: Number = value / this.height;
			for (var j:int = 0; j < _bitmaps[0].length; j++)	{
				for (var i:int = 0; i < _bitmaps.length; i++) {
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.height = Math.round(bmp.bmpDataOrigin.height * value);
				}
			}
			this.arrangePosYBmps();
		}
		
		private function arrangePosXBmps(): void {
			for (var i: uint = 0; i < _bitmaps.length; i++) {
				var sumWidth: Number = 0;	
				for (var j: uint = 0; j < _bitmaps[i].length; j++) {
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.x = sumWidth;
					sumWidth += Math.round(bmp.width);
				}
			}
		}

		private function arrangePosYBmps(): void {
			for (var j: uint = 0; j < _bitmaps[0].length; j++) {
				var sumHeight: Number = 0;	
				for (var i: uint = 0; i < _bitmaps.length; i++) {
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.y = sumHeight;
					sumHeight += Math.round(bmp.height);
				}
			}
		}
		
		public function setBmpDataOriginFromBmpData(): void {
			for (var i: uint = 0; i < _bitmaps.length; i++) {
				for (var j: uint = 0; j < _bitmaps[i].length; j++) {
					var bmp: BitmapSmooth = BitmapSmooth(_bitmaps[i][j]);
					bmp.bmpDataOrigin = bmp.bitmapData;
				}
			}
		}
		
	}

}