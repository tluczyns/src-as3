package base.sprite {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import base.math.MathExt;
	
	public class RectRoundWithFrameGradient extends Sprite {
		
		private var radiusFrame: Number;
		private var arrColor: Array;
		private var arrAlpha: Array;
		private var arrRatio: Array;
		private var isRoundedFrameFromOutside: Boolean;
		private var _width: Number;
		private var _height: Number;
		
		private var shpCenter: Shape;
		private var shpCornerTL: Shape;
		private var shpCornerTR: Shape;
		private var shpCornerBL: Shape;
		private var shpCornerBR: Shape;
		private var shpEdgeTop: Shape;
		private var shpEdgeBottom: Shape;
		private var shpEdgeLeft: Shape;
		private var shpEdgeRight: Shape;
		
		public function RectRoundWithFrameGradient(radiusFrame: Number = 5, arrColor: Array = null, arrAlpha: Array = null, arrRatio: Array = null, isRoundedFrameFromOutside: Boolean = false, width: Number = 100, height: Number = 100): void {
			this.radiusFrame = radiusFrame;
			this.arrColor = arrColor || [0xffffff, 0xffffff];
			this.arrAlpha = arrAlpha || [0, 1];
			this.arrRatio = arrRatio || [0, 255];
			this.isRoundedFrameFromOutside = isRoundedFrameFromOutside;
			
			this.createShpCenter();
			
			this.shpCornerTL = this.createShpCorner();
			this.shpCornerTL.scaleX = this.shpCornerTL.scaleY = -1;
			this.shpCornerTL.x = this.shpCornerTL.y = this.radiusFrame;
			this.shpCornerTR = this.createShpCorner();
			this.shpCornerTR.scaleY = -1;
			this.shpCornerTR.y = this.radiusFrame;
			this.shpCornerBL = this.createShpCorner();
			this.shpCornerBL.scaleX = -1;
			this.shpCornerBL.x = this.radiusFrame;
			this.shpCornerBR = this.createShpCorner();
			
			this.shpEdgeTop = this.createEdge();
			this.shpEdgeTop.x = this.radiusFrame;
			this.shpEdgeBottom = this.createEdge();
			this.shpEdgeBottom.rotation = 180;
			this.shpEdgeBottom.x = this.radiusFrame;
			this.shpEdgeLeft = this.createEdge();
			this.shpEdgeRight = this.createEdge();
			this.shpEdgeRight.y = this.radiusFrame;
			this.setSize(width, height);
		}
		
		private function createShpCenter(): void {
			this.shpCenter = new Shape();
			this.shpCenter.graphics.beginFill(this.arrColor[0], this.arrAlpha[0]);
			this.shpCenter.graphics.drawRect(0, 0, 10, 10);
			this.shpCenter.graphics.endFill();
			this.shpCenter.x = this.radiusFrame;
			this.shpCenter.y = this.radiusFrame;
			this.addChild(this.shpCenter);
		}
		
		private function createShpCorner(): Shape {
			var shpCorner: Shape = new Shape();
			var diameterFrame: Number = this.radiusFrame * 2;
			var mrxGradientCorner: Matrix = new Matrix();
			mrxGradientCorner.createGradientBox(this.radiusFrame * 2, this.radiusFrame * 2, 0, - this.radiusFrame, - this.radiusFrame);
			shpCorner.graphics.beginGradientFill(GradientType.RADIAL, this.arrColor, this.arrAlpha, this.arrRatio, mrxGradientCorner);
			if (this.isRoundedFrameFromOutside) {
				shpCorner.graphics.moveTo(0, 0);
				shpCorner.graphics.lineTo(this.radiusFrame, 0);
				shpCorner.graphics.curveTo(this.radiusFrame, this.radiusFrame * (Math.SQRT2 - 1), this.radiusFrame * (Math.SQRT2 / 2), this.radiusFrame * (Math.SQRT2 / 2));
				shpCorner.graphics.curveTo(this.radiusFrame * (Math.SQRT2 - 1), this.radiusFrame, 0, this.radiusFrame);
				shpCorner.graphics.lineTo(0, 0);
			} else {
				shpCorner.graphics.drawRect(0, 0, this.radiusFrame, this.radiusFrame);	
			}
			shpCorner.graphics.endFill();
			this.addChild(shpCorner);
			return shpCorner;
		}
		
		private function createEdge(): Shape {
			var shpEdge: Shape = new Shape();
			var mrxGradientEdge: Matrix = new Matrix();
			mrxGradientEdge.createGradientBox(this.radiusFrame, this.radiusFrame, - 90 * MathExt.TO_RADIANS);
			shpEdge.graphics.beginGradientFill(GradientType.LINEAR, this.arrColor, this.arrAlpha, this.arrRatio, mrxGradientEdge);
			shpEdge.graphics.drawRect(0, 0, this.radiusFrame, this.radiusFrame);
			shpEdge.graphics.endFill();
			this.addChild(shpEdge);
			return shpEdge;
		}
		
		
		override public function set width(value: Number): void {
			this._width = Math.round(value);
			this.redraw();
		}
		
		override public function set height(value: Number): void {
			this._height = Math.round(value);
			this.redraw();
		}
		
		public function setSize(width: Number, height: Number): void {
			this._width = Math.round(width);
			this._height = Math.round(height);
			this.redraw();
		}
		
		protected function redraw(): void {
			if ((this._width > 0) && (this._height > 0)) {
				this.shpCenter.width = Math.round(this._width - 2 * this.radiusFrame);
				this.shpCenter.height = Math.round(this._height - 2 * this.radiusFrame);
				this.shpCornerTR.x = this._width - this.radiusFrame;
				this.shpCornerBL.y = this._height - this.radiusFrame;
				this.shpCornerBR.x = Math.round(this._width - this.radiusFrame);
				this.shpCornerBR.y = Math.round(this._height - this.radiusFrame);
				this.shpEdgeTop.width = this.shpEdgeBottom.width = this._width - 2 * this.radiusFrame;
				this.shpEdgeBottom.x = this._width - this.radiusFrame;
				this.shpEdgeBottom.y = this._height;
				this.shpEdgeLeft.rotation = 0;
				this.shpEdgeLeft.width = this._height - 2 * this.radiusFrame;
				this.shpEdgeLeft.y = this._height - this.radiusFrame;
				this.shpEdgeLeft.rotation = -90;
				this.shpEdgeRight.rotation = 0;
				this.shpEdgeRight.width = this.shpEdgeLeft.height;
				this.shpEdgeRight.x = this._width;
				this.shpEdgeRight.rotation = 90;
			}
		}
		
		public function destroy(): void {
		
		}

	}

}