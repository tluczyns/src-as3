package base.mvc.section {
	import base.mvc.section.ViewSection;
	
	public class ViewSectionWithContentAndNum extends ViewSectionWithContent {
		
		public var num: uint;
		
		public function ViewSectionWithContentAndNum(content: ContentViewSection, num: uint): void {
			super(content);
			this.num = num;
		}
		
	}

}