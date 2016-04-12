package base.loader {
	import flash.events.EventDispatcher;
	import com.adobe.serialization.json.JSONA;
	import base.utils.FunctionCallback;
	
	public class LoaderJSON extends EventDispatcher {
		
		private var pathJSON: String;
		public var data: Object;
		public var isLoading: Boolean;
		private var isAbort: Boolean;
		
		function LoaderJSON(pathJSON: String): void {
			this.pathJSON = pathJSON;
		}
		
		public function readJSON(): void {
			this.isLoading = true;
			this.isAbort = false;
			var callbackEnd: FunctionCallback = new FunctionCallback(function(isLoaded: Boolean, strData: String, ...args): void {
				this.isLoading = false;
				if (!this.isAbort) {
					//trace("isLoaded:" + isLoaded)
					if (isLoaded) {
						try {
							this.data = JSONA.decode(strData);
							this.parseJSON();
							this.dispatchEvent(new LoaderJSONEvent(LoaderJSONEvent.JSON_LOADED));
						} catch (e: Error) {
							this.dispatchEvent(new LoaderJSONEvent(LoaderJSONEvent.JSON_NOT_LOADED));
						}
					} else this.dispatchEvent(new LoaderJSONEvent(LoaderJSONEvent.JSON_NOT_LOADED));
				}
			}, this)
			var urlLoaderExt: URLLoaderExt = new URLLoaderExt({url: this.pathJSON, isGetPost: 1, callbackEnd: callbackEnd});
		}
		
		protected function parseJSON(): void {}
		
		public function abort(): void {
			this.isAbort = true;
			this.isLoading = false; 
		}
		
	}
}