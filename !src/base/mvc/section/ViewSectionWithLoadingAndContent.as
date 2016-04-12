package base.mvc.section {
	
	public class ViewSectionWithLoadingAndContent extends ViewSectionWithContent {
		
		private var _isLoading: Boolean = false;
		private var isHiding: Boolean = false;
		
		public function ViewSectionWithLoadingAndContent(content: ContentViewSection): void {
			super(content);
			this.isHideShow = 0;
		}
		
		override public function show(): void {
			//trace("this.isLoading:" + this.isLoading, "this.isHideShow:" + this.isHideShow);
			if (!this.isLoading) {
				if (this.isHideShow == 0) {
					if (this.startLoading()) this.isLoading = true;
					else {
						this.isHideShow = 1;
						this.initAfterLoading();
						this.showAfterLoading();
					}
				} else if (this.isHideShow == 1) {
					this.showAfterLoading();
				}
			}
		}
		
		protected function startLoading(): Boolean {
			trace("start loading");
			return true;
		}
		
		protected function initAfterLoading(): void {
			
		}
		
		protected function showAfterLoading(): void {
			this.hideShow(1);
		}
		
		public function finishLoading(): void {
			this.isHideShow = 1;
			this.isHiding = false;
			this.isLoading = false;
		}
		
		public function get isLoading(): Boolean {
			return this._isLoading;
		}
		
		public function set isLoading(value: Boolean): void {
			if (value != this._isLoading) {
				this._isLoading = value;
				this.addRemovePreloader(uint(value));
			}
		}
		
		protected function addRemovePreloader(isRemoveAdd: uint): void {
			//odpalana gdy nie ma preloadera
			if (isRemoveAdd == 0) this.finishRemovePreloader();
		}
		
		protected function finishRemovePreloader(): void {
			if (this.isHideShow == 0) super.hideComplete();
			else if ((this.isHideShow == 1) && (!this.isHiding)) {
				this.initAfterLoading();
				this.showAfterLoading();
			}
		}
		
		protected function abortLoading(): Boolean {
			trace("abort loading");
			return true;
		}
		
		protected function hideAfterLoading(): void {
			this.hideShow(0);
		}
		
		override public function hide(): void {
			this.isHiding = true;
			this.stopBeforeHide();
			if (this.isLoading) {
				if (this.abortLoading()) this.isLoading = false;
				else this.hideAfterLoading();
			} else {
				this.hideAfterLoading();
			}
		}
		
		override public function hideComplete(): void {
			this.isHideShow = 0;
			super.hideComplete();
		}
		
	}
	
}