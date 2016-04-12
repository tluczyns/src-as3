package base.mvc.section {
	import base.mvc.section.ViewSectionWithContent;
	import base.mvc.section.ContentViewSection;
	
	public class ViewSectionEmpty extends ViewSectionWithContent {
		
		public function ViewSectionEmpty(content: ContentViewSection): void {
			super(content);
		}
		
		override public function init(): void {
			
		}
		
		override protected function hideShow(isHideShow: uint): void {
			if (isHideShow == 0) this.hideComplete();
			else if (isHideShow == 1) this.startAfterShow();
		}
		
		override public function startAfterShow(): void {
			
			super.startAfterShow();
		}
			
		override public function stopBeforeHide(): void {
			
		}
		
		override public function hideComplete(): void {
			
			super.hideComplete();
		}
		
	}

}