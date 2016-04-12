package base.gallery {
	import base.vspm.EventModel;
	import flash.events.Event;

	public class EventGallery extends EventModel {

		static public const SELECTED_ITEM_CHANGED: String = "selectedItemChanged";
		static public const RENDER: String = "render"
		
		public function EventGallery(type: String, data: * = null, bubbles: Boolean = false): void {
			super(type, data, bubbles);
		}
		
	}

}