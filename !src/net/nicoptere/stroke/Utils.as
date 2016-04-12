package net.nicoptere.stroke
{
	import flash.geom.Point;
	/**
	 * @author nicoptere
	 */
	public class Utils 
	{
		
		public function Utils() 
		{
			
		}
		
		//function by Andreas Weber to simplify the path
		//http://www.motiondraw.com/blog/?p=50
		static public function simplifyLang( distance:int, tolerance:Number, points:Vector.<Point> ):Vector.<Point>
		{
			
			if (distance <= 1)
			{
				return points;
			};
			var offset:Number, len:Number, count:Number;
			var PL:int = points.length;
			
			var i:int;
			var tmp:Vector.<Point> = new Vector.<Point>();
			tmp.push( points[0] );
			
			count = 1;
			
			if (distance > PL - 1)
			{
				distance = PL - 1;
			};
			
			
			for ( i = 0; i < PL; i++)
			{
				if (i + distance > PL) 
				{ 
					distance = PL - i -1 
				};
				
				offset = recursiveToleranceBar(points, i, distance, tolerance);
				if (offset > 0)
				{
					tmp.push( points[i + offset] );
					i += offset-1;
					count++;
				}
			}
		//	tmp.push( points[0] );
			return tmp;
		}
		
		
		// this function is called by simplifyLang
		static private function recursiveToleranceBar(points:Vector.<Point>, c:int, distance:int, tolerance:Number):int
		{
			var n:int = distance;
			var cp:Point = points[c];
			var cLP:Point = new Point();
			
			var v1:Point = new Point();
			var v2:Point = new Point(); 
			var angle:Number, dx:Number, dy:Number;
			
			var id:int 
			if ( c + n > points.length - 1 ) 
			{
				id = points.length - 1;
				n =  points.length - 1 - c;
			}else {
				id = ( c + n );
			}
			
			v1 = new Point( points[ id ].x - cp.x, points[id].y - cp.y );
			var dist:Number;
			var j:int;
			
			for ( j = 1; j <= n; j++)
			{
				cLP = points[c+j]; 
				  
				v2.x = cLP.x - cp.x;
				v2.y = cLP.y - cp.y;
				  
				angle = Math.acos((v1.x * v2.x + v1.y * v2.y)/(Math.sqrt(v1.y * v1.y + v1.x * v1.x)*Math.sqrt(v2.y * v2.y + v2.x * v2.x)));
				 
				 
				if(isNaN(angle)){angle = 0;}
				
				dx = cp.x - cLP.x; 
				dy = cp.y - cLP.y;
				
				dist = Math.sqrt(dx*dx+dy*dy);

				if ( Math.sin(angle) * dist >= tolerance)
				{
					n--;
					if (n > 0)
					{	
						return recursiveToleranceBar(points, c, n, tolerance);
					}else{
						return 0;
					}
				}
			}
			return n;
		}
	}
	
}