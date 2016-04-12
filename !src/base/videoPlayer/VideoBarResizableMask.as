package base.videoPlayer {
	import flash.display.Sprite;

	public class VideoBarResizableMask extends Sprite	{
		
		public var sideLeft: Sprite;
		public var center: Sprite;
		public var sideRight: Sprite;
		
		public function VideoBarResizableMask(): void {}
		
		override public function set width(value: Number): void {
			this.center.width = value - this.sideLeft.width - this.sideRight.width;
			this.sideRight.x = this.center.x + this.center.width + this.sideRight.width;
		}
		
	}
	
}