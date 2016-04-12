package baseStarling.tf {
	import base.types.Singleton;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.text.TextFieldAutoSize;
	
	public class TextFieldUtils extends Singleton {
		
		static public function createTextField(objTextField: Object = null): TextField {
			objTextField = objTextField || {};
			objTextField.width = objTextField.width || 1;
			objTextField.height = objTextField.height || 1;
			objTextField.text = objTextField.text || "";
			objTextField.fontName = objTextField.fontName || "Verdana";
			objTextField.fontSize = objTextField.fontSize || 12;
			objTextField.multiline = Boolean(objTextField.multiline);
			objTextField.leading = objTextField.leading || 0;
			var tFormat: TextFormat = new TextFormat(objTextField.fontName, objTextField.fontSize, objTextField.color, objTextField.hAlign, objTextField.vAlign);
			var tf: TextField = new TextField(objTextField.width, objTextField.height, objTextField.text, tFormat);
			tf.autoSize = objTextField.multiline ? TextFieldAutoSize.VERTICAL : TextFieldAutoSize.BOTH_DIRECTIONS;
			return tf;
		}
		
		static public function fitTextToMaxWidth(tf: TextField, text: String, startMaxFontSize: uint, maxWidthTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 0, text, startMaxFontSize, maxWidthTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		static public function fitTextToMaxHeight(tf: TextField, text: String, startMaxFontSize: uint, maxHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 1, text, startMaxFontSize, maxHeightTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		static public function fitTextToMaxWidthHeight(tf: TextField, isWidthHeight: uint, text: String, startMaxFontSize: uint, maxWidthHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			if (text != null) {
				//if (isSetHtmlText) tf.htmlText = text else 
				tf.text = text;
				tf.format.size = Number(startMaxFontSize);
				while ((tf.textBounds[["width", "height"][isWidthHeight]] > maxWidthHeightTextWhenStartDecreaseFontSize) && (tf.format.size > minFontSize)) {
					tf.format.size -= 1;
				}
				var addXYPos: Number = (maxWidthHeightTextWhenStartDecreaseFontSize - tf[["width", "height"][isWidthHeight]]) / 2;
				return addXYPos;
			} else {
				return -1;
			}
		}
		
	}
	
}