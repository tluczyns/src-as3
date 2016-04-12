package base.btn {
	import base.tf.ITextField;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.greensock.TweenNano; 
	import com.greensock.easing.Linear;
	
	public class BtnLabelAndBlockWithEvents extends BtnLabelWithEvents implements IBtnWithEvents, IBtnBlock, IBtn {
		
		public var _isEnabled: Boolean;
		private var isOver: Boolean;
		
		public function BtnLabelAndBlockWithEvents(strLabel: String, tfLabel: * /*ITextField*/ = null, hit: Sprite = null): void {
			super(strLabel, tfLabel, hit);
			this.alpha = 0;
			this.isEnabled = false;
			this.isOver = false;
		}
		
		protected function setUnblockBlockWhenAddRemoveMouseEvents(isRemoveAdd: uint): void {
			TweenNano.killTweensOf(this);
			TweenNano.to(this, 10, {alpha: [0.4, 1][isRemoveAdd], useFrames: true, ease: Linear.easeNone});
		}
		
		override public function addMouseEvents(): void {
			this.isEnabled = true;
		}
		
		override public function removeMouseEvents(): void {
			this.isEnabled = false;
		}
		
		override protected function onMouseOverHandler(event: MouseEvent): void {
			this.isOver = true;
			if (this.isEnabled) {
				super.onMouseOverHandler(event);
			}
		}
		
		override protected function onMouseOutHandler(event: MouseEvent): void {
			this.isOver = false;
			if (this.isEnabled) {
				super.onMouseOutHandler(event);
			}
		}
		
		public function get isEnabled(): Boolean {
			return this._isEnabled;
		}
		
		public function set isEnabled(value: Boolean): void {
			if (value != this._isEnabled) {
				if ((this.isOver) && (!value)) this.hit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, false));
				if (value) {
					this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
					this.hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
					super.addMouseEvents();
				} else {
					super.removeMouseEvents();
					this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
					this.hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				}
				this._isEnabled = value;
				this.setUnblockBlockWhenAddRemoveMouseEvents(uint(value));
				if ((this.isOver) && (value)) this.hit.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, false));
			}
		}
		
		override public function destroy(): void {
			TweenNano.killTweensOf(this);
			super.destroy();
		}
		
		
	}

}