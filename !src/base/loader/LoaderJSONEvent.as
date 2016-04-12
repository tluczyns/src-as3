package base.loader {
	import base.vspm.EventModel;

	public class LoaderJSONEvent extends EventModel {

		public static const JSON_LOADED: String = "jsonLoaded";
		public static const JSON_NOT_LOADED: String = "jsonNotLoaded";
		
		public function LoaderJSONEvent(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}