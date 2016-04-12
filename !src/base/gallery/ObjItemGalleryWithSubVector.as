package base.gallery {
	
	public class ObjValueWithSubVector extends Object {
		
		public var sub: Vector.<ObjValueWithSubVector>;
		public var value: *;
		
		public function ObjValueWithSubVector(value: *, sub: Vector.<ObjValueWithSubVector> = null): void {
			this.value = value;
			this.sub = sub;
		}
		
	}

}