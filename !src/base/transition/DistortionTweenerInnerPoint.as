package base.transition {
	import flash.events.EventDispatcher;
	import com.reintroducing.transitions.DistortionTweener;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;

	public class DistortionTweenerInnerPoint extends EventDispatcher {
		
		private var containerDistortedBmp: Sprite;
		private var bmpDataDspObj: BitmapData;
		public var dtTopLeft: DistortionTweener;
		private var dtTopRight: DistortionTweener;
		private var dtBottomLeft: DistortionTweener;
		private var dtBottomRight: DistortionTweener;
		private var initDistortPointTopLeft: Point;
		private var initDistortPointTopRight: Point;
		private var initDistortPointBottomLeft: Point;
		private var initDistortPointBottomRight: Point;
		
		
		public function DistortionTweenerInnerPoint(dspObj: DisplayObject, containerDistortedBmp: Sprite = null): void {
			this.containerDistortedBmp = containerDistortedBmp;
			if (this.containerDistortedBmp == null) {
				this.containerDistortedBmp = new Sprite();
				this.containerDistortedBmp.x = dspObj.x;
				this.containerDistortedBmp.y = dspObj.y;
				this.containerDistortedBmp.buttonMode = true;
				dspObj.parent.addChild(this.containerDistortedBmp);
				dspObj.visible = false;
			}
			if (dspObj is Bitmap) this.bmpDataDspObj = Bitmap(dspObj).bitmapData;
			else {
				this.bmpDataDspObj = new BitmapData(Math.floor(dspObj.width), Math.floor(dspObj.height), true, 0x00FFFFFF);
				this.bmpDataDspObj.draw(dspObj, null, null, null, null, true);
			}
			var objDtAndIPTopLeft: Object = this.createDistortionTweenerAndInitPoint(0, 0);
			this.dtTopLeft = objDtAndIPTopLeft.dt;
			this.initDistortPointTopLeft = objDtAndIPTopLeft.dp;
			
			var objDtAndIPTopRight: Object = this.createDistortionTweenerAndInitPoint(1, 0);
			this.dtTopRight = objDtAndIPTopRight.dt;
			this.initDistortPointTopRight = objDtAndIPTopRight.dp;
			
			var objDtAndIPBottomLeft: Object = this.createDistortionTweenerAndInitPoint(0, 1);
			this.dtBottomLeft = objDtAndIPBottomLeft.dt;
			this.initDistortPointBottomLeft = objDtAndIPBottomLeft.dp;
			
			var objDtAndIPBottomRight: Object = this.createDistortionTweenerAndInitPoint(1, 1);
			this.dtBottomRight = objDtAndIPBottomRight.dt;
			this.initDistortPointBottomRight = objDtAndIPBottomRight.dp;
		}
		
		private function createDistortionTweenerAndInitPoint(isLeftRight: uint, isTopBottom: uint): Object {
			var bmpDataQuarter: BitmapData = new BitmapData(this.bmpDataDspObj.width / 2, this.bmpDataDspObj.height / 2, true, 0x00FFFFFF);
			var xBmpQuarter: Number = isLeftRight * Math.floor(this.bmpDataDspObj.width / 2);
			var yBmpQuarter: Number = isTopBottom * Math.floor(this.bmpDataDspObj.height / 2);
			bmpDataQuarter.copyPixels(this.bmpDataDspObj, new Rectangle(xBmpQuarter, yBmpQuarter, Math.ceil(this.bmpDataDspObj.width / 2) + isLeftRight * Math.floor(this.bmpDataDspObj.width / 2), Math.ceil(this.bmpDataDspObj.height / 2) + isTopBottom * Math.floor(this.bmpDataDspObj.height / 2)), new Point(0, 0));
			var bmpQuarter: Bitmap = new Bitmap(bmpDataQuarter, "auto", true);
			
			var distortedBmpQuarter: Sprite = new Sprite();
			distortedBmpQuarter.x = xBmpQuarter - [0, 2][isLeftRight];
			distortedBmpQuarter.y = yBmpQuarter - [0, 2][isTopBottom];
			this.containerDistortedBmp.addChild(distortedBmpQuarter);
			var dt: DistortionTweener = new DistortionTweener(distortedBmpQuarter, bmpQuarter, new Point(0, 0), new Point(bmpDataQuarter.width, 0), new Point(bmpDataQuarter.width, bmpDataQuarter.height), new Point(0, bmpDataQuarter.height), 5);
			var dp: Point = [[dt._br, dt._tr][isTopBottom], [dt._bl, dt._tl][isTopBottom]][isLeftRight]
			dp = new Point(dp.x, dp.y);
			return {dt: dt, dp: dp};
		}
		
		public function tweenTo(posX: Number, posY: Number, tweenFunc: Function, time:Number) : void {
			if (this.dtTopLeft.isCompleted) {
				this.dtTopLeft.tweenTo(this.dtTopLeft._tl, this.dtTopLeft._tr, new Point(this.initDistortPointTopLeft.x + posX, this.initDistortPointTopLeft.y + posY), this.dtTopLeft._bl, tweenFunc, time);
				this.dtTopRight.tweenTo(this.dtTopRight._tl, this.dtTopRight._tr, this.dtTopRight._br, new Point(this.initDistortPointTopRight.x + posX, this.initDistortPointTopRight.y + posY), tweenFunc, time);
				this.dtBottomLeft.tweenTo(this.dtBottomLeft._tl, new Point(this.initDistortPointBottomLeft.x + posX, this.initDistortPointBottomLeft.y + posY), this.dtBottomLeft._br, this.dtBottomLeft._bl, tweenFunc, time);
				this.dtBottomRight.tweenTo(new Point(this.initDistortPointBottomRight.x + posX, this.initDistortPointBottomRight.y + posY), this.dtBottomRight._tr, this.dtBottomRight._br, this.dtBottomRight._bl, tweenFunc, time);
			}
		}
		
	}

}