package base.mvc.section {

	public class ControllerSectionDescription extends Object {
		
		public var className: Class;
		public var x: Number;
		public var y: Number;
		
		public function ControllerSectionDescription(className: Class, x: Number = 0, y: Number = 0) {
			this.className = className;
			this.x = x;
			this.y = y;
		}
		
	}

}