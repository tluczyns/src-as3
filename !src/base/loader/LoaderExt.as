package base.loader {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;	
	import flash.net.URLRequest;
	import base.service.ExternalInterfaceExt;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	
	public class LoaderExt extends Loader {
		
		private var onLoadComplete: Function;
		private var onLoadProgress: Function;
		private var onLoadError: Function;
		
		public function LoaderExt(objLoaderExt: Object): void {
			super();
			var url: String = String(objLoaderExt.url);
			this.onLoadComplete = objLoaderExt.onLoadComplete || this.onLoadCompleteDefault;
			this.onLoadProgress = objLoaderExt.onLoadProgress || this.onLoadProgressDefault;
			this.onLoadError = objLoaderExt.onLoadError || this.onLoadErrorDefault;
			var checkPolicyFile: Boolean = Boolean(objLoaderExt.checkPolicyFile);
            this.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadComplete);
			this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
            this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			var request: URLRequest = new URLRequest(url);
			if (ExternalInterfaceExt.isBrowser) {
				var variables:URLVariables = new URLVariables();  
				variables.nocache = new Date().getTime(); 
				request.data = variables;
			}
			var context:LoaderContext = new LoaderContext(checkPolicyFile, ApplicationDomain.currentDomain); //SecurityDomain.currentDomain
            this.load(request, context);
		}
			
		private function onLoadCompleteDefault(event:Event): void {
			trace("The img / movie has finished loading.");
		}
		
		private function onLoadProgressDefault(event:ProgressEvent): void {
			var ratioLoaded:Number = event.bytesLoaded / event.bytesTotal;
			var percentLoaded: uint = Math.round(ratioLoaded * 100);
			//trace("The img / movie has loaded in " + percentLoaded + " %");
		}
		
		private function onLoadErrorDefault(errorEvent:IOErrorEvent): void {
            trace("The img / movie could not be loaded: " + errorEvent.text);
        }
		
		public function destroy(): void {
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onLoadComplete);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
            this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			try {this.close();} catch (e: Error) {}
		}
		
	}
	
}