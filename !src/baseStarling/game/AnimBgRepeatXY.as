package baseStarling.game {
	import starling.display.Sprite;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import base.bitmap.BitmapUtils;
	import starling.textures.Texture;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import starling.display.Image;
	import base.math.MathExt;
	
	public class AnimBgRepeatXY extends Sprite {
		
		static private const MAX_DIMENSION_TEXTURE: uint = 2048;
		
		protected var bmpDrawableSegment: IBitmapDrawable;
		private var arrDimensionCover: Array;
		private var arrDimensionGradientToTransparent: Array;
		
		private var scaleTexture: Number;
		private var arrOfArrTextureSegmentFragment: Array;
		private var arrOfArrSegment: Array;
		private var arrDimensionSegment: Array;
		private var bmpDataSegment: BitmapData;
		private var _arrCountSegment: Array;
		public var arrPosAnim: Array = [0, 0];
		
		public function AnimBgRepeatXY(bmpDrawableSegment: IBitmapDrawable, arrDimensionCover: Array = null, arrDimensionGradientToTransparent: Array = null, scaleTexture: Number = 1): void {
			this.bmpDrawableSegment = bmpDrawableSegment;
			this.arrDimensionCover = arrDimensionCover || [0, 0];
			if (!this.arrDimensionGradientToTransparent) this.arrDimensionGradientToTransparent = this.arrDimensionCover;
			else {
				this.arrDimensionGradientToTransparent.length = 2;
				for (var i: uint = 0; i < this.arrDimensionGradientToTransparent.length; i++)
					this.arrDimensionGradientToTransparent[i] = (this.arrDimensionGradientToTransparent[i] == null) ? Math.min(this.arrDimensionGradientToTransparent[i], this.arrDimensionCover[i]) : this.arrDimensionCover[i];
			}
			this.scaleTexture = scaleTexture;
			this.arrOfArrSegment = [];
			this.arrDimensionSegment = [Math.floor(bmpDrawableSegment["width"]), Math.floor(bmpDrawableSegment["height"])];
			this.createBmpDataSegment(bmpDrawableSegment);
			this._arrCountSegment = [0, 0];
			this.setDimensionFromExternal(this.arrDimensionSegment);
		}
		
		public function setDimensionFromDimensionBmpDataSegmentSource(): void {
			this.width = this.bmpDrawableSegment["width"];
			this.height = this.bmpDrawableSegment["height"];
		}
		
		private function createBmpDataSegment(bmpDrawableSegment: IBitmapDrawable): void {
			var bmpDataSegmentWithCorrectSize: BitmapData = BitmapUtils.drawScaled(bmpDrawableSegment, this.scaleTexture);
			var bmpDataSegmentWithOnePassGradientToTransparent: BitmapData = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithCorrectSize, 1, 1, this.arrDimensionGradientToTransparent[1] / bmpDrawableSegment["height"]);
			bmpDataSegmentWithCorrectSize.dispose();
			bmpDataSegmentWithCorrectSize = null;
			var bmpDataSegment: BitmapData = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithOnePassGradientToTransparent, 0, 1, this.arrDimensionGradientToTransparent[0] / bmpDrawableSegment["width"]);
			bmpDataSegmentWithOnePassGradientToTransparent.dispose();
			bmpDataSegmentWithOnePassGradientToTransparent = null;
			var arrOfArrBmpDataSegmentFragment: Array = this.putBmpDataSegmentFragmentsForDimension(bmpDataSegment, "width");
			if (this.arrOfArrTextureSegmentFragment) this.removeArrTextureSegmentFragment();
			this.arrOfArrTextureSegmentFragment = new Array(arrOfArrBmpDataSegmentFragment.length);
			for (var i: uint = 0; i < arrOfArrBmpDataSegmentFragment.length; i++) {
				this.arrOfArrTextureSegmentFragment[i] = new Array(arrOfArrBmpDataSegmentFragment[i].length);
				for (var j: uint = 0; j < arrOfArrBmpDataSegmentFragment[i].length; j++) {
					var bmpDataSegmentFragment: BitmapData = arrOfArrBmpDataSegmentFragment[i][j];
					this.arrOfArrTextureSegmentFragment[i][j] = Texture.fromBitmapData(bmpDataSegmentFragment, false, false);
					if (bmpDataSegmentFragment != bmpDataSegment) bmpDataSegmentFragment.dispose(); //zakomentowane gdy zmienia się orientacja
					bmpDataSegmentFragment = null;
				}
			}
			arrOfArrBmpDataSegmentFragment = [];
			//this.textureSegment = Texture.fromBitmapData(bmpDataSegment)
			bmpDataSegment.dispose(); //zakomentowane gdy zmienia się orientacja
			bmpDataSegment = null;
		}
		
		
		//gdy bitmapdata do tekstury ma animowany wymiar większy niż MAX_DIMENSION_TEXTURE px, to tniemy bitmapdatę na kawałki po MAX_DIMENSION_TEXTURE px
		private function putBmpDataSegmentFragmentsForDimension(bmpDataSegment: BitmapData, nameDimension: String, startX: Number = 0, width: Number = 0): Array {
			var startCoordinate: Number = 0;
			var arrBmpDataSegmentFragment: Array = [];
			while (startCoordinate < bmpDataSegment[nameDimension]) {
				var dimension: Number = Math.min(MAX_DIMENSION_TEXTURE, bmpDataSegment[nameDimension] - startCoordinate);
				if (nameDimension == "width") {
					arrBmpDataSegmentFragment.push(this.putBmpDataSegmentFragmentsForDimension(bmpDataSegment, "height", startCoordinate, dimension));
				} else {
					var bmpDataSegmentFragment: BitmapData = new BitmapData(width, dimension, true, 0x00000000);
					var rectCopyPixelsFromBmpDataSegment: Rectangle = new Rectangle(startX, startCoordinate, width, dimension);
					bmpDataSegmentFragment.copyPixels(bmpDataSegment, rectCopyPixelsFromBmpDataSegment, new Point(0, 0))
					arrBmpDataSegmentFragment.push(bmpDataSegmentFragment);
					
				}
				startCoordinate += dimension;
			}
			return arrBmpDataSegmentFragment;
		}
		
		override public function set width(value: Number): void {}
		
		override public function set height(value: Number): void {}
		
		public function setDimensionFromExternal(arrDimension: Array): void {
			var arrCountSegment: Array = new Array(2);
			for (var i: uint = 0; i < arrCountSegment.length; i++)
				arrCountSegment[i] = Math.max(1 + Math.ceil((arrDimension[i] + this.arrDimensionCover[i]) / (this.arrDimensionSegment[i] - this.arrDimensionCover[i])), 2);
			this.arrCountSegment = arrCountSegment;
			trace("this.arrCountSegment:", arrCountSegment)
			this.updatePosSegments();
		}
		
		public function set arrCountSegment(value: Array): void {
			var arrSegment: Array;
			var segment: Sprite; //Image;
			var imgSegmentFragment: Image;
			var i: uint;
			var j: uint;
			var k: uint;
			var l: uint;
			if (value[0] != this._arrCountSegment[0]) {
				if (value[0] < this._arrCountSegment[0]) {
					for (i = value[0]; i < this._arrCountSegment[0]; i++) {
						arrSegment = this.arrOfArrSegment[i];
						for (j = 0; j < this._arrCountSegment[1]; j++) {
							segment = arrSegment[j];
							for (k = 0; k < segment.numChildren; k++) {
								imgSegmentFragment = Image(segment.getChildAt(0));
								segment.removeChild(imgSegmentFragment);
								imgSegmentFragment.dispose();
								imgSegmentFragment = null;
							}
							this.removeChild(segment);
							segment = null;
						}
						arrSegment = null;
					}
					this.arrOfArrSegment.length = value[0];
				} else {
					this.arrOfArrSegment.length = value[0];
					for (i = this._arrCountSegment[0]; i < value[0]; i++) {
						arrSegment = new Array(this._arrCountSegment[1]);
						for (j = 0; j < this._arrCountSegment[1]; j++) {
							segment = new Sprite();
							for (k = 0; k < this.arrOfArrTextureSegmentFragment.length; k++) {
								for (l = 0; l < this.arrOfArrTextureSegmentFragment[k].length; l++) {
									imgSegmentFragment = new Image(this.arrOfArrTextureSegmentFragment[k][l]);
									imgSegmentFragment.width /= this.scaleTexture;
									imgSegmentFragment.height /= this.scaleTexture;
									imgSegmentFragment.x = MAX_DIMENSION_TEXTURE * k / this.scaleTexture;
									imgSegmentFragment.y = MAX_DIMENSION_TEXTURE * l / this.scaleTexture;
									segment.addChild(imgSegmentFragment);
								}
							}
							arrSegment[j] = segment;
							this.addChild(segment);
						}
						this.arrOfArrSegment[i] = arrSegment;
					}
				}
				this._arrCountSegment[0] = value[0];
			}
			if (value[1] != this._arrCountSegment[1]) {
				for (i = 0; i < this._arrCountSegment[0]; i++) {
					arrSegment = this.arrOfArrSegment[i];
					if (value[1] < this._arrCountSegment[1]) {
						for (j = value[1]; j < this._arrCountSegment[1]; j++) {
							segment = arrSegment[j];
							for (k = 0; k < segment.numChildren; k++) {
								imgSegmentFragment = Image(segment.getChildAt(0));
								segment.removeChild(imgSegmentFragment);
								imgSegmentFragment.dispose();
								imgSegmentFragment = null;
							}
							this.removeChild(segment);
							segment = null;
						}
						arrSegment.length = value[1];
					} else {
						arrSegment.length = value[1];
						for (j = this._arrCountSegment[1]; j < value[1]; j++) {
							segment = new Sprite();
							for (k = 0; k < this.arrOfArrTextureSegmentFragment.length; k++) {
								for (l = 0; l < this.arrOfArrTextureSegmentFragment[k].length; l++) {
									imgSegmentFragment = new Image(this.arrOfArrTextureSegmentFragment[k][l]);
									imgSegmentFragment.width /= this.scaleTexture;
									imgSegmentFragment.height /= this.scaleTexture;
									imgSegmentFragment.x = MAX_DIMENSION_TEXTURE * k / this.scaleTexture;
									imgSegmentFragment.y = MAX_DIMENSION_TEXTURE * l / this.scaleTexture;
									segment.addChild(imgSegmentFragment);
								}
							}
							arrSegment[j] = segment;
							this.addChild(segment);
						}
					}
				}
				this._arrCountSegment[1] = value[1]
			}
		}
		
		//override public function set scaleX(value: Number): void {}
		//override public function set scaleY(value: Number): void {}
		
		public function updatePosSegments(): void {
			var arrStartPosAnimForSegments: Array = new Array(2); 
			for (var i: uint = 0; i < arrStartPosAnimForSegments.length; i++) {
				arrStartPosAnimForSegments[i] = - this.arrDimensionCover[i] - MathExt.moduloPositive(this.arrPosAnim[i], this.arrDimensionSegment[i] - this.arrDimensionCover[i]);
			}
			var arrSegment: Array;
			var segment: Sprite; //Image
			for (i = 0; i < this._arrCountSegment[0]; i++) {
				arrSegment = this.arrOfArrSegment[i];
				for (var j: uint = 0; j < this._arrCountSegment[1]; j++) {
					segment = arrSegment[j];
					segment.x = Math.round(arrStartPosAnimForSegments[0] + (this.arrDimensionSegment[0] - this.arrDimensionCover[0]) * (this._arrCountSegment[0] - 1 - i));
					segment.y = Math.round(arrStartPosAnimForSegments[1] + (this.arrDimensionSegment[1] - this.arrDimensionCover[1]) * (this._arrCountSegment[1] - 1 - j));
				}
			}
		}
		
		private function removeArrTextureSegmentFragment(): void {
			/*if (this.textureSegment) {
				this.textureSegment.dispose();
				this.textureSegment = null;
			}*/
			for (var i: uint = 0; i < this.arrOfArrTextureSegmentFragment.length; i++) {
				for (var j: uint = 0; j < this.arrOfArrTextureSegmentFragment[i].length; j++) {
					var textureSegmentFragment: Texture = this.arrOfArrTextureSegmentFragment[i][j];
					textureSegmentFragment.dispose();
					textureSegmentFragment = null;
				}
			}
			this.arrOfArrTextureSegmentFragment = [];
		}
		
		override public function dispose(): void {
			this.arrCountSegment = [0, 0];
			this.removeArrTextureSegmentFragment();
			super.dispose();
		}
		
	}

}