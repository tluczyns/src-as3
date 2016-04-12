package base.btnTouch {
	import flash.display.Sprite;

	public class BtnTouchHitWithEvents extends BtnTouchHit {
		
		public function BtnTouchHitWithEvents(hit: Sprite = null): void {
			this.addTouchBtnHitEvents();
			super(hit);
		}
		
		public function addTouchBtnHitEvents(): void {
			this.addEventListener(EventBtnTouchHit.BEGIN, this.onBeginHandler);
			this.addEventListener(EventBtnTouchHit.OVER, this.onBeginHandler);
			this.addEventListener(EventBtnTouchHit.END, this.onEndHandler);
			this.addEventListener(EventBtnTouchHit.OUT, this.onEndHandler);
		}
		
		public function removeBtnHitEvents(): void {
			this.removeEventListener(EventBtnTouchHit.BEGIN, this.onBeginHandler);
			this.removeEventListener(EventBtnTouchHit.OVER, this.onBeginHandler);
			this.removeEventListener(EventBtnTouchHit.END, this.onEndHandler);
			this.removeEventListener(EventBtnTouchHit.OUT, this.onEndHandler);
		}

		public function setElementsOnBeginEnd(isBeginEnd: uint): void {
			//throw new Error("no effect on btn begin/end? come on!");
		}
		
		private function onBeginHandler(event: EventBtnTouchHit): void {
			this.setElementsOnBeginEnd(1);
		}
		
		private function onEndHandler(event: EventBtnTouchHit): void {
			this.setElementsOnBeginEnd(0);
		}
		
		override public function destroy(): void {
			this.removeBtnHitEvents();
			super.destroy()
		}
		
	}

}