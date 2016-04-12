package base.loader {
	
	public class LoaderLibAndApplicationSwfs extends LoaderOneSwf {
		
		private var pathAssets: String;
		private var pathSwfApplication: String;
		protected var libraryLoader: LibraryLoader;
		
		public function LoaderLibAndApplicationSwfs(pathAssets: String, scaleMode: String = "noScale", nameSwfLib: String = "lib.swf", nameSwfApplication: String = "application.swf"): void {
			this.pathAssets = pathAssets;
			this.pathSwfApplication = pathAssets + nameSwfApplication;
			super(pathAssets + nameSwfLib, scaleMode);
		}
		
		override protected function hideLoaderProgressAndShowSwf(): void {
			this.loadLibrary();
		}
		
		private function loadLibrary(): void {
			this.libraryLoader = new LibraryLoader([this.pathSwfApplication]);
			this.libraryLoader.addEventListener(LibraryLoaderEvent.LIBRARIES_LOAD_SUCCESS, this.onLibraryLoaded);
		}
		
		protected function onLibraryLoaded(e: LibraryLoaderEvent): void {
			super.hideLoaderProgressAndShowSwf();
		}
		
		override protected function showSwf(isTweenShow: Boolean): void {
			this.swf = this.libraryLoader.arrSwfLib[0];
			super.showSwf(isTweenShow);
		}
		
		override protected function initSwf(): void {
			this.destroy();
			this.swf.init(this.pathAssets);
		}
		
	}

}