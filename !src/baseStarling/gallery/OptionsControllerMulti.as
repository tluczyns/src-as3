package baseStarling.gallery {
	
	public class OptionsControllerMulti extends Object {
		public var isSelectSingleOrAllInDimension: uint; 
		public var isArrow: Boolean; 
		public var isSwipe: Boolean;
		public var isSetSwipeOnStage: Boolean;
		public var isAutoChangeItem: Boolean;
		public var timeChangeItemFirstTime: uint;
		public var timeChangeItem: uint;
		
		public function OptionsControllerMulti(isSelectSingleOrAllInDimension: uint = 1, isArrow: Boolean = true, isSwipe: Boolean = true, isSetSwipeOnStage: Boolean = true, isAutoChangeItem: Boolean = false, timeChangeItemFirstTime: uint = 5000, timeChangeItem: uint = 2500): void {
			this.isSelectSingleOrAllInDimension = isSelectSingleOrAllInDimension;
			this.isArrow = isArrow;
			this.isSwipe = isSwipe;
			this.isSetSwipeOnStage = isSetSwipeOnStage;
			this.isAutoChangeItem = isAutoChangeItem;
			this.timeChangeItemFirstTime = timeChangeItemFirstTime;
			this.timeChangeItem = timeChangeItem;
		}
		
	}

}