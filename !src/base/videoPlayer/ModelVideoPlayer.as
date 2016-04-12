package base.videoPlayer {
	import base.types.Singleton;
	import flash.events.EventDispatcher;

	public class ModelVideoPlayer extends Singleton {
		
		public static var modelDispatcher: EventDispatcher = new EventDispatcher();
		
		private static var _isPausePlay: uint = 0;
		public static var _volume: Number = 1;
		private static var _isFullScreenOffOn: uint = 0;
		public static var isStop: Boolean = true;
		
		public static function addEventListener(type: String, func: Function, priority: uint = 10): void {
			ModelVideoPlayer.modelDispatcher.addEventListener(type, func, false, priority);
		}
		
		public static function removeEventListener(type: String, func: Function): void {
			ModelVideoPlayer.modelDispatcher.removeEventListener(type, func);
		}
		
		public static function dispatchEvent(type: String, data: * = null): void {
			ModelVideoPlayer.modelDispatcher.dispatchEvent(new EventModelVideoPlayer(type, data)); 
		}
		
		static public function get isPausePlay(): uint {
			return ModelVideoPlayer._isPausePlay;
		}
		
		static public function set isPausePlay(value: uint): void {
			ModelVideoPlayer._isPausePlay = value;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.PAUSE_PLAY, value); 
		}
		
		static public function get volume(): Number {
			return ModelVideoPlayer._volume;
		}
		
		static public function set volume(value: Number): void {
			ModelVideoPlayer._volume = value;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.VOLUME_CHANGE, value); 
		}
		
		static public function get isFullScreenOffOn(): uint {
			return ModelVideoPlayer._isFullScreenOffOn;
		}
		
		static public function set isFullScreenOffOn(value: uint): void {
			ModelVideoPlayer._isFullScreenOffOn = value;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.FULLSCREEN_OFF_ON, value); 
		}
		
	}

}