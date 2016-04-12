package ca.newcommerce.utils 
{
	/**
	 * ...
	 * @author Martin Legris ( http://blog.martinlegris.com )
	 */
	public class DateUtil
	{
		public static function fromGoogleFormat(date:String):Date
		{
			var exp:RegExp = /(\d\d\d\d)([- \/.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])T([0-2][0-9]):([0-5][0-9]):([0-5][0-9]).([0-9]{3})Z/i;
			var res:Object = exp.exec(date);
			
			// year res[1]
			// month res[3]
			// day res[4]
			// hour res[5]
			// minute res[6]
			// seconds res[7]
			// microseconds res[8]
			
			var time:Date = new Date(res[1], res[3] - 1, res[4] - 1, res[5], res[6], res[7], res[8]);
			
			// switch to proper timezone
			time.minutes -= time.getTimezoneOffset();
			
			return time;
		}
	}
}