package baseStarling.btn {
	import starling.display.Shape;
	import starling.events.TouchEvent;
	import com.greensock.TweenNano; 
	import com.greensock.easing.*;
	import starling.events.Touch;
	import starling.display.DisplayObject;
	import starling.events.TouchPhase;
	
	public class BtnHitAndBlockWithEvents extends BtnHitWithEvents implements IBtnWithEvents, IBtnBlock, IBtn {
		
		protected var isConstruct: Boolean;
		private var _isEnabled: Boolean = false;
		private var isOverForEnabled: Boolean = false;
		
		public function BtnHitAndBlockWithEvents(hit: Shape = null, isEnabled: Boolean = false): void {
			this.isConstruct = true;
			super(hit);
			this.isEnabled = isEnabled;
			if (!this.isEnabled) this.setBlockUnblockWhenRemoveAddTouchEvents(uint(this.isEnabled))
			this.isConstruct = false
			this.hit.addEventListener(TouchEvent.TOUCH, this.onHitTouch);
		}
		
		protected function setBlockUnblockWhenRemoveAddTouchEvents(isRemoveAdd: uint): void {
			TweenNano.killTweensOf(this);
			TweenNano.to(this, [0.3, 0][uint(this.isConstruct)], {alpha: [0.3, 1][isRemoveAdd], ease: Linear.easeNone});
		}
		
		override public function addTouchEvents(): void {
			if (!this.isConstruct) this.isEnabled = true;
		}
		
		override public function removeTouchEvents(): void {
			this.isEnabled = false;
		}
		
		private function onHitTouch(e: TouchEvent): void {
			var touch: Touch = e.getTouch(e.target as DisplayObject);
			var typeEvent: String;
			if (touch) {
				if (touch.phase == TouchPhase.HOVER) this.isOverForEnabled = true;
			} else this.isOverForEnabled = false;
		}
		
		public function get isEnabled(): Boolean {
			return this._isEnabled;
		}
		
		public function set isEnabled(value: Boolean): void {
			if (value != this._isEnabled) {
				if ((this.isOverForEnabled) && (!value)) this.dispatchEvent(new EventBtnHit(EventBtnHit.OUT));
				this._isEnabled = value;
				this.setBlockUnblockWhenRemoveAddTouchEvents(uint(value));
				if (value) super.addTouchEvents();
				else super.removeTouchEvents();
				if ((this.isOverForEnabled) && (value)) this.dispatchEvent(new EventBtnHit(EventBtnHit.OVER));
			}
		}
		
		override public function dispose(): void {
			TweenNano.killTweensOf(this);
			super.dispose();
		}
		
	}

}