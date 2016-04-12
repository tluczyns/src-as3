package base.tf {
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	import com.luaye.console.C;
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ExampleExtrudeTextField extends Sprite {
		
		[Embed(source = "SamsungIF_Blk.ttf", fontName="Samsung InterFace Black", mimeType = 'application/x-font', advancedAntiAliasing="true", embedAsCFF='false', unicodeRange='U+0020-U+007E, U+0105, U+0119, U+00F3, U+0142, U+017C, U+017A, U+0107, U+015B, U+0144, U+0104, U+0118, U+00D3, U+0141, U+017B, U+0179, U+0106, U+015A, U+0143, U+00A0, U+F0B7, U+0095, U+0099, U+00B0')]
		static public const classFontInterFaceBlack: Class;
		{Font.registerFont(ExampleExtrudeTextField.classFontInterFaceBlack);}
		
		private var eTf: ExtrudeTextField;
		
		public function ExampleExtrudeTextField(): void {
			C.start(this);
			var tf: TextField = TextFieldUtils.createTextField(new TextFormat("Samsung InterFace Black", 150, 0x000000));
			tf.text = "DO ZOBACZENIA";
			this.eTf = new ExtrudeTextField(tf, new DescriptionGradient([0xffff00, 0x00ff00], [1, 1], [0, 255], 0), 0xAAAAAA, 100, 10);
			this.eTf.x = 50;
			this.eTf.y = 250;
			this.addChild(this.eTf);
			
			TweenMax.to(this.eTf, 2, { x: 600, ease: Cubic.easeInOut, yoyo: true, repeat: -1 } );
		}
		
	}

}