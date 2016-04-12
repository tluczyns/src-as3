package ca.newcommerce.googlecontacts.data 
{
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class GroupData 
	{
		protected var _id:String;
		protected var _updated:Date;
		protected var _title:String;
		protected var _editLink:String;
		protected var _selfLink:String;
		
		public function GroupData() 
		{
			
		}
		
		public function get selfLink():String { return _selfLink; }
		public function set selfLink(value:String):void { _selfLink = value; }
		
		public function get editLink():String { return _editLink; }
		public function set editLink(value:String):void { _editLink = value; }
		
		public function get title():String { return _title; }
		public function set title(value:String):void { _title = value; }
		
		public function get updated():Date { return _updated; }
		public function set updated(value:Date):void { _updated = value; }
		
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		
	}
	
}

/*
<entry>
	<id>http://www.google.com/m8/feeds/groups/martin.legris%40gmail.com/base/270f</id>
	<updated>2008-11-20T23:26:24.478Z</updated>
	<category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/contact/2008#group'/>
	<title type='text'>Travel News</title><content type='text'>Travel News</content>
	<link rel='self' type='application/atom+xml' href='http://www.google.com/m8/feeds/groups/martin.legris%40gmail.com/full/270f'/>
	<link rel='edit' type='application/atom+xml' href='http://www.google.com/m8/feeds/groups/martin.legris%40gmail.com/full/270f/1227223584478000'/>
</entry>
*/