package base.btnTouch {
	import base.mvc.EventModel;
	
	public class EventBtnTouchHit extends EventModel {

		public static const OVER: String = "overBtnTouchHit";
		public static const OUT: String = "outBtnTouchHit";
		public static const BEGIN: String = "beginBtnTouchHit";
		public static const END: String = "endBtnTouchHit";
		public static const TAP: String = "tapBtnTouchHit";
		
		public function EventBtnTouchHit(type: String, data: * = null): void {
			super(type, data);//, true);
		}
		
	}

}