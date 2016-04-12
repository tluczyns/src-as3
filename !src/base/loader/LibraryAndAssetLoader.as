package base.loader {
	import base.loader.LibraryLoader;
	import flash.display.MovieClip;

	public class LibraryAndAssetLoader extends LibraryLoader {
		
		private var arrFilenameAsset: Array;
		private var arrIndAsset: Array;
		public var arrAsset: Array;
		private var isAllAssetsLoaded: Boolean;
		
		public function LibraryAndAssetLoader(arrFilenameSwfLib: Array, arrFilenameAsset: Array): void {
			this.arrFilenameAsset = arrFilenameAsset;
			super(arrFilenameSwfLib);
		}
		
		override protected function loadContent(arrFilenameSwfLib: Array): void {
			super.loadContent(arrFilenameSwfLib);
			this.arrIndAsset = [];
			for (var i: uint = 0; i < this.arrFilenameAsset.length; i++) {
				this.arrIndAsset.push(this.loadContentQueue.addToLoadQueue(String(this.arrFilenameAsset[i])));
			}
		}
		
		override protected function onContentLoadCompleteHandler(arrContent: Array): void {
			this.arrAsset = new Array(this.arrIndAsset.length);
			this.isAllAssetsLoaded = true;
			for (var i: uint = 0; i < this.arrIndAsset.length; i++) {
				var objAsset: Object = arrContent[this.arrIndAsset[i]];
				if (objAsset.isLoaded) {
					if (objAsset.type == LoadContentQueue.SWF) MovieClip(objAsset.content).stop();
					this.arrAsset[i] = objAsset.content;
				}
				else this.isAllAssetsLoaded = false;
			}
			super.onContentLoadCompleteHandler(arrContent);
		}
		
		override protected function onHideLoaderProgress(): void {
			if ((this.isAllLibrariesLoaded) && (this.isAllAssetsLoaded)) this.dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.LIBRARIES_AND_ASSETS_LOAD_SUCCESS));
			else this.dispatchEvent(new LibraryLoaderEvent(LibraryLoaderEvent.LIBRARIES_AND_ASSETS_LOAD_ERROR));
		}
		
	}

}