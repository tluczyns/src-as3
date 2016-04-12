package base.bitmap {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class BitmapExt extends Bitmap {
		
		public var bmpDataOrigin: BitmapData;
		protected var isOverwriteBmpDataOrigin: Boolean;
		
		public function BitmapExt(bitmapData: BitmapData = null, pixelSnapping: String = "auto", smoothing: Boolean = true): void {
			this.isOverwriteBmpDataOrigin = true;
			this.bmpDataOrigin = bitmapData;
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		override public function set bitmapData(value: BitmapData): void {
			var oldScaleX: Number = this.scaleX;
			var oldScaleY: Number = this.scaleY;
			if (super.bitmapData != this.bmpDataOrigin) super.bitmapData.dispose();
			super.bitmapData = value;
			this.smoothing = true;
			if (this.isOverwriteBmpDataOrigin) {
				this.bmpDataOrigin = value;
				this.scaleX = oldScaleX;
				this.scaleY = oldScaleY;
				this.dispatchEvent(new BitmapExtEvent(BitmapExtEvent.BITMAPDATA_SET));
			}
		}
		
		public function destroy(): void {
			if (this.bmpDataOrigin) this.bmpDataOrigin.dispose();
			if (super.bitmapData) super.bitmapData.dispose();
		}
		
	}

}