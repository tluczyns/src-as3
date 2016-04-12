package base.tf {
	import base.types.Singleton;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.Font;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	public class TextFieldUtilsLite extends Singleton {
		
		public static function createTextField(tFormat: TextFormat = null, isDynamicInput: uint = 0, isSingleMultiLine: uint = 0, isAutoSizeLeftCenterNone: uint = 0, isSetEventForSelectionInInputTf: Boolean = false): TextField {
			var tf: TextField = new TextField();
			tf.type = [TextFieldType.DYNAMIC, TextFieldType.INPUT][isDynamicInput];
			if ((isDynamicInput == 1) && (isSetEventForSelectionInInputTf)) TextFieldUtilsLite.setEventForSelectionInInputTf(tf);
			tf.selectable = [false, true][isDynamicInput];
			tf.multiline = [false, true][isSingleMultiLine];
			tf.wordWrap = [false, true][isSingleMultiLine];
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.autoSize = [[TextFieldAutoSize.LEFT, TextFieldAutoSize.CENTER, TextFieldAutoSize.NONE][isAutoSizeLeftCenterNone], TextFieldAutoSize.LEFT][isDynamicInput];
			if (isDynamicInput == 1) {
				var heightForInputText: Number = tf.height + 5;
				tf.autoSize = TextFieldAutoSize.NONE;
				tf.height = heightForInputText;
			}
			var isFont: Boolean = ((tFormat != null) && (TextFieldUtilsLite.isFontExists(tFormat.font)));
			tf.embedFonts = isFont;
			if (tFormat != null) {
				tf.defaultTextFormat = tFormat;
				tf.setTextFormat(tFormat);
			}
			return tf;
		}
		
		public static function isFontExists(fontName: String): Boolean {
			var arrFont: Array = Font.enumerateFonts();
			var i: uint = 0;
			while ((i < arrFont.length) && (fontName != Font(arrFont[i]).fontName)) i++;
			return (i < arrFont.length);
		}
		
		public static function setEventForSelectionInInputTf(tf: TextField): void {
			tf.addEventListener(FocusEvent.FOCUS_IN , TextFieldUtilsLite.onTfFocusIn)
			tf.addEventListener(MouseEvent.MOUSE_UP , TextFieldUtilsLite.onTfMouseUp);
		}
		
		private static function onTfFocusIn(event: FocusEvent): void {
			var tf: TextField = TextField(event.target);
			tf.setSelection(0, tf.length)
		}
		
		private static function onTfMouseUp(event: MouseEvent): void {
			var tf: TextField  = TextField(event.target);
			if (tf.selectionBeginIndex == tf.selectionEndIndex) tf.setSelection(0, tf.length);
		}
		
		
		public static function fitTextToMaxWidth(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxWidthTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtilsLite.fitTextToMaxWidthHeight(tf, 0, text, startMaxFontSize, maxWidthTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		public static function fitTextToMaxHeight(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtilsLite.fitTextToMaxWidthHeight(tf, 1, text, startMaxFontSize, maxHeightTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}

		public static function fitTextToMaxTextWidth(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxWidthTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtilsLite.fitTextToMaxWidthHeight(tf, 2, text, startMaxFontSize, maxWidthTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		public static function fitTextToMaxTextHeight(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtilsLite.fitTextToMaxWidthHeight(tf, 3, text, startMaxFontSize, maxHeightTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		public static function fitTextToMaxWidthHeight(tf: */*ITextField*/, isWidthHeightTextWidthTextHeight: uint, text: String, startMaxFontSize: uint, maxWidthHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			if (text != null) {
				if (isSetHtmlText) tf.htmlText = text
				else tf.text = text;
				var tFormat: TextFormat = tf.getTextFormat();
				tFormat.size = startMaxFontSize;
				tf.setTextFormat(tFormat);
				while ((tf[["width", "height", "textWidth", "textHeight"][isWidthHeightTextWidthTextHeight]] > maxWidthHeightTextWhenStartDecreaseFontSize) && (tFormat.size > minFontSize)) {
					tFormat.size = Number(tFormat.size) - 1;
					tf.setTextFormat(tFormat);
				}
				var addXYPos: Number = (maxWidthHeightTextWhenStartDecreaseFontSize - tf[["width", "height", "textWidth", "textHeight"][isWidthHeightTextWidthTextHeight]]) / 2;
				return addXYPos;
			} else {
				return -1;
			}
		}
		
	}

}