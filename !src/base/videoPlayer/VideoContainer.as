package base.videoPlayer {
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.events.Event;
	import flash.net.NetStream;
	
	public class VideoContainer extends Sprite {
		
		public var video: Video;
		
		public function VideoContainer(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STREAM_SET, this.assignStreamToVideo);
			/*this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		private function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);*/
			if (!this.video) {
				this.video = new Video();
				this.addChild(this.video);
			}
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.VIDEO_CONTAINER_ADDED, this);
			this.video.smoothing = true;
		}
		
		private function assignStreamToVideo(e: EventModelVideoPlayer): void {
			var stream: NetStream = NetStream(e.data);
			this.video.attachNetStream(stream);
		}
		
		override public function get width(): Number {
			return this.video.width;
		}
		
		override public function set width(value: Number): void {
			this.video.width = value;
		}
		
		override public function get height(): Number {
			return this.video.height;
		}

		override public function set height(value: Number): void {
			this.video.height = value;
		}

		public function destroy(): void {
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STREAM_SET, this.assignStreamToVideo);
		}
		
	}

}