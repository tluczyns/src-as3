package base.videoPlayer {
	import flash.events.MouseEvent;
	
	public class ControllerStop extends ControllerVideoPlayer {
		
		public function ControllerStop(): void {}
		
		override protected function onClickHandler(event: MouseEvent): void {
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STOP, null); 
		}
		
	}

}