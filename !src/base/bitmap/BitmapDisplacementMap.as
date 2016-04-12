package base.bitmap {
	import flash.display.BitmapData;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilterMode;
	import flash.events.Event;
	
	public class BitmapDisplacementMap extends BitmapExt {
		
		protected var dmFilter: DisplacementMapFilter;
		
		public function BitmapDisplacementMap(bmpData: BitmapData, bmpDataMap: BitmapData): void {
			this.dmFilter = new DisplacementMapFilter(bmpDataMap, new Point((bmpData.width - bmpDataMap.width) / 2, (bmpData.height - bmpDataMap.height) / 2), BitmapDataChannel.RED, BitmapDataChannel.RED, 0, 0, DisplacementMapFilterMode.COLOR, 0, 0);
			this.stopStartDisplace(1);
			super(bmpData, "auto", true);
		}
		
		protected function onEnterFrameHandler(e: Event = null): void {
			this.filters = new Array(this.dmFilter);
		}
		
		protected function randRange(min: int, max: int): int {
		    var randomNum:int = Math.floor(Math.random() * (max - min + 1)) + min;
		    return randomNum;
		}
		
		public function stopStartDisplace(isStopStart: uint): void {
			if ((isStopStart == 0) && (this.hasEventListener(Event.ENTER_FRAME))) {
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
				this.dmFilter.scaleX = this.dmFilter.scaleY = 0;
				this.onEnterFrameHandler();
			} else if ((isStopStart == 1) && (!this.hasEventListener(Event.ENTER_FRAME))) this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
		}
		
		override public function destroy(): void {
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			super.destroy();
		}
		
	}

}