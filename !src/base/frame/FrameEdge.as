package base.frame {
	import flash.display.Shape;
	
	public class FrameEdge extends Shape {
		
		public function FrameEdge(thickness: Number, color: uint = 0xffffff, alpha: Number = 1) {
			this.graphics.beginFill(color, alpha);
			this.graphics.drawRect(0, 0, thickness, thickness);
			this.graphics.endFill();
		}
		
	}

}