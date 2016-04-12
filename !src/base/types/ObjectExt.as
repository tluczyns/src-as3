package base.types {
	
	public dynamic class ObjectExt extends Object {
		
		public function ObjectExt(srcObj: Object = null): void { 
			if (srcObj) this.clone(srcObj);
		}
		
		public function clone(srcObj: Object): void {
			for (var i: String in srcObj) {
				this[i] = srcObj[i];
			}
		}
		
		public function clone2(): * {
			var newObjectExt: ObjectExt = new ObjectExt();
			for (var i: String in this) {
				newObjectExt[i] = this[i];
			}
			return newObjectExt;
		}
		
	}
	
}