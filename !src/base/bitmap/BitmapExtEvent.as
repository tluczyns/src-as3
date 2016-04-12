package base.bitmap {
	import base.mvc.EventModel;

	public class BitmapExtEvent extends EventModel {

		public static const BITMAPDATA_SET: String = "bitmapdataSet";
		
		public function BitmapExtEvent(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}