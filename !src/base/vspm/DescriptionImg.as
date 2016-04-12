package base.vspm {
	import flash.events.EventDispatcher;
	import flash.display.BitmapData;
	import base.loader.progress.LoaderProgress;
	import flash.events.Event;
	
	public class DescriptionImg extends EventDispatcher {
		
		public static const IMG_LOADED: String = "imgLoaded";
		
		public var urlImg: String;
		private var _bmpDataImg: BitmapData;
		public var loaderProgress: LoaderProgress;
		public var num: uint;
	
		public function DescriptionImg(urlImg: String): void {
			this.urlImg = urlImg;
			this._bmpDataImg = new BitmapData(1, 1, true, 0);
		}
		
		public function get bmpDataImg(): BitmapData {
			return this._bmpDataImg;
		}
		
		public function set bmpDataImg(value: BitmapData): void {
			this._bmpDataImg = value;
			this.dispatchEvent(new Event(DescriptionImg.IMG_LOADED));
		}
		
	}

}