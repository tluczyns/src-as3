package baseStarling.vspm {
	import starling.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	//import base.types.DictionaryExt;

	public class DescriptionViewSection extends DescriptionView {
		
		public var indBase: String;
		public var num: int;
		public var isEngaged: Boolean = false;
		
		public function DescriptionViewSection(ind: String, nameClass: Class, content: ContentViewSection, num: int, x: Number = 0, y: Number = 0, container: DisplayObjectContainer = null): void {
			super(ind + ((num == -1) ? "" : String(num)), nameClass, content, x, y, container);
			this.indBase = ind;
			this.num = num;
		}
		
		override protected function getDictDescriptionViewInManager(): Dictionary { //DictionaryExt
			return ManagerSection.dictDescriptionViewSection;
		}
		
		override protected function createViewInstance(): View { //ViewSection
			return new this.nameClass(this.content, this.num);
		}
		
		override protected function getDefaultContainerView(): DisplayObjectContainer {
			return ManagerSection.dspObjContainerSection;
		}
		
	}

}