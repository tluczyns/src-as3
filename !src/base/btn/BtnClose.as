package base.btn {
	import flash.display.Sprite;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	public class BtnClose extends BtnHitWithEvents {
		
		public var cross: Sprite;
		public static var COUNT_FRAMES_MOUSE_OVER_OUT: uint = 10;
		
		public function BtnClose(cross: Sprite = null, hit: Sprite = null): void {
			this.initCross(cross);
			super(hit);
			this.cross.x = this.hit.width / 2;
			this.cross.y = this.hit.height / 2;
		}
		
		private function initCross(cross: Sprite): void {
			if ((this.cross == null) && (cross != null)) {
				this.addChild(cross);
				this.cross = cross;
			}
		}
		
		override public function setElementsOnOutOver(isOutOver: uint): void {
			var targetScale: Number = [1, 0.7][isOutOver];
			TweenLite.killTweensOf(this.cross);
			TweenLite.to(this.cross, BtnClose.COUNT_FRAMES_MOUSE_OVER_OUT, {scaleX: targetScale, scaleY: targetScale, rotation: [-360, 360][isOutOver], useFrames: true, ease: Quad.easeInOut});
		}
		
		private function removeCross(): void {
			this.removeChild(this.cross);
			this.cross = null;
		}
		
		override public function destroy(): void {
			this.removeCross();
			super.destroy()
		}
		
	}

}