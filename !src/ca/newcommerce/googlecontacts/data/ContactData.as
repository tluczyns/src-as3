package ca.newcommerce.googlecontacts.data 
{
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class ContactData 
	{
		protected var _id:String;
		protected var _updated:Date;
		protected var _title:String;
		protected var _email:String;
		protected var _phoneNumber:String;
		protected var _image:String;
		protected var _groups;
		
		public function ContactData() 
		{
			
		}
		
		public function get id():String { return _id; }
		public function set id(value:String):void {	_id = value; }
		
		public function get updated():Date { return _updated; }
		public function set updated(value:Date):void { _updated = value; }
		
		public function get title():String { return _title; }
		public function set title(value:String):void { _title = value; }
		
		public function get email():String { return _email; }
		public function set email(value:String):void { _email = value; }
		
		public function get phoneNumber():String { return _phoneNumber; }		
		public function set phoneNumber(value:String):void { _phoneNumber = value; }
		
		public function get image():String { return _image; }
		public function set image(value:String):void { _image = value; }
	}
	
	/* 
	 * 
	 * <entry>
		<id>http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/base/4</id>
		<updated>2009-08-10T01:59:25.711Z</updated>
		<category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/contact/2008#contact'/>
		<title type='text'>Karine Truflandier</title>
		<link rel='http://schemas.google.com/contacts/2008/rel#edit-photo' type='image/*' href='http://www.google.com/m8/feeds/photos/media/martin.legris%40gmail.com/4/1B2M2Y8AsgTpgAmY7PhCfg'/>
		<link rel='self' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full/4'/>
		<link rel='edit' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full/4/1249869565711000'/>
		<gd:email rel='http://schemas.google.com/g/2005#other' address='ktruflandier@gmail.com' primary='true'/>
		<gd:phoneNumber rel='http://schemas.google.com/g/2005#mobile'>514-303-7077</gd:phoneNumber>
		<gContact:groupMembershipInfo deleted='false' href='http://www.google.com/m8/feeds/groups/martin.legris%40gmail.com/base/270f'/>
		<gContact:groupMembershipInfo deleted='false' href='http://www.google.com/m8/feeds/groups/martin.legris%40gmail.com/base/2710'/>
	</entry>
	
	*/
}