package base.bridgeAs2As3 {
	import flash.events.EventDispatcher;
	
	public class BridgeFromToAs2 extends EventDispatcher {
		
		private var lcFromAs2: LocalConnectionFromAs2;
		private var lcToAs2: LocalConnectionToAs2;
		
		public function BridgeFromToAs2(suffixNameConnection: String = ""): void {
			this.lcFromAs2 = new LocalConnectionFromAs2(this, suffixNameConnection);
			this.lcToAs2 = new LocalConnectionToAs2(suffixNameConnection);	
		}
		
		public function call(strFunction: String, args: Array = null): void {
			this.lcToAs2.call(strFunction, args);
		}
		
		public function close(): void {
			try {
				this.lcFromAs2.close();
			} catch (e: Error) {}
		}
		
	}
	
}