package base.mvc.section {
	
	public class ViewSectionWithContent extends ViewSection {
				
		public var content: ContentViewSection;
		
		public function ViewSectionWithContent(content: ContentViewSection): void {
			this.content = content;
		}
		
	}

}