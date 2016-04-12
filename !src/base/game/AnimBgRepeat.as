package base.game {
	import flash.display.Sprite;
	import flash.display.IBitmapDrawable;
	import base.bitmap.BitmapUtils;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import base.math.MathExt;
	
	public class AnimBgRepeat extends Sprite {
		
		private var bmpDrawableSegment: IBitmapDrawable;
		private var isAnimXY: uint;
		private var valDimensionCover: Number;
		private var valDimensionCoverCorrected: Number;
		private var valDimensionGradientToTransparent: Number;
		private var valDimensionGradientToTransparentCorrected: Number;
		
		private var nameDimensionAnim: String;
		private var nameDimensionStatic: String;
		private var nameCoordinateAnim: String;
		
		private var bmpDataSegment: BitmapData;
		private var arrSegment: Array;
		private var containerSegment: Sprite;
		private var maskContainerSegment: Shape;
		private var ratioValDimensionAnimToStaticOrigBmp: Number;
		private var valDimensionAnimAll: Number;
		private var _countSegments: uint;
		
		private var valDimensionAnimSegment: Number;
		private var valDimensionStaticSegment: Number;
		
		private var _posAnim: Number = 0;
		
		public function AnimBgRepeat(bmpDrawableSegment: IBitmapDrawable, isAnimXY: uint, valDimensionCover: Number, valDimensionGradientToTransparent: Number = -1): void {
			this.bmpDrawableSegment = bmpDrawableSegment;
			this.isAnimXY = isAnimXY;
			this.valDimensionCover = valDimensionCover;
			this.valDimensionGradientToTransparent = (valDimensionGradientToTransparent != -1) ? Math.min(valDimensionGradientToTransparent, this.valDimensionCover) : this.valDimensionCover;
			this.nameDimensionAnim = ["width", "height"][isAnimXY];
			this.nameDimensionStatic = ["height", "width"][isAnimXY];
			this.nameCoordinateAnim = ["x", "y"][isAnimXY];
			this.arrSegment = [];
			this.createContainerSegment();
			this.ratioValDimensionAnimToStaticOrigBmp = bmpDrawableSegment[this.nameDimensionAnim] / bmpDrawableSegment[this.nameDimensionStatic];
			this._countSegments = 0;
			this[this.nameDimensionAnim] = bmpDrawableSegment[this.nameDimensionAnim];
			this[this.nameDimensionStatic] = bmpDrawableSegment[this.nameDimensionStatic];
		}
		
		private function createContainerSegment(): void {
			this.containerSegment = new Sprite();
			this.addChild(this.containerSegment);
			this.maskContainerSegment = new Shape();
			this.maskContainerSegment.graphics.beginFill(0, 1);
			this.maskContainerSegment.graphics.drawRect(0, 0, 1, 1);
			this.maskContainerSegment.graphics.endFill();
			this.addChild(this.maskContainerSegment);
			this.containerSegment.mask = this.maskContainerSegment;
		}
		
		private function removeContainerSegment(): void {
			this.containerSegment.mask = null;
			this.removeChild(this.maskContainerSegment);
			this.maskContainerSegment = null;
			this.removeChild(this.containerSegment);
			this.containerSegment = null;
		}
		
		override public function set width(value: Number): void {
			this.setDimensionFromExternal("width", value);
		}
		
		override public function set height(value: Number): void {
			this.setDimensionFromExternal("height", value);
		}
		
		public function setDimensionFromExternal(nameDimensionChanged: String, value: Number): void {
			this.maskContainerSegment[nameDimensionChanged] = value;
			if (nameDimensionChanged == this.nameDimensionAnim)
				this.valDimensionAnimAll = value;
			else if (nameDimensionChanged == this.nameDimensionStatic) {
				this.valDimensionStaticSegment = value;
				this.valDimensionAnimSegment = this.valDimensionStaticSegment * this.ratioValDimensionAnimToStaticOrigBmp;
				this.valDimensionCoverCorrected = Math.min(this.valDimensionCover, this.valDimensionAnimSegment * 0.7);
				this.valDimensionGradientToTransparentCorrected = Math.min(this.valDimensionGradientToTransparent, this.valDimensionCoverCorrected)
				//reset bmp data segment
				this.countSegments = 0;
				var bmpDataSegmentWithCorrectSize: BitmapData = BitmapUtils.drawScaled(this.bmpDrawableSegment, this.valDimensionStaticSegment / this.bmpDrawableSegment[this.nameDimensionStatic]);
				this.bmpDataSegment = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithCorrectSize, this.isAnimXY, 1, this.valDimensionGradientToTransparentCorrected / this.valDimensionAnimSegment);
				bmpDataSegmentWithCorrectSize.dispose();
				bmpDataSegmentWithCorrectSize = null;
			}
			//trace("setDimensionFromExternal:", this.valDimensionAnimAll, this.valDimensionCover, this.valDimensionAnimSegment)
			if ((this.valDimensionAnimAll) && (this.valDimensionAnimSegment)) {
				this.countSegments = Math.max(1 + Math.ceil((this.valDimensionAnimAll + this.valDimensionCoverCorrected) / (this.valDimensionAnimSegment - this.valDimensionCoverCorrected)), 2);
				this.posAnim = this.posAnim;
			}
		}
		
		public function get countSegments(): uint {
			return this._countSegments;
		}
		
		public function set countSegments(value: uint): void {
			//trace("val countSegments:", value)
			if (value != this._countSegments) {
				var i: uint;
				var segment: Bitmap;
				if (value < this._countSegments) {
					for (i = value; i < this._countSegments; i++) {
						segment = this.arrSegment[i];
						this.containerSegment.removeChild(segment);
						segment = null;
					}
					this.arrSegment.length = value;
				} else {
					this.arrSegment.length = value;
					for (i = this._countSegments; i < value; i++) {
						segment = new Bitmap(this.bmpDataSegment, "auto", true);
						this.arrSegment[i] = segment;
						this.containerSegment.addChild(segment);
					}
				}
				this._countSegments = value;
			}
		}
		
		override public function set scaleX(value: Number): void {}
		override public function set scaleY(value: Number): void {}
		
		public function get posAnim(): Number {
			return this._posAnim;
		}
		
		public function set posAnim(value: Number): void {
			this._posAnim = value;
			var startPosAnimForSegments: Number = - this.valDimensionCoverCorrected - MathExt.moduloPositive(posAnim, this.valDimensionAnimSegment - this.valDimensionCoverCorrected);
			for (var i: uint = 0; i < this.arrSegment.length; i++) {
				var segment: Bitmap = this.arrSegment[i];
				segment[this.nameCoordinateAnim] = startPosAnimForSegments + (this.valDimensionAnimSegment - this.valDimensionCoverCorrected) * (this.arrSegment.length - 1 - i);
			}
		}
		
		public function destroy(): void {
			this.countSegments = 0;
			this.removeContainerSegment();
			if (this.bmpDataSegment) {
				this.bmpDataSegment.dispose();
				this.bmpDataSegment = null;
			}
		}
		
	}

}