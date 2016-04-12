package baseStarling.vspm {
	import base.loader.LoadContentQueue;
	import flash.utils.Dictionary;
	import baseStarling.loader.progress.LoaderProgress;
	import flash.display.Bitmap;
	
	public class LoaderImgs extends Object {
		
		public static var instance: LoaderImgs;
		
		private var loadContentQueue: LoadContentQueue;
		private var dictUrlImgToDescriptionImg: Dictionary;
		
		public function LoaderImgs(): void {
			if (!LoaderImgs.instance) {
				LoaderImgs.instance = this;
				this.init();
			} else throw new Error("cannot construct object");
		}
		
		protected function init(): void {
			this.loadContentQueue = new LoadContentQueue(null, null, null, this.onElementImgLoadCompleteHandler, this, false);
			this.dictUrlImgToDescriptionImg = new Dictionary();
		}
		
		protected function createDescriptionImg(urlImg: String): DescriptionImg {
			var descriptionImg: DescriptionImg = new DescriptionImg(urlImg);
			descriptionImg.loaderProgress = new LoaderProgress();
			descriptionImg.loaderProgress.visible = false;
			descriptionImg.loaderProgress.alpha = 0;
			return descriptionImg;
		}
		
		public function addLoadImgToQueue(urlImg: String): DescriptionImg {
			var descriptionImg: DescriptionImg;
			if (!this.dictUrlImgToDescriptionImg[urlImg]) {
				descriptionImg = this.createDescriptionImg(urlImg);
				this.loadContentQueue.addToLoadQueue(descriptionImg.urlImg, 1, 0, false, descriptionImg.loaderProgress);
				this.dictUrlImgToDescriptionImg[descriptionImg.urlImg] = descriptionImg;
			} else descriptionImg = this.dictUrlImgToDescriptionImg[urlImg];
			return descriptionImg;
		}
		
		public function get isLoading(): Boolean {
			return this.loadContentQueue.isLoading;
		}
		
		public function loadImgs(): void {
			this.loadContentQueue.startLoading();
		}
		
		private function onElementImgLoadCompleteHandler(contentImg: Object, indImg: uint): void {
			if ((contentImg.isLoaded) && (contentImg.type == LoadContentQueue.IMAGE)) {
				var descriptionImg: DescriptionImg = DescriptionImg(this.dictUrlImgToDescriptionImg[contentImg.url]);
				Bitmap(contentImg.content).smoothing = true;
				descriptionImg.bmpDataImg = Bitmap(contentImg.content).bitmapData;
			}
		}
		
		public function bringLoadPhotoToFrontInQueue(descriptionImg: DescriptionImg): void {
			this.loadContentQueue.bringToFrontInLoadQueue(descriptionImg.urlImg);
		}
		
	}

}