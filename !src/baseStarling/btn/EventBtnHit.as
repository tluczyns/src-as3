package baseStarling.btn {
	import starling.events.Event;
	
	public class EventBtnHit extends Event {
		
		public static const OVER: String = "over";
		public static const OUT: String = "out";
		public static const RELEASE: String = "release";
		public static const MOVED: String = "moved";
		
		public function EventBtnHit(type: String, data: * = null): void {
			super(type, false, data);
		}
		
	}

}