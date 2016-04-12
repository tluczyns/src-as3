package base.loader {
	import flash.events.EventDispatcher;
	import base.utils.FunctionCallback;

	public class LoaderXML extends EventDispatcher {
		
		public var isLoading: Boolean;
		public var isLoaded: Boolean;
		private var isAbort: Boolean;
		
		function LoaderXML(): void {}
		
		public function loadXML(pathXML: String): void {
			if (!this.isLoading) {
				this.isLoaded = false;
				this.isLoading = true;
				this.isAbort = false;
				var callbackEnd: FunctionCallback = new FunctionCallback(function(isLoaded: Boolean, strNode: String, ...args): void {
					this.isLoading = false;
					if (!this.isAbort) {
						//trace("isLoaded:" + isLoaded)
						if (isLoaded) {
							this.isLoaded = true;
							var xmlNode: XML = new XML(strNode)
							this.parseXML(xmlNode);
							this.dispatchEvent(new EventLoaderXML(EventLoaderXML.XML_LOADED, xmlNode));
						} else this.dispatchEvent(new EventLoaderXML(EventLoaderXML.XML_NOT_LOADED));
					}
				}, this);
				var urlLoaderExt: URLLoaderExt = new URLLoaderExt({url: pathXML, isGetPost: 0, callbackEnd: callbackEnd});
			}
		}
		
		public function parseXML(xmlNode: XML): void {}
		
		public function abort(): void {
			this.isAbort = true;
			this.isLoading = false; 
		}
		
	}
}