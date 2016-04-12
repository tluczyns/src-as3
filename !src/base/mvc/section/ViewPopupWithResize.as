package base.mvc.section {
	import flash.events.Event;
	
	public class ViewPopupWithResize extends ViewPopupWithContent {
		
		public function ViewPopupWithResize(content: ContentViewPopup): void {
			super(content);
		}
		
		override public function init(): void {
			super.init();
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
			this.onStageResize(null);
		}
		
		protected function onStageResize(e: Event): void {
			throw new Error("onStageResize must be implemented");
		}
		
		override public function hideComplete(): void {
			this.stage.removeEventListener(Event.RESIZE, this.onStageResize);			
			super.hideComplete();
		}
		
	}

}