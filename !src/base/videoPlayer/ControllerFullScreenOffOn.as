package base.videoPlayer {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import base.dspObj.DoOperations;
	import flash.events.MouseEvent;
	
	public dynamic class ControllerFullScreenOffOn extends ControllerVideoPlayer {
		
		public var indicatorFullScreenOff: Sprite;
		public var indicatorFullScreenOn: Sprite;
		
		public function ControllerFullScreenOffOn(): void {
			this.indicatorFullScreenOff.alpha = 0;
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.FULLSCREEN_OFF_ON, this.setVisibleIndicatorFullScreenOffOn);	
			ModelVideoPlayer.isFullScreenOffOn = 0;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		private function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.onFullScreenChange)
		}
		
		private function onFullScreenChange(e: FullScreenEvent): void {
			if (ModelVideoPlayer.isFullScreenOffOn != uint(e.fullScreen)) ModelVideoPlayer.isFullScreenOffOn = uint(e.fullScreen);
		}
		
		private function setVisibleIndicatorFullScreenOffOn(e: EventModelVideoPlayer): void {
			var isFullScreenOffOn: uint = uint(e.data);
			DoOperations.hideShow(this.indicatorFullScreenOff, isFullScreenOffOn);
			DoOperations.hideShow(this.indicatorFullScreenOn, 1 - isFullScreenOffOn);
		}
		
		override protected function onClickHandler(event: MouseEvent): void {
			ModelVideoPlayer.isFullScreenOffOn = 1 - ModelVideoPlayer.isFullScreenOffOn;
		}
		
		override public function destroy(): void {
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.FULLSCREEN_OFF_ON, this.setVisibleIndicatorFullScreenOffOn);	
			this.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, this.onFullScreenChange);
			super.destroy();
		}

	}

}