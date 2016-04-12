package ca.newcommerce.googlecontacts.feeds 
{
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class AbstractFeed 
	{
		protected var _xml:XML;
		protected var _pointer:Number = 0;
		
		public function get osNS():Namespace { return _xml.namespace("openSearch"); }
		public function get defaultNS():Namespace { return _xml.namespace(""); }
		
		public function AbstractFeed(xml:XML) 
		{
			_xml = xml;
			_pointer = 0;
		}
		
		public function get startIndex():Number { return parseInt(_xml.osNS::startIndex.toString()); }
		public function get totalResults():Number { return parseInt(_xml.osNS::totalResults.toString()); }
		public function get itemsPerPage():Number { return parseInt(_xml.osNS::itemsPerPage.toString()); }	
		public function get count():Number { return Math.min(totalResults - startIndex, itemsPerPage); }		
		public function get pointer():Number { return _pointer; }
	}
}