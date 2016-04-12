package base.videoPlayer {
	import base.mvc.EventModel;

	public class EventModelVideoPlayer extends EventModel {

		public static const PAUSE_PLAY: String = "pausePlay";
		public static const STOP: String = "stop";
		public static const VOLUME_CHANGE: String = "volumeChange";
		public static const FULLSCREEN_OFF_ON: String = "fullScreenOffOn";
		public static const STREAM_SET: String = "streamSet";
		public static const VIDEO_CONTAINER_ADDED: String = "videoContainerAdded";
		public static const STREAM_SEEK: String = "streamSeek";
		public static const STREAM_LOAD: String = "streamLoad";
		public static const STREAM_PROGRESS: String = "streamProgress";
		public static const METADATA_SET: String = "metadataSet";
		public static const BAR_PROGRESS: String = "barProgress";
		public static const BUFFER_EMPTY: String = "bufferEmpty";
		public static const BUFFER_FULL: String = "bufferFull";
		
		public function EventModelVideoPlayer(type: String, data: * = null): void {
			super(type, data);
		}
		
	}

}