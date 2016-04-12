package base.btn {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class BtnHit extends MovieClip implements IBtn {
		
		public var hit: Sprite;
		
		public function BtnHit(hit: Sprite = null): void {
			this.initHit(hit);
			this.addMouseEvents();
		}

		private function initHit(hit: Sprite = null): void {
			if (this.hit == null) { 
				if (hit != null) {
					hit.alpha = 0;
					this.addChild(hit);
					this.hit = hit;
				} else this.createGenericHit();
			}
		}
		
		public function createGenericHit(rectDimension: Rectangle = null): void {
			if (rectDimension == null) rectDimension = this.getRect(this);
			if (this.hit == null) {
				this.hit = new Sprite();
				this.hit.alpha = 0;
				this.hit.x = rectDimension.x;
				this.hit.y = rectDimension.y;
				this.hit.graphics.beginFill(0x000000, 0);
				this.hit.graphics.drawRect(0, 0, rectDimension.width + 0.1, rectDimension.height + 0.1);
				this.hit.graphics.endFill();
				this.addChild(this.hit);
			}
		}
		
		public function createGenericHitAndAddMouseEvents(rectDimension: Rectangle = null): void {
			this.createGenericHit(rectDimension);
			this.addMouseEvents();
		}
		
		public function addMouseEvents(): void {
			this.hit.tabEnabled = false;	
			if (!this.hit.buttonMode) {
				this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OUT));
				this.hit.buttonMode = true;
				this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
				this.hit.addEventListener(MouseEvent.CLICK, this.onClickHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			}
		}
		
		public function removeMouseEvents(): void {
			if (this.hit.buttonMode) {
				this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OUT));
				this.hit.buttonMode = false;
				this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
				this.hit.removeEventListener(MouseEvent.CLICK, this.onClickHandler);
				if (this.hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
					this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
					this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
				}
			}
		}

		protected function onMouseOverHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OVER));
		}
		
		protected function onMouseOutHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OUT));	
		}
		
		protected function onMouseDownHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.DOWN));
		}
		
		protected function onMouseUpHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.UP));	
		}
		
		protected function onClickHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED));
		}
		
		private function onMouseOverForMouseMoveHandler(event: MouseEvent): void {
			if (this.hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
			}
		}
		
		private function onMouseMoveHandler(event: MouseEvent): void {
			this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
			this.onMouseOverHandler(event);
		}
		
		protected function removeHit(): void {
			if (this.hit != null) {
				this.removeChild(this.hit);
				this.hit = null;
			}
		}
		
		public function destroy(): void {
			this.removeMouseEvents();
			this.removeHit();
		}
		
	}

}