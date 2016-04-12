package base.math {
	import flash.display.Sprite;

	public class VectorFinger extends Sprite {
		
		public function VectorFinger(): void {
			Vector.<Object>.prototype.valueOf = function(): Number {
				   var sum:Number = 0;
				   trace("sum:", sum)
				   for each (var v:* in this)  {
						trace("v:", v)   
						if (v is Number)
							sum += v;
				   }
				   trace("sum2:", sum)
				   return sum;
			};
			
			
			trace(Number([1,2,3,7]) - Number([3,2,1]) - Number([5,3,2]));
		}
		
	}

}