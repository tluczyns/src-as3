package net.nicoptere.stroke
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author nicolas barradeau
	 */
	public class AnimatedStroke extends RichStroke {
		
		public var t:Number = 0;
		private var src:BitmapData;
		public var speed: Number = 10;
		
		public function AnimatedStroke(bd: BitmapData = null ): void {
			super(bd);
		}
		
		public function animate():void {
			if (src == null) src = bitmapData.clone();
			t += this.speed;
			if (t <= -bitmapData.width) t = bitmapData.width;
			else if (t >= bitmapData.width) t = - bitmapData.width;
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
			bitmapData.draw( src, new Matrix(1, 0, 0, 1, t, 0));
		}
		
	}
	
}