package base.sound {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ScrollSoundVolume extends MovieClip {
		
		public var scroller: Sprite;
		public var scrollerTrack: Sprite;
		
		private var isScrollerDragged: Boolean;
		
		public function ScrollSoundVolume() {
			this.setScrollerPosition();
			this.addMouseEvents();
			ModelSoundEngine.addEventListener(EventSoundEngine.VOLUME_RATIO_CHANGED, this.setScrollerPosition);
		}
		
		internal function addMouseEvents(): void {
			this.buttonMode = true;
			this.isScrollerDragged = false;
			this.scrollerTrack.addEventListener(MouseEvent.CLICK, this.onScrollerTrackClickHandler);
			this.scrollerTrack.addEventListener(MouseEvent.MOUSE_UP, this.onScrollerTrackMouseUpHandler);
			this.scrollerTrack.addEventListener(MouseEvent.MOUSE_OUT, this.onScrollerTrackMouseUpHandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		public function removeMouseEvents(): void {
			this.buttonMode = false;
			this.isScrollerDragged = false;
			this.scrollerTrack.removeEventListener(MouseEvent.CLICK, this.onScrollerTrackClickHandler);
			this.scrollerTrack.removeEventListener(MouseEvent.MOUSE_UP, this.onScrollerTrackMouseUpHandler);
			this.scrollerTrack.removeEventListener(MouseEvent.MOUSE_OUT, this.onScrollerTrackMouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		private function onScrollerTrackClickHandler(event:MouseEvent): void {
			var posXScroller: Number = this.mouseX;
			this.changeScrollerPosition(posXScroller, 1);
			this.isScrollerDragged = true;
		}
		
		private function onScrollerTrackMouseUpHandler(event:MouseEvent): void {
			this.isScrollerDragged = false;
		}
		
		private function onMouseMoveHandler(event:MouseEvent): void {
			if (this.isScrollerDragged) {
				var posXScroller: Number = this.mouseX;
				this.changeScrollerPosition(posXScroller, 0);
			}
		}
		
		private function changeScrollerPosition(posXScroller: Number, isJumpTween: uint): void {
			if (posXScroller >= this.scrollerTrack.x + this.scrollerTrack.width - this.scroller.width / 2) {
				posXScroller = this.scrollerTrack.x + this.scrollerTrack.width - this.scroller.width / 2;
			} else if (posXScroller <= this.scrollerTrack.x + this.scroller.width / 2) {
				posXScroller = this.scrollerTrack.x + this.scroller.width / 2;
			}
			var percentScroller: Number = (posXScroller - this.scroller.width / 2 - this.scrollerTrack.x) / (this.scrollerTrack.width - this.scroller.width);
			if (isJumpTween == 0) {
				this.scroller.x = posXScroller;
				ModelSoundEngine.volumeRatio = percentScroller;
			} else if (isJumpTween == 1)
				ModelSoundEngine.tweenVolumeRatio = percentScroller;
		}
			
		private function setScrollerPosition(e: EventSoundEngine = null): void {
			this.scroller.x = this.scrollerTrack.x + this.scroller.width / 2 + ModelSoundEngine.volumeRatio * (this.scrollerTrack.width - this.scroller.width);
		}
			
	}
	
}