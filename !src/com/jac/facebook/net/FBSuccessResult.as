package com.jac.facebook.net 
{//Package
	
	public class FBSuccessResult
	{//FBSuccessResult Class
	
		private var _errorCode:String;
		private var _message:String;
		private var _success:Boolean;
		
		public function FBSuccessResult(isSuccess:Boolean, error:String="", message:String="") 
		{//FBSuccessResult
			_success = isSuccess;
			_message = message;
			_errorCode = error;
		}//FBSuccessResult
		
		public function get errorCode():String { return _errorCode; }
		public function get message():String { return _message; }
		public function get success():Boolean { return _success; }
		
	}//FBSuccessResult Class

}//Package