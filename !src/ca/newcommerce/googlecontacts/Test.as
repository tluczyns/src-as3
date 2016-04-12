package ca.newcommerce.googlecontacts 
{
	import ca.newcommerce.googlecontacts.data.ContactData;
	import ca.newcommerce.googlecontacts.data.GroupData;
	import ca.newcommerce.googlecontacts.events.ContactFeedEvent;
	import ca.newcommerce.googlecontacts.events.GContactsEvent;
	import ca.newcommerce.googlecontacts.events.GroupFeedEvent;
	import ca.newcommerce.googlecontacts.events.PhotoEvent;
	import ca.newcommerce.googlecontacts.feeds.ContactFeed;
	import ca.newcommerce.googlecontacts.feeds.GroupFeed;
	import ca.newcommerce.googlecontacts.webservice.GContactsClient;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	/**
	* ...
	* @author Martin Legris ( http://blog.martinlegris.com )
	*/
	public class Test extends MovieClip
	{
		protected var _username:String = "";
		protected var _password:String = "";
		protected var _ws:GContactsClient;
		
		public function Test() 
		{
			_ws = GContactsClient.getInstance();
			_ws.login(_username, _password);
			_ws.addEventListener(GContactsEvent.LOGIN_SUCCESS, doLoggedIn);
			_ws.addEventListener(ContactFeedEvent.READY, doContactsReady);
			_ws.addEventListener(PhotoEvent.LOADED, doPhotoLoaded);
			_ws.addEventListener(GroupFeedEvent.READY, doGroupsReady);
		}
		
		public function doLoggedIn(evt:GContactsEvent):void
		{
			//_ws.getContacts();
			_ws.getGroups();
		}
		
		protected function doGroupsReady(evt:GroupFeedEvent):void
		{
			var feed:GroupFeed = evt.feed;
			var group:GroupData;
			
			while (group = feed.next())
			{
				trace("[" + feed.pointer + "] " + group.title);
			}
		}
		
		public function doContactsReady(evt:ContactFeedEvent):void
		{
			var feed:ContactFeed = evt.feed;
			var contact:ContactData;
			
			while (contact = feed.next())
			{
				trace("["+feed.pointer+"] " + contact.title + " <" + contact.email + "> -- " + contact.image);
			}
			
			_ws.getPhoto(feed.getAt(0).image);
		}
		
		protected function doPhotoLoaded(evt:PhotoEvent):void
		{
			trace("dophotoLoaded");
			evt.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, doImgReady);
			
			//var bmpData:BitmapData = (evt.loader.content as Bitmap).bitmapData;
			//var bmp:Bitmap = new Bitmap(bmpData);
			//addChild(bmp);
		}
		
		protected function doImgReady(evt:Event):void
		{
			var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
			addChild(loaderInfo.content);
		}
	}
}