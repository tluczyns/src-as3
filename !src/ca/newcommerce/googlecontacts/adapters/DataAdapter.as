package ca.newcommerce.googlecontacts.adapters 
{
	import ca.newcommerce.googlecontacts.data.ContactData;
	import ca.newcommerce.googlecontacts.data.GroupData;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class DataAdapter 
	{
		
		public function DataAdapter() 
		{
			
		}
		
		public static function digestContact(xml:XML):ContactData
		{
			var defaultNS:Namespace = xml.namespace("");
			var gdNS:Namespace = xml.namespace("gd");
			var gContactNS:Namespace = xml.namespace("gContact");
			
			var data:ContactData = new ContactData();
			data.email = xml.gdNS::email[0].@address.toString();
			data.phoneNumber = xml.gdNS::phoneNumber.toString();
			data.id = xml.defaultNS::id.toString();
			data.title = xml.defaultNS::title.toString();
			data.image = xml.defaultNS::link.(@rel == "http://schemas.google.com/contacts/2008/rel#photo").@href.toString();
			
			return data;
		}
		
		/* 
			<entry>
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
			
		
		
	
		public static function digestGroup(xml:XML):GroupData
		{
			var defaultNS:Namespace = xml.namespace("");
			var data:GroupData = new GroupData();
			try { data.id = xml.defaultNS::id.toString(); } catch (e:TypeError) { };
			try { data.title = xml.defaultNS::title.toString(); } catch (e:TypeError) { };
			try { data.selfLink = xml.defaultNS::link.(@rel == "self").toString(); } catch (e:TypeError) { } ;
			try { data.editLink = xml.defaultNS::link.(@rel == "edit").toString(); } catch (e:TypeError) { } ;
			
			//data.updated = new Date();		
			//data.updated.setTime(Date.parse(xml.defaultNS::updated.toString()));			
			
			return data;
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
	}
}