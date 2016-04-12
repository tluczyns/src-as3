package base.mvc.section {
	import flash.display.DisplayObjectContainer;

	public class DescriptionViewSectionWithContentAndNum extends DescriptionViewSectionWithContent {
		
		public var indBase: String;
		public var num: uint;
		
		public function DescriptionViewSectionWithContentAndNum(ind: String, className: Class, content: ContentViewSection, num: uint, x: Number = 0, y: Number = 0, containerViewSection: DisplayObjectContainer = null): void {
			this.indBase = ind;
			this.num = num;
			super(ind + String(num), className, content, x, y, containerViewSection);
		}
		
		override protected function createViewSectionInstance(): ViewSection {
			return new this.className(this.content, this.num);
		}
		
	}

}