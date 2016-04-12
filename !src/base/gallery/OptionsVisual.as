package base.gallery {
	
	public class OptionsVisual extends Object {

		public var isDepthManagement: Boolean;
		public var isAlphaManagement: Boolean;
		public var timeMoveOneItem: Number;
		
		public function OptionsVisual(isDepthManagement: Boolean = true, isAlphaManagement: Boolean = true, timeMoveOneItem: Number = 0.4): void {
			this.isDepthManagement = isDepthManagement;
			this.isAlphaManagement = isAlphaManagement;
			this.timeMoveOneItem = timeMoveOneItem;
		}
		
	}

}