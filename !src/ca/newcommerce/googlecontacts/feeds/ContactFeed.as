package ca.newcommerce.googlecontacts.feeds 
{
	import ca.newcommerce.googlecontacts.adapters.DataAdapter;
	import ca.newcommerce.googlecontacts.data.ContactData;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class ContactFeed extends AbstractFeed
	{
		
		public function ContactFeed(xml:XML) 
		{
			super(xml);
		}		
		
		public function getAt(idx:Number):ContactData
		{			
			if (idx >= 0 && idx < count)			
				return DataAdapter.digestContact(_xml.defaultNS::entry[idx]);				
			else
				return null;
		}
		
		public function first():ContactData
		{
			return getAt(_pointer = 0);
		}
		
		public function next():ContactData
		{
			if (_pointer < count)
				return getAt(_pointer++);
			else
			{
				_pointer = 0;
				return null;
			}
		}
		
		public function current():ContactData
		{
			return getAt(_pointer);
		}
	}
}

/**

<feed xmlns='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearchrss/1.0/' xmlns:gContact='http://schemas.google.com/contact/2008' xmlns:batch='http://schemas.google.com/gdata/batch' xmlns:gd='http://schemas.google.com/g/2005'>
	<id>martin.legris@gmail.com</id>
	<updated>2009-08-11T19:18:01.599Z</updated>
	<category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/contact/2008#contact'/>
	<title type='text'>Martin's Contacts</title><link rel='alternate' type='text/html' href='http://www.google.com/'/>
	<link rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full'/>
	<link rel='http://schemas.google.com/g/2005#post' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full'/>
	<link rel='http://schemas.google.com/g/2005#batch' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full/batch'/>
	<link rel='self' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full?max-results=25'/>
	<link rel='next' type='application/atom+xml' href='http://www.google.com/m8/feeds/contacts/martin.legris%40gmail.com/full?start-index=26&amp;max-results=25'/>
	<author>
		<name>Martin</name>
		<email>martin.legris@gmail.com</email>
	</author>
	<generator version='1.0' uri='http://www.google.com/m8/feeds'>Contacts</generator>
	<openSearch:totalResults>603</openSearch:totalResults>
	<openSearch:startIndex>1</openSearch:startIndex>
	<openSearch:itemsPerPage>25</openSearch:itemsPerPage>
	<entry>
	</entry>
	
**/