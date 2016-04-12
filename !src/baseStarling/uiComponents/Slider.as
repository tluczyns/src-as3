package baseStarling.uiComponents {
	import baseStarling.btn.BtnHitAndBlockWithEvents;
	import starling.display.DisplayObject;
	import baseStarling.btn.EventBtnHit;
	import starling.display.Shape;
	import starling.events.Event;
	
	public class Slider extends BtnHitAndBlockWithEvents {
		
		static public const POSITION_CHANGED: String = "sliderPositionChanged";
		
		protected var track: DisplayObject;
		protected var thumb: DisplayObject;

		private var nameCoordinateMove: String;
		private var nameCoordinateStatic: String;
		protected var nameDimensionMove: String;
		private var nameDimensionStatic: String;
		protected var marginThumb: Number;
		private var _dimensionMove: Number;
		private var _position: Number
		
		
		public function Slider(isHorizontalVertical: uint, dimensionMove: Number = 100, marginThumb: Number = 5): void {
			this.nameCoordinateMove = ["x", "y"][isHorizontalVertical];
			this.nameCoordinateStatic = ["y", "x"][isHorizontalVertical];
			this.nameDimensionMove = ["width", "height"][isHorizontalVertical];
			this.nameDimensionStatic = ["height", "width"][isHorizontalVertical];
			this.marginThumb = marginThumb;
			this.createElements();
			this.initElements();
			super(null, true);
			this.dimensionMove = dimensionMove;
			this.addThumbEvents();
		}
		
		protected function createElements(): void {
			this.track = this.createTrack();
			this.thumb = this.createThumb();
		}
		
		protected function createTrack(): DisplayObject {
			var track: Shape = new Shape();
			track.graphics.beginFill(0x000000, 0.3);
			track.graphics.drawRect(0, 0, 15, 1);
			track.graphics.endFill();
			return track;
		}
		
		protected function removeTrack(): void {
			this.removeChild(this.track);
			this.track.dispose();
			this.track = null;
		}
		
		protected function createThumb(): DisplayObject {
			var thumb: Shape = new Shape();
			thumb.graphics.beginFill(0x000000, 1);
			thumb.graphics.drawRect(0, 0, 10, 30);
			thumb.graphics.endFill();
			return thumb;
		}
		
		protected function removeThumb(): void {
			this.removeChild(this.thumb);
			this.thumb.dispose();
			this.thumb = null;
		}
		
		protected function initElements(): void {
			this.addChild(this.track);
			this.addChild(this.thumb);
			this.track[this.nameCoordinateStatic] = this.thumb[this.nameCoordinateStatic] + (this.thumb[this.nameDimensionStatic] - this.track[this.nameDimensionStatic]) / 2;
		}
		
		protected function removeElements(): void {
			this.removeThumb();
			this.removeTrack();
		}
		
		protected function addThumbEvents(): void {
			this.useHandCursor = true;
			this.addEventListener(EventBtnHit.OVER, this.onOverOrMoved);
			this.addEventListener(EventBtnHit.MOVED, this.onOverOrMoved);
		}
		
		protected function removeThumbEvents(): void {
			this.useHandCursor = false;
			this.removeEventListener(EventBtnHit.OVER, this.onOverOrMoved);
			this.removeEventListener(EventBtnHit.MOVED, this.onOverOrMoved);
		}
		
		private function onOverOrMoved(e: EventBtnHit): void {
			this.position = this.getPositionFromLocationTouch();
			//this.position -= e.delta * 4
		}
		
		private function getPositionFromLocationTouch(): Number {
			var posLocationTouch: Number = this.pointLocationTouch[this.nameCoordinateMove];
			var halfOfDimensionThumbPlusMargin: Number = this.thumb[this.nameDimensionMove] / 2 + this.marginThumb;
			posLocationTouch = Math.max(halfOfDimensionThumbPlusMargin, Math.min(posLocationTouch, this.dimensionMove - halfOfDimensionThumbPlusMargin));
			var precision: Number = 1000;
			if (this.dimensionMove - (halfOfDimensionThumbPlusMargin * 2) == 0) return 0;
			else return Math.min(Math.max(0, Math.round((posLocationTouch - halfOfDimensionThumbPlusMargin) / (this.dimensionMove - (halfOfDimensionThumbPlusMargin * 2)) * precision) / precision), 1);
		}
		
		protected function get position(): Number {
			return _position;
		}
		
		protected function set position(value: Number): void {
			this._position = value;
			this.dispatchEvent(new Event(Slider.POSITION_CHANGED, false, value));
			this.updatePosThumb();
		}
		
		protected function get dimensionMove(): Number {
			return this._dimensionMove;
		}
		
		protected function set dimensionMove(value: Number): void {
			this._dimensionMove = value;
			this.track[this.nameDimensionMove] = value;
			this.updatePosThumb();
		}
		
		protected function updatePosThumb(): void {
			this.thumb[this.nameCoordinateMove] = this.marginThumb + this.position * Math.max(this.dimensionMove - (this.thumb[this.nameDimensionMove] + this.marginThumb * 2), 0);
		}
	
		override public function set width(value: Number): void {}
		override public function set height(value: Number): void {}
		
		override public function dispose(): void {
			this.removeThumbEvents();
			this.removeElements();
			super.dispose();
		}
		
	}

}