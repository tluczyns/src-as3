package base.types {

	public class SingletonInstance extends Object {
		
		public static var instance: *;
		
		public function SingletonInstance(): void {
			if (!SingletonInstance.instance) SingletonInstance.instance = this;
			else throw new Error("cannot construct object");
		}
		
	}

}