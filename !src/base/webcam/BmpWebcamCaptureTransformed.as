package base.webcam {
	import flash.filters.BitmapFilter;
	import flash.events.Event;
	
	public class BmpWebcamCaptureTransformed extends BmpWebcamCapture {
		
		private var bmpFilter: BitmapFilter;
		
		public function BmpWebcamCaptureTransformed(width: uint, height: uint, bmpFilter: BitmapFilter, fps: uint = 30): void {
			super(width, height, fps);
			this.bmpFilter = bmpFilter;
		}
		
		override protected function onEnterFrameHandler(e: Event): void {
			super.onEnterFrameHandler(e);
			this.bitmapData.applyFilter(this.bitmapData, this.bitmapData.rect, this.bitmapData.rect.topLeft, this.bmpFilter);
		}
		
	}

}