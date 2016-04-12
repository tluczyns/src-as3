package base.sprite {
	import flash.display.Shape;
	import flash.display.IGraphicsFill;
	import flash.display.IGraphicsData;
	import flash.geom.Matrix;
	import flash.display.BlendMode;
	
	public class BgBalloon extends RectRoundWithFrame {
		
		private var tail: Shape;
		private var tailInner: Shape;
		private var tailErase: Shape;
		
		private var widthTail: Number;
		private var posXTail: Number;
		
		public function BgBalloon(thicknessFrame: Number = 3, radiusFrame: Number = 5, graphicsFillFrame: IGraphicsFill = null, isInnerNoYesTransparent: uint = 1, graphicsFillInner: IGraphicsFill = null, widthTail: Number = 30, heightTail: Number = 20, moveXBottomTail: Number = 10, posXTail: Number = 40, width: Number = 100, height: Number = 100): void {
			
			heightTail = heightTail + thicknessFrame;
			this.widthTail = widthTail;
			this.posXTail = posXTail;
			
			super(thicknessFrame, radiusFrame, graphicsFillFrame, isInnerNoYesTransparent, graphicsFillInner, width, height);

			var diffUpDownTailPointCenter: Number = (heightTail / (widthTail / 2)) * thicknessFrame;
			var substractRatioMoveXBottomTail: Number = ((heightTail - diffUpDownTailPointCenter) / heightTail);
			
			var graphicsFillDataFrame: Vector.<IGraphicsData> = this.graphicsFillDataFrame
			function createTail(isExtrudeInner: Boolean): Shape {
				var tail: Shape = new Shape();
				tail.graphics.drawGraphicsData(graphicsFillDataFrame);
				tail.graphics.moveTo(- widthTail / 2, 0);
				if (isExtrudeInner) {
					tail.graphics.lineTo(- widthTail / 2 + thicknessFrame, 0);
					tail.graphics.lineTo(moveXBottomTail * substractRatioMoveXBottomTail, heightTail - diffUpDownTailPointCenter);
					tail.graphics.lineTo(widthTail / 2 - thicknessFrame, 0);
				}			
				tail.graphics.lineTo(widthTail / 2, 0);
				tail.graphics.lineTo(moveXBottomTail, heightTail);
				tail.graphics.lineTo(-widthTail / 2, 0);
				tail.graphics.endFill();
				return tail;
			}
			this.tail = createTail(this.isInnerNoYesTransparent > 0);
			this.addChild(this.tail);
			
			if (this.isInnerNoYesTransparent == 1) {
				this.tailInner = new Shape();
				this.tailInner.graphics.drawGraphicsData(this.graphicsFillDataInner);
				this.tailInner.graphics.moveTo(-widthTail / 2 + this.thicknessFrame, 0);
				this.tailInner.graphics.lineTo(widthTail / 2 - this.thicknessFrame, 0);
				this.tailInner.graphics.lineTo(moveXBottomTail * substractRatioMoveXBottomTail, heightTail - diffUpDownTailPointCenter);
				this.tailInner.graphics.lineTo(-widthTail / 2 + this.thicknessFrame, 0);
				this.tailInner.graphics.endFill();
				this.addChild(this.tailInner);
			} else if (this.isInnerNoYesTransparent == 2) this.tailErase = createTail(false);
			this.setSize(width, height);
		}
		
		override protected function redraw(): void {
			super.redraw();
			if (this.tail) {
				this.tail.x = Math.min(this.posXTail, this._width - this.radiusFrame - this.widthTail / 2);
				this.tail.y = this._height - this.thicknessFrame;
				if (this.isInnerNoYesTransparent == 1) {
					this.tailInner.x = this.tail.x;
					this.tailInner.y = this.tail.y;
				} else if (this.isInnerNoYesTransparent == 2) {
					var mrxTail: Matrix = new Matrix(1, 0, 0, 1, this.tail.x, this.tail.y);
					this.bmpFrame.bitmapData.draw(this.tailErase, mrxTail, null, BlendMode.ERASE, null, true);
				}
			}
		}
		
		override public function destroy(): void {
			super.destroy();
		}
		
	}

}