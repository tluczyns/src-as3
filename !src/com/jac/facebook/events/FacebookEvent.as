package com.jac.facebook.events 
{//Packge
	import flash.events.Event;
	
	public class FacebookEvent extends Event 
	{//FacebookEvent Class
	
		static public const GET_FACEBOOK:String = "facebookGetFacebook";
	
		private var _data:Object;
		
		public function FacebookEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{//FacebookEvent 
			super(type, bubbles, cancelable);
			
			_data = data;
			
		}//FacebookEvent
		
		public override function clone():Event 
		{ 
			return new FacebookEvent(type, _data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FacebookEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object { return _data; }
		
	}//FacebookEvent Class
	
}//Packge