package base.loader {  
	import base.loader.LoadContentQueue;
		
	public class FontLoader {  
 
		private var arrFontSwfName: Array;
		private var onLoadComplete: Function;
		private var onLoadScope: Object;
		private var loadFontSwfsQueue: LoadContentQueue;
		private var arrIndFontSwfInArrContent: Array;
		public var arrFontName: Array;
		public var arrFontSwf: Array;
		public var arrFont: Array;
		
		public function FontLoader(arrFontSwfName: Array, onLoadComplete: Function, onLoadScope: Object) {
			this.arrFontSwfName = arrFontSwfName;
			this.onLoadComplete = onLoadComplete;
			this.onLoadScope = onLoadScope;
			this.loadFontSwfs();
		}
		
		internal function loadFontSwfs(): void {
			this.loadFontSwfsQueue = new LoadContentQueue(this.onFontSwfsLoadCompleteHandler, this);
			this.arrIndFontSwfInArrContent = new Array(this.arrFontSwfName.length);
			for (var i: uint = 0; i < this.arrFontSwfName.length; i++) {
				this.arrIndFontSwfInArrContent[i] = this.loadFontSwfsQueue.addToLoadQueue(this.arrFontSwfName[i]);
			}
			this.loadFontSwfsQueue.startLoading();
		}		
		
		private function onFontSwfsLoadCompleteHandler(arrFontSwfContent: Array): void {
			this.arrFontSwf = new Array(this.arrIndFontSwfInArrContent.length);
			this.arrFontName = new Array(this.arrIndFontSwfInArrContent.length);
			var objContent: Object;
			for (var i: uint = 0; i < this.arrIndFontSwfInArrContent.length; i++) {
				objContent = arrFontSwfContent[this.arrIndFontSwfInArrContent[i]];
				if (objContent.isLoaded) {
					this.arrFontSwf[this.arrIndFontSwfInArrContent[i]] = objContent;
					this.arrFontName[this.arrIndFontSwfInArrContent[i]] = objContent.content.arrFont[0].fontName;
				}
			}
			var lastFontSwf: Object = this.arrFontSwf[this.arrFontSwf.length - 1];
			if ((lastFontSwf != null) && (lastFontSwf.content != null)) {
				this.arrFont = lastFontSwf.content.arrFont;
			}
			this.onLoadComplete.apply(this.onLoadScope);
		}
		
	}

}