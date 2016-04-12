package base.tf {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ExtrudeTextField extends Sprite  implements ITextField {
		
		private var tfFg: GradientTextField;
		private var vecTfExtrude: Vector.<TextField>; //GradientTextField
		
		public function ExtrudeTextField(tf: TextField, descriptionGradientFg: DescriptionGradient, colorExtrude: uint, maxZ: Number = 50, precision: uint = 3): void {
			var countTfExtrude: uint = Math.ceil(maxZ / precision);
			this.vecTfExtrude = new Vector.<TextField>(countTfExtrude); //GradientTextField
			var tfExtrude: TextField;//GradientTextField;
			for (var i: uint = 0; i < countTfExtrude; i++) {
				tfExtrude = TextFieldUtils.cloneTextField(tf);//new GradientTextField(TextFieldUtils.cloneTextField(tf), descriptionGradientExtrude);
				//var valColorToWhite(countTfExtrude - i - 1) * (255 / countTfExtrude);
				TextFieldUtils.changeTFormatPropsInTf(tfExtrude, {color: colorExtrude + ((i * 10) << 16 | (i * 10) << 8 | i)});
				tfExtrude.x = (tf.textWidth - tf.width) / 2
				tfExtrude.y = (tf.textHeight - tf.height) / 2
				tfExtrude.z = (countTfExtrude - i) * precision;
				this.addChild(tfExtrude);
				this.vecTfExtrude[i] = tfExtrude;
			}
			this.tfFg = new GradientTextField(tf, descriptionGradientFg);
			this.addChild(this.tfFg);
		}
		
		public function get text(): String {
			return this.tfFg.text;
		}
		
		public function set text(value: String): void {
			this.setPropValueInAllTfs("text", value);
		}
		
		public function get htmlText(): String {
			return this.tfFg.htmlText;
		}
		
		public function set htmlText(value: String): void {
			this.setPropValueInAllTfs("htmlText", value);
		}
		
		public function get autoSize(): String {
			return this.tfFg.autoSize;
		}
			
		public function set autoSize(value: String): void {
			this.setPropValueInAllTfs("autoSize", value);
		}

		public function get textWidth(): Number {
			return this.tfFg.textWidth;
		}
		
		public function get textHeight(): Number {
			return this.tfFg.textHeight;
		}
		
		override public function get width(): Number {
			return this.tfFg.width;
		}

		override public function get height(): Number {
			return this.tfFg.height;
		}

		public function getTextFormat(): TextFormat {
			return this.tfFg.getTextFormat();
		}
		
		public function setTextFormat(value: TextFormat): void {
			this.tfFg.setTextFormat(value);
			var tfExtrude: TextField; //GradientTextField
			for (var i: uint = 0; i < this.vecTfExtrude.length; i++) {
				tfExtrude = this.vecTfExtrude[i];
				tfExtrude.setTextFormat(value);
			}
		}
		
		public function get defaultTextFormat(): TextFormat {
			return this.tfFg.defaultTextFormat;
		}
		
		public function set defaultTextFormat(value: TextFormat): void {
			this.setPropValueInAllTfs("defaultTextFormat", value);
		}
		
		private function setPropValueInAllTfs(nameProp: String, valueProp: * ): void {
			this.tfFg[nameProp] = valueProp;
			var tfExtrude: TextField; //GradientTextField;
			for (var i: uint = 0; i < this.vecTfExtrude.length; i++) {
				tfExtrude = this.vecTfExtrude[i];
				tfExtrude[nameProp] = valueProp;
			}
		}
		
		public function destroy(): void {
			this.tfFg.destroy();
			this.removeChild(this.tfFg);
			this.tfFg = null;
			var tfExtrude: TextField;//GradientTextField;
			for (var i: uint = 0; i < this.vecTfExtrude.length; i++) {
				tfExtrude = this.vecTfExtrude[i];
				//tfExtrude.destroy();
				this.removeChild(tfExtrude);
				tfExtrude = null;
			}
			this.vecTfExtrude = new Vector.<GradientTextField>();
		}
		
	}

}