package base.mvc.section {
	import base.mvc.EventModel;
	import flash.events.Event;

	public class EventModelSection extends EventModel {

		public static const START_CHANGE_SECTION: String = "startChangeSection";
		public static const CHANGE_SECTION: String = "changeSection";
		public static const CHANGE_CURR_SECTION: String = "changeCurrSection";
		public static const PARAMETERS_CHANGE: String = "parametersChange";
		
		public function EventModelSection(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}