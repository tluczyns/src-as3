package base.videoPlayer {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class VideoBar extends Sprite {
		
		public var totalBar: Sprite;
		public var loadBar: Sprite;
		public var progressBar: Sprite;
		
		public function VideoBar(): void {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.initBars();
		}
		
		private function initBars(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STREAM_LOAD, this.setLoadBarWidth);	
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.STREAM_PROGRESS, this.setProgressBarWidth);
			this.loadBar.width = 0;
			this.progressBar.width = 0;
		}
		
		private function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.buttonMode = true;
			this.addMouseEvents();
		}
		
		private function addMouseEvents(): void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
		}
		
		private function removeMouseEvents(): void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			}
		}
		
		private function onMouseDownHandler(e: MouseEvent): void {
			if (this.stage) {
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				this.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
			}
		}
		
		private function onMouseUpHandler(e: MouseEvent): void {
			if (this.stage) this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		private function onMouseMoveHandler(e: Event): void {
			var ratioX: Number = Math.min(Math.max(this.mouseX, 0), this.totalBar.width) / this.totalBar.width;
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.STREAM_SEEK, ratioX);
		}
		
		private function setLoadBarWidth(e: EventModelVideoPlayer): void {
			var ratioLoad: Number = Number(e.data);
			if (ratioLoad != 0) this.loadBar.width = this.totalBar.width * Number(e.data);
		}
		
		private function setProgressBarWidth(e: EventModelVideoPlayer): void {
			this.progressBar.width = this.totalBar.width * Number(e.data);
			ModelVideoPlayer.dispatchEvent(EventModelVideoPlayer.BAR_PROGRESS, this.x + this.progressBar.x + this.progressBar.width);
		}
		
		public function destroy(): void {
			this.removeMouseEvents();
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STREAM_LOAD, this.setLoadBarWidth);	
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.STREAM_PROGRESS, this.setProgressBarWidth);
		}
		
	}

}