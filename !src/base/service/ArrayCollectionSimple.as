package base.service {
	import flash.utils.Proxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	public class ArrayCollectionSimple extends Proxy implements IExternalizable {
		
		public var source;
		
		public function ArrayCollectionSimple() {
			super();
		}
		
		public function readExternal(input:IDataInput): void  {
			this.source = input.readObject() as Array;
		}
		
        public function writeExternal(output:IDataOutput): void {
			output.writeObject(source);
		}
		
	}

}