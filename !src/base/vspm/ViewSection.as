package base.vspm {
	
	public class ViewSection extends View {
		
		public var num: int;
		
		public function ViewSection(content: ContentViewSection, num: int): void {
			super(content);
			this.num = num;
		}
		
		override protected function startAfterShow(): void {
			ManagerSection.startSection();
		}
		
		override protected function hideComplete(): void {
			super.hideComplete();
			ManagerSection.finishStopSection(DescriptionViewSection(this.description));
		}
		
	}

}