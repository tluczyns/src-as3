package base.vspm {
	
	public class ViewPopup extends View {
		
		public var descriptionViewPopup: DescriptionViewPopup;
		
		public function ViewPopup(content: ContentViewPopup): void {
			super(content);
		}
		
		override protected function hideComplete(): void {
			super.hideComplete();
			this.description.removeView();
		}
		
	}

}