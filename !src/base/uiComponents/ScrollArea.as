package base.uiComponents {
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import com.greensock.TweenMax;
	
	public class ScrollArea extends Sprite {
		
		public var area: Sprite;
		protected var maskArea: Sprite;
		internal var isSetMouseWheelOnStage: Boolean;
		public var countFramesMove: uint = 5;
		internal var dontTween: Boolean = false;
		
		public function ScrollArea(width: Number = 0, isSetMouseWheelOnStage: Boolean = false): void {
			width = width || 150;
			if (!this.area) this.area = this.createArea(width);
			width = this.area.width;
			this.maskArea = this.createMaskArea(width);
			this.isSetMouseWheelOnStage = isSetMouseWheelOnStage;
			this.initElements();
		}
		
		protected function initElements(): void {
			this.addChild(this.maskArea);
			this.addChild(this.area);
			this.area.mask = this.maskArea;
		}
		
		protected function createMaskArea(width: Number): Sprite {
			var maskArea: Sprite = new Sprite();
			maskArea.graphics.beginFill(0x000000, 0);
			maskArea.graphics.drawRect(0, 0, width, 1);
			maskArea.graphics.endFill();
			return maskArea;
		}
		
		protected function createArea(width: Number): Sprite {
			var area: Sprite = new Sprite();
			area.x = 0;
			var mrxGradientArea: Matrix = new Matrix();
			mrxGradientArea.createGradientBox(10, 10, Math.PI / 2);
			area.graphics.beginGradientFill(GradientType.LINEAR, [0x222222, 0xDDDDDD], [1, 1], [0, 255], mrxGradientArea);
			area.graphics.drawRect(0, 0, 10, 10);
			area.graphics.endFill();
			area.width = this.width;
			area.height = 500;
			return area;
		}
		
		protected function getTargetPosYForPercent(percent: Number): Number {
			return Math.min(percent * (this.height - this.area.height), 0);
		}
		
		/*public function get percentScroll(): Number {
			return this.area.y / (this.height - this.area.height);
		}*/
		
		public function set percentScroll(value: Number): void {
			TweenMax.killTweensOf(this.area);
			var targetPosY: Number = this.getTargetPosYForPercent(value);
			if (!this.dontTween) TweenMax.to(this.area, this.countFramesMove, {y: targetPosY, useFrames: true});
			else this.area.y = targetPosY;
		}
		
		public function isAreaShorterThanMask(): Boolean {
			return (this.area.height <= this.height);
		}
		
		override public function get width(): Number {
			return this.maskArea.width;
		}
		
		override public function set width(value: Number): void {
			this.maskArea.width = this.area.width = value;
		}
		
		override public function get height(): Number {
			return this.maskArea.height;
		}
		
		override public function set height(value: Number): void {
			this.maskArea.height = value;
		}
		
		public function destroy(): void {
			this.removeChild(this.maskArea);
			this.removeChild(this.area);
		}
		
	}

}