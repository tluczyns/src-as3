package base.app {
	import flash.display.Sprite;
	import flash.events.Event;
	import base.videoPlayer.ModelVideoPlayer;
	import base.videoPlayer.EventModelVideoPlayer;
	import flash.events.FullScreenEvent;
	import flash.display.StageDisplayState;

	public class ControllerFullScreen extends Sprite {
		
		static private var _isFullScreenOffOn: uint;
		
		public function ControllerFullScreen(): void {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		private function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.FULLSCREEN_OFF_ON, this.setFullScreenOffOn);
			this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.onFullScreenChange);
			ModelVideoPlayer.isFullScreenOffOn = ModelVideoPlayer.isFullScreenOffOn;
		}

		private function setFullScreenOffOn(e: EventModelVideoPlayer): void {
			var isFullScreenOffOn: uint = uint(e.data);
			var newFullScreenMode: String = [StageDisplayState.NORMAL, StageDisplayState.FULL_SCREEN][isFullScreenOffOn];
			if (this.stage.displayState != newFullScreenMode) {
				this.stage.displayState = newFullScreenMode;
			//	this.stage.dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		private function onFullScreenChange(e: FullScreenEvent): void {
			if (ModelVideoPlayer.isFullScreenOffOn != uint(e.fullScreen)) ModelVideoPlayer.isFullScreenOffOn = uint(e.fullScreen);
		}
		
		public function changeFullScreenOffOn(): void {
			ModelVideoPlayer.isFullScreenOffOn = 1 - ModelVideoPlayer.isFullScreenOffOn;
		}
		
		public function destroy(): void {
			this.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, this.onFullScreenChange);
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.FULLSCREEN_OFF_ON, this.setFullScreenOffOn);
		}
		
	}

}