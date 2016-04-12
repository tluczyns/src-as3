package base.loader {
	import base.vspm.EventModel;

	public class LibraryLoaderEvent extends EventModel {

		public static const LIBRARIES_LOAD_SUCCESS: String = "librariesLoadSuccess";
		public static const LIBRARIES_LOAD_ERROR: String = "librariesLoadError";
		public static const LIBRARIES_AND_ASSETS_LOAD_SUCCESS: String = "librariesAndAssetsLoadSuccess";
		public static const LIBRARIES_AND_ASSETS_LOAD_ERROR: String = "librariesAndAssetsLoadError";
		
		public function LibraryLoaderEvent(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}