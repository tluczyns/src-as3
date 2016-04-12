package base.graphics {
	import base.math.MathExt;
	import flash.display.Graphics;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.GraphicsSolidFill;
	
	public class GraphicsLineDot extends Object {
		
		private var gfx: Graphics;
		private var sizeDot: Number;
		private var sizeGap: Number;
		private var isRectCircle: uint;
		private var graphicsFillData: Vector.<IGraphicsData>;
		private var xStart: Number;
		private var yStart: Number;
		
		
		public function GraphicsLineDot(gfx: Graphics): void {
			this.gfx = gfx;
			this.xStart = 0;
			this.yStart = 0;
		}
		
		public function lineStyle(sizeDot: Number = 1, sizeGap: Number = 2, isRectCircle: uint = 0, graphicsFill: IGraphicsFill = null): void {
			this.sizeDot = sizeDot;
			this.sizeGap = sizeGap;
			this.isRectCircle = isRectCircle;
			graphicsFill = graphicsFill || new GraphicsSolidFill(0xffffff, 1);
			this.graphicsFillData = new <IGraphicsData>[IGraphicsData(graphicsFill)];
		}
		
		public function moveTo (xStart:Number, yStart:Number) : void {
			this.xStart = xStart;
			this.yStart = yStart;
		}
		
		/*public function lineTo(xEnd:Number, yEnd:Number): void {
			this.gfx.drawGraphicsData(this.graphicsFillData);
			
			var angle: Number = Math.atan2(xEnd - xStart, yEnd - yStart)
			var __dx:Number = this.sizeGap * Math.sin(angle);
			var __dy:Number = this.sizeGap * Math.cos(angle);
			
			var xx:Number = xStart;
			var yy:Number = yStart;
			
			var _xlimit:Number = xEnd - xStart;
			var _ylimit:Number = yEnd - yStart;
			var _xDir:int
			var _yDir:int
			
			if (_xlimit > 0) _xDir = 1
			else if (_xlimit == 0) _xDir = 0
			else _xDir = -1
			
			
			if (_ylimit > 0) _yDir = 1
			else if (_ylimit == 0) _yDir = 0
			else _yDir = -1
		
			var _i1: int = Math.ceil(Math.abs(_xlimit) / Math.abs(this.sizeDot * _xDir + __dx));
			var _i2: int = Math.ceil(Math.abs(_ylimit) / Math.abs(this.sizeDot * _yDir + __dy));
			var _i: int = Math.max(_i1, _i2)
			for (var j:int = 0; j < _i;j++) {
				this.gfx.drawRect(xx, yy, this.sizeDot, this.sizeDot)
				xx += (this.sizeDot * _xDir + __dx);
				yy += (this.sizeDot * _yDir + __dy);
			}
			this.gfx.endFill();
			this.moveTo(xEnd, yEnd);
		}*/
		
		public function lineTo(xEnd:Number, yEnd:Number): void {
			this.gfx.drawGraphicsData(this.graphicsFillData);
			var angle: Number = Math.atan2(xEnd - xStart, yEnd - yStart);
			var countDots: uint = Math.round(MathExt.hypotenuse(xEnd - xStart, yEnd - yStart) / (this.sizeGap + this.sizeDot)) + 1;
			var xStartCorrSizeDot: Number = this.xStart - this.sizeDot / 2;
			var yStartCorrSizeDot: Number = this.yStart - this.sizeDot / 2;
			var radiusDot: Number = this.sizeDot / 2;
			var moveXOne: Number = Math.sin(angle) * (this.sizeGap + this.sizeDot);
			var moveYOne: Number = Math.cos(angle) * (this.sizeGap + this.sizeDot);
			for (var i: uint = 0; i < countDots; i++) {
				if (this.isRectCircle == 0) this.gfx.drawRect(xStartCorrSizeDot + moveXOne * i, yStartCorrSizeDot + moveYOne * i, this.sizeDot, this.sizeDot)
				else if (this.isRectCircle == 1) this.gfx.drawCircle(this.xStart + moveXOne * i, this.yStart + moveYOne * i, radiusDot)
			}
			this.gfx.endFill();
			this.moveTo(xEnd, yEnd);
		}
		
		public function endFill() : void {}
		
		public function clear(): void {
			this.gfx.clear();
		}
		
	}

}