package base.bitmap {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.filters.BitmapFilter;
	import flash.events.Event;

	public class BitmapTransformed extends BitmapExt {
		
		private var mrxTransform: Matrix;
		private var bmpFilter: BitmapFilter;
		
		public function BitmapTransformed(bmpData: BitmapData = null, mrxTransform: Matrix = null, bmpFilter: BitmapFilter = null): void {
			this.mrxTransform = (mrxTransform != null) ? mrxTransform : new Matrix();
			this.bmpFilter = bmpFilter;
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			super(bmpData, "auto", true);
		}
		
		protected function onEnterFrameHandler(e: Event):void {
			this.bitmapData.draw(this.bmpDataOrigin, this.mrxTransform, null, null, null, true);
			if (this.bmpFilter != null) this.bitmapData.applyFilter(this.bitmapData, this.bitmapData.rect, this.bitmapData.rect.topLeft, this.bmpFilter);
		}
		
	}

}