package baseStarling.btn {
	import starling.display.Shape;

	public class BtnHitWithEvents extends BtnHit implements IBtnWithEvents {
		
		public function BtnHitWithEvents(hit: Shape = null): void {
			this.addEventBtnHits();
			super(hit);
		}
		
		public function addEventBtnHits(): void {
			this.addEventListener(EventBtnHit.OVER, this.onOverHandler);
			this.addEventListener(EventBtnHit.OUT, this.onOutHandler);
		}
		
		public function removeEventBtnHits(): void {
			this.removeEventListener(EventBtnHit.OVER, this.onOverHandler);
			this.removeEventListener(EventBtnHit.OUT, this.onOutHandler);
		}

		public function setElementsOnOutOver(isOutOver: uint): void {
			//throw new Error("no effect on btn over/out? come on!");
		}
		
		private function onOverHandler(event: EventBtnHit): void {
			this.setElementsOnOutOver(1);
		}
		
		private function onOutHandler(event: EventBtnHit): void {
			this.setElementsOnOutOver(0);
		}
		
		override public function dispose(): void {
			this.removeEventBtnHits();
			super.dispose()
		}
		
	}

}