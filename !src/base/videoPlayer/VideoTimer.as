package base.videoPlayer {
	import flash.display.Sprite;
	import flash.text.TextField;
	import base.types.StringUtils;
	
	public class VideoTimer extends Sprite {
		
		public var tfDuration: TextField;
		public var tfTimePlayed: TextField;
		private var duration: Number = 0;
		
		public function VideoTimer(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.METADATA_SET, this.setTfDuration);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STREAM_PROGRESS, this.setTfTimePlayed);
		}
		
		private function setTfDuration(e: EventModelVideoPlayer): void {
			if (Metadata(e.data).duration) {
				this.duration = Metadata(e.data).duration;
				this.tfDuration.text = this.getStrFromTime(this.duration);
			}
		}
		
		private function setTfTimePlayed(e: EventModelVideoPlayer): void {
			var ratioPlayedTimeStream: Number = Number(e.data);
			this.tfTimePlayed.text = this.getStrFromTime(ratioPlayedTimeStream * this.duration);
		}

		private function getStrFromTime(time: Number): String {
			time = Math.round(time);
			return (StringUtils.addZerosBeforeNumberAndReturnString(Math.floor(time / 60), 2) + ":" + StringUtils.addZerosBeforeNumberAndReturnString(time % 60, 2)); 
		}
		
	}
	
}