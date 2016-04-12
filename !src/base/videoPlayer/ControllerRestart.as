package base.videoPlayer {
	import flash.events.MouseEvent;
	
	public dynamic class ControllerRestart extends ControllerVideoPlayer {
		
		public function ControllerRestart(): void {}
		
		override protected function onClickHandler(event: MouseEvent): void {
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SEEK, 0);
			ModelVideoPlayer.isPausePlay = 1;
		}
		
	}

}