package base.uiComponents.scrollArea {
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	
	public class MaskCover extends Shape {
		
		public function MaskCover(): void {
			var mrxGradient: Matrix = new Matrix();
			mrxGradient.createGradientBox(1, 1, Math.PI / 2);
			super();
			this.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0, 1], [0, 255], mrxGradient);
			this.graphics.drawRect(0, 0, 1, 1);
			this.graphics.endFill();
		}
		
	}

}