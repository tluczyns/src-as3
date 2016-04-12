package baseStarling.gallery {
	
	public class OptionsController extends Object {

		public var isArrow: Boolean; 
		public var isMouseMove: Boolean;
		public var isSwipe: Boolean;
		public var isAutoChangeItem: Boolean;
		public var isSetSwipeOnStage: Boolean;
		public var timeChangeItemFirstTime: uint;
		public var timeChangeItem: uint;
		
		public function OptionsController(isArrow: Boolean = false, isSwipe: Boolean = true, isSetSwipeOnStage: Boolean = false, isMouseMove: Boolean = false,  isAutoChangeItem: Boolean = false, timeChangeItemFirstTime: uint = 5000, timeChangeItem: uint = 2500): void {
			this.isArrow = isArrow;
			this.isSwipe = isSwipe;
			this.isSetSwipeOnStage = isSetSwipeOnStage;
			this.isMouseMove = isMouseMove;
			this.isAutoChangeItem = isAutoChangeItem;
			this.timeChangeItemFirstTime = timeChangeItemFirstTime;
			this.timeChangeItem = timeChangeItem;
		}
		
	}

}