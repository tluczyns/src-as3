package base.btn {
	import base.tf.ITextField;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.FramePlugin;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.events.MouseEvent;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	
	public class BtnLabelWithIconWithEvents extends BtnHitAndBlockWithEvents {
		
		public var tfLabel: *//ITextField;
		public var icon: MovieClip;
		private var _typeIcon: uint;
		
		public function BtnLabelWithIconWithEvents(strLabel: String, typeIcon: uint = 0, marginXIcon: Number = 10, icon: MovieClip = null, tfLabel: * /*ITextField*/ = null, hit: Sprite = null): void {
			TweenPlugin.activate([FramePlugin]);
			if ((this.icon == null) && (icon != null)) {
				this.addChild(DisplayObject(icon));
				this.icon = icon;
			}
			if ((this.tfLabel == null) && (tfLabel != null)) {
				this.addChild(DisplayObject(tfLabel));
				this.tfLabel = tfLabel;
			}
			this.tfLabel.htmlText = "";
			this.tfLabel.autoSize = TextFieldAutoSize.LEFT;
			this.tfLabel.htmlText = strLabel;
			if (this.tfLabel.htmlText == "") this.icon.x = this.tfLabel.x;
			else this.icon.x = this.tfLabel.x + this.tfLabel.textWidth + marginXIcon;
			this.typeIcon = typeIcon;
			super(hit);
			this.hit.width = this.icon.x + this.icon.width + this.tfLabel.x;
			if (this.tfLabel.getTextFormat().align == TextFormatAlign.RIGHT) this.tfLabel.x -= (this.tfLabel.width - this.tfLabel.textWidth);
			//pos y icon 
			var heightTfLabel: Number;;
			if (this.tfLabel.htmlText == "") {
				this.tfLabel.htmlText = " ";
				heightTfLabel = this.tfLabel.height
				this.tfLabel.htmlText = "";
			} else heightTfLabel = this.tfLabel.height;
			this.icon.y = this.tfLabel.y + (heightTfLabel - this.icon.height) / 2;
			
			this.isEnabled = true;
		}
		
		override protected function onClickHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED, this.typeIcon));
		}
		
		override public function get width(): Number {
			return this.hit.width;
		}
		
		protected function get typeIcon(): uint {
			return this._typeIcon;
		}
		
		protected function set typeIcon(value: uint): void {
			this._typeIcon = value;
			//this.icon.stop();
			//this.icon.gotoAndStop(value + 1);
			TweenLite.to(this.icon, this.icon.totalFrames - (value + 1), {frame: value + 1, useFrames: true});
		}
			
		private function removeIcon(): void {
			this.removeChild(this.icon);
			this.icon = null;
		}
		
		private function removeLabel(): void {
			this.removeChild(DisplayObject(this.tfLabel));
			this.tfLabel = null;
		}
		
		override public function destroy(): void {
			this.removeIcon();
			this.removeLabel();
			super.destroy();
		}
		
	}

}