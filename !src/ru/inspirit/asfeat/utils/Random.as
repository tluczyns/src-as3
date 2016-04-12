package ru.inspirit.asfeat.utils
{
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class Random
	{
		public static var seed:Number = Math.random() * 0x7FFFFFFE;
		public static var useLastRand:Boolean = false;
		public static var y2Rand:Number;
		public static function random():Number
        {
        	return (seed = (seed * 16807) % 2147483647) / 0x7FFFFFFF+0.000000000233;
        }
        public static function randInt():int
        {
			seed = (seed * 16807) % 2147483647;
        	return int(seed);
        }
        public static function randNormal(std:Number, mu:Number = 0.0):Number
        {
        	var x1:Number, x2:Number, w:Number, y1:Number;
        	//
        	if (useLastRand)		        /* use value from previous call */
			{
				y1 = y2Rand;
				useLastRand = false;
			}
			else
			{
				do {
					x1 = 2.0 * random() - 1.0;
					x2 = 2.0 * random() - 1.0;
					w = x1 * x1 + x2 * x2;
				} while ( w >= 1.0 );
				//
				w = Math.sqrt( (-2.0 * Math.log( w ) ) / w );
				y1 = x1 * w;
				y2Rand = x2 * w;
				useLastRand = true;
			}
			
			return mu + y1 * std;
        }
	}
}
