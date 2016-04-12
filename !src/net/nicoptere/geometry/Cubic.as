package net.nicoptere.geometry 
{
	
	/**
	 * http://www.cse.unsw.edu.au/~lambert/splines/Cubic.java
	 * htt://en.nicoptere.net/
	 * @author nicoptere
	 */
	public class Cubic 
	{
		/** this class represents a cubic polynomial */
		private var a:Number,b:Number,c:Number,d:Number;         /* a + b*u + c*u^2 +d*u^3 */
		
		public function Cubic(a:Number, b:Number, c:Number, d:Number) 
		{
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
		}
		  
		/** evaluate cubic */
		public function eval( u:Number ):Number
		{
			
			return (((d * u) + c) * u + b) * u + a;
			
		}
	}	
}
