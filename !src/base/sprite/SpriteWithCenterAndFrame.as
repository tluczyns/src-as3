package base.sprite {
	import flash.display.Sprite;
	
	public class SpriteWithCenterAndFrame extends Sprite {

		public var frameLeft: Sprite;
		public var frameTop: Sprite;
		public var frameRight: Sprite;
		public var frameBottom: Sprite;
		public var center: Sprite;
		
		public function SpriteWithCenterAndFrame(): void {
			this.width = this.width;
			this.height = this.height;
		}
		
		override public function set width(value: Number): void {
			this.frameTop.width = this.frameBottom.width = value;
			this.frameRight.x = value - this.frameRight.width;
			this.center.width = value - this.frameLeft.width - this.frameRight.width;
		}
		
		override public function set height(value: Number): void {
			this.frameLeft.height = this.frameRight.height = this.center.height = value - this.frameTop.height - this.frameBottom.height;
			this.frameBottom.y = value - this.frameBottom.height;
		}
		
	}

}