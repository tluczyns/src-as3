package base.flashUtils {
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.utils.clearTimeout;

	public class TestBandwidth extends TestSpeed {
		
		public var urlPathTest: String;
		public var debug: Boolean = false;
		private var loader: Loader;
		
		public function TestBandwidth(urlPathTest: String, timeAbortTest: Number = 50000): void {
			this.urlPathTest = urlPathTest;
			super(timeAbortTest);
		}
		
		override public function start(): void {
			this.createLoader();
		}
		
		private function createLoader(): void {
			this.loader = new Loader( );
			this.loader.contentLoaderInfo.addEventListener(Event.OPEN, this.onOpen);
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onComplete);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			this.loader.load(new URLRequest(this.urlPathTest + "?" + String(Math.random() * 100000)));
		}
		
		private function onOpen(e: Event):void {
			super.start();
		}
		
		private function onComplete(e: Event): void {
			var timeTotal: Number = (getTimer() - this.timeStart) / 1000;
			var mBTotal: Number = e.currentTarget.bytesTotal / 1024 / 1024;
			this._speed = mBTotal / timeTotal;
			//trace("total time: " + timeTotal + ", total MB: " + mBTotal + ", speed: " + speed + " MB/s" );
			clearTimeout(this.timeoutAbort);
			this.removeLoader();
		}
		
		private function onIOError(e: IOErrorEvent): void {
			//trace("onIOError")
			clearTimeout(this.timeoutAbort);
			this.removeLoader();
		}
		
		private function removeLoader(): void {
			
			this.loader.contentLoaderInfo.removeEventListener(Event.OPEN, this.onOpen);
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onComplete);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			try {
				this.loader.close();
				this.loader.unload();
				this.loader = null;
			} catch (e: Error) {}
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override protected function set isAbort(value: Boolean): void {
			if (value) {
				super.isAbort = value;
				this.removeLoader();
			}
		}
		
	}
}