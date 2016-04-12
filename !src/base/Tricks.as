package base {
	import flash.net.LocalConnection;
	
	public class Tricks {
		
		public static function runGC(): Boolean {
			try {
				var lc1:LocalConnection = new LocalConnection();
				var lc2:LocalConnection = new LocalConnection();
				lc1.connect('name');
				lc2.connect('name');
			} catch (e: Error) {
				return false;
			}
			return true;
		}
		
		//trace(getFunctionName(new Error());
		public static function getFunctionName(e:Error):String {
			var stackTrace:String = e.getStackTrace();     // entire stack trace
			var startIndex:int = stackTrace.indexOf("at ");// start of first line
			var endIndex:int = stackTrace.indexOf("()");   // end of function name
			stackTrace = stackTrace.substring(startIndex + 3, endIndex);
			return stackTrace.substring(stackTrace.lastIndexOf("/") + 1)
		}

	}
	
}