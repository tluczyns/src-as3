package com.jac.facebook.net.events 
{//Packge
	import com.adobe.serialization.json.JSON;
	import com.jac.facebook.net.FBRequest;
	import com.jac.facebook.net.FBSuccessResult;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class FBRequestEvent extends Event 
	{//FBRequestEvent Class
	
		//Types
		static public const COMPLETE:String  = "fbRequestComplete";
		
		private var _result:String;
		private var _successResult:FBSuccessResult;
		private var _fbObj:Object;
		private var _binaryData:ByteArray;
		
		public function FBRequestEvent(type:String, successResult:FBSuccessResult, result:String = null, bindaryData:ByteArray = null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{//FBRequestEvent 
			super(type, bubbles, cancelable);
			
			_result = result;
			_successResult = successResult;
			
			if (!bindaryData)
			{//text result
				if (_result.charAt(0) == "[")
				{//array
					try
					{//could be an IOError or Security Error (not JSON)
						var resultList:Array = JSON.decode(_result) as Array;
						_fbObj = resultList[0];
					}//could be an IOError or Security Error (not JSON)
					catch (err:Error)
					{//error
						_fbObj = _result;
					}//error
				}//array
				else
				{//not a list
					try
					{//could be an IOError or Security Error (not JSON)
						_fbObj = JSON.decode(_result);
					}//could be an IOError or Security Error (not JSON)
					catch (err:Error)
					{//error
						_fbObj = _result;
					}//error
				}//not a list
			}//text result
			else
			{//binary result
				_result = FBRequest.BINARY_DATA;
				_fbObj = bindaryData;
			}//binary result
		}//FBRequestEvent
		
		public override function clone():Event 
		{ 
			return new FBRequestEvent(type, _successResult, _result, _binaryData, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FBRequestEvent", "type", "successResult", "result", "binaryData", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get result():String { return _result; }
		public function get successResult():FBSuccessResult { return _successResult; }
		public function get fbObj():Object { return _fbObj; }
		public function get binaryData():ByteArray { return _binaryData; }
		
	}//FBRequestEvent Class
	
}//Packge