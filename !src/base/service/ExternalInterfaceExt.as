package base.service {
	import base.types.Singleton;
	import flash.system.Security;
	import flash.system.Capabilities;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	
	public class ExternalInterfaceExt extends Singleton {
		
		/*{
			Security.allowDomain("*");
		}*/
		
		static public function get isBrowser(): Boolean {
			return ((Capabilities.playerType == "PlugIn") || (Capabilities.playerType == "ActiveX"));
		}
		
		static public function addCallbackAndCall(nameFunction: String, scopeFunction: Object, ...arrParams): void {
			if (ExternalInterfaceExt.isBrowser) {
				arrParams.splice(0, 0, nameFunction);
				ExternalInterface.addCallback(nameFunction, scopeFunction[nameFunction]);
				ExternalInterface.call.apply(ExternalInterface, arrParams);
			} else {
				setTimeout(function(): void {scopeFunction[nameFunction].apply(scopeFunction, arrParams)}, 500, arrParams);
				//scopeFunction[nameFunction].apply(scopeFunction, arrParams);
			}
		}
		
		static public function addCallback(nameFunction: String, scopeFunction: Object): void {
			if (ExternalInterfaceExt.isBrowser)
				ExternalInterface.addCallback(nameFunction, scopeFunction[nameFunction]);
		}
		
		static public function removeCallback(nameFunction: String): void {
			if (ExternalInterfaceExt.isBrowser) 
				ExternalInterface.addCallback(nameFunction, null);
		}
		
		static public function call(nameJSFunction: String, ...arrParams): void {
			if (ExternalInterfaceExt.isBrowser) {
				//ExternalInterface.call(nameJSFunction, arrParams);
				arrParams.unshift(nameJSFunction);
				ExternalInterface.call.apply(ExternalInterface, arrParams);
			}
		}
		
	}

}