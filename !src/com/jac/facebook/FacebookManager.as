package com.jac.facebook 
{//Package
	import com.jac.facebook.net.events.FBRequestEvent;
	import com.jac.facebook.net.FBClassicRequest;
	import com.jac.facebook.net.FBRequest;
	import com.jac.log.Log;
	import flash.display.LoaderInfo;
	import flash.events.EventDispatcher;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	
	public class FacebookManager extends EventDispatcher
	{//FacebookManager Class
	
		static public const NO_TOKEN:String = "noFacebookAccessToken";
		
		private var _params:Object;
		private var _goodToken:Boolean = false;
		
		//PARAMS
		private var _accessToken:String;
		private var _fb_sig_in_iframe:String;
		private var _fb_sig_iframe_key:String;
		private var _fb_sig_locale:String;
		private var _fb_sig_in_new_facebook:String;
		private var _fb_sig_time:String;
		private var _fb_sig_added:String;
		private var _fb_sig_profile_update_time:String;
		private var _fb_sig_expires:String;
		private var _fb_sig_user:String;
		private var _fb_sig_session_key:String;
		private var _fb_sig_ss:String;
		private var _fb_sig_cookie_sig:String;
		private var _fb_sig_ext_perms:String;
		private var _fb_sig_api_key:String;
		private var _fb_sig_app_id:String;
		private var _fb_sig:String;
		
		
		public function FacebookManager(loaderInfo:LoaderInfo, testToken:String="") 
		{//FacebookManager
		
			//Grab Params
			_params = loaderInfo.parameters;
		
			//Grab crossdomain
			Security.loadPolicyFile("https://graph.facebook.com/crossdomain.xml");
			
			if (_params.access_token)
			{//good token
				Log.log("Using Real Token: " + _params.access_token);
				_accessToken = _params.access_token;
				_goodToken = true;
				
				setAllProps();
				
			}//good token
			else if(testToken != "")
			{//test token
				Log.log("Using Test Token: " + testToken);
				_accessToken = testToken;
				_goodToken = true;
			}//test token
			else
			{//test token
				Log.log("No Usable Token!");
				_accessToken = NO_TOKEN;
				_goodToken = false;
			}//test token
			
		}//FacebookManager
		
		private function setAllProps():void
		{//setAllProps
			
			_fb_sig_in_iframe = _params["fb_sig_in_iframe"];
			_fb_sig_iframe_key = _params["fb_sig_iframe_key"];
			_fb_sig_locale = _params["fb_sig_locale"];
			_fb_sig_in_new_facebook = _params["fb_sig_in_new_facebook"];
			_fb_sig_time = _params["fb_sig_time"];
			_fb_sig_added = _params["fb_sig_added"];
			_fb_sig_profile_update_time = _params["fb_sig_profile_update_time"];
			_fb_sig_expires = _params["fb_sig_expires"];
			_fb_sig_user = _params["fb_sig_user"];
			_fb_sig_session_key = _params["fb_sig_session_key"];
			_fb_sig_ss = _params["fb_sig_ss"];
			_fb_sig_cookie_sig = _params["fb_sig_cookie_sig"];
			_fb_sig_ext_perms = _params["fb_sig_ext_perms"];
			_fb_sig_api_key = _params["fb_sig_api_key"];
			_fb_sig_app_id = _params["fb_sig_app_id"];
			_fb_sig = _params["fb_sig"];
			Log.log("Set all props");
		}//setAllProps
		
		public function fbRequest(callback:Function, itemID:String, apiCall:String = "", paramObject:Object = null):void
		{//fbRequest
			var fbReq:FBRequest = new FBRequest(callback, itemID, apiCall, _accessToken, paramObject);
			fbReq.addEventListener(FBRequestEvent.COMPLETE, handleFBRequestComplete, false, 0, false);
			fbReq.load();
		}//fbRequest
		
		public function fbClassicRequest(callback:Function, apiCall:String, paramObject:Object):void
		{//fbClassicRequest
			var fbReq:FBClassicRequest = new FBClassicRequest(callback, apiCall, _accessToken, paramObject);
			fbReq.addEventListener(FBRequestEvent.COMPLETE, handleFBClassicRequestComplete, false, 0, false);
			fbReq.load();
		}//fbClassicRequest
		
		public function fbBinaryRequest(callback:Function, itemID:String, apiCall:String = "", paramObject:Object = null):void
		{//fbBinaryRequest
			var fbReq:FBRequest = new FBRequest(callback, itemID, apiCall, _accessToken, paramObject);
			fbReq.resultFormat = URLLoaderDataFormat.BINARY;
			fbReq.addEventListener(FBRequestEvent.COMPLETE, handleFBClassicRequestComplete, false, 0, false);
			fbReq.load();
		}//fbBinaryRequest
		
		private function handleFBClassicRequestComplete(e:FBRequestEvent):void 
		{//handleFBClassicRequestComplete
			dispatchEvent(e);
		}//handleFBClassicRequestComplete
		
		private function handleFBRequestComplete(e:FBRequestEvent):void 
		{//handleFBRequestComplete
			Log.log("Handle Request COmplete: " + e.result);
			dispatchEvent(e);
		}//handleFBRequestComplete
		
		private function handleFeedComplete(e:FBRequestEvent):void 
		{//handleFeedComplete
			dispatchEvent(e);
		}//handleFreedComplete
		
		
		////////////////////////////// CONVENIENCE AND EXAMPLE METHODS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
		public function getMeClassic(callback:Function):void
		{//getMeClassic
			if (_goodToken)
			{//good
				var fbReq:FBClassicRequest = new FBClassicRequest(callback, "users.getInfo", _accessToken, {"uids":_fb_sig_user, "fields":"first_name,last_name"});
				fbReq.addEventListener(FBRequestEvent.COMPLETE, handleGetMeClassicComplete, false, 0, true);
				
				Log.log("Complete ClassicME Request: " + fbReq.url);
				
				fbReq.load();
				
			}//good
		}//getMeClassic
		
		
		public function getMe(callback:Function):void
		{//getMe
			if (_goodToken)
			{//good
				var fbReq:FBRequest = new FBRequest(callback, "me", "", _accessToken);
				fbReq.addEventListener(FBRequestEvent.COMPLETE, handleGetMeComplete, false, 0, true);
				
				Log.log("CompleteRequest: " + fbReq.url);
				
				fbReq.load();
			}//good
		}//getMe
		
		public function postToFeed(callback:Function, profileID:String, message:String="", name:String="", link:String="", description:String="", pic:String=""):void
		{//postToFeed
			if (_goodToken)
			{//good
				var argsObj:Object = new Object();
				
				if (message != "")
				{//
					argsObj["message"] = message;
				}//
				
				if (name != "")
				{//name
					argsObj["name"] = name;
				}//name
				
				if (link != "")
				{//link
					argsObj["link"] = link;
				}//link
				
				if (description != "")
				{//description
					argsObj["description"] = description;
				}//description
				
				if (pic != "")
				{//pic
					Log.log("Adding Pic: " + pic);
					argsObj["picture"] = pic;
				}//pic
				
				var fbReq:FBRequest = new FBRequest(callback, profileID, "feed", _accessToken, argsObj);
				fbReq.requestMethod = URLRequestMethod.POST;
				fbReq.addEventListener(FBRequestEvent.COMPLETE, handleFeedComplete, false, 0, false);
				Log.log("Full Request: " + fbReq.url);
				fbReq.load();
			}//good
		}//postToFeed
		
		//////////// CALL HANDLERS \\\\\\\\\\\
		private function handleGetMeClassicComplete(e:FBRequestEvent):void 
		{//handleGetMeClassicComplete
			dispatchEvent(e);
		}//handleGetMeClassicComplete
		
		private function handleGetMeComplete(e:FBRequestEvent):void 
		{//handleGetmeComplete
			dispatchEvent(e);
		}//handleGetMeComplete
		
		
		////////// GETTERS \ SETTERS \\\\\\\\\\\\
		public function get accessToken():String { return _accessToken; }
		public function get params():Object { return _params; }
		public function get fb_sig_in_iframe():String { return _fb_sig_in_iframe; }
		public function get fb_sig_iframe_key():String { return _fb_sig_iframe_key; }
		public function get fb_sig_locale():String { return _fb_sig_locale; }
		public function get fb_sig_in_new_facebook():String { return _fb_sig_in_new_facebook; }
		public function get fb_sig_time():String { return _fb_sig_time; }
		public function get fb_sig_added():String { return _fb_sig_added; }
		public function get fb_sig_profile_update_time():String { return _fb_sig_profile_update_time; }
		public function get fb_sig_expires():String { return _fb_sig_expires; }
		public function get fb_sig_user():String { return _fb_sig_user; }
		public function get fb_sig_session_key():String { return _fb_sig_session_key; }
		public function get fb_sig_ss():String { return _fb_sig_ss; }
		public function get fb_sig_cookie_sig():String { return _fb_sig_cookie_sig; }
		public function get fb_sig_ext_perms():String { return _fb_sig_ext_perms; }
		public function get fb_sig_api_key():String { return _fb_sig_api_key; }
		public function get fb_sig_app_id():String { return _fb_sig_app_id; }
		public function get fb_sig():String { return _fb_sig; }
		public function set fb_sig_user(value:String):void 
		{
			_fb_sig_user = value;
		}
		
	}//FacebookManager Class

}//Package