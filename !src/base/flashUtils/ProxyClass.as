package base.flashUtils {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.events.Event;
	
	public dynamic class ProxyClass extends Proxy {
		
		public var object: *;
		
		public function ProxyClass(object: *): void {
			this.object = object;
		}

		override flash_proxy function callProperty(methodName: *, ... args): * {
			var result: * = this.object[methodName].apply(this.object, args);
			this.object.dispatchEvent(new ProxyClassEvent(ProxyClassEvent.PROPERTY_CALL, {methodName: methodName, args: args}));
			return result;
		}

		override flash_proxy function getProperty(name: *): * {
			return this.object[name];
		}

		override flash_proxy function setProperty(name: *, value: *): void {
			this.object[name] = value;
			this.object.dispatchEvent(new ProxyClassEvent(ProxyClassEvent.PROPERTY_CHANGE, {name: name, value: value}));
		}
		
	}
	
}