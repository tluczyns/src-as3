package base.tf {
	import base.types.Singleton;
	import flash.text.TextField;
	import flash.utils.*;
	
	public class TextFieldUtilsDots extends Singleton	{
		
		static public var countDots: uint = 3;
		static public var timeRepeatAddDots: uint = 120;
		
		static private var dictBaseText: Dictionary = new Dictionary();
		static private var dictNumDots: Dictionary = new Dictionary();
		static private var dictIntervalAddDots: Dictionary = new Dictionary();
		
		static private function repeatAddDots(tf: TextField): void {
			tf.text = TextFieldUtilsDots.dictBaseText[tf];
			if (TextFieldUtilsDots.dictNumDots[tf] == TextFieldUtilsDots.countDots) TextFieldUtilsDots.dictNumDots[tf] = 0;
			else TextFieldUtilsDots.dictNumDots[tf]++;
			for (var i: uint = 0; i < TextFieldUtilsDots.dictNumDots[tf]; i++)
				tf.appendText(".");
		}
		
		static public function addDots(tf: TextField): void {
			TextFieldUtilsDots.dictBaseText[tf] = tf.text;
			TextFieldUtilsDots.stopAddDots(tf);
			TextFieldUtilsDots.dictNumDots[tf] = 0;
			TextFieldUtilsDots.dictIntervalAddDots[tf] = setInterval(TextFieldUtilsDots.repeatAddDots, TextFieldUtilsDots.timeRepeatAddDots, tf);
		}
		
		static public function stopAddDots(tf: TextField): void {
			var intervalAddDots: uint = TextFieldUtilsDots.dictIntervalAddDots[tf];
			if (intervalAddDots) {
				clearInterval(intervalAddDots)
				tf.text = TextFieldUtilsDots.dictBaseText[tf];
			}
		}
	
	}
	
}