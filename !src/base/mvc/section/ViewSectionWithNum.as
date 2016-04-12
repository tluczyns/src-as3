package base.mvc.section {
	import base.mvc.section.ViewSection;
	
	public class ViewSectionWithNum extends ViewSection {
		
		protected var num: uint;
		
		public function ViewSectionWithNum(num: uint): void {
			this.num = num;
		}
		
	}

}