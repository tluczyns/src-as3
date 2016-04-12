package baseStarling.vspm {

	public class EventStateModel extends EventModel {

		public static const START_CHANGE_SECTION: String = "startChangeSection";
		public static const CHANGE_SECTION: String = "changeSection";
		public static const CHANGE_CURR_SECTION: String = "changeCurrSection";
		public static const PARAMETERS_CHANGE: String = "parametersChange";
		
		public function EventStateModel(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}