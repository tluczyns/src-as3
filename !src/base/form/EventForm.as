package base.form {
	import base.mvc.EventModel;

	public class EventForm extends EventModel {

		public static const PROCESSED_POSITIVE: String = "processedPositive";
		public static const PROCESSED_NEGATIVE: String = "processedNegative";
		
		public function EventForm(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}