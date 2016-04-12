package base {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;		
		
	public class FrameRate extends Sprite {
		private var maxStepCount: uint = 10;
		private var stepCount: uint;
		private var txtFrameRate: TextField;
		private var tfTxtFrameRate: TextFormat;
		private var currentTime: Number;
		private var arrTimeDifferences: Array;
		public var frameRate: Number;
				
		public function FrameRate(maxStepCount: uint = 10) {
			this.maxStepCount = maxStepCount;
			this.createFrameRateTextField();
			this.currentTime = this.getCurrentTime();
			this.initiateArrayOfTimeDifferences();
		}
		
		private function createFrameRateTextField() {
			this.txtFrameRate = new TextField();
    		this.addChild(this.txtFrameRate);
 			this.txtFrameRate.width = 100;
			this.txtFrameRate.selectable = false;
			this.txtFrameRate.multiline = false;
			this.txtFrameRate.wordWrap = false;
			this.txtFrameRate.text = "estimate fps"
			this.tfTxtFrameRate = new TextFormat("Arial", 16, 0xFF0000, true, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0)
			this.txtFrameRate.setTextFormat(this.tfTxtFrameRate);
		}
		
		private function getCurrentTime() {
			var currentDate: Date = new Date();
			return currentDate.getTime();
		}
		
		private function putCurrentTimeDifference() {
			this.arrTimeDifferences[this.stepCount] = (this.getCurrentTime() - this.currentTime);
			this.currentTime = this.getCurrentTime();
		}
		
		private function initiateArrayOfTimeDifferences() {
			this.stepCount = 0;
			this.arrTimeDifferences = new Array(this.maxStepCount);
		}
		
		private function countFrameRate() {
			var sumTimeDifferences: Number = 0;
			var frameRate: Number;
			for (var i: uint = 0; i < this.maxStepCount; i++) {
				sumTimeDifferences += this.arrTimeDifferences[i];
			}
			frameRate = 1000 / (sumTimeDifferences / this.maxStepCount);
			frameRate = Math.round(frameRate * 100) / 100;
			return frameRate;
		}
		
		private function refreshFrameRate() {
			this.frameRate = this.countFrameRate();
			this.txtFrameRate.text = String(this.frameRate) + " fps";
			this.txtFrameRate.setTextFormat(this.tfTxtFrameRate);
		}
		
		public function notify() {
			this.putCurrentTimeDifference();
			this.stepCount++;
			if (this.stepCount == this.maxStepCount) {
				this.refreshFrameRate();
				this.initiateArrayOfTimeDifferences();
			}
		}
	}
}		