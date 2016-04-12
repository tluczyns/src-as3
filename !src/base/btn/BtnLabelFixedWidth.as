package base.btn {
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	
	public class BtnLabelFixedWidth extends BtnHitAndBlock {
		
		public var tfLabel: TextField;
		
		public function BtnLabelFixedWidth(strLabel: String, isTfLabelAutoSizeLeftCenter: uint, width: Number, tfLabel: TextField = null, hit: Sprite = null): void {
			if ((this.tfLabel == null) && (tfLabel != null)) {
				this.addChild(tfLabel);
				this.tfLabel = tfLabel;
			}
			super(hit);
			this.tfLabel.text = "";
			this.tfLabel.autoSize = [TextFieldAutoSize.LEFT, TextFieldAutoSize.CENTER][isTfLabelAutoSizeLeftCenter];
			this.tfLabel.text = strLabel;
			if (isTfLabelAutoSizeLeftCenter == 1) {
				this.tfLabel.x = 0;
				this.tfLabel.width = width;
			}
			this.hit.x = 0;
			this.hit.width = width;
			this.tfLabel.y = this.hit.y + (this.hit.height - this.tfLabel.height) / 2;
			this.isEnabled = true;
		}
		
	}

}