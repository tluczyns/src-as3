package base.flashUtils {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ExampleFlashUtilsSetTimeout extends Sprite {
		
		private var numFrame: uint;
		private var idTimeout: uint;
		
		public function ExampleFlashUtilsSetTimeout(): void {
			this.numFrame = 0;
			this.addEventListener(Event.ENTER_FRAME, this.oEF)
			this.idTimeout = FlashUtils.setTimeout(this.afterTimeout, 1000, ["bbb", "ccc"])
		}
		
		private function oEF(e: Event): void {
			if (this.numFrame == 10) {
				FlashUtils.pauseTimeout(this.idTimeout)
			} else if (this.numFrame == 50) {
				FlashUtils.continueTimeout(this.idTimeout)
			} else if (this.numFrame == 60) {
				//FlashUtils.clearTimeout(this.idTimeout);
			}
			this.numFrame++
			
		}
		
		private function afterTimeout(str1: String, str2: String): void {
			trace("this.numFrame:"+this.numFrame)
			trace("str:"+str1 + ", str2:" + str2)
		}
		
	}

}