package base.bridgeAs2As3 {
	import flash.net.LocalConnection;
	
	public class LocalConnectionToAs2 extends LocalConnection {
		
		private var suffixNameConnection: String;
		
		public function LocalConnectionToAs2(suffixNameConnection: String = ""): void {
			this.suffixNameConnection = suffixNameConnection;
		}
		
		internal function call(strFunction: String, args: Array = null): void {
			this.send("connFromAs3ToAs2" + this.suffixNameConnection, "connectionCall", strFunction, args);
		}
		
	}
	
}