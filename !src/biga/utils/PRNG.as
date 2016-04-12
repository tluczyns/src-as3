package biga.utils 
{
	/**
	 * ...
	 * @author Nicolas Barradeau
	 * @website http://en.nicoptere.net
	 */
	public class PRNG
	{
    
		static private var a:uint = 16807;            /* multiplier */
		static private var m:uint = 0x7FFFFFFF;        /* 2**31 - 1 */
		static private var q:uint = 127773;         /* m div a */
		static private var r:uint = 2836;            /* m mod a */
		static private var randomnum:uint = 1;
		static private var div:Number = 1 / m;
		
		static private function nextlongrand( seed:uint ):uint
		{
			var lo:uint, hi:uint;
			
			lo = a * (seed & 0xFFFF);
			hi = a * (seed >> 16);
			lo += (hi & 0x7FFF) << 16;
			if (lo > m)
			{
				lo &= m;
				++lo;
			}
			lo += hi >> 15;
			if (lo > m)
			{
				lo &= m;
				++lo;
			}
			return lo;
			
		}
		
		static public function random():Number /* return next random number */
		{
			
			randomnum = nextlongrand(randomnum);
			return randomnum * div;
			
		}
		
		static public function set seed( value:uint ):void
		{
			
			randomnum = ( value <= 0 ) ? 1 : value;
			
		}
    }
}