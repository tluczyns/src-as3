package ca.newcommerce.googlecontacts.events 
{
	import ca.newcommerce.googlecontacts.feeds.ContactFeed;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	
	public class ContactFeedEvent extends Event
	{
		public static const READY:String = "contact_feed_ready";
		
		protected var _feed:ContactFeed;
		public function get feed():ContactFeed { return _feed; }
		
		public function ContactFeedEvent(type:String, feed:ContactFeed) 
		{
			_feed = feed;
			super(type);
		}
	}
}