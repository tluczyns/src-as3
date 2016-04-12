package base.sound {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import caurina.transitions.Tweener;
	
	public class BtnSoundOffOn extends MovieClip {
		
		public var hit: Sprite;
		public var background: Sprite;
		public var cross: Sprite;
		
		public function BtnSoundOffOn(): void {
			this.background.alpha = 0;
			this.addMouseEvent();
			this.cross.alpha = uint(ModelSoundEngine.volumeRatio == 0);
			ModelSoundEngine.addEventListener(EventSoundEngine.VOLUME_RATIO_CHANGED, this.checkVolumeRatioAndHideShowCross);
		}
		
		internal function addMouseEvent(): void {
			this.hit.buttonMode = true;
			this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
			this.hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
			this.hit.addEventListener(MouseEvent.CLICK, this.onClickHandler);
			this.hit.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		internal function removeMouseEvent(): void {
			this.hit.buttonMode = false;
			this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
			this.hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
			this.hit.removeEventListener(MouseEvent.CLICK, this.onClickHandler);
			this.hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		private function onMouseOverHandler(event:MouseEvent): void {
			if (this.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			}
			Tweener.addTween(this.background, {alpha: 1, time: 10, useFrames: true, transition: "linear"});
		}
		
		private function onMouseOutHandler(event:MouseEvent): void {
			Tweener.addTween(this.background, {alpha: 0, time: 10, useFrames: true, transition: "linear"});
		}
		
		private function onClickHandler(event:MouseEvent): void {
			ModelSoundEngine.isSoundOffOn = 1 - uint(ModelSoundEngine.volumeRatio > 0); //- ModelSoundEngine.isSoundOffOn
		}
		
		private function onMouseMoveHandler(event:MouseEvent): void {
			this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			this.onMouseOverHandler(null);
		}	

		private function checkVolumeRatioAndHideShowCross(e: EventSoundEngine): void {
			if (ModelSoundEngine.volumeRatio == 0) this.hideShowCross(1);
			else if (ModelSoundEngine.volumeRatio > 0) this.hideShowCross(0);
		}
		
		internal function hideShowCross(isHideShow: Number): void {
			if ((isHideShow == 0) && (this.cross.alpha > 0)) {
				Tweener.addTween(this.cross, {alpha: 0, time: 10, useFrames: true, transition: "linear"});
			} else if ((isHideShow == 1) && (this.cross.alpha < 1)) {
				Tweener.addTween(this.cross, {alpha: 1, time: 10, useFrames: true, transition: "linear"});
			}
		}
		
	}
	
}