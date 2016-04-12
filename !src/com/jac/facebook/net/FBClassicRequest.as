package com.jac.facebook.net 
{//Package
	import com.adobe.serialization.json.JSON;
	import com.jac.log.Log;
	import flash.events.Event;
	import com.jac.facebook.net.FBRequest;
	import com.jac.facebook.net.FBSuccessResult;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	
	public class FBClassicRequest extends FBRequest
	{//FBClassicRequest Class
	
		private const CLASSIC_BASE_URL:String = "https://api.facebook.com";
	
		public function FBClassicRequest(callback:Function, rpc:String, accessToken:String, args:Object = null, resultFormat:String = URLLoaderDataFormat.TEXT, requestMethod:String = URLRequestMethod.GET, baseURL:String = CLASSIC_BASE_URL) 
		{//FBClassicRequest
			if (!args)
			{//make
				args = new Object();
			}//make
			
			//Force facebook to return a JSON result, and not XML
			args["format"] = "JSON";
			
			super(callback, "method", rpc, accessToken, args, resultFormat, requestMethod, baseURL);
		}//FBClassicRequest
		
		
		override protected function evaluateSuccess(e:Event):FBSuccessResult 
		{//evaluateSuccess
			var rawData:String = e.target.data;
			
			var resultList:Array;
			var resultObj:Object;
			
			if (rawData.charAt(0) == "[")
			{//array
				resultList = JSON.decode(rawData) as Array;
				resultObj = resultList[0];
			}//array
			else
			{//not a list
				resultObj = JSON.decode(rawData);
			}//not a list
			
			
			if (!resultObj)
			{//no results
				return new FBSuccessResult(false, "No Results", "No Results");
			}//no results
			
			if (resultObj["error_code"])
			{//we have an error
				return new FBSuccessResult(false, String(resultObj["error_code"]), String(resultObj["error_msg"])); 
			}//we have an error
			else
			{//good
				return new FBSuccessResult(true);
			}//good
		}//evaluateSuccess
		
	}//FBClassicRequest Class

}//Package