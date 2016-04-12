package base.btn {
	import flash.display.Sprite;
	import base.tf.ITextField;
	import flash.display.DisplayObject;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	public class BtnCheckBox extends BtnHitWithEvents {
		
		public var tfLabel: *//ITextField;
		public var bgCb: Sprite;
		public var cb: Sprite;
		private var _isChecked: Boolean;
		
		public function BtnCheckBox(strLabel: String, bgCb: Sprite = null, cb: Sprite = null, tfLabel: */*ITextField*/ = null): void {
			if ((this.bgCb == null) && (bgCb != null)) {
				this.addChild(DisplayObject(bgCb));
				this.bgCb = bgCb;
			}
			if ((this.cb == null) && (cb != null)) {
				this.addChild(DisplayObject(cb));
				this.cb = cb;
			}
			if ((this.tfLabel == null) && (tfLabel != null)) {
				this.addChild(DisplayObject(tfLabel));
				this.tfLabel = tfLabel;
			}
			this.cb.alpha = 0;
			this.cb.x = this.bgCb.x + (this.bgCb.width - this.cb.width) / 2;
			this.cb.y = this.bgCb.y + (this.bgCb.height - this.cb.height) / 2;
			this.tfLabel.text = strLabel;
			this.tfLabel.x = this.bgCb.x + this.bgCb.width + this.bgCb.width / 2;
			super(this.createHit());
			this.addEventListener(BtnHitEvent.CLICKED, this.onClicked);
		}
		
		protected function createHit(): Sprite {
			var hit: Sprite = new Sprite();
			hit.graphics.beginFill(0x000000, 0);
			hit.graphics.drawRect(0, 0, this.tfLabel.x + this.tfLabel.width, this.tfLabel.height);
			hit.graphics.endFill();
			return hit;
		}
		
		private function hideShowCB(isHideShow: uint): void {
			TweenLite.to(this.cb, 0.3, {alpha: isHideShow, ease: Linear.easeNone});
		}
		
		public function get isChecked(): Boolean { 
			return this._isChecked; 
		
		}		
		public function set isChecked(value: Boolean): void {
			this._isChecked = value;
			this.hideShowCB(uint(value));
		}
		
		private function onClicked(event: BtnHitEvent): void {
			this.isChecked = !this.isChecked;
		}
		
		private function removeLabel(): void {
			this.removeChild(DisplayObject(this.tfLabel));
			this.tfLabel = null;
		}
		
		private function removeCb(): void {
			this.removeChild(DisplayObject(this.cb));
			this.cb = null;
		}
		
		private function removeBgCb(): void {
			this.removeChild(DisplayObject(this.bgCb));
			this.bgCb = null;
		}
		
		override public function destroy(): void {
			this.removeLabel();
			this.removeCb()
			this.removeBgCb();
			this.removeEventListener(BtnHitEvent.CLICKED, this.onClicked);
			super.destroy();
		}
		
	}

}