package base.types {
	
	public class Singleton extends Object {
		
        /*(function():void {
				trace("static constructor");
        })();*/
		
		public function Singleton(): void {
			throw new Error("cannot construct object");
		}
		
	}

}