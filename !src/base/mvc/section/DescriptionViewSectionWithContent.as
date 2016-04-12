package base.mvc.section {
	import base.types.StringUtils;
	import flash.display.DisplayObjectContainer;

	public dynamic class DescriptionViewSectionWithContent extends DescriptionViewSection {
		
		public var content: ContentViewSection;
		
		public function DescriptionViewSectionWithContent(ind: String, className: Class, content: ContentViewSection, x: Number = 0, y: Number = 0, containerViewSection: DisplayObjectContainer = null): void {
			this.content = content;
			super(ind, className, x, y, containerViewSection);
		}
		
		override protected function createViewSectionInstance(): ViewSection {
			return new this.className(this.content);
		}
		
	}

}