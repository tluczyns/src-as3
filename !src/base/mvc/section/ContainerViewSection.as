package base.mvc.section {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ContainerViewSection extends Sprite {
		
		static public const FINISHED_SHOW: String = "finishedShow";
		
		public function ContainerViewSection(): void {
			this.finishedShow();
		}
		
		private function finishedShow(): void {
			this.dispatchEvent(new Event(ContainerViewSection.FINISHED_SHOW));
		}
		
	}

}