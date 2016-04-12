package base.mvc.section {
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;

	public class DescriptionViewSection extends Object {
		
		public var ind: String;
		public var className: Class;
		public var x: Number;
		public var y: Number;
		public var containerViewSection: DisplayObjectContainer;
		public var viewSection: ViewSection;
		public var isEngaged: Boolean = false;
		
		public function DescriptionViewSection(ind: String, className: Class, x: Number = 0, y: Number = 0, containerViewSection: DisplayObjectContainer = null): void {
			this.ind = ind;
			this.className = className;
			this.x = x;
			this.y = y;
			this.containerViewSection = containerViewSection;
			this.viewSection = null;
		}
		
		protected function createViewSectionInstance(): ViewSection {
			return new this.className();
		}
		
		private function getContainerViewSection(): DisplayObjectContainer {
			return (this.containerViewSection != null) ? this.containerViewSection : ViewSectionManager.dspObjContainerSection;
		}
		
		public function createViewSection(): void {
			var containerViewSection: DisplayObjectContainer = this.getContainerViewSection();
			if (this.viewSection == null) {
				this.viewSection = this.createViewSectionInstance();
				this.viewSection.descriptionViewSection = this;
				this.viewSection.x = this.x;
				this.viewSection.y = this.y;
				containerViewSection.addChild(DisplayObject(this.viewSection));
				containerViewSection.setChildIndex(DisplayObject(this.viewSection), containerViewSection.numChildren - 1);
				this.viewSection.init();
			}
		}
		
		public function removeViewSection(): void {
			var containerViewSection: DisplayObjectContainer = this.getContainerViewSection();
			if (this.viewSection != null) {
				containerViewSection.removeChild(DisplayObject(this.viewSection));
				this.viewSection = null;
			}
		}
		
	}

}