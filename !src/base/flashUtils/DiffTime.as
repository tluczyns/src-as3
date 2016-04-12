package base.flashUtils {
	import flash.utils.getTimer;
	
	public class DiffTime {
		
		private var timeStart: uint;
		
		public function DiffTime(): void {
			this.restart();
		}
		
		public function restart(): void {
			this.timeStart = getTimer();
		}
		
		public function getDiffTime(): uint {
			var timeCurr: uint = getTimer();
			var diffTime: uint = timeCurr - this.timeStart;
			this.timeStart = timeCurr;
			return diffTime;
		}
		
	}

}