package base.uiComponents.scrollBar {
	import base.btn.BtnIcon;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.greensock.TweenNano;
	
	public class Btn extends BtnIcon {
		
		public static const COUNT_FRAMES_MOUSE_OVER_OUT: uint = 10;
		private static var MOVE_X_ICON: Number = 3;
		protected var _height: Number;
		private var originPosXIcon: Number;
		
		public function Btn(height: Number, isUpDown: uint): void {
			this._height = height;
			super(this.createIcon(), this.createHit(), isUpDown);
			this.initIcon();
			this.createHit();
			this.originPosXIcon = this.icon.x;
			Btn.MOVE_X_ICON = height / 6;
		}
		
		protected function createIcon(): MovieClip {
			var icon: MovieClip = new MovieClip();
			icon.graphics.beginFill(0x000000, 1);
			icon.graphics.moveTo(0, 0);
			icon.graphics.lineTo(this._height / 3, this._height / 3);
			icon.graphics.lineTo(0, this._height * 2 / 3);
			icon.graphics.endFill();
			return icon;
			
			/*var iconInner: MovieClip = new MovieClip();
			iconInner.cacheAsBitmap = true;
			iconInner.graphics.beginFill(0x000000, 1);
			iconInner.graphics.drawRect(0, 0, this._height / 3 + 2, this._height * 2 / 3 + 2);
			iconInner.graphics.endFill();
			icon.addChild(iconInner)
			
			var iconMask: MovieClip = new MovieClip();
			iconMask.cacheAsBitmap = true;
			iconMask.graphics.lineStyle(2, 0x000000, 1);
			iconMask.graphics.moveTo(1, 1);
			iconMask.graphics.lineTo(1 + this._height / 3, 1 + this._height / 3);
			iconMask.graphics.lineTo(1, 1 + this._height * 2 / 3);
			iconInner.mask = iconMask;
			icon.addChild(iconMask)*/
			
			return icon;
		}
		
		private function initIcon(): void {
			this.icon.x = (this._height - this.icon.width) / 2;
			this.icon.y = (this._height - this.icon.height) / 2;
		}
		
		private function createHit(): Sprite {
			var hit: Sprite = new Sprite();
			hit.graphics.beginFill(0x000000, 0);
			hit.graphics.drawRect(0, 0, 1, this._height);
			hit.graphics.endFill();
			return hit;
		}
		
		protected function moveArrowOverOut(isOutOver: uint): void {
			TweenNano.killTweensOf(this.icon);
			TweenNano.to(this.icon, Btn.COUNT_FRAMES_MOUSE_OVER_OUT, {x: this.originPosXIcon + [0, Btn.MOVE_X_ICON][isOutOver], useFrames: true});
		}
		
		override public function setElementsOnOutOver(isOutOver: uint): void {
			this.moveArrowOverOut(isOutOver);
		}
		
	}

}