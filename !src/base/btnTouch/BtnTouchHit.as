package base.btnTouch {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	
	public class BtnTouchHit extends MovieClip {
		
		public var hit: Sprite;
		
		public function BtnTouchHit(hit: Sprite = null): void {
			this.initHit(hit);
			this.addTouchEvents();
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
		
		public function createGenericHitAndAddTouchEvents(rectDimension: Rectangle = null): void {
			this.createGenericHit(rectDimension);
			this.addTouchEvents();
		}
		
		public function addTouchEvents(): void {
			this.hit.tabEnabled = false;	
			if (!this.hit.buttonMode) {
				this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.OUT));
				this.hit.buttonMode = true;
				this.hit.addEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_OUT, this.onTouchOutHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_BEGIN, this.onTouchBeginHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_END, this.onTouchEndHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_TAP, this.onTouchTapHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverForTouchMoveHandler);
				this.hit.addEventListener(TouchEvent.TOUCH_MOVE, this.onTouchMoveHandler);
			}
		}
		
		public function removeTouchEvents(): void {
			if (this.hit.buttonMode) {
				this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.OUT));
				this.hit.buttonMode = false;
				this.hit.removeEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverHandler);
				this.hit.removeEventListener(TouchEvent.TOUCH_OUT, this.onTouchOutHandler);
				this.hit.removeEventListener(TouchEvent.TOUCH_BEGIN, this.onTouchBeginHandler);
				this.hit.removeEventListener(TouchEvent.TOUCH_END, this.onTouchEndHandler);
				this.hit.removeEventListener(TouchEvent.TOUCH_TAP, this.onTouchTapHandler);
				if (this.hit.hasEventListener(TouchEvent.TOUCH_MOVE)) {
					this.hit.removeEventListener(TouchEvent.TOUCH_MOVE, this.onTouchMoveHandler);
					this.hit.removeEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverForTouchMoveHandler);
				}
			}
		}

		protected function onTouchOverHandler(event: TouchEvent): void {
			this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.OVER));
		}
		
		protected function onTouchOutHandler(event: TouchEvent): void {
			this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.OUT));	
		}
		
		protected function onTouchBeginHandler(event: TouchEvent): void {
			trace("onTouchTapHandler")
			this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.BEGIN));
		}
		
		protected function onTouchEndHandler(event: TouchEvent): void {
			this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.END));	
		}
		
		protected function onTouchTapHandler(event: TouchEvent): void {
			trace("onTouchTapHandler")
			this.dispatchEvent(new EventBtnTouchHit(EventBtnTouchHit.TAP));
		}
		
		private function onTouchOverForTouchMoveHandler(event: TouchEvent): void {
			if (this.hit.hasEventListener(TouchEvent.TOUCH_MOVE)) {
				this.hit.removeEventListener(TouchEvent.TOUCH_MOVE, this.onTouchMoveHandler);
				this.hit.removeEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverForTouchMoveHandler);
			}
		}
		
		private function onTouchMoveHandler(event: TouchEvent): void {
			this.hit.removeEventListener(TouchEvent.TOUCH_MOVE, this.onTouchMoveHandler);
			this.hit.removeEventListener(TouchEvent.TOUCH_OVER, this.onTouchOverForTouchMoveHandler);
			this.onTouchOverHandler(event);
		}
		
		protected function removeHit(): void {
			if (this.hit != null) {
				this.removeChild(this.hit);
				this.hit = null;
			}
		}
		
		public function destroy(): void {
			this.removeTouchEvents();
			this.removeHit();
		}
		
	}

}