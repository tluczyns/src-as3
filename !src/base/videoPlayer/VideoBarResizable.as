package base.videoPlayer {
	import flash.display.Sprite;
	
	public class VideoBarResizable extends Sprite {
		
		public var videoBar: VideoBar;
		public var maska: VideoBarResizableMask;
		
		public function VideoBarResizable(): void {
			this.videoBar.mask = this.maska;
		}
		
		override public function set width(value: Number): void {
			this.videoBar.width = value;
			this.maska.width = value;
		}
		
	}

}