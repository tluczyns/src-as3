package baseStarling.vspm {
	import starling.events.ResizeEvent;
	import starling.core.Starling;
	import starling.events.Event;
	
	public class ViewSectionWithResize extends ViewSection {
		
		public function ViewSectionWithResize(content: ContentViewSection, num: uint = 0): void {
			super(content, num);
		}
		
		override public function init(): void {
			super.init();
			this.stage.addEventListener(ResizeEvent.RESIZE, this.onStageResize);
			this.onStageResize(null);
			Starling.current.addEventListener(Event.CONTEXT3D_CREATE, this.onStarlingContext3DCreate);
		}
		
		private function onStarlingContext3DCreate(e: Event): void {
			this.onStageResize(null);
		}
		
		protected function onStageResize(e: ResizeEvent): void {
			throw new Error("onStageResize must be implemented");
		}
		
		override protected function hideComplete(): void {
			Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, this.onStarlingContext3DCreate);
			if (this.stage) this.stage.removeEventListener(ResizeEvent.RESIZE, this.onStageResize);			
			super.hideComplete();
		}
		
	}

}