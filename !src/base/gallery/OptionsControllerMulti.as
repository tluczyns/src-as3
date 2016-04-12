package base.gallery {
	import base.service.ExternalInterfaceExt;
	
	public class OptionsControllerMulti extends Object {
		public var isSelectSingleOrAllInDimension: uint; 
		public var isArrow: Boolean; 
		public var isMouseWheel: Boolean;
		public var isHandleMouseWheelInternallyFromJS: uint;
		public var isSetMouseWheelOnStage: Boolean;
		public var isAutoChangeItem: Boolean;
		public var timeChangeItemFirstTime: uint;
		public var timeChangeItem: uint;
		
		public function OptionsControllerMulti(isSelectSingleOrAllInDimension: uint = 1, isArrow: Boolean = true, isMouseWheel: Boolean = true, isHandleMouseWheelInternallyFromJS: uint = 0, isSetMouseWheelOnStage: Boolean = true, isAutoChangeItem: Boolean = false, timeChangeItemFirstTime: uint = 5000, timeChangeItem: uint = 2500): void {
			this.isSelectSingleOrAllInDimension = isSelectSingleOrAllInDimension;
			this.isArrow = isArrow;
			this.isMouseWheel = isMouseWheel;
			this.isHandleMouseWheelInternallyFromJS = ExternalInterfaceExt.isBrowser ? isHandleMouseWheelInternallyFromJS : 0;
			this.isSetMouseWheelOnStage = isSetMouseWheelOnStage;
			this.isAutoChangeItem = isAutoChangeItem;
			this.timeChangeItemFirstTime = timeChangeItemFirstTime;
			this.timeChangeItem = timeChangeItem;
		}
		
	}

}