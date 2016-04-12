package base.game {
	import flash.display.Sprite;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import base.bitmap.BitmapUtils;
	import flash.display.Bitmap;
	import base.math.MathExt;
	
	public class AnimBgRepeatXY extends Sprite {
		
		private var bmpDrawableSegment: IBitmapDrawable;
		private var arrDimensionCover: Array;
		private var arrDimensionGradientToTransparent: Array;
		
		private var arrOfArrSegment: Array;
		private var arrDimensionSegment: Array;
		private var bmpDataSegment: BitmapData;
		private var containerSegment: Sprite;
		private var maskContainerSegment: Shape;
		private var _arrCountSegment: Array;
		public var arrPosAnim: Array = [0, 0];
		
		public function AnimBgRepeatXY(bmpDrawableSegment: IBitmapDrawable, arrDimensionCover: Array = null, arrDimensionGradientToTransparent: Array = null): void {
			this.bmpDrawableSegment = bmpDrawableSegment;
			this.arrDimensionCover = arrDimensionCover || [0, 0];
			if (!this.arrDimensionGradientToTransparent) this.arrDimensionGradientToTransparent = this.arrDimensionCover;
			else {
				this.arrDimensionGradientToTransparent.length = 2;
				for (var i: uint = 0; i < this.arrDimensionGradientToTransparent.length; i++)
					this.arrDimensionGradientToTransparent[i] = (this.arrDimensionGradientToTransparent[i] == null) ? Math.min(this.arrDimensionGradientToTransparent[i], this.arrDimensionCover[i]) : this.arrDimensionCover[i];
			}
			this.arrOfArrSegment = [];
			this.arrDimensionSegment = [Math.floor(bmpDrawableSegment["width"]), Math.floor(bmpDrawableSegment["height"])];
			this.createBmpDataSegment(bmpDrawableSegment);
			this.createContainerSegment();
			this._arrCountSegment = [0, 0];
			this.setDimensionFromExternal(this.arrDimensionSegment);
		}
		
		private function createBmpDataSegment(bmpDrawableSegment: IBitmapDrawable): void {
			var bmpDataSegmentWithCorrectSize: BitmapData = new BitmapData(this.arrDimensionSegment[0], this.arrDimensionSegment[1]);
			bmpDataSegmentWithCorrectSize.draw(bmpDrawableSegment, null, null, null, null, true);
			var bmpDataSegmentWithOnePassGradientToTransparent: BitmapData = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithCorrectSize, 1, 1, this.arrDimensionGradientToTransparent[1] / bmpDrawableSegment["height"]);
			bmpDataSegmentWithCorrectSize.dispose();
			bmpDataSegmentWithCorrectSize = null;
			this.bmpDataSegment = BitmapUtils.drawWithGradientToTransparent(bmpDataSegmentWithOnePassGradientToTransparent, 0, 1, this.arrDimensionGradientToTransparent[0] / bmpDrawableSegment["width"]);
			bmpDataSegmentWithOnePassGradientToTransparent.dispose();
			bmpDataSegmentWithOnePassGradientToTransparent = null;
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
		
		override public function set width(value: Number): void {}
		
		override public function set height(value: Number): void {}
		
		public function setDimensionFromExternal(arrDimension: Array): void {
			this.maskContainerSegment.width = arrDimension[0];
			this.maskContainerSegment.height = arrDimension[1];
			var arrCountSegment: Array = new Array(2);
			for (var i: uint = 0; i < arrCountSegment.length; i++)
				arrCountSegment[i] = Math.max(1 + Math.ceil((arrDimension[i] + this.arrDimensionCover[i]) / (this.arrDimensionSegment[i] - this.arrDimensionCover[i])), 2);
			this.arrCountSegment = arrCountSegment;
			this.updatePosSegments();
		}
		
		public function set arrCountSegment(value: Array): void {
			var arrSegment: Array;
			var segment: Bitmap;	
			var i: uint;
			var j: uint;
			if (value[0] != this._arrCountSegment[0]) {
				if (value[0] < this._arrCountSegment[0]) {
					for (i = value[0]; i < this._arrCountSegment[0]; i++) {
						arrSegment = this.arrOfArrSegment[i];
						for (j = 0; j < this._arrCountSegment[1]; j++) {
							segment = arrSegment[j];
							this.containerSegment.removeChild(segment);
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
							segment = new Bitmap(this.bmpDataSegment, "auto", true);
							arrSegment[j] = segment;
							this.containerSegment.addChild(segment);
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
							this.containerSegment.removeChild(segment);
							segment = null;
						}
						arrSegment.length = value[1];
					} else {
						arrSegment.length = value[1];
						for (j = this._arrCountSegment[1]; j < value[1]; j++) {
							segment = new Bitmap(this.bmpDataSegment, "auto", true);
							arrSegment[j] = segment;
							this.containerSegment.addChild(segment);
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
			var segment: Bitmap;
			for (i = 0; i < this._arrCountSegment[0]; i++) {
				arrSegment = this.arrOfArrSegment[i];
				for (var j: uint = 0; j < this._arrCountSegment[1]; j++) {
					segment = arrSegment[j];
					segment.x = arrStartPosAnimForSegments[0] + (this.arrDimensionSegment[0] - this.arrDimensionCover[0]) * (this._arrCountSegment[0] - 1 - i);
					segment.y = arrStartPosAnimForSegments[1] + (this.arrDimensionSegment[1] - this.arrDimensionCover[1]) * (this._arrCountSegment[1] - 1 - j);
				}
			}
		}
		
		public function destroy(): void {
			this.arrCountSegment = [0, 0];
			this.removeContainerSegment();
		}
		
	}

}