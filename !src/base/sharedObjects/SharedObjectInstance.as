package base.sharedObjects {
	import flash.net.SharedObject;
	
	public class SharedObjectInstance extends Object {
		
		protected var so: SharedObject;
		
		public function SharedObjectInstance(soName: String): void {
			if (soName) this.so = SharedObject.getLocal(soName, "/");
		}
			
		public function setPropValue(propName: String, propValue: *): Boolean {
			if (this.so != null) {
				this.so.data[propName] = propValue;
				this.so.flush();
				return true;
			} return false;
		}
		
		public function getPropValue(propName: String, defaultValue: * = undefined): * {
			return ((this.so != null) && (this.so.data[propName])) ? this.so.data[propName] : defaultValue;
		}
		
		public function clear(): void {
			this.so.close();
		}
		
		public function close(): void {
			this.so.flush();
			this.so.close();
		}
		
	}

}