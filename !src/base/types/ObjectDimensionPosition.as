package base.types {
	import flash.display.DisplayObject;

	public class ObjectDimensionPosition extends ObjectExt {
		
		public var x: Number;
		public var y: Number;
		public var width: Number;
		public var height: Number;
		
		public function ObjectDimensionPosition(x: Number = 0, y: Number = 0, width: Number = 0, height: Number = 0) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
	
		public function applyToDspObj(dspObj: DisplayObject): void {
			dspObj.x = this.x;
			dspObj.y = this.y;
			dspObj.width = this.width;
			dspObj.height = this.height;
		}
		
		override public function clone2(): * {
			var newObjectDimensionPosition: ObjectDimensionPosition = new ObjectDimensionPosition(this.x, this.y, this.width, this.height);
			return newObjectDimensionPosition;
		}
		
		public function toString(): String {
			return String("x: " + this.x + ", y:" + this.y + ", width:" + this.width + ", height:" + this.height);
		}
		
	}
	
}