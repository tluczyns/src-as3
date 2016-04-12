package base.tf {
	import base.types.Singleton;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.utils.ByteArray;
	import flash.geom.Transform;
	import flash.text.Font;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import base.math.MathExt;
	import flash.geom.Rectangle;
	import flash.text.TextLineMetrics;
	import flash.text.TextFormatAlign;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	
	public class TextFieldUtils extends Singleton {
		
		public static function createTextField(tFormat: TextFormat = null, isDynamicInput: uint = 0, isSingleMultiLine: uint = 0, isAutoSizeLeftCenterNone: uint = 0, isSetEventForSelectionInInputTf: Boolean = false): TextField {
			var tf: TextField = new TextField();
			tf.type = [TextFieldType.DYNAMIC, TextFieldType.INPUT][isDynamicInput];
			if ((isDynamicInput == 1) && (isSetEventForSelectionInInputTf)) TextFieldUtils.setEventForSelectionInInputTf(tf);
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
			var isFont: Boolean = ((tFormat != null) && (TextFieldUtils.isFontExists(tFormat.font)));
			tf.embedFonts = isFont;
			if (tFormat != null) {
				tf.defaultTextFormat = tFormat;
				tf.setTextFormat(tFormat);
			}
			return tf;
		}
		
		public static function createGradientTextField(tf: TextField, descriptionGradient: DescriptionGradient): GradientTextField {
			return new GradientTextField(tf, descriptionGradient);
		}
		
		public static function createExtrudeTextField(tf: TextField, descriptionGradientFg: DescriptionGradient, colorExtrude: uint, maxZ: Number = 50, precision: uint = 3): ExtrudeTextField {
			return new ExtrudeTextField(tf, descriptionGradientFg, colorExtrude, maxZ, precision);
		}
		
		public static function getByteArray(obj: Object): * {
			var byteArray: ByteArray=new ByteArray();
			byteArray.writeObject(obj);
			byteArray.position = 0;
			return byteArray.readObject();
		}
		
		public static function cloneTextFormat(tFormat: TextFormat): TextFormat {
			var tFormatClone: TextFormat = new TextFormat();
			var objTFormat: Object = TextFieldUtils.getByteArray(tFormat);
			for (var prop:String in objTFormat) tFormatClone[prop] = objTFormat[prop];
			return tFormatClone;
		}
		
		public static function cloneTextField(tf: TextField): TextField {
			var tfClone: TextField = new TextField();
			var objTf: Object = TextFieldUtils.getByteArray(tf);
			for (var prop: String in objTf){
				if (prop == "transform") tfClone[prop] =new Transform(tf);
				else if (prop == "defaultTextFormat") tfClone[prop] = TextFieldUtils.cloneTextFormat(tf[prop]);
				else if (prop != "metaData") {
					try {tfClone[prop] = objTf[prop];}
					catch (err:Error){trace("Error Hit: "+err)}
				}
			}
			/*var tFormat: TextFormat = tf.getTextFormat();
			tfClone.setTextFormat(tFormat);*/
			return tfClone;
		}
		
		public static function isFontExists(fontName: String): Boolean {
			var arrFont: Array = Font.enumerateFonts();
			var i: uint = 0;
			while ((i < arrFont.length) && (fontName != Font(arrFont[i]).fontName)) i++;
			return (i < arrFont.length);
		}
		
		public static function setEventForSelectionInInputTf(tf: TextField): void {
			tf.addEventListener(FocusEvent.FOCUS_IN , TextFieldUtils.onTfFocusIn)
			tf.addEventListener(MouseEvent.MOUSE_UP , TextFieldUtils.onTfMouseUp);
		}
		
		public static function removeEventForSelectionInInputTf(tf: TextField): void {
			tf.removeEventListener(FocusEvent.FOCUS_IN , TextFieldUtils.onTfFocusIn)
			tf.removeEventListener(MouseEvent.MOUSE_UP , TextFieldUtils.onTfMouseUp);
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
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 0, text, startMaxFontSize, maxWidthTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		public static function fitTextToMaxHeight(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 1, text, startMaxFontSize, maxHeightTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}

		public static function fitTextToMaxTextWidth(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxWidthTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 2, text, startMaxFontSize, maxWidthTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
		}
		
		public static function fitTextToMaxTextHeight(tf: */*ITextField*/, text: String, startMaxFontSize: uint, maxHeightTextWhenStartDecreaseFontSize: Number, minFontSize: uint = 4, isSetHtmlText: Boolean = false): Number {
			return TextFieldUtils.fitTextToMaxWidthHeight(tf, 3, text, startMaxFontSize, maxHeightTextWhenStartDecreaseFontSize, minFontSize, isSetHtmlText);
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
		
		public static function setLeadingFromFontSize(tf: TextField, ratioOfFontSize: Number): void {
			var tFormat: TextFormat = tf.getTextFormat();
            tFormat.leading = ratioOfFontSize * Number(tFormat.size);
            tf.setTextFormat(tFormat);
			tf.defaultTextFormat = tFormat;
		}
		
		public static function rotateToFitHeight(tf: TextField, isRotateLeftRight: uint, heightForRotation: Number): void {
			tf.rotation = 0;
			tf.rotation = [1, -1][isRotateLeftRight] * (Math.asin(heightForRotation / MathExt.hypotenuse(tf.width, tf.height)) - Math.atan(tf.height / tf.width)) * MathExt.TO_DEGREES;
		}
		
		public static function blockUnblockInput(tf: TextField, isBlockUnblock: uint): void {
			if (isBlockUnblock == 0) {
				tf.type = "dynamic";
				tf.selectable = false;
			} else if (isBlockUnblock == 1) {
				tf.type = "input";
				tf.selectable = true;
			}
		}
	
		//pobiera szerokość oraz wysokość i pozycję y ostatniej linii tekstu w polu tekstowym multiline 
		//(funkcja do wyznaczania pozycji ikon w btnie w stosunku do pola tekstowego)
		public static function getPosYWidthHeightLastLineInTf(tf: TextField): Rectangle {
			/*
			if (tf.multiline) {
				var rectWidthHeightPosYLastLine: Rectangle = new Rectangle();
				var countLinesTf:int = tf.numLines;
				var strTf:String = "";
				if (countLinesTf == 1) {
					rectWidthHeightPosYLastLine.y = 0;
					rectWidthHeightPosYLastLine.width = tf.textWidth;
					rectWidthHeightPosYLastLine.height = tf.height;
				} else {
					var strTfSource: String = tf.htmlText;
					var arrWordTf: Array = tf.htmlText.split(" ")
					tf.htmlText = "";
					var strTfPrevious: String;
					var numWordTf: uint = 0;
					while ((numWordTf < arrWordTf.length) && (tf.numLines < countLinesTf)) {
						strTfPrevious = tf.htmlText;
						tf.htmlText += ["", " "][uint(numWordTf > 0)] + arrWordTf[numWordTf++];
					}
					numWordTf--;
					tf.htmlText = strTfPrevious;
					rectWidthHeightPosYLastLine.y = tf.height;
					
					tf.htmlText = "";
					for (var numWordTfInLastLine: uint = numWordTf; numWordTfInLastLine < arrWordTf.length; numWordTfInLastLine++) {
						tf.htmlText += ["", " "][uint(numWordTfInLastLine > numWordTf)] + arrWordTf[numWordTfInLastLine];
					}
					rectWidthHeightPosYLastLine.width = tf.textWidth;
					
					tf.htmlText = strTfSource;
					rectWidthHeightPosYLastLine.height = tf.height - rectWidthHeightPosYLastLine.y;
				}
				return rectWidthHeightPosYLastLine;
			} else return null;*/
			var tfLineMetrics: TextLineMetrics = tf.getLineMetrics(tf.numLines - 1);
			var sumHeight: Number = 0;
			for (var numLine: uint = 0; numLine < tf.numLines; numLine++) {
				tfLineMetrics = tf.getLineMetrics(numLine);
				if (numLine < tf.numLines - 1) sumHeight += (tfLineMetrics.ascent + tfLineMetrics.descent + tfLineMetrics.leading);
			}
			var rectWidthHeightPosYLastLine: Rectangle = new Rectangle();
			rectWidthHeightPosYLastLine.y = sumHeight + 2;
			rectWidthHeightPosYLastLine.width = [tfLineMetrics.x, 2][uint(tf.getTextFormat().align == TextFormatAlign.LEFT)] + tfLineMetrics.width;
			rectWidthHeightPosYLastLine.height = tfLineMetrics.height;
			return rectWidthHeightPosYLastLine;
		}
		
		public static function createUnderline(tf: TextField, thickness: Number): Shape {
			var underline: Shape = new Shape();
			underline.graphics.beginFill(uint(tf.getTextFormat().color), 1);
			underline.graphics.drawRect(0, 0, tf.width, thickness);
			underline.graphics.endFill();
			underline.x = Math.round(tf.x);
			underline.y = Math.round(tf.y + tf.height - 2);
			var tfParent: DisplayObjectContainer = tf.parent;
			if (tfParent != null) tfParent.addChild(underline);
			return underline;
		}
		
		public static function changeTFormatPropsInTf(tf: TextField, objPropToChange: Object, beginIndex:int = -1, endIndex:int = -1): void {
			var tFormat: TextFormat = tf.getTextFormat(beginIndex, endIndex);
			for (var prop: String in objPropToChange) tFormat[prop] = objPropToChange[prop];
			tf.setTextFormat(tFormat, beginIndex, endIndex);
			tf.defaultTextFormat = tFormat;
		}
		
		public static function traceFonts():void {
			var embeddedFonts:Array = Font.enumerateFonts(false);
			embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);
			trace("\n\n----- Enumerate Fonts -----");
			for (var i:int = 0; i < embeddedFonts.length; i++) {
				var font: Font = embeddedFonts[i];
				trace(font.fontName, font.fontStyle);
			}
			trace("---------------------------\n\n");
		}
		
	}
	
}