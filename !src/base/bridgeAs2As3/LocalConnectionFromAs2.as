package base.bridgeAs2As3 {
	import flash.net.LocalConnection;
	
	public class LocalConnectionFromAs2 extends LocalConnection {
		
		public var classBridgeFromToAs2: BridgeFromToAs2;
		
		public function LocalConnectionFromAs2(classBridgeFromToAs2: BridgeFromToAs2, suffixNameConnection: String) {
			this.classBridgeFromToAs2 = classBridgeFromToAs2;
			try {this.connect("connFromAs2ToAs3" + suffixNameConnection);}
			catch (e: ArgumentError) {}
			finally {}
			this.client = {connectionCall: this.connectionCall};	
		}
		
		public function connectionCall(strFunction: String, args: Array): void {
			this.classBridgeFromToAs2[strFunction].apply(this.classBridgeFromToAs2, [args]);
		}
		
	}

}