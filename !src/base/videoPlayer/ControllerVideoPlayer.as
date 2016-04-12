package base.videoPlayer {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ControllerVideoPlayer extends Sprite {
		
		public var hit: Sprite;
		public static var onMouseOverHandler: Function;
		public static var onMouseOutHandler: Function;
		
		public function ControllerVideoPlayer (): void {
			this.addMouseEvents();
		}
		
		public function addMouseEvents(): void {
			if (!this.hit.buttonMode) {
				this.hit.buttonMode = true;
				this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.addEventListener(MouseEvent.CLICK, this.onClickHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			}
		}
		
		public function removeMouseEvents(): void {
			if (this.hit.buttonMode) {
				this.hit.buttonMode = false;
				this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.removeEventListener(MouseEvent.CLICK, this.onClickHandler);
				if (this.hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
					this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				}
			}
		}
		
		protected function onMouseOverHandler(event: MouseEvent): void {
			if (ControllerVideoPlayer.onMouseOverHandler != null) ControllerVideoPlayer.onMouseOverHandler(this);
			if (this.hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			}
		}
		
		protected function onMouseOutHandler(event: MouseEvent): void {
			if (ControllerVideoPlayer.onMouseOutHandler != null) ControllerVideoPlayer.onMouseOutHandler(this);
		}
		
		protected function onClickHandler(event: MouseEvent): void {}
		
		private function onMouseMoveHandler(event:MouseEvent): void {
			this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			this.onMouseOverHandler(null);
		}
		
		public function destroy(): void {
			this.removeMouseEvents();
		}
		
	}

}