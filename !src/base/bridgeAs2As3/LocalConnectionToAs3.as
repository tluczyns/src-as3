class base.bridgeAs2As3.LocalConnectionToAs3 extends LocalConnection {
	
	public function LocalConnectionToAs3(suffixNameConnection: String) {
		this.suffixNameConnection = suffixNameConnection || "";
	}
	
	function call(strFunction: String, args: Array) {
		this.send('connFromAs2ToAs3' + this.suffixNameConnection, 'connectionCall', strFunction, args);
	}
	
}