package base.service {
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.events.NetStatusEvent;
	
	public class ServiceAmf extends NetConnection {
		
		public static var ref: ServiceAmf;
		private var nameService: String;
		private var isConnected: Boolean;
		private var onStatus: Function;
		public var arrIdCalls: Array;
		
		public function ServiceAmf (url: String, nameService: String): void {
			ServiceAmf.ref = this;
			this.objectEncoding = ObjectEncoding.AMF3;
			this.nameService = nameService;
			this.isConnected = true;
			try {
				this.connect(url);
			} catch (e: Error) {
				this.isConnected = false;
			}
			this.addEventListener(NetStatusEvent.NET_STATUS, this.onStatusNetConnection);
			this.arrIdCalls = new Array();
		}
		
		public function callServiceFunction(nameFunction: String, onResult: Function = null, onStatus: Function = null, ... arrParams): uint {
			trace("callServiceFunction:", nameFunction)
			this.onStatus = onStatus;
			if (this.isConnected) {
				this.arrIdCalls.push(1);
				var idCall: uint = this.arrIdCalls.length - 1
				var onResultInternal: Function = function(objResult: Object): void { 
					if ((arrIdCalls[idCall] == 1) && (onResult != null)) onResult(objResult); 
					else trace("aborted call " + idCall);
				}
				var responder: Responder = new Responder(onResultInternal, this.onStatusAmf);
				arrParams.splice(0, 0, this.nameService + "." + nameFunction, responder);
				this.call.apply(this, arrParams);
				return idCall;
			} else {
				this.onStatusAmf({faultDetail: "not connected"});
				return 0;
			}
		}
		
		public function abort(idCall: int): Boolean {
			if ((idCall >= 0) && (idCall < this.arrIdCalls.length)) {
				this.arrIdCalls[idCall] = 0;
				return true;
			} else return false;
		}
		
		public function onStatusAmf(error: Object) : void {
			trace("faultDetail:" + error.faultDetail, "faultString:" + error.faultString, "faultCode:" + error.faultCode);
			if (this.onStatus != null) this.onStatus(error, 1);
		}
		
		public function onStatusNetConnection(event: NetStatusEvent): void {
            var infoCode: String = event.info.code;
			trace("infoCode:" + infoCode); 
			if ((infoCode == "NetConnection.Call.BadVersion") || (infoCode == "NetConnection.Call.Failed") || (infoCode == "NetConnection.Call.Prohibited")) {
				trace("infoCode:" + infoCode);
				if (this.onStatus != null) this.onStatus(event, 0);
			}
		}
		
	}

}