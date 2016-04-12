package base.flashUtils {

	import flash.events.Event;

	public class ProxyClassEvent extends Event {

		public static const PROPERTY_CHANGE: String = "PropertyChange";
		public static const PROPERTY_CALL: String = "PropertyCall";
		
		public var data:*; 

		public function ProxyClassEvent(type: String, data:*): void {
			this.data = data;
			super(type);
		}
		
	}
	
}