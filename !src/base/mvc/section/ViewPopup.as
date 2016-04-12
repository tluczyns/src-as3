package base.mvc.section {
	
	public class ViewPopup extends ViewSection {
		
		public var descriptionViewPopup: DescriptionViewPopup;
		
		public function ViewPopup(): void {}
		
		override public function hideComplete(): void {
			if (this.tMaxHideShow) this.tMaxHideShow.stop();
			this.descriptionViewPopup.removeViewPopup();
		}
		
		override public function startAfterShow(): void {}
		
	}

}