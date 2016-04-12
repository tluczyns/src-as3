package base.uiComponents.scrollArea {
	import flash.display.Sprite;
	import flash.display.Shape;
	
	public class MaskWithCovers extends Sprite {
		
		private var coverTop: MaskCover;
		private var center: Shape;
		private var coverBottom: MaskCover;
		
		public function MaskWithCovers(heightCover: Number = 20): void {
			this.createCoverTop(heightCover);
			this.createCenter();
			this.createCoverBottom(heightCover);
		}
		
		private function createCoverTop(heightCover: Number): void {
			this.coverTop = new MaskCover();
			this.coverTop.x = this.coverTop.y = 0;
			this.coverTop.height = heightCover;
			this.addChild(this.coverTop);
		}
		
		private function createCenter(): void {
			this.center = new Shape();
			this.center.x = 0;
			this.center.y = this.coverTop.y + this.coverTop.height;
			this.center.graphics.beginFill(0, 1);
			this.center.graphics.drawRect(0, 0, 1, 1);
			this.center.graphics.endFill();
			this.addChild(this.center);
		}
		
		private function createCoverBottom(heightCover: Number): void {
			this.coverBottom = new MaskCover();
			this.coverBottom.rotation = 180;
			this.coverBottom.height = heightCover;
			this.addChild(this.coverBottom);
		}

		override public function set height(value: Number): void {
			value = Math.round(value);
			this.center.height = value - this.coverTop.height - this.coverBottom.height;
			this.coverBottom.y = this.center.y + this.center.height + this.coverBottom.height;
		}
		
		override public function set width(value: Number): void {
			this.coverTop.width = value;
			this.center.width = value;
			this.coverBottom.width = this.coverBottom.x = value;
		}
		
	}

}