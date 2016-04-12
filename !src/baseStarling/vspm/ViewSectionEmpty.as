package baseStarling.vspm {
	
	public class ViewSectionEmpty extends ViewSection {
		
		public function ViewSectionEmpty(content: ContentViewSection, num: int): void {
			super(content, num);
		}
		
		override public function init(): void {
			
		}
		
		override protected function hideShow(isHideShow: uint): void {
			if (isHideShow == 0) this.hideComplete();
			else if (isHideShow == 1) this.startAfterShow();
		}
		
		override protected function startAfterShow(): void {
			
			super.startAfterShow();
		}
			
		override protected function stopBeforeHide(): void {
			
		}
		
		override protected function hideComplete(): void {
			
			super.hideComplete();
		}
		
	}

}