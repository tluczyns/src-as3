package ca.newcommerce.googlecontacts.feeds 
{
	import ca.newcommerce.googlecontacts.adapters.DataAdapter;
	import ca.newcommerce.googlecontacts.data.GroupData;
	
	/**
	 * ...
	 * @author Martin Legris -- http://blog.martinlegris.com
	 */
	public class GroupFeed extends AbstractFeed
	{
		public function GroupFeed(xml:XML) 
		{
			super(xml);			
		}
		
		public function getAt(idx:Number):GroupData
		{
			if (idx >= 0 && idx < count)
				return DataAdapter.digestGroup(_xml.defaultNS::entry[idx]);
			else
				return null;
		}
		
		public function first():GroupData
		{
			return getAt(_pointer = 0);
		}
		
		public function next():GroupData
		{
			if (_pointer < count)
				return getAt(_pointer++);
			else
			{
				_pointer = 0;
				return null;
			}
		}
		
		public function current():GroupData
		{
			return getAt(_pointer);
		}
	}
}