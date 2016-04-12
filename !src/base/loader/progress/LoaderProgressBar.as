package base.loader.show {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class LoaderProgressBar extends LoaderProgress {
		
		private var colorBar: uint;
		private var isVerticalHorizontal: uint;
		private var bg: Sprite;
		protected var bar: Sprite;
		private var maskBg: Sprite;
		private var maskBar: Bitmap;
		
		public function LoaderProgressBar(mask: Sprite, colorBar: uint, isVerticalHorizontal: uint, tfPercent: TextField = null, isTLOrCenterAnchorPointWhenCenterOnStage: uint = 0, timeFramesTweenPercent: Number = 0.2, alphaBg: Number = 0.2): void {
			this.maskBg = mask;
			this.colorBar = colorBar;
			this.isVerticalHorizontal = isVerticalHorizontal;
			this.createElements(alphaBg);
			super(tfPercent, isTLOrCenterAnchorPointWhenCenterOnStage, timeFramesTweenPercent);
			if (this.tfPercent != null) {
				this.basePosXTfPercent = mask.width / 2;
				this.tfPercent.y = Math.round(mask.height + 20);
			}
		}
		
		private function createElements(alphaBg: Number): void {
			this.maskBg.x = this.maskBg.y = 0;
			this.addChild(this.maskBg);
			
			this.bg = new Sprite();
			this.bg.x = 0;
			this.bg.y = this.maskBg.height;
			this.bg.graphics.beginFill(this.colorBar, 1);
			this.bg.graphics.drawRect(0, 0, this.maskBg.width, -this.maskBg.height);
			this.bg.graphics.endFill();
			this.addChild(this.bg);
			
			this.maskBar = new Bitmap();
			this.maskBar.x = this.maskBar.y = 0;
			this.maskBar.cacheAsBitmap = true;
			this.maskBar.bitmapData = new BitmapData(this.maskBg.width, this.maskBg.height, true, 0x000000);
			this.maskBar.bitmapData.draw(this.maskBg);
			this.addChild(this.maskBar);
			
			this.bg.mask = this.maskBg;
			
			this.bar = new Sprite();
			this.bar.graphics.copyFrom(this.bg.graphics);
			this.bar.x = this.bg.x;
			this.bar.y = this.bg.y;
			this.bar.cacheAsBitmap = true;
			this.addChild(this.bar);
			this.bar.mask = this.maskBar;
			
			this.bar[["width", "height"][this.isVerticalHorizontal]] = 0;
			this.bg.alpha = alphaBg;
		}
		
		private function changeDimensionBar(): void {
			this.bar[["width", "height"][this.isVerticalHorizontal]] = this.ratioProgress * this.maskBar[["width", "height"][this.isVerticalHorizontal]];
		}
		
		override protected function update(): void {
			super.update();
			this.changeDimensionBar();
			if (this.tfPercent != null) this.tfPercent.x = this.basePosXTfPercent - this.tfPercent.width / 2;
		}
		
		protected function repositionBgAndBar(newPosX: Number, newPosY: Number): void {
			this.maskBg.x = this.maskBar.x = this.bg.x = this.bar.x = newPosX;
			this.maskBg.y = this.maskBar.y = newPosY;
			this.bg.y = newPosY + this.maskBg.height;
			this.bar.y = newPosY + this.maskBar.height;
		}
		
		override public function destroy(): void {
			this.removeChild(this.maskBg);
			this.removeChild(this.maskBar);
			this.bg.graphics.clear();
			this.removeChild(this.bg)
			this.bar.graphics.clear();
			this.removeChild(this.bar);
			super.destroy();
		}
		
	}
	
}