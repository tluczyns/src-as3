package com.jac.facebook
{//Package
	import com.jac.facebook.events.FacebookEvent;
	import com.jac.facebook.FacebookManager;
	import com.jac.facebook.net.events.FBRequestEvent;
	import com.jac.log.Log;
	import com.jac.log.targets.BrowserConsoleTarget;
	import com.jac.log.targets.TraceTarget;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class FBAppLoaderMain extends MovieClip
	{//FBAppLoaderMain Class
	
		//Local testing settings
		private const IS_TESTING:Boolean = true;
		
		//The TEST_TOKEN will change daily (you will need to get this from the url from facebook, as this must be a valid and current access token)
		private const TEST_TOKEN:String = "124773070881879|2.XQe_mxkCWB8T_dOPxV00vg__.3600.1274328000-771864046|e2FsQDHB4iilS_OL_rd8vJ79fc0."; 
		private const TEST_SWF:String = "FBTestAppPhoto.swf";
		private const TEST_USERID:String = "me";	//You can put any profile id in here to test with
		
		//Vars
		private var _swfLoader:Loader;
		private var _swfRequest:URLRequest;
		private var _fb:FacebookManager;
		private var _loadedSWF:IFBApp;
		
		public function FBAppLoaderMain() 
		{//FBAppLoaderMain
		
			//setup logging
			Log.addLogTarget(new TraceTarget());
			Log.addLogTarget(new BrowserConsoleTarget());
		
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
		}//FBAppLoaderMain
		
		private function handleAddedToStage(e:Event):void 
		{//handleAddedToStage
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			
			//Create new Facebook Manager
			_fb = new FacebookManager(loaderInfo, TEST_TOKEN);
			_fb.addEventListener(FBRequestEvent.COMPLETE, handleRequestComplete, false, 0, true);
				
			
			//Load other swf
			if (_fb.params["mainSWF"])
			{//load it
				_swfLoader = new Loader();
				Log.log("Trying To Load: " + _fb.params["mainSWF"]);
				_swfRequest = new URLRequest(_fb.params["mainSWF"]);
				_swfLoader.load(_swfRequest);
			}//load it
			else if (IS_TESTING)
			{//fake it
				_fb.fb_sig_user = TEST_USERID;
				_swfLoader = new Loader();
				Log.log("Trying To Load: " + TEST_SWF + " for testing.");
				_swfRequest = new URLRequest(TEST_SWF);
				_swfLoader.load(_swfRequest);
			}//fake it
			else
			{//no main swf to load
				Log.log("No mainSWF to load!");
			}//no main swf to load
			
			
			//setup events
			if (_swfLoader)
			{//handle events
				_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete, false, 0, true);
				_swfLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleSWFLoadProgress, false, 0, true);
				_swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleIOError, false, 0, true);
				_swfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError, false, 0, true);
				_swfLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleHTTPStatus, false, 0, true);
			}//handle events
			
		}//handleAddedToStage
		
		private function handleGetFacebook(e:FacebookEvent):void 
		{//handleGetFacebook
			//Call on the name of the method passed to the initial event dispatch from the loaded swf
			_loadedSWF[e.data](_fb);
		}//handleGetFacebook
		
		private function handleRequestComplete(e:FBRequestEvent):void 
		{//handleRequestComplete
			Log.log("Handle Request Complete: " + e.successResult.success + " / " + e.successResult.errorCode + " / " + e.successResult.message);
		}//handleRequestComplete
		
		private function handleHTTPStatus(e:HTTPStatusEvent):void 
		{//handleHTTPStatus
			Log.log("HTTPStatus: " + e.status);
		}//handleHTTPStatus
		
		private function handleSecurityError(e:SecurityErrorEvent):void 
		{//handleSecurityError
			Log.log("SecurityError: " + e.text);
		}//handleSecurityError
		
		private function handleIOError(e:IOErrorEvent):void 
		{//handleIOError
			Log.log("IOError: " + e.text);
		}//handleIOError
		
		private function handleSWFLoadProgress(e:ProgressEvent):void 
		{//handleSWFLoadProgress
			Log.log("Loading: " + e.bytesLoaded + " / " + e.bytesTotal);
		}//handleSWFLoadProgress
		
		private function handleSWFLoadComplete(e:Event):void 
		{//handleSWFLoadComplete
			_loadedSWF = IFBApp(e.currentTarget.content);
			
			_loadedSWF.addEventListener(FacebookEvent.GET_FACEBOOK, handleGetFacebook, false, 0, true);
			
			addChild(e.currentTarget.content);
		}//handleSWFLoadComplete
		
	}//FBAppLoaderMain Class

}//Package