package base.game {
	import flash.display.Sprite;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.BlendMode;
	import flash.display.Bitmap;
	
	public class AnimBgRepeatLight extends Sprite {
		
		static public const TO_RADIANS: Number = Math.PI / 180;
		
		private var bmpDrawableSegment: IBitmapDrawable;
		private var isAnimXY: uint;
		private var valDimensionCover: Number;
		private var valDimensionCoverCorrected: Number;
		private var valDimensionGradientToTransparent: Number;
		private var valDimensionGradientToTransparentCorrected: Number;
		
		private var nameDimensionAnim: String;
		private var nameDimensionStatic: String;
		
		private var bmpDataSegment: BitmapData;
		private var arrBmpSegment: Array;
		private var containerBmpSegment: Sprite;
		private var maskContainerBmpSegment: Shape;
		private var ratioValDimensionAnimToStaticOrigBmp: Number;
		private var valDimensionAnimAll: Number;
		private var _countSegmentsBmp: uint;
		
		private var valDimensionAnimBmpSegment: Number;
		private var valDimensionStaticBmpSegment: Number;
		
		private var _posAnim: Number = 0;
		
		public function AnimBgRepeatLight(bmpDrawableSegment: IBitmapDrawable, isAnimXY: uint, valDimensionCover: Number, valDimensionGradientToTransparent: Number = -1): void {
			this.bmpDrawableSegment = bmpDrawableSegment;
			this.isAnimXY = isAnimXY;
			this.valDimensionCover = valDimensionCover;
			this.valDimensionGradientToTransparent = (valDimensionGradientToTransparent != -1) ? Math.min(valDimensionGradientToTransparent, this.valDimensionCover) : this.valDimensionCover;
			this.nameDimensionAnim = ["width", "height"][isAnimXY];
			this.nameDimensionStatic = ["height", "width"][isAnimXY];
			this.arrBmpSegment = [];
			this.createContainerBmpSegment();
			this.ratioValDimensionAnimToStaticOrigBmp = bmpDrawableSegment[this.nameDimensionAnim] / bmpDrawableSegment[this.nameDimensionStatic];
			this._countSegmentsBmp = 0;
			this[this.nameDimensionAnim] = bmpDrawableSegment[this.nameDimensionAnim];
			this[this.nameDimensionStatic] = bmpDrawableSegment[this.nameDimensionStatic];
		}
		
		private function createContainerBmpSegment(): void {
			this.containerBmpSegment = new Sprite();
			this.addChild(this.containerBmpSegment);
			this.maskContainerBmpSegment = new Shape();
			this.maskContainerBmpSegment.graphics.beginFill(0, 1);
			this.maskContainerBmpSegment.graphics.drawRect(0, 0, 1, 1);
			this.maskContainerBmpSegment.graphics.endFill();
			this.addChild(this.maskContainerBmpSegment);
			this.containerBmpSegment.mask = this.maskContainerBmpSegment;
		}
		
		private function removeContainerBmpSegment(): void {
			this.containerBmpSegment.mask = null;
			this.removeChild(this.maskContainerBmpSegment);
			this.maskContainerBmpSegment = null;
			this.removeChild(this.containerBmpSegment);
			this.containerBmpSegment = null;
		}
		
		override public function set width(value: Number): void {
			this.setDimensionFromExternal("width", value);
		}
		
		override public function set height(value: Number): void {
			this.setDimensionFromExternal("height", value);
		}
		
		static public function checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc: IBitmapDrawable): BitmapData {
			var bmpDataResult: BitmapData;
			if (bmpDrawableSrc is DisplayObject) {
				var dspObjectSrc: DisplayObject = DisplayObject(bmpDrawableSrc);
				var boundsDspObjectSrc: Rectangle = dspObjectSrc.getBounds(dspObjectSrc);
				var mrxForBounds: Matrix = new Matrix();
				mrxForBounds.translate(-boundsDspObjectSrc.x, -boundsDspObjectSrc.y);
				mrxForBounds.scale(dspObjectSrc.scaleX, dspObjectSrc.scaleY);
				bmpDataResult = new BitmapData(Math.ceil(dspObjectSrc.width), Math.ceil(dspObjectSrc.height), true, 0x00ffffff);
				bmpDataResult.draw(dspObjectSrc, mrxForBounds, null, null, null, true);		
			} else bmpDataResult = BitmapData(bmpDrawableSrc);
			return bmpDataResult;
		}
		
		static public function drawScaled(bmpDrawableSrc: IBitmapDrawable, scale: Number): BitmapData {
			var bmpDataSrc: BitmapData = AnimBgRepeatLight.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var mrxScaleBmpDataScaled: Matrix = new Matrix();
			mrxScaleBmpDataScaled.scale(scale, scale);
			var bmpDataScaled: BitmapData = new BitmapData(Math.round(bmpDataSrc.width * scale), Math.round(bmpDataSrc.height * scale), true, 0x00FFFFFF);
			bmpDataScaled.draw(bmpDataSrc, mrxScaleBmpDataScaled, null, null, null, true);
			if (bmpDataSrc != bmpDrawableSrc) bmpDataSrc.dispose();
			return bmpDataScaled;
		}
		
		static private function drawEraseGradientToBmpData(bmpDataToDrawEraseGradient: BitmapData, rotationGradient: Number, arrAlpha: Array = null, arrRatio: Array = null): void {
			var arrColor: Array = [];
			for (var i: uint = 0; i < arrAlpha.length; i++) arrColor.push(0);
			var mrxGradient: Matrix = new Matrix();
			mrxGradient.createGradientBox(bmpDataToDrawEraseGradient.width, bmpDataToDrawEraseGradient.height, rotationGradient * AnimBgRepeatLight.TO_RADIANS);
			var maskGradient: Shape = new Shape();
			maskGradient.graphics.beginGradientFill(GradientType.LINEAR, arrColor, arrAlpha, arrRatio, mrxGradient)
			maskGradient.graphics.drawRect(0, 0, bmpDataToDrawEraseGradient.width, bmpDataToDrawEraseGradient.height);
			maskGradient.graphics.endFill();
			bmpDataToDrawEraseGradient.draw(maskGradient, null, null, BlendMode.ALPHA);
		}
		
		static public function drawWithGradientToTransparent(bmpDrawableSrc: IBitmapDrawable, isXY: uint = 0, isStartEnd: uint = 1, ratioDimensionGradientToTransparent: Number = 0.8): BitmapData {
			var bmpDataSrc: BitmapData = AnimBgRepeatLight.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var bmpDataWithGradientToTransparent: BitmapData = new BitmapData(bmpDataSrc.width, bmpDataSrc.height, true, 0x00ffffff)
			bmpDataWithGradientToTransparent.draw(bmpDataSrc, null, null, null, null, true);
			var dimensionGradientToTransparent: Number = Math.round(ratioDimensionGradientToTransparent * 255);
			AnimBgRepeatLight.drawEraseGradientToBmpData(bmpDataWithGradientToTransparent, [0, 90][isXY], [isStartEnd, 1 - isStartEnd], [[dimensionGradientToTransparent, 255 - dimensionGradientToTransparent][isStartEnd], 255]);
			if (bmpDataSrc != bmpDrawableSrc) bmpDataSrc.dispose();
			return bmpDataWithGradientToTransparent;
		}
		
		private function setDimensionFromExternal(nameDimensionChanged: String, value: Number): void {
			this.maskContainerBmpSegment[nameDimensionChanged] = value;
			if (nameDimensionChanged == this.nameDimensionAnim)
				this.valDimensionAnimAll = value;
			else if (nameDimensionChanged == this.nameDimensionStatic) {
				this.valDimensionStaticBmpSegment = value;
				this.valDimensionAnimBmpSegment = this.valDimensionStaticBmpSegment * this.ratioValDimensionAnimToStaticOrigBmp;
				this.valDimensionCoverCorrected = Math.min(this.valDimensionCover, this.valDimensionAnimBmpSegment * 0.7);
				this.valDimensionGradientToTransparentCorrected = Math.min(this.valDimensionGradientToTransparent, this.valDimensionCoverCorrected)
				//reset bmp data segment
				this.countSegmentsBmp = 0;
				var bmpDataSegmentWithCorrectSize: BitmapData = AnimBgRepeatLight.drawScaled(this.bmpDrawableSegment, this.valDimensionStaticBmpSegment / this.bmpDrawableSegment[this.nameDimensionStatic]);
				this.bmpDataSegment = AnimBgRepeatLight.drawWithGradientToTransparent(bmpDataSegmentWithCorrectSize, this.isAnimXY, 1, this.valDimensionGradientToTransparentCorrected / this.valDimensionAnimBmpSegment);
			}
			//trace("setDimensionFromExternal:", this.valDimensionAnimAll, this.valDimensionCover, this.valDimensionAnimBmpSegment)
			this.countSegmentsBmp = Math.max(1 + Math.ceil((this.valDimensionAnimAll + this.valDimensionCoverCorrected) / (this.valDimensionAnimBmpSegment - this.valDimensionCoverCorrected)), 2);
			this.posAnim = this.posAnim;
		}
		
		public function get countSegmentsBmp(): uint {
			return this._countSegmentsBmp;
		}
		
		public function set countSegmentsBmp(value: uint): void {
			//trace("val countSegmentsBmp:", value)
			if (value != this._countSegmentsBmp) {
				var i: uint;
				var bmpSegment: Bitmap;
				if (value < this._countSegmentsBmp) {
					for (i = value; i < this._countSegmentsBmp; i++) {
						bmpSegment = this.arrBmpSegment[i];
						this.containerBmpSegment.removeChild(bmpSegment);
						bmpSegment = null;
					}
					this.arrBmpSegment.length = value;
				} else {
					this.arrBmpSegment.length = value;
					for (i = this._countSegmentsBmp; i < value; i++) {
						bmpSegment = new Bitmap(this.bmpDataSegment, "auto", true);
						this.arrBmpSegment[i] = bmpSegment;
						this.containerBmpSegment.addChild(bmpSegment);
					}
				}
				this._countSegmentsBmp = value;
			}
		}
		
		override public function set scaleX(value: Number): void {}
		override public function set scaleY(value: Number): void {}
		
		public function get posAnim(): Number {
			return this._posAnim;
		}
		
		static public function floorRange(val: Number, range: Number): Number {
			return Math.floor(val / range) * range;
		}

		//moduloRangePositive(-7.3, 5) = 2.7, moduloRangePositive(8, 5) = 3
		static public function moduloPositive(val: Number, range: Number): Number {
			return val - AnimBgRepeatLight.floorRange(val, range);
		}
    	
		
		public function set posAnim(value: Number): void {
			this._posAnim = value;
			var startPosAnimForSegments: Number = - this.valDimensionCoverCorrected - AnimBgRepeatLight.moduloPositive(posAnim, this.valDimensionAnimBmpSegment - this.valDimensionCoverCorrected);
			for (var i: uint = 0; i < this.arrBmpSegment.length; i++) {
				var bmpSegment: Bitmap = this.arrBmpSegment[i];
				bmpSegment.x = startPosAnimForSegments + (this.valDimensionAnimBmpSegment - this.valDimensionCoverCorrected) * (this.arrBmpSegment.length - 1 - i);
			}
		}
		
		public function destroy(): void {
			this.countSegmentsBmp = 0;
			this.removeContainerBmpSegment();
		}
		
	}

}