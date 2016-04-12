package base.videoPlayer {
	
	public class VideoContainerResizable extends VideoContainer {
		
		public function VideoContainerResizable(): void {
			this.visible = false;
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.METADATA_SET, this.changeVideoWidthHeight);
		}
		
		public function changeVideoWidthHeight(e: EventModelVideoPlayer): void {
			var metadata: Metadata = Metadata(e.data);
			this.video.width = metadata.width;
			this.video.height = metadata.height;
			this.visible = true;
		}
		
	}

}