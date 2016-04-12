package base.mvc.section {
	
	public class ViewPopupWithContent extends ViewPopup {
				
		public var content: ContentViewPopup;
		
		public function ViewPopupWithContent(content: ContentViewPopup): void {
			this.content = content;
		}
		
	}

}