package ca.newcommerce.googlecontacts.events 
{
	import flash.display.Loader;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	
	public class PhotoEvent extends Event
	{
		public static const LOADED:String = "photo_loaded";
		protected var _loader:Loader;
		protected var _requestId:Number;
		
		public function get loader():Loader { return _loader; }
		public function get requestId():Number { return _requestId; }
		
		public function PhotoEvent(type:String, loader:Loader, requestId:Number) 
		{
			_requestId = requestId;
			_loader = loader;
			super(type);
		}
	}
}