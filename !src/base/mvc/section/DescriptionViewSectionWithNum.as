package base.mvc.section {
	import flash.display.DisplayObjectContainer;

	public class DescriptionViewSectionWithNum extends DescriptionViewSection {
		
		public var indBase: String;
		public var num: uint;
		
		public function DescriptionViewSectionWithNum(ind: String, className: Class, num: uint, x: Number = 0, y: Number = 0, containerViewSection: DisplayObjectContainer = null): void {
			this.indBase = ind;
			this.num = num;
			super(ind + String(this.num), className, 0, 0, containerViewSection);
		}
		
		override protected function createViewSectionInstance(): ViewSection {
			return new this.className(this.num);
		}
		
	}

}