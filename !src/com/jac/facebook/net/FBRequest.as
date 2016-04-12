package com.jac.facebook.net 
{//Package
	import adobe.utils.ProductManager;
	import com.adobe.serialization.json.JSON;
	import com.jac.facebook.net.events.FBRequestEvent;
	import com.jac.log.Log;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class FBRequest extends EventDispatcher
	{//FBRequest Class
	
		static public const BINARY_DATA:String = "binarydata";
	
		private const BASE_URL:String = "https://graph.facebook.com";
		
		protected var _loader:URLLoader;
		protected var _variables:URLVariables;
		protected var _completeRequest:URLRequest;
		protected var _requestMethod:String;
		protected var _resultFormat:String;
		
		protected var _callback:Function;
		protected var _itemID:String;
		protected var _rpc:String;
		protected var _args:Object;
		protected var _accessToken:String;
		
		
		public function FBRequest(callback:Function, itemID:String, rpc:String, accessToken:String, args:Object = null, resultFormat:String = URLLoaderDataFormat.TEXT, requestMethod:String = URLRequestMethod.GET, baseURL:String = BASE_URL) 
		{//FBRequest
			_callback = callback;
			_itemID = itemID;
			_rpc = rpc;
			_args = args;
			_accessToken = accessToken;
			_requestMethod = requestMethod;
			
			//Build Request
			_variables = new URLVariables();
			
			//Update file path if needed
			if (rpc.charAt(0) != "/" && rpc != "")
			{//add forward slash
				rpc = ("/" + rpc);
			}//add forward slash
			
			//Build base request
			_completeRequest = new URLRequest(baseURL + ("/")+ _itemID + rpc);
			
			//Build arguments
			_variables["access_token"] = _accessToken;
			if (_args)
			{//vars
				//Gather vars
				for (var myVar:String in _args)
				{//get each var
					_variables[myVar] = _args[myVar];
				}//get each var
			}//vars
			
			//Add vars
			_completeRequest.data = _variables;
			
			//Set method
			_completeRequest.method = _requestMethod;
			
			//Set up loader
			_loader = new URLLoader();
			_loader.dataFormat = resultFormat;
			
			//Setup events
			_loader.addEventListener(Event.COMPLETE, completeHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleHTTPStatus, false, 0, true);
		}//FBRequest
		
		public function load():void
		{//load
			_loader.load(_completeRequest);
		}//load
		
		/**
		 * Compares the result from the web request to the string "success".
		 * <br/> however this is designed to be overridded, so as to do a custom evaluation.
		 * @param	e
		 * @return	returns <code>true</code> if the request was a success, <code>false</code> otherwise.
		 */
		protected function evaluateSuccess(e:Event):FBSuccessResult
		{//evaluateSuccess
			//Log.log("Returned Data: " + e.target.data);
			
			if (e.target.data is ByteArray)
			{//binary data
				return new FBSuccessResult(true);
			}//binary data
			else
			{//text data
				var rawData:String = e.target.data;
				var resultObj:Object = JSON.decode(rawData);
				
				if (resultObj["error"])
				{//we have an error
					return new FBSuccessResult(false, String(resultObj["error"]["type"]), String(resultObj["error"]["message"])); 
				}//we have an error
				else
				{//good
					return new FBSuccessResult(true);
				}//good
			}//text data
		}//evaluateSuccess
		
		private function handleHTTPStatus(e:HTTPStatusEvent):void 
		{//handleHTTPStatus
			Log.log("HTTPStatus: " + e.status);
		}//handleHTTPStatus
		
		/**
		 * Called when the request has finished and returned a value.
		 * @param	e
		 */
		protected function completeHandler(e:Event):void
		{//completeHandler
			var returnedSuccess:FBSuccessResult = evaluateSuccess(e);
			var returnedResult:String;
			var evt:FBRequestEvent;
			
			//create event
			if (_resultFormat == URLLoaderDataFormat.BINARY)
			{//binary data
				returnedResult = BINARY_DATA;
				evt = new FBRequestEvent(FBRequestEvent.COMPLETE, returnedSuccess, returnedResult, e.target.data);
			}//binary data
			else
			{//text data
				 returnedResult = e.target.data;
				evt = new FBRequestEvent(FBRequestEvent.COMPLETE, returnedSuccess, returnedResult);
			}///text data
			
			//notify of completion
			if (_callback != null){_callback(evt);}
			dispatchEvent(evt);
		}//completeHandler
		
		/**
		 * Called when the request returns with an error.  This dispatches a FBRequestEvent.COMPLETE with "IOError" passed as the error property.
		 * <br/>Please note that this is different than a failed <code>evaluateSuccess</code> call.
		 * @param	e
		 */
		protected function ioErrorHandler(e:IOErrorEvent):void
		{//ioErrorHandler
			var evt:FBRequestEvent = new FBRequestEvent(FBRequestEvent.COMPLETE, new FBSuccessResult(false, "IOError", String(e)), e.text);
			if (_callback != null){_callback(evt);}
			dispatchEvent(evt);
			
			Log.log("ServiceRequest:ioErrorHandler: An error was thrown during the request: " + e.text);
		}//ioErrorHandler
		
		/**
		 * Called when the request retruns with a security error. This dispatches a FBRequestEvent.COMPLETE with "SecurityError" passed as the error property.
		 * @param	e
		 */
		protected function securityErrorHandler(e:SecurityErrorEvent):void
		{//securityErrorHandler
			var evt:FBRequestEvent = new FBRequestEvent(FBRequestEvent.COMPLETE, new FBSuccessResult(false, "SecurityError", String(e)), e.text);
			if (_callback != null){_callback(evt);}
			dispatchEvent(evt);
			
			Log.log("ServiceRequest:securityErrorHandler: A security error was thrown during a request");
		}//securityErrorHandler
		
		/**
		 * Called when there has been progress on the request result download.  This redispatches the ProgressEvent.
		 * @param	e
		 */
		protected function progressHandler(e:ProgressEvent):void
		{//progressHandler
			dispatchEvent(e);
		}//progressHandler
		
		public function get url():String
		{//get url
			return (_completeRequest.url + "?" + _completeRequest.data);
		}//get url
		
		public function get requestMethod():String { return _requestMethod; }
		public function set requestMethod(value:String):void 
		{
			_requestMethod = value;
			_completeRequest.method = _requestMethod;
		}
		
		public function get resultFormat():String { return _resultFormat; }
		public function set resultFormat(value:String):void 
		{
			_resultFormat = value;
			_loader.dataFormat = _resultFormat;
		}
		
	}//FBRequest Class

}//Package