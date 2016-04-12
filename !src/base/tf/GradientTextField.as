package base.tf {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	public class GradientTextField extends Sprite implements ITextField {
		
		public var tf: TextField;
		private var maskedTf: Sprite;
		private var descriptionGradient: DescriptionGradient;
		private var isDimensionFromText: Boolean;
		
		public function GradientTextField(tf: TextField, descriptionGradient: DescriptionGradient, isDimensionFromText: Boolean = true): void {
			this.tf = tf;
			this.descriptionGradient = descriptionGradient;
			this.isDimensionFromText = isDimensionFromText;
			this.maskedTf = new Sprite();
			this.addChild(this.maskedTf);
			this.addChild(tf);
			this.maskedTf.mask = tf;
			this.redraw();
		}
		
		private function redraw(): void {
			if (isDimensionFromText) {
				this.tf.x = (this.tf.textWidth - this.tf.width) / 2;
				this.tf.y = (this.tf.textHeight - this.tf.height) / 2;
			}
			var mrxTf: Matrix = new Matrix();
			var widthTf: Number = [tf.width, tf.textWidth][uint(isDimensionFromText)];
			var heightTf: Number = [tf.height, tf.textHeight][uint(isDimensionFromText)];
			mrxTf.createGradientBox(widthTf, heightTf, this.descriptionGradient.rotationGradient, this.descriptionGradient.tx, this.descriptionGradient.ty);
			this.maskedTf.graphics.clear();
			this.maskedTf.graphics.beginGradientFill(this.descriptionGradient.gradientType, this.descriptionGradient.colors, this.descriptionGradient.alphas, this.descriptionGradient.ratios, mrxTf);
			this.maskedTf.graphics.drawRect(0, 0, widthTf, heightTf);
			this.maskedTf.graphics.endFill();
		}
		
		public function get text(): String {
			return this.tf.text;
		}
		
		public function set text(value: String): void {
			this.tf.text = value;
			this.redraw();
		}
		
		public function get htmlText(): String {
			return this.tf.htmlText;
		}
		
		public function set htmlText(value: String): void {
			this.tf.htmlText = value;
			this.redraw();
		}
		
		public function get autoSize(): String {
			return this.tf.autoSize;
		}
			
		public function set autoSize(value: String): void {
			this.tf.autoSize = value;
			this.redraw();
		}

		public function get textWidth(): Number {
			return this.maskedTf.width;
		}
		
		public function get textHeight(): Number {
			return this.maskedTf.height;
		}
		
		override public function get width(): Number {
			return this.maskedTf.width;
		}
		
		override public function get height(): Number {
			return this.maskedTf.height;
		}
		
		public function getTextFormat(): TextFormat {
			return this.tf.getTextFormat();
		}
		
		public function setTextFormat(value: TextFormat): void {
			this.tf.setTextFormat(value);
			this.redraw();
		}
		
		public function get defaultTextFormat(): TextFormat {
			return this.tf.defaultTextFormat;
		}
		
		public function set defaultTextFormat(value: TextFormat): void {
			this.tf.defaultTextFormat = value;
			this.redraw();
		}
		
		public function destroy(): void {
			this.removeChild(this.maskedTf);
			this.maskedTf = null;
			this.removeChild(this.tf);
			this.tf = null;
		}
		
	}

}