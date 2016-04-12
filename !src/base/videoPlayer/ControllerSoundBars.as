package base.videoPlayer {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public dynamic class ControllerSoundBars extends Sprite {
		
		public var hit: Sprite;
		
		private var _countBars: uint;
		private var arrBar: Array;
		public var marginBetweenBars: Number;
		public var marginSide: Number;
		public var ratioBarHeightSoundOff: Number;
		public var colorHide: uint = 0xAAAAAA;
		public var colorVisible: uint = 0xFFFFFF;
		
		public function ControllerSoundBars(): void {
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.setVisibleBars);
			this.hit.width = 1;
			this._countBars = 0;
			this.arrBar = [];
			this.marginBetweenBars = 1;
			this.marginSide = 3;
			this.ratioBarHeightSoundOff = 0.3;
			this.countBars = 3;
			this.addMouseEvents();
		}
		
		public function get countBars(): uint {
			return this._countBars;
		}
		
		public function set countBars(value: uint): void {
			this.removeBars();
			this._countBars = value;
			this.addBars();
		}
		
		private function removeBars(): void {
			for (var i:uint = 0; i < this.countBars; i++) {
				var bar: ControllerSoundBar = this.arrBar[i];
				this.removeChild(bar);
			}
		}
		
		private function addBars(): void {
			this.arrBar = new Array(this.countBars);
			for (var i: uint = 0; i < this.countBars; i++) {
				var bar: ControllerSoundBar = new ControllerSoundBar();
				bar.x = this.marginSide + i * (bar.width + this.marginBetweenBars);
				var newHeightBar: Number = (this.ratioBarHeightSoundOff + (1 - this.ratioBarHeightSoundOff) * (i / Math.max(this.countBars - 1, 1))) * bar.height;
				bar.y = (this.hit.height - bar.height) / 2 + (bar.height - newHeightBar);
				bar.height = newHeightBar;
				this.addChild(bar);
				this.arrBar[i] = bar;
			}
			var totalWidthBars: Number = i * bar.width + (i - 1) * this.marginBetweenBars + 2 * this.marginSide;
			this.hit.width = totalWidthBars;
			this.setChildIndex(this.hit, this.numChildren - 1);
		}
		
		public function addMouseEvents(): void {
			this.buttonMode = true;
			this.addEventListener(Event.ADDED_TO_STAGE, this.addMouseEventsOnAddedToStage);
		}
		
		private function addMouseEventsOnAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addMouseEventsOnAddedToStage);
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
		}

		public function removeMouseEvents(): void {
			this.buttonMode = false;
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDownHandler);
			if (this.stage) this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUpHandler);
		}
		
		private function onMouseDownHandler(e: MouseEvent): void {
			if (this.stage) {
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				this.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
			}
		}
		
		private function onMouseUpHandler(e: MouseEvent = null): void {
			if (this.stage) this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
		}
		
		private function onMouseMoveHandler(e: MouseEvent): void {
			var i: uint = 0;
			var bar: ControllerSoundBar = this.arrBar[i];
			while ((i < this.arrBar.length) && (this.mouseX > bar.x)) {
				i++;
				bar = this.arrBar[i];
			}
			ModelVideoPlayer.volume = i / this.arrBar.length;
		}
		
		private function setVisibleBars(e: EventModelVideoPlayer): void {
			var volume: Number = Number(e.data);
			var numFirstBarWithVolume: uint = Math.floor(volume * this.arrBar.length);
			for (var i: uint = 0; i < this.countBars; i++) {
				var bar: ControllerSoundBar = this.arrBar[i];
				//bar.addRemoveTweenBrightness(uint(i < numFirstBarWithVolume));
				bar.addTweenColor([this.colorHide, this.colorVisible][uint(i < numFirstBarWithVolume)])
			}
		}
		
		public function destroy(e: Event = null): void {
			ModelVideoPlayer.removeEventListener(EventModelVideoPlayer.VOLUME_CHANGE, this.setVisibleBars);
			this.onMouseUpHandler();
			this.removeMouseEvents();
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addMouseEventsOnAddedToStage);
		}
		
	}
	
}