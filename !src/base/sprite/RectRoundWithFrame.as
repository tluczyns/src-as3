package base.sprite {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	public class RectRoundWithFrame extends Sprite {
		
		static private const MIN_RADIUS_INNER: Number = 0;
		
		private var frame: Shape;
		protected var bmpFrame: Bitmap;
		private var inner: Shape;
		
		protected var thicknessFrame: Number;
		protected var radiusFrame: Number;
		protected var graphicsFillDataFrame: Vector.<IGraphicsData>;
		protected var isInnerNoYesTransparent: uint;
		private var radiusInner: Number;
		protected var graphicsFillDataInner: Vector.<IGraphicsData>;;
		protected var _width: Number;
		protected var _height: Number;
		
		public function RectRoundWithFrame(thicknessFrame: Number = 3, radiusFrame: Number = 5, graphicsFillFrame: IGraphicsFill = null, isInnerNoYesTransparent: uint = 1, graphicsFillInner: IGraphicsFill = null, width: Number = 100, height: Number = 100): void {
			this.thicknessFrame = thicknessFrame;
			this.radiusFrame = radiusFrame;
			graphicsFillFrame = graphicsFillFrame || new GraphicsSolidFill(0xffffff, 1);
			this.graphicsFillDataFrame = new <IGraphicsData>[IGraphicsData(graphicsFillFrame)];
			this.isInnerNoYesTransparent = isInnerNoYesTransparent;
			this.radiusInner = Math.max(this.radiusFrame - this.thicknessFrame, RectRoundWithFrame.MIN_RADIUS_INNER);
			graphicsFillInner = graphicsFillInner || new GraphicsSolidFill(0x000000, 1);
			this.graphicsFillDataInner = new <IGraphicsData>[IGraphicsData(graphicsFillInner)];
			
			this.frame = new Shape();
			if (this.isInnerNoYesTransparent > 0) {
				this.inner = new Shape();
			}
			if (isInnerNoYesTransparent < 2) { 
				this.addChild(this.frame);
				if (isInnerNoYesTransparent == 1) this.addChild(this.inner);
			} else if (isInnerNoYesTransparent == 2) {
				this.frame.cacheAsBitmap = true
				this.inner.cacheAsBitmap = true;
				this.bmpFrame = new Bitmap(null, "auto", true);
				this.addChild(this.bmpFrame);
			}
			this.setSize(width, height);
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
				this.frame.graphics.clear();
				this.frame.graphics.drawGraphicsData(this.graphicsFillDataFrame);
				//this.frame.graphics.beginFill(this.colorFrame, this.alphaFrame);
				this.frame.graphics.drawRoundRectComplex(0, 0, this._width, this._height, this.radiusFrame, this.radiusFrame, this.radiusFrame, this.radiusFrame);
				this.frame.graphics.endFill();
				if (this.isInnerNoYesTransparent > 0) {
					this.inner.graphics.clear();
					//this.inner.graphics.beginFill(this.colorInner, this.alphaInner);
					this.inner.graphics.drawGraphicsData(this.graphicsFillDataInner);
					this.inner.graphics.drawRoundRectComplex(this.thicknessFrame, this.thicknessFrame, this._width - 2 * this.thicknessFrame, this._height - 2 * this.thicknessFrame, this.radiusInner, this.radiusInner, this.radiusInner, this.radiusInner);
					this.inner.graphics.endFill();
				}
				if (this.isInnerNoYesTransparent == 2) {
					if (this.bmpFrame.bitmapData) {
						this.bmpFrame.bitmapData.dispose();
						this.bmpFrame.bitmapData = null;
					}
					var bmpDataFrame: BitmapData = new BitmapData(this.frame.width, this.frame.height, true, 0x00000000);
					bmpDataFrame.draw(this.frame, null, null, null, null, true);
					bmpDataFrame.draw(this.inner, null, null, BlendMode.ERASE, null, true);
					this.bmpFrame.bitmapData = bmpDataFrame;
				}
			}
		}
		
		public function destroy(): void {
		
		}

	}

}