package base.sprite {
	import flash.display.Sprite;
	
	public class SpriteWithCenterAndEdges extends Sprite {
		
		public var center: Sprite;
		public var sideLeft: Sprite;
		public var sideRight: Sprite;
		public var sideTop: Sprite;
		public var sideBottom: Sprite;
		public var isHorizontalVertical: uint;
		
		public function SpriteWithCenterAndEdges(isHorizontalVertical: uint = 0): void {
			this.isHorizontalVertical = isHorizontalVertical;
		}
		
		override public function set width(value: Number): void {
			if (this.isHorizontalVertical == 0) {
				this.center.width = value - this.sideLeft.width - this.sideRight.width;
				this.sideRight.x = this.center.x + this.center.width + this.sideRight.width;
			} else super.width = value;
		}
		
		override public function set height(value: Number): void {
			if (this.isHorizontalVertical == 1) {
				this.center.height = value - this.sideTop.height - this.sideBottom.height;
				this.sideBottom.y = this.center.y + this.center.height + this.sideBottom.height;
			} else super.height = value;
		}
		
	}

}