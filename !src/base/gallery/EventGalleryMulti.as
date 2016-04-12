package base.gallery {
	import base.vspm.EventModel;
	import flash.events.Event;

	public class EventGalleryMulti extends EventModel {

		static public const SELECTED_RENDERABLE_CHANGED: String = "selectedRenderableChanged";
		
		public function EventGalleryMulti(type: String, data: * = null, bubbles: Boolean = false): void {
			super(type, data, bubbles);
		}
		
	}

}