package baseStarling.game {
	import starling.display.Sprite;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import base.bitmap.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import starling.textures.Texture;
	import starling.display.Image;
	import base.math.MathExt;
	
	public class AnimBgRepeat extends Sprite {
		
		static private const MAX_DIMENSION_TEXTURE: uint = 2048;
		
		protected var bmpDrawableSegment: IBitmapDrawable;
		private var isAnimXY: uint;
		private var valDimensionCover: Number;
		private var valDimensionCoverCorrected: Number;
		private var valDimensionGradientToTransparent: Number;
		private var valDimensionGradientToTransparentCorrected: Number;
		
		private var nameDimensionAnim: String;
		protected var nameDimensionStatic: String;
		private var nameCoordinateAnim: String;
		
		private var scaleTexture: Number;		
		private var arrTextureSegmentFragment: Array;
		private var arrSegment: Array;
		private var ratioValDimensionAnimToStaticOrigBmp: Number;
		private var valDimensionAnimAll: Number;
		private var _countSegments: uint;
		
		private var valDimensionAnimSegment: Number;
		private var valDimensionStaticSegment: Number;
		
		private var _posAnim: Number = 0;
		
		public function AnimBgRepeat(bmpDrawableSegment: IBitmapDrawable, isAnimXY: uint, valDimensionCover: Number, valDimensionGradientToTransparent: Number = -1, scaleTexture: Number = 1): void {
			this.bmpDrawableSegment = bmpDrawableSegment;
			this.isAnimXY = isAnimXY;
			this.valDimensionCover = valDimensionCover;
			this.valDimensionGradientToTransparent = (valDimensionGradientToTransparent != -1) ? Math.min(valDimensionGradientToTransparent, this.valDimensionCover) : this.valDimensionCover;
			this.nameDimensionAnim = ["width", "height"][isAnimXY];
			this.nameDimensionStatic = ["height", "width"][isAnimXY];
			this.nameCoordinateAnim = ["x", "y"][isAnimXY];
			this.scaleTexture = scaleTexture;
			this.arrSegment = [];
			//this.clipRect = new Rectangle(0, 0, 1, 1);
			this._countSegments = 0;
		}
		
		public function setDimensionFromDimensionBmpDataSegmentSource(): void {
			this[this.nameDimensionAnim] = this.bmpDrawableSegment[this.nameDimensionAnim];
			this[this.nameDimensionStatic] = this.bmpDrawableSegment[this.nameDimensionStatic];
		}
		
		override public function get width(): Number {
			return this.getDimension("width");
		}
		
		override public function set width(value: Number): void {
			this.setDimensionFromExternal("width", value);
		}
		
		override public function get height(): Number {
			return this.getDimension("height");
		}
		
		override public function set height(value: Number): void {
			this.setDimensionFromExternal("height", value);
		}
		
		private function getDimension(nameDimensionGet: String): Number {
			var value: Number;
			if (nameDimensionGet == this.nameDimensionAnim) value = this.valDimensionAnimAll;
			else if (nameDimensionGet == this.nameDimensionStatic) value = this.valDimensionStaticSegment;
			return value;
		}
		
		protected function setDimensionFromExternal(nameDimensionChanged: String, value: Number): void {
			//this.clipRect[nameDimensionChanged] = value;
			if (nameDimensionChanged == this.nameDimensionAnim)
				this.valDimensionAnimAll = value;
			else if (nameDimensionChanged == this.nameDimensionStatic) {
				this.valDimensionStaticSegment = value;
				if (!this.ratioValDimensionAnimToStaticOrigBmp) this.ratioValDimensionAnimToStaticOrigBmp = this.bmpDrawableSegment[this.nameDimensionAnim] / this.bmpDrawableSegment[this.nameDimensionStatic];
				this.valDimensionAnimSegment = this.valDimensionStaticSegment * this.ratioValDimensionAnimToStaticOrigBmp - 2;
				this.valDimensionCoverCorrected = Math.min(this.valDimensionCover, this.valDimensionAnimSegment * 0.7);
				this.valDimensionGradientToTransparentCorrected = Math.min(this.valDimensionGradientToTransparent, this.valDimensionCoverCorrected)
				//reset bmp data segment
				this.countSegments = 0;
				var bmpDataSegmentWithCorrectSize: BitmapData = BitmapUtils.drawScaled(this.bmpDrawableSegment, this.valDimensionStaticSegment / this.bmpDrawableSegment[this.nameDimensionStatic] * this.scaleTexture);
				var bmpDataSegment: BitmapData  = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithCorrectSize, this.isAnimXY, 1, this.valDimensionGradientToTransparentCorrected / this.valDimensionAnimSegment);
				bmpDataSegmentWithCorrectSize.dispose();
				bmpDataSegmentWithCorrectSize = null;
				//gdy bitmapdata do tekstury ma animowany wymiar większy niż MAX_DIMENSION_TEXTURE px, to tniemy bitmapdatę na kawałki po MAX_DIMENSION_TEXTURE px
				var arrBmpDataSegmentFragment: Array = [];
				var bmpDataSegmentFragment: BitmapData;
				if (bmpDataSegment[this.nameDimensionAnim] <= MAX_DIMENSION_TEXTURE) arrBmpDataSegmentFragment.push(bmpDataSegment);
				else {
					var startCoordinateAnim: Number = 0;
					while (startCoordinateAnim < bmpDataSegment[this.nameDimensionAnim]) {
						var dimensionAnim: Number = Math.min(MAX_DIMENSION_TEXTURE, bmpDataSegment[this.nameDimensionAnim] - startCoordinateAnim);
						var rectCopyPixelsFromBmpDataSegment: Rectangle;
						if (this.nameDimensionAnim == "width") {
							bmpDataSegmentFragment = new BitmapData(dimensionAnim, bmpDataSegment[this.nameDimensionStatic], true, 0x00000000);
							rectCopyPixelsFromBmpDataSegment = new Rectangle(startCoordinateAnim, 0, dimensionAnim, bmpDataSegment[this.nameDimensionStatic]);
						} else {
							bmpDataSegmentFragment = new BitmapData(bmpDataSegment[this.nameDimensionStatic], dimensionAnim, true, 0x00000000);
							rectCopyPixelsFromBmpDataSegment = new Rectangle(0, startCoordinateAnim, bmpDataSegment[this.nameDimensionStatic], dimensionAnim);
						}
						bmpDataSegmentFragment.copyPixels(bmpDataSegment, rectCopyPixelsFromBmpDataSegment, new Point(0, 0))
						arrBmpDataSegmentFragment.push(bmpDataSegmentFragment);
						startCoordinateAnim += dimensionAnim;
					}
				}
				if (this.arrTextureSegmentFragment) this.removeArrTextureSegmentFragment();
				this.arrTextureSegmentFragment = new Array(arrBmpDataSegmentFragment.length);
				for (var i: uint = 0; i < arrBmpDataSegmentFragment.length; i++) {
					bmpDataSegmentFragment = arrBmpDataSegmentFragment[i];
					this.arrTextureSegmentFragment[i] = Texture.fromBitmapData(bmpDataSegmentFragment, false, false);
					if (bmpDataSegmentFragment != bmpDataSegment) bmpDataSegmentFragment.dispose(); //zakomentowane gdy zmienia się orientacja
					bmpDataSegmentFragment = null;
				}
				arrBmpDataSegmentFragment = [];
				//this.textureSegment = Texture.fromBitmapData(bmpDataSegment)
				bmpDataSegment.dispose(); //zakomentowane gdy zmienia się orientacja
				bmpDataSegment = null;
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
				var j: uint
				var segment: Sprite; //Image;
				var imgSegmentFragment: Image;
				if (value < this._countSegments) {
					for (i = value; i < this._countSegments; i++) {
						segment = this.arrSegment[i];
						for (j = 0; j < segment.numChildren; j++) {
							imgSegmentFragment = Image(segment.getChildAt(0));
							segment.removeChild(imgSegmentFragment);
							imgSegmentFragment.dispose();
							imgSegmentFragment = null;
						}
						this.removeChild(segment);
						segment = null;
					}
					this.arrSegment.length = value;
				} else {
					this.arrSegment.length = value;
					for (i = this._countSegments; i < value; i++) {
						//segment = new Image(this.textureSegment);
						segment = new Sprite();
						for (j = 0; j < this.arrTextureSegmentFragment.length; j++) {
							imgSegmentFragment = new Image(this.arrTextureSegmentFragment[j]);
							imgSegmentFragment.width /= this.scaleTexture;
							imgSegmentFragment.height /= this.scaleTexture;
							imgSegmentFragment[this.nameCoordinateAnim] = MAX_DIMENSION_TEXTURE * j / this.scaleTexture;
							segment.addChild(imgSegmentFragment)
						}
						this.arrSegment[i] = segment;
						this.addChild(segment);
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
				var segment: Sprite = this.arrSegment[i]; //Image
				segment[this.nameCoordinateAnim] = Math.round(startPosAnimForSegments + (this.valDimensionAnimSegment - this.valDimensionCoverCorrected) * (this.arrSegment.length - 1 - i));
			}
		}
		
		private function removeArrTextureSegmentFragment(): void {
			/*if (this.textureSegment) {
				this.textureSegment.dispose();
				this.textureSegment = null;
			}*/
			for (var i: uint = 0; i < this.arrTextureSegmentFragment.length; i++) {
				var textureSegmentFragment: Texture = this.arrTextureSegmentFragment[i];
				textureSegmentFragment.dispose();
				textureSegmentFragment = null;
			}
			this.arrTextureSegmentFragment = [];
		}
		
		override public function dispose(): void {
			this.countSegments = 0;
			this.removeArrTextureSegmentFragment();
			super.dispose();
		}
		
	}

}