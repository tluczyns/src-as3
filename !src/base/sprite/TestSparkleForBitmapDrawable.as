package base.sprite {
	import base.tf.TextFieldUtils;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setInterval;
	

	public class TestSparkleForBitmapDrawable extends Sprite {
		private var angle: Number = 0;
		private var shp: Shape;
		private var sparkleShp: SparkleForBitmapDrawable;
		
		public function TestSparkleForBitmapDrawable(): void {
			var tf: TextField = TextFieldUtils.createTextField(new TextFormat(null, 100, 0x000000, true));
			tf.text = "Szczepan";
			tf.x = 100;
			this.addChild(tf);
			/*shp = new Shape();
			shp.graphics.beginFill(0xff0000, 1);
			shp.graphics.drawRect(0, 0, 1000, 300);
			shp.graphics.endFill();
			shp.x = 100;
			this.addChild(shp);*/
			//setInterval(this.addSparkle, 100);
			
			
			sparkleShp = new SparkleForBitmapDrawable(tf, 200, 30, 0x00ff00)
			sparkleShp.anim(true, 0.5, 2);
		}
		
		private function addSparkle(): void {
			if (sparkleShp) sparkleShp.destroy();
			sparkleShp = new SparkleForBitmapDrawable(shp, 300, this.angle++ % 360)
		}
		
	}

}