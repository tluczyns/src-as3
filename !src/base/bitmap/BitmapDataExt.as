package base.bitmap {
	import flash.display.BitmapData;
	
    public class BitmapDataExt extends BitmapData {

		public function BitmapDataExt(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF) {
			super(width, height, transparent, fillColor);
		}

		public function drawLine(startX:uint, startY:uint, endX:uint, endY:uint, color: uint = 0xFFFFFFFF): void {
			var countPixels:int = Math.max(Math.abs(endX - startX), Math.abs(endY - startY));
			var diffX:int = endX - startX;
			var diffY:int = endY - startY;
			for (var i: uint = 0; i <= countPixels; i++) {
				var ratioI: Number = i / Math.max(countPixels, 1);
				var posXPixel: uint = startX + Math.round(diffX * ratioI);
				var posYPixel: uint = startY + Math.round(diffY * ratioI);
				this.setPixel32(posXPixel, posYPixel, color);
			}
		} 
		
		public function drawPoly(arrPoints: Array, color: uint = 0xFFFFFFFF): void {
			for (var i: uint = 0; i < arrPoints.length; i++) {
				if (i < arrPoints.length - 1) {
					this.drawLine(arrPoints[i].x, arrPoints[i].y, arrPoints[i + 1].x, arrPoints[i + 1].y, color);
				} else {
					this.drawLine(arrPoints[i].x, arrPoints[i].y, arrPoints[0].x, arrPoints[0].y, color)
				}
			}
		}
		
		public function fillPoly(arrPoints: Array, color: uint = 0xFFFFFFFF): void {
			this.drawPoly(arrPoints, color);
			var sumX: uint = 0;
			var sumY: uint = 0;
			for (var i: uint = 0; i < arrPoints.length; i++) {
				sumX += arrPoints[i].x;
				sumY += arrPoints[i].y;
			}
			this.floodFill(Math.round(sumX / arrPoints.length), Math.round(sumY / arrPoints.length), color);
		}
		
	}

}