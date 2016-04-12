package base.flashUtils {
	import flash.utils.Timer;
	
	public class ArgumentsTimeoutInterval extends Object {
		
		internal var id: uint;
		internal var timer: Timer;
		internal var onComplete: Function;
		internal var onCompleteScope: Object;
		internal var params: Array;
		
		public function ArgumentsTimeoutInterval(id: uint, timer: Timer, onComplete: Function, onCompleteScope: Object, params: Array): void {
			this.id = id;
			this.timer = timer;
			this.onComplete = onComplete;
			this.onCompleteScope = onCompleteScope;
			this.params = params;
		}
		
	}

}