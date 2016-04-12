package base.uiComponents {
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	import flash.events.TransformGestureEvent;
	
	public class ScrollBar extends Sprite {
		
		protected var track: Sprite;
		protected var bar: Sprite;
		private var isBarDragged: Boolean;
		protected var originHeightBar: Number;
		public static var MARGIN_Y_BAR: Number = 5;
		public static var ADDITIONAL_HEIGHT_OPERATIVE_BAR: Number = 10;
		protected var multiplicatorDeltaMouseWheel: Number = 4;
		protected var multiplicatorOffsetYGestureSwipe: Number = 50;
		public var currOffsetYGestureSwipe: Number;
		private var timeAnimOffsetYGestureSwipe: Number = 1;
		protected var _scrollArea: ScrollArea;
		private var _height: Number;
		;
		
		public function ScrollBar(scrollArea: ScrollArea = null, height: Number = 100): void {
			this._scrollArea = scrollArea;
			this._height = height;
			this.createElements();
			this.originHeightBar = this.bar.height;
			this.initElements();
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		protected function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.bar.visible = false;
			this.track.visible = false;
			this.scrollArea = this._scrollArea;
			this.height = this._height;
		}
		
		protected function createElements(): void {
			this.track = this.createTrack();
			this.bar = this.createBar();
		}
		
		protected function createTrack(): Sprite {
			var track: Sprite = new Sprite();
			track.graphics.beginFill(0x000000, 0.3);
			track.graphics.drawRect(0, 0, 15, 1);
			track.graphics.endFill();
			return track;
		}
		
		protected function createBar(): Sprite {
			var bar: Sprite = new Sprite();
			bar.graphics.beginFill(0x000000, 1);
			bar.graphics.drawRect(0, 0, 10, 30);
			bar.graphics.endFill();
			return bar;
		}
		
		protected function initElements(): void {
			this.addChild(this.track);
			this.bar.x = this.track.x + (this.track.width - this.bar.width) / 2;
			this.addChild(this.bar);
		}
		
		public function addBarEvents(): void {
			if (!this.bar.visible) {
				this.isBarDragged = false;
				this.bar.buttonMode = true;
				this.bar.addEventListener(MouseEvent.MOUSE_DOWN, this.onBarMouseDownHandler);
				this.bar.stage.addEventListener(MouseEvent.MOUSE_UP, this.onBarMouseUpHandler);
				this.bar.addEventListener(Event.ENTER_FRAME, this.onBarEnterFrameHandler);
				this.bar.addEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				this.bar.visible = true;
				this.track.buttonMode = true;
				this.track.addEventListener(MouseEvent.MOUSE_DOWN, this.onTrackMouseDownHandler);
				this.track.addEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				this.track.visible = true;
			}
		}
		
		public function addScrollAreaEvents(): void {
			if (this.scrollArea) {
				this.scrollArea.addEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				this.scrollArea.addEventListener(TransformGestureEvent.GESTURE_SWIPE, this.onContentGestureSwipeHandler);
			}
		}
		
		private function onBarMouseDownHandler(e: MouseEvent): void {
			this.isBarDragged = true;
		}
		
		private function onBarMouseUpHandler(e: MouseEvent): void {
			this.isBarDragged = false;
		}
		
		private function onBarEnterFrameHandler(e: Event): void {
			if (this.isBarDragged) this.getPercentBarAndChangePosY(this.mouseY);
		}
		
		protected function onContentMouseWheelHandler(e: MouseEvent): void {
			this.getPercentBarAndChangePosY(this.bar.y + this.bar.height / 2 - e.delta * this.multiplicatorDeltaMouseWheel);
		}
		
		protected function onContentGestureSwipeHandler(e: TransformGestureEvent): void {
			this.currOffsetYGestureSwipe = e.offsetY * this.multiplicatorOffsetYGestureSwipe;
			this.moveByOffsetYWhenGestureSwipe();
			TweenMax.killTweensOf(this, {currOffsetYGestureSwipe: true});
			TweenMax.to(this, this.timeAnimOffsetYGestureSwipe, {currOffsetYGestureSwipe: 0, ease: Cubic.easeOut, onUpdate: this.moveByOffsetYWhenGestureSwipe});
		}
		
		private function moveByOffsetYWhenGestureSwipe(): void {
			this.getPercentBarAndChangePosY(this.bar.y + this.bar.height / 2 - this.currOffsetYGestureSwipe);
		}
		
		private function onTrackMouseDownHandler(e: MouseEvent): void {
			this.getPercentBarAndChangePosY(this.mouseY);
		}
		
		protected function getPercentBar(posYBar: Number): Number {
			var halfOfHeightBarPlusMargin: Number = this.bar.height / 2 + ScrollBar.MARGIN_Y_BAR;
			if (posYBar >= this.height - halfOfHeightBarPlusMargin) {
				posYBar = this.height - halfOfHeightBarPlusMargin;
			}
			if (posYBar <= halfOfHeightBarPlusMargin) {
				posYBar = halfOfHeightBarPlusMargin;
			}
			var precision: Number = 1000;
			if (this.height - (halfOfHeightBarPlusMargin * 2) == 0) return 0;
			else return Math.min(Math.max(0, Math.round((posYBar - halfOfHeightBarPlusMargin) / (this.height - (halfOfHeightBarPlusMargin * 2)) * precision) / precision), 1);
		}
		
		protected function changePosYFromPercentBar(percentBar: Number): void {
			this.bar.y = ScrollBar.MARGIN_Y_BAR + percentBar * Math.max(this.height - (this.bar.height + ScrollBar.MARGIN_Y_BAR * 2), 0);
			if (this.scrollArea) this.scrollArea.percentScroll = percentBar;
		}
		
		private function getPercentBarAndChangePosY(posYBar: Number): void {
			this.changePosYFromPercentBar(this.getPercentBar(posYBar));
		}
		
		protected function removeBarEvents(): void {
			if (this.bar.visible) {
				this.bar.buttonMode = false;
				this.bar.removeEventListener(MouseEvent.MOUSE_DOWN, this.onBarMouseDownHandler);
				if (this.bar.stage) this.bar.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onBarMouseUpHandler);
				this.bar.removeEventListener(Event.ENTER_FRAME, this.onBarEnterFrameHandler);
				this.bar.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				this.bar.visible = false;
				this.track.buttonMode = false;
				this.track.removeEventListener(MouseEvent.MOUSE_DOWN, this.onTrackMouseDownHandler);
				this.track.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				this.track.visible = false;
			}
		}
		
		private function removeScrollAreaEvents(): void {
			if (this.scrollArea) {
				TweenMax.killTweensOf(this, {currOffsetYGestureSwipe: true});
				this.scrollArea.removeEventListener(TransformGestureEvent.GESTURE_SWIPE, this.onContentGestureSwipeHandler);
				this.scrollArea.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
			}
		}
		
		override public function get height(): Number {
			return this._height;
		}
		
		override public function set height(value: Number): void {
			var percent: Number = this.getPercentBar(this.bar.y + this.bar.height / 2);
			this.track.height = value;
			this._height = value;
			if (this.scrollArea) this.setScrollAreaHeightAndAddRemoveBarEvents();
			if ((this.bar.visible) || (this.scrollArea == null)) {
				var maxHeightBar: Number = this.height - 2 * ScrollBar.MARGIN_Y_BAR - ScrollBar.ADDITIONAL_HEIGHT_OPERATIVE_BAR;
				if (maxHeightBar <= 0) this.removeBarEvents();
				else {
					this.addBarEvents();
					if (this.bar.height > maxHeightBar)  this.bar.height = maxHeightBar;
					else this.bar.height = Math.min(maxHeightBar, this.originHeightBar);
				}
			}
			if (this.bar.visible) this.changePosYFromPercentBar(percent);
		}
		
		private function refreshPosYFromScrollAreaHeightChange(e: Event): void {
			this.changePosYFromPercentBar(this.getPercentBar(this.bar.y + this.bar.height / 2));
		}
		
		private function setScrollAreaHeightAndAddRemoveBarEvents(): void {
			this.scrollArea.dontTween = true;
			this.scrollArea.height = this.height;
			this.scrollArea.dontTween = false;
			if (this.scrollArea.isAreaShorterThanMask()) {
				this.removeBarEvents();
				this.removeScrollAreaEvents();
				this.scrollArea.percentScroll = 0;
			} else {
				this.addBarEvents();
				this.addScrollAreaEvents();
			}
		}
		
		public function get scrollArea(): ScrollArea {
			return this._scrollArea;
		}
		
		public function set scrollArea(value: ScrollArea): void {
			if (value != null) {
				var intrObjForMouseWheel: InteractiveObject;
				if (this._scrollArea) {
					this._scrollArea.removeEventListener(Event.CHANGE, this.refreshPosYFromScrollAreaHeightChange);
					if (this._scrollArea.isSetMouseWheelOnStage) intrObjForMouseWheel = this._scrollArea.stage;
					else intrObjForMouseWheel = this._scrollArea;
					if (intrObjForMouseWheel) intrObjForMouseWheel.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
					intrObjForMouseWheel = null;
				}
				if (value.isSetMouseWheelOnStage) intrObjForMouseWheel = value.stage;
				else intrObjForMouseWheel = value; 
				/*if (intrObjForMouseWheel) */intrObjForMouseWheel.addEventListener(MouseEvent.MOUSE_WHEEL, this.onContentMouseWheelHandler);
				value.addEventListener(Event.CHANGE, this.refreshPosYFromScrollAreaHeightChange);
				this._scrollArea = value;
				this.x = value.x + value.width;
				this.y = value.y;
				this.setScrollAreaHeightAndAddRemoveBarEvents();
			}
		}
		
		public function destroy(): void {
			this.removeBarEvents();
			this.removeScrollAreaEvents();
		}
		
	}

}