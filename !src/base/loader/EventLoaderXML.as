package base.loader {
	import base.vspm.EventModel;

	public class EventLoaderXML extends EventModel {

		public static const XML_LOADED: String = "xmlLoaded";
		public static const XML_NOT_LOADED: String = "xmlNotLoaded";
		
		public function EventLoaderXML(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}