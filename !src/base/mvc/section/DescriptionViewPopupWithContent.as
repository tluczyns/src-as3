package base.mvc.section {
	import base.types.StringUtils;
	import flash.display.DisplayObjectContainer;

	public dynamic class DescriptionViewPopupWithContent extends DescriptionViewPopup {
		
		public var content: ContentViewPopup;
		
		public function DescriptionViewPopupWithContent(objParamsWithValuesToShow: Object, ind: String, nameClass: Class, content: ContentViewPopup, x: Number = 0, y: Number = 0, containerPopup: DisplayObjectContainer = null): void {
			this.content = content;
			super(objParamsWithValuesToShow, ind, nameClass, x, y, containerPopup);
		}
		
		override protected function createViewPopupInstance(): ViewPopup {
			return new this.nameClass(this.content);
		}
		
		override protected function trackPageView(): void {
			if (!uint(this.content.isNotOmniture)) super.trackPageView();
		}
		
	}

}