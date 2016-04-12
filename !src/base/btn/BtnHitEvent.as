package base.btn {
	import base.mvc.EventModel;
	
	public class BtnHitEvent extends EventModel {
		
		public static const OVER: String = "over";
		public static const OUT: String = "out";
		public static const DOWN: String = "down";
		public static const UP: String = "up";
		public static const CLICKED: String = "clicked";
		
		public function BtnHitEvent(type: String, data: * = null): void {
			super(type, data);//, true);
		}
		
	}

}