package ca.newcommerce.googlecontacts.webservice 
{
	import ca.newcommerce.googlecontacts.events.ContactFeedEvent;
	import ca.newcommerce.googlecontacts.events.GContactsEvent;
	import ca.newcommerce.googlecontacts.events.GroupFeedEvent;
	import ca.newcommerce.googlecontacts.events.PhotoEvent;
	import ca.newcommerce.googlecontacts.feeds.ContactFeed;
	import ca.newcommerce.googlecontacts.feeds.GroupFeed;
	import com.dynamicflash.util.Base64;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.utils.ByteArray;
	
	/**
	 * Dispatched when the list of contacts has been received
	 * @eventType ca.newcommerce.googlecontacts.events.ContactFeedEvent.READY
	 */
	[Event(name="contact_feed_ready",type="ca.newcommerce.googlecontacts.events.ContactFeedEvent")]	
	
	/**
	 * Dispatched when the list of groups has been received
	 * @eventType ca.newcommerce.googlecontacts.events.GroupFeedEvent.READY
	 */
	[Event(name="group_feed_ready",type="ca.newcommerce.googlecontacts.events.GroupFeedEvent")]	
	
	
	/**
	 * Dispatched when a photo is ready!
	 * @eventType ca.newcommerce.googlecontacts.events.PhotoEvent.LOADED
	 */
	[Event(name="photo_loaded",type="ca.newcommerce.googlecontacts.events.PhotoEvent")]
	
	/**
	* ...
	* @author Martin Legris ( http://blog.martinlegris.com )
	*/
	public class GContactsClient extends EventDispatcher
	{
		protected const _clientId:String = "ytapi-MartinLegris-YoutubeDiscovery-rn7ifdis-0";
		protected const _developerKey:String = "AI39si5ojvdQW_7wzbgApyTS1EMXiEfRVZtq4usxFYDFq6ZqEDiaSsPrkNLdFPwy97z9wyGtk6FPrc35H5B9LjugSQG5duueYg";
		protected const _apName:String = "NewCommerceSolutionsInc_discovery_01";
		
		protected var _auth:String = "";
		protected var _username:String = "";
		
		protected var _requestQueue:Array;
		protected var _requestId:Number = 0;
		
		protected var _conn:NetConnection;
		
		protected var _proxyUrl:String = "http://www.martinlegris.com/amf3/gateway.php";
		
		private static var _instance:GContactsClient;
		
		public static function getInstance():GContactsClient
		{
			if (_instance == null)
				_instance = new GContactsClient();
				
			return _instance;
		}
		
		public function get proxyUrl():String { return _proxyUrl; }
		
		public function set proxyUrl(value:String):void {
			_proxyUrl = value;
		}

		public function GContactsClient() 
		{
			_requestQueue = [];
			
			_conn = new NetConnection();
			_conn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, doAsyncError);
			_conn.addEventListener(NetStatusEvent.NET_STATUS, doNetStatus);
			_conn.addEventListener(IOErrorEvent.IO_ERROR, doIOError);
			_conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, doSecurityError);
			_conn.connect(_proxyUrl);	
		}
		
		protected function getRequestById(id:Number):Object
		{
			var i:Number = 0;
			for (i = 0; i < _requestQueue.length; i++)
			{
				if (_requestQueue[i].id == id)
					return _requestQueue[i];
			}
			
			return null;
		}
		
		public function login(username:String, password:String, loginToken:String = "", captcha:String = ""):Number
		{
			var url:String =  "https://www.google.com/accounts/ClientLogin";
			var headers:Array = ["Content-Type", "application/x-www-form-urlencoded"];
			var method:String = "POST";
			var postVars:Array = ["Email=" + username,
								  "Passwd=" + password,
								  "service=cp",
								  "source=" + _apName];
								  
			if (loginToken.length)
				postVars.push("loginToken=" + loginToken);
				
			if (captcha.length)
				postVars.push("captcha=" + captcha);
				
			var responder:Responder = new Responder(doLogin, doFault);
			var wrapper:Object = getWrapper(responder, "login");
				
			callProxy(responder, url, method, [], postVars, headers, wrapper.id);
			
			return wrapper.id;
		}
		
		protected function callProxy(responder:Responder, url:String, method:String, getVars:Array, postVars:Array, headers:Array, id:Number, base64Encode:Boolean = false):void
		{
			_conn.call("RESTProxy.request", responder, url, method, getVars, postVars, headers, id, base64Encode);
		}
		
		protected function doLogin(result:Object):void
		{	
			var content:String = result.content;
			var wrapper:Object = getWrapperFromResult(result);
			
			if (result.httpCode == "200")
			{
				
				var authRegEx:RegExp = /Auth=(.*)\n/i;
				var userRegEx:RegExp = /YouTubeUser=(.*)\n/i;

				_auth = authRegEx.exec(content)[1];
				
				dispatchEvent(new GContactsEvent(GContactsEvent.LOGIN_SUCCESS, wrapper));
			}
			else if (result.httpCode == "403")
			{
				var errEx:RegExp = /Error=(.+)\n/i;
				//var error:String = errEx.exec(content)[1];
				
				dispatchEvent(new GContactsEvent(GContactsEvent.LOGIN_FAILED, wrapper ));
			}
			else if (result.httpCode == "401")
			{
				
			}
		}
		
		public function getGroups():Number
		{
			var url:String = "http://www.google.com/m8/feeds/groups/default/full";
			var method:String = "GET";
			var headers:Array = getStdHeaders();
			
			var responder:Responder = new Responder(doGroups, doFault);
			var wrapper:Object = getWrapper(responder, "groups");
			
			callProxy(responder, url, method, [], [], headers, wrapper.id);
			
			return wrapper.id;
		}
		
		protected function doGroups(result:Object):void
		{
			var content:String = result.content;
			var wrapper:Object = getWrapperFromResult(result);
			var feed:GroupFeed = new GroupFeed(new XML(content));
			dispatchEvent(new GroupFeedEvent(GroupFeedEvent.READY, feed));			
		}
		
		public function getContacts(startIndex:Number = 1, maxResults:Number = 25):Number
		{
			//GET http://www.google.com/m8/feeds/contacts/liz%40gmail.com/full
			var url:String = "http://www.google.com/m8/feeds/contacts/default/thin?start-index="+startIndex+"&max-results="+maxResults;
			var method:String = "GET";
			var headers:Array = getStdHeaders();
			
			var responder:Responder = new Responder(doContacts, doFault);
			var wrapper:Object = getWrapper(responder, "contacts");
			
			callProxy(responder, url, method, [], [], headers, wrapper.id);
			
			return wrapper.id;
		}
		
		protected function doContacts(result:Object):void
		{
			var content:String = result.content;
			var wrapper:Object = getWrapperFromResult(result);
			var feed:ContactFeed = new ContactFeed(new XML(content));
			
			dispatchEvent(new ContactFeedEvent(ContactFeedEvent.READY, feed));
		}
		
		public function getPhoto(photoUrl:String):Number
		{
			var url:String = photoUrl;
			var method:String = "GET";
			var headers:Array = getStdHeaders();
			
			var responder:Responder = new Responder(doPhoto, doFault);
			var wrapper:Object = getWrapper(responder, "photo");
			
			callProxy(responder, url, method, [], [], headers, wrapper.id, true);
			
			return wrapper.id;
		}
		
		protected function doPhoto(result:Object):void
		{
			var wrapper:Object = getWrapperFromResult(result);
			var ba:ByteArray = Base64.decodeToByteArray(result.content);
			trace("length:"+ba.length);
			var loader:Loader = new Loader();
			loader.loadBytes(ba);

			dispatchEvent(new PhotoEvent(PhotoEvent.LOADED, loader, wrapper.id));
		}
		
		protected function getStdHeaders():Array
		{
			var headers = ["Content-Type: application/atom+xml",
			   "Authorization: GoogleLogin auth=" + _auth];

			return headers;
		}
		
		protected function getWrapper(responder:Responder, type:String):Object
		{
			var wrapper:Object = { };
			wrapper.id = _requestId++;
			wrapper.success = false;
			wrapper.type = type;
			wrapper.responder = responder;
			_requestQueue.push(wrapper);
			
			return wrapper;
		}
		
		protected function getWrapperById(requestId:Number):Object
		{
			for (var i:Number = 0; i < _requestQueue.length; i++)
			{
				if (_requestQueue[i].id == requestId)
					return _requestQueue[i];
			}
			
			trace("wrapper with requestId:" + requestId + " not found. Returning null");
			return null;
		}
		
		protected function getWrapperFromResult(result:Object):Object
		{
			var requestId:Number = parseInt(result.requestId);
			return getWrapperById(requestId);
		}
		
		protected function doAsyncError(evt:AsyncErrorEvent):void
		{
			
		}
		
		protected function doNetStatus(evt:NetStatusEvent):void
		{
			
		}
		
		protected function doIOError(evt:IOErrorEvent):void
		{
			
		}
		
		protected function doSecurityError(evt:SecurityErrorEvent):void
		{
			
		}
		
		protected function doFault(fault:Object):void
		{
			
		}
	}
}