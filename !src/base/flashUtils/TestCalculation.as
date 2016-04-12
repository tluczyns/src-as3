package base.flashUtils {
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	public class TestCalculation extends TestSpeed {
		
		public function TestCalculation(timeAbortTest: Number = 100000000): void {
			super(timeAbortTest);
		}
		
		override public function start(): void {
			if (!Capabilities.isDebugger) {
				super.start();
				for (var i:int = 0; i < 20000000; i++) {
					var test:int = i;
					test = test - 1;
					test--;
				}
				for (i = 0; i < 10000000; i++) {
					var testDiv: Number = i/2;
					var testMult: Number = i * .5;
					var testBit: int = i >> 1;
					var n: Number = 1.5;
					var testFloor: Number = Math.floor(n);
					var testUintFloor: uint = uint(n);
					var testIntFloor: int = int(n);
					var testBitShiftFloor: Number = n >> 0;
				}
				this._speed = 1 / (getTimer() - this.timeStart);
			} else this._speed = -1
		}
		
	}

}