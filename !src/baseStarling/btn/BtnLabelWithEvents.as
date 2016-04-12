package baseStarling.btn {
	import baseStarling.tf.ITextField;
	import starling.display.Shape;
	import starling.display.DisplayObject;
	import flash.text.TextFieldAutoSize;
	
	public class BtnLabelWithEvents extends BtnHitWithEvents {
		
		public var tfLabel: *//ITextField;
		
		public function BtnLabelWithEvents(strLabel: String, tfLabel: */*ITextField*/ = null, hit: Shape = null): void {
			if ((this.tfLabel == null) && (tfLabel != null)) {
				this.addChild(DisplayObject(tfLabel));
				this.tfLabel = tfLabel;
			}
			super(hit);
			this.tfLabel.text = "";
			//this.tfLabel.autoSize = TextFieldAutoSize.LEFT;
			this.text = strLabel;
		}
		
		protected function removeTfLabel(): void {
			this.removeChild(DisplayObject(this.tfLabel));
			this.tfLabel = null;
		}
		
		public function set text(value: String): void {
			this.tfLabel.text = value;
			if (this.hit.height < this.tfLabel.height) this.hit.height = this.tfLabel.height + 2 * this.tfLabel.y;
			this.tfLabel.y = this.hit.y + (this.hit.height - this.tfLabel.height) / 2;
			this.hit.width = this.tfLabel.width + 2 * this.tfLabel.x;
		}
		
		override public function dispose(): void {
			this.removeTfLabel();
			super.dispose();
		}
		
	}

}