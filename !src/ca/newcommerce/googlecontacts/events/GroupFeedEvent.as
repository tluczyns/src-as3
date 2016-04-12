package ca.newcommerce.googlecontacts.events 
{
	import ca.newcommerce.googlecontacts.feeds.GroupFeed;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class GroupFeedEvent extends Event
	{
		public static const READY:String = "group_feed_ready";
		
		protected var _feed:GroupFeed;
		public function get feed():GroupFeed { return _feed; }
		
		public function GroupFeedEvent(type:String, feed:GroupFeed) 
		{
			_feed = feed;
			super(type);
		}
	}
}