package base.flashUtils {
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	
	public class TestSpeed extends EventDispatcher {
		
		protected var _speed: Number = -1;
		protected var timeStart: Number;
		protected var _isAbort: Boolean = false;
		protected var timeoutAbort: uint;
		
		public function TestSpeed(timeAbortTest: Number = 2000): void { 
			this.timeoutAbort = setTimeout(this.abort, timeAbortTest);
		}
		
		public function get speed(): Number {
			return this._speed; 
		}
		
		public function start(): void {
			this.timeStart = getTimer();
		}
		
		public function abort(): void {
			this.isAbort = true;
		}
		
		protected function get isAbort(): Boolean {
			return this._isAbort;
		}
		
		protected function set isAbort(value: Boolean): void {
			if (value) this._isAbort = value;
		}
		
		public function destroy(): void {
			clearTimeout(this.timeoutAbort);
		}
		
	}

}