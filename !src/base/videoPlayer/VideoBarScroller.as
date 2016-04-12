package base.videoPlayer {
	import flash.display.Sprite;
	
	public class VideoBarScroller extends Sprite {
		
		public function VideoBarScroller(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.BAR_PROGRESS, this.setScrollerPosX);
			this.mouseEnabled = false;
		}
		
		private function setScrollerPosX(e: EventModelVideoPlayer): void {
			this.x = Number(e.data);
		}
		
	}
	
}