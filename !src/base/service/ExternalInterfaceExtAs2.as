import flash.external.ExternalInterface;

class base.service.ExternalInterfaceExtAs2 {
	
	static public function get isBrowser(): Boolean {
		return ((System.capabilities.playerType == "PlugIn") || (System.capabilities.playerType == "ActiveX"));
	}
	
	static public function addCallbackAndCall(nameFunction, scopeFunction): Void {
		var arrParams = arguments.splice(2);
		if (ExternalInterfaceExtAs2.isBrowser) {
			arrParams.splice(0, 0, nameFunction);
			ExternalInterface.addCallback(nameFunction, scopeFunction, scopeFunction[nameFunction]);
			ExternalInterface.call.apply(ExternalInterface, arrParams);
		} else {
			setTimeout(function(): Void {scopeFunction[nameFunction].apply(scopeFunction, arrParams)}, 500, arrParams);
			//scopeFunction[nameFunction].apply(scopeFunction, arrParams);
		}
	}
	
	static public function addCallback(nameFunction, scopeFunction): Void {
		if (ExternalInterfaceExtAs2.isBrowser)
			ExternalInterface.addCallback(nameFunction, scopeFunction, scopeFunction[nameFunction]);
	}
	
	static public function removeCallback(nameFunction): Void {
		if (ExternalInterfaceExtAs2.isBrowser) 
			ExternalInterface.addCallback(nameFunction, null, null);
	}
	
	static public function call(nameJSFunction): Void {
		var arrParams = arguments.splice(1);
		if (ExternalInterfaceExtAs2.isBrowser) {
			//ExternalInterface.call(nameJSFunction, arrParams);
			arrParams.unshift(nameJSFunction);
			ExternalInterface.call.apply(ExternalInterface, arrParams);
		}
	}
	
}