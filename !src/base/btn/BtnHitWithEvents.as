package base.btn {
	import flash.display.Sprite;

	public class BtnHitWithEvents extends BtnHit implements IBtnWithEvents {
		
		public function BtnHitWithEvents(hit: Sprite = null): void {
			this.addBtnHitEvents();
			super(hit);
		}
		
		public function addBtnHitEvents(): void {
			this.addEventListener(BtnHitEvent.OVER, this.onOverHandler);
			this.addEventListener(BtnHitEvent.OUT, this.onOutHandler);
		}
		
		public function removeBtnHitEvents(): void {
			this.removeEventListener(BtnHitEvent.OVER, this.onOverHandler);
			this.removeEventListener(BtnHitEvent.OUT, this.onOutHandler);
		}

		public function setElementsOnOutOver(isOutOver: uint): void {
			//throw new Error("no effect on btn over/out? come on!");
		}
		
		private function onOverHandler(event: BtnHitEvent): void {
			this.setElementsOnOutOver(1);
		}
		
		private function onOutHandler(event: BtnHitEvent): void {
			this.setElementsOnOutOver(0);
		}
		
		override public function destroy(): void {
			this.removeBtnHitEvents();
			super.destroy()
		}
		
	}

}