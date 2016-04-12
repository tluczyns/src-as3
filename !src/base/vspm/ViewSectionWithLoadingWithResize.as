package base.vspm {
	import flash.events.Event;
	
	public class ViewSectionWithLoadingWithResize extends ViewSectionWithLoading {
		
		public function ViewSectionWithLoadingWithResize(content: ContentViewSection, num: int = 0): void {
			super(content, num);
		}
		
		override protected function initAfterLoading(): void {
			super.initAfterLoading();
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
			this.onStageResize(null);
		}
		
		protected function onStageResize(e: Event): void {
			throw new Error("onStageResize must be implemented");
		}
		
		override protected function hideComplete(): void {
			this.stage.removeEventListener(Event.RESIZE, this.onStageResize);		
			super.hideComplete();
		}
		
	}

}