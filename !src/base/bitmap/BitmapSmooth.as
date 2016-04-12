package base.bitmap {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.StageQuality;
	
	public class BitmapSmooth extends BitmapExt {
		
		private var widthRedraw: Number = 1;
		private var heightRedraw: Number = 1;
		
		public function BitmapSmooth(bitmapData: BitmapData = null, pixelSnapping: String = "auto", smoothing: Boolean = true): void {
			if (bitmapData) {
				this.widthRedraw = bitmapData.width;
				this.heightRedraw = bitmapData.height;
			}
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		override public function get width(): Number {
			return this.widthRedraw;
		}
		
		override public function get height(): Number {
			return this.heightRedraw;
		}
		
		override public function set width(value: Number): void {
			this.widthRedraw = value;
			this.redrawSmooth();
		}
			
		override public function set height(value: Number): void {
			this.heightRedraw = value;
			this.redrawSmooth();
		}
		
		override public function get scaleX(): Number {
			var result: Number;
			try {result = this.width / this.bmpDataOrigin.width;}
			catch (e: Error) {result = 1}
			return result;
		}
		
		override public function get scaleY(): Number {
			var result: Number;
			try {result = this.height / this.bmpDataOrigin.height;}
			catch (e: Error) {result = 1}
			return result;
		}
		
		override public function set scaleX(value: Number): void {
			if (value == Infinity) value = 1;
			this.width = value * this.bmpDataOrigin.width;
		}

		override public function set scaleY(value: Number): void {
			if (value == Infinity) value = 1;
			this.height = value * this.bmpDataOrigin.height;
		}
		
		private function redrawSmooth(): void {
			this.isOverwriteBmpDataOrigin = false;
			var transparent: Boolean = true;
			if (this.bitmapData) transparent = this.bitmapData.transparent;
			this.bitmapData = new BitmapData(Math.max(this.widthRedraw, 1), Math.max(this.heightRedraw, 1), transparent);
			this.isOverwriteBmpDataOrigin = true;
			var mrxRedraw: Matrix = new Matrix();
			mrxRedraw.scale(this.widthRedraw / this.bmpDataOrigin.width, this.heightRedraw / this.bmpDataOrigin.height);
			var prevQuality: String;
			if (this.stage) {
				prevQuality = this.stage.quality;
				this.stage.quality = StageQuality.BEST;
			}
			this.bitmapData.draw(this.bmpDataOrigin, mrxRedraw, null, null, null, true);
			if (this.stage) this.stage.quality = prevQuality;	
		}
		
	}

}