package base.btn {
	import base.tf.ITextField;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextFieldAutoSize;
	
	public class BtnLabel extends BtnHit {
		
		public var tfLabel: *//ITextField;
		
		public function BtnLabel(strLabel: String, tfLabel: */*ITextField*/ = null, hit: Sprite = null): void {
			if ((this.tfLabel == null) && (tfLabel != null)) {
				this.addChild(DisplayObject(tfLabel));
				this.tfLabel = tfLabel;
			}
			this.tfLabel.text = "X";
			super(hit);
			this.tfLabel.autoSize = TextFieldAutoSize.LEFT;
			this.text = strLabel;
		}
		
		private function removeLabel(): void {
			this.removeChild(DisplayObject(this.tfLabel));
			this.tfLabel = null;
		}
		
		public function set text(value: String): void {
			this.tfLabel.text = value;
			this.tfLabel.y = this.hit.y + (this.hit.height - this.tfLabel.height) / 2 - 1;
			this.hit.width = this.tfLabel.width + 2 * this.tfLabel.x;
		}
		
		override public function destroy(): void {
			this.removeLabel();
			super.destroy();
		}
		
	}

}