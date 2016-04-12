package base.uiComponents {
	import flash.display.Sprite;
	import base.uiComponents.scrollArea.MaskWithCovers;

	public class ScrollAreaWithGradientMask extends ScrollArea {
		
		public var heightCover: Number;
		
		public function ScrollAreaWithGradientMask(width: Number = 0, isSetMouseWheelOnStage: Boolean = false, heightCover: Number = 20): void {
			this.heightCover = heightCover;
			super(width, isSetMouseWheelOnStage);
		}
		
		override protected function initElements(): void {
			super.initElements();
			this.maskArea.cacheAsBitmap = true;
			this.area.cacheAsBitmap = true;
		}
		
		override protected function createMaskArea(width: Number): Sprite {
			var maskArea: Sprite = new MaskWithCovers(this.heightCover);
			maskArea.width = width;
			return maskArea;
		}
		
		override protected function getTargetPosYForPercent(percent: Number): Number {
			return this.heightCover  + Math.min(percent * (this.height - 2 * this.heightCover - this.area.height), 0);
		}
		
		override public function isAreaShorterThanMask(): Boolean {
			return (this.area.height <= this.height - this.heightCover);
		}
		
	}

}