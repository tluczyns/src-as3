package base.videoPlayerIsolated {
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetStream;
	
	public class VideoContainer extends Sprite {
		
		public var video: Video;
		
		public function VideoContainer(): void {
			if (!this.video) {
				this.video = new Video();
				this.addChild(this.video);
			}
			this.video.smoothing = true;
		}
		
		public function assignStreamToVideo(stream: NetStream): void {
			this.video.attachNetStream(stream);
		}
		
		public function destroy(): void {
			this.removeChild(this.video)
			this.video = null;
		}
		
	}

}