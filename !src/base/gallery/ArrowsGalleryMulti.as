package base.gallery {
	import flash.display.Sprite;
	import flash.events.Event;
	import base.btn.BtnArrow;
	import base.btn.BtnHitEvent;
	import base.vspm.EventModel;
	
	public class ArrowsGalleryMulti extends Sprite {
		
		static public const ON_ARROWS_CLICKED: String = "onArrowsClicked";
		
		private var dimension: uint;
		protected var multiGallery: MultiCircleGallery;
		
		public var arrBtnArrowPrevNext: Array;
		
		public function ArrowsGalleryMulti(dimension: uint, multiGallery: MultiCircleGallery): void {
			this.dimension = dimension;
			this.multiGallery = multiGallery;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		private function onAddedToStage(e: Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.createArrBtnArrow();
		}
		
		private function createArrBtnArrow(): void {
			this.arrBtnArrowPrevNext = new Array(2);
			for (var i: uint = 0; i < this.arrBtnArrowPrevNext.length; i++) {
				var classBtnArrowPrevNext: Class = this.getClassForBtnArrowPrevNext();
				var btnArrowPrevNext: BtnArrow = new classBtnArrowPrevNext(i);
				btnArrowPrevNext.isEnabled = true;
				btnArrowPrevNext.addEventListener(BtnHitEvent.CLICKED, this.onBtnArrowClicked);
				this.addChild(btnArrowPrevNext);	
				this.arrBtnArrowPrevNext[i] = btnArrowPrevNext;
			}
			this.setPositionArrowsInit();
		}
		
		protected function getClassForBtnArrowPrevNext(): Class {
			return BtnArrow;
		}
		
		protected function setPositionArrowsInit(): void { }
		
		protected function setPositionArrowsOnItem(): void {}

		protected function onBtnArrowClicked(e: BtnHitEvent): void {
			this.dispatchEvent(new EventModel(ArrowsGalleryMulti.ON_ARROWS_CLICKED, {isPrevNext: BtnArrow(e.target).isPrevNext, dimension: this.dimension}));
		}
		
		private function removeArrBtnArrow(): void {
			for (var i: uint = 0; i < this.arrBtnArrowPrevNext.length; i++) {
				var btnArrowPrevNext: BtnArrow = this.arrBtnArrowPrevNext[i];
				btnArrowPrevNext.destroy();
				this.removeChild(btnArrowPrevNext);
				btnArrowPrevNext = null;
			}
			this.arrBtnArrowPrevNext = [];
		}
		
		public function destroy(): void {
			this.removeArrBtnArrow();
		}
		
	}

}