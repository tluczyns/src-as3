package base.bridgeAs2As3 {
	import base.mvc.EventModel;
	
	public class BridgeFromToAs2Event extends EventModel {
		
		public static const EXIT: String = "exit";
		
		public function BridgeFromToAs2Event(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}