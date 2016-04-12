package base.frame {
	import flash.display.Sprite;
	import flash.display.Shape;

	public class Frame extends Sprite {
		
		private var thickness: Number;
		private var bg: Shape;
		private var arrEdge: Array;
		
		public function Frame(thickness: Number = 1, colorFrame: uint = 0x000000, alphaFrame: Number = 1, isBg: Boolean = false, colorBg: uint = 0xffffff, alphaBg: Number = 1, width: Number = 100, height: Number = 100): void {
			this.thickness = thickness;
			if (isBg) {
				this.bg = new Shape();
				this.bg.graphics.beginFill(colorBg, alphaBg);
				this.bg.graphics.drawRect(0, 0, 1, 1);
				this.bg.graphics.endFill();
				this.addChild(this.bg)
			}
			this.arrEdge = new Array(4);
			for (var i: uint = 0; i < this.arrEdge.length; i++) {
				var edge: FrameEdge = new FrameEdge(thickness, colorFrame, alphaFrame);
				edge.rotation = 90 * i;
				this.addChild(edge);
				this.arrEdge[i] = edge;
			}
			this.width = width;
			this.height = height;
		}
		
		override public function set width(value: Number): void {
			if (this.bg) this.bg.width = value;
			for (var i: uint = 0; i < this.arrEdge.length; i++) {
				var edge: FrameEdge = this.arrEdge[i];
				if (i % 2 == 0) edge.width = value - this.thickness;
				if (Math.floor((i + 1) / 2) == 1) edge.x = value;
			}
		}
		
		override public function set height(value: Number): void {
			if (this.bg) this.bg.height = value;
			for (var i: uint = 0; i < this.arrEdge.length; i++) {
				var edge: FrameEdge = this.arrEdge[i];
				if (i % 2 == 1) edge.width = value - this.thickness;
				if (Math.floor(i / 2) == 1) edge.y = value;
			}
		}
		
	}

}