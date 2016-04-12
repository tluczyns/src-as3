package base.mvc.section {
	
	public class ViewSectionWithLoadingAndContentAndNum extends ViewSectionWithLoadingAndContent {
		
		protected var num: uint;
		
		public function ViewSectionWithLoadingAndContentAndNum(content: ContentViewSection, num: uint): void {
			super(content);
			this.num = num;
		}
		
	}

}