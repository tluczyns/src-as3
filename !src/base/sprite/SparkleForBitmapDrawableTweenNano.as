package base.sprite {
	import flash.display.Sprite;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	
	public class SparkleForBitmapDrawableTweenNano extends Sprite {
		
		static public const TO_RADIANS: Number = Math.PI / 180;
		
		private var bmpDrawableForSparkle: IBitmapDrawable;
		private var shpGradientSparkle: Shape;
		private var bmpMaskForSparkle: Bitmap;
		private var intervalRepeatAnim: uint;
		private var timeAnim: Number;
		
		public function SparkleForBitmapDrawableTweenNano(bmpDrawableForSparkle: IBitmapDrawable, dimensionGradient: Number, rotationGradient: Number = 30, color: uint = 0xFFFFFF): void {
			this.bmpDrawableForSparkle = bmpDrawableForSparkle;
			
			var bmpDataMask: BitmapData = SparkleForBitmapDrawable.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableForSparkle);
			this.bmpMaskForSparkle = new Bitmap(bmpDataMask, "auto", true);
			this.addChild(this.bmpMaskForSparkle)
			
			var xLeftEdgeCenterGradientBox: Number = dimensionGradient / 2 - Math.cos(rotationGradient * SparkleForBitmapDrawable.TO_RADIANS) * (dimensionGradient / 2);
			var yLeftEdgeCenterGradientBox: Number = dimensionGradient / 2 - Math.sin(rotationGradient * SparkleForBitmapDrawable.TO_RADIANS) * (dimensionGradient / 2);
			var xLeftBottomGradientBox: Number = Math.tan(rotationGradient * SparkleForBitmapDrawable.TO_RADIANS) * (bmpDataMask.height - yLeftEdgeCenterGradientBox);
			var txGradientBox: Number = xLeftBottomGradientBox - xLeftEdgeCenterGradientBox;
			var widthGradient: Number = dimensionGradient / Math.cos(rotationGradient * SparkleForBitmapDrawable.TO_RADIANS) + Math.tan(rotationGradient * SparkleForBitmapDrawable.TO_RADIANS) * bmpDataMask.height;
			var mrxGradient: Matrix = new Matrix();
			mrxGradient.createGradientBox(dimensionGradient, dimensionGradient, rotationGradient * SparkleForBitmapDrawable.TO_RADIANS, txGradientBox);
			this.shpGradientSparkle = new Shape();
			this.shpGradientSparkle.graphics.beginGradientFill(GradientType.LINEAR, [color, color, color], [0, 1, 0], [0, 127, 255], mrxGradient);
			//this.shpGradientSparkle.graphics.beginGradientFill(GradientType.LINEAR, [color, color, color, color, color], [0.2, 0.5, 1, 0.5, 0.2], [0, 1, 127, 254, 255], mrxGradient);
			this.shpGradientSparkle.graphics.drawRect(0, 0, widthGradient, bmpDataMask.height);
			this.shpGradientSparkle.graphics.endFill();
			this.addChild(this.shpGradientSparkle);
			
			this.bmpMaskForSparkle.cacheAsBitmap = true;
			this.shpGradientSparkle.cacheAsBitmap = true;
			this.shpGradientSparkle.mask = this.bmpMaskForSparkle;
			this.shpGradientSparkle.x = - this.shpGradientSparkle.width;
			
			this.alignToDspObject();
		}
		
		static public function checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc: IBitmapDrawable): BitmapData {
			var bmpDataResult: BitmapData;
			if (bmpDrawableSrc is DisplayObject) {
				var dspObjectSrc: DisplayObject = DisplayObject(bmpDrawableSrc);
				var boundsDspObjectSrc: Rectangle = dspObjectSrc.getBounds(dspObjectSrc);
				var mrxForBounds: Matrix = new Matrix();
				mrxForBounds.translate(-boundsDspObjectSrc.x, -boundsDspObjectSrc.y);
				bmpDataResult = new BitmapData(Math.ceil(dspObjectSrc.width), Math.ceil(dspObjectSrc.height), true, 0x00ffffff);
				bmpDataResult.draw(dspObjectSrc, mrxForBounds, null, null, null, true);		
			} else bmpDataResult = BitmapData(bmpDrawableSrc);
			return bmpDataResult;
		}
		
		public function alignToDspObject(): void {
			if (this.bmpDrawableForSparkle is DisplayObject) {	
				var dspObjForSparkle: DisplayObject = DisplayObject(this.bmpDrawableForSparkle);
				this.x = dspObjForSparkle.x;
				this.y = dspObjForSparkle.y;
				if ((dspObjForSparkle.parent) && (!dspObjForSparkle.parent.contains(this))) dspObjForSparkle.parent.addChild(this);
			}
		}
		
		public function anim(isRepeat: Boolean, repeatDelay: Number = 0, time: Number = 1): void {
			this.timeAnim = time;
			if (!isRepeat) this.shpGradientSparkle.x = - this.shpGradientSparkle.width;
			if (isRepeat) {
				clearInterval(this.intervalRepeatAnim);
				this.intervalRepeatAnim = setInterval(this._anim, repeatDelay);
			}
		}
		
		private function _anim(): void {
			TweenNano.to(this.shpGradientSparkle, this.timeAnim, {x: this.bmpMaskForSparkle.width, ease: Linear.easeNone});
		
		}
		
		public function destroy(): void {
			clearInterval(this.intervalRepeatAnim);
			TweenNano.killTweensOf(this.shpGradientSparkle);
			this.shpGradientSparkle.mask = null;
			this.removeChild(this.bmpMaskForSparkle);
			bmpMaskForSparkle.bitmapData.dispose();
			bmpMaskForSparkle = null;
			this.removeChild(this.shpGradientSparkle);
			this.shpGradientSparkle = null;
			if (this.bmpDrawableForSparkle is DisplayObject) {	
				var dspObjForSparkle: DisplayObject = DisplayObject(this.bmpDrawableForSparkle);
				if ((dspObjForSparkle.parent) && (dspObjForSparkle.parent.contains(this))) dspObjForSparkle.parent.removeChild(this);
			}
		}
		
	}

}