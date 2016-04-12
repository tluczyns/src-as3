package base {

	public class AsBroadcaster extends Object {

		public var _listeners:Array;
		
		public function AsBroadcaster() {
			this._listeners = new Array();	
		}
		
		public function addListener(o:Object): Number {
			this.removeListener(o);
			return this._listeners.push(o);
		}
		
		public function removeListener(o:Object): Boolean {
			var a:Array = this._listeners;	
			var i:Number = a.length;
			while (i--) {
				if (a[i] == o) {
					a.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		public function broadcastMessage(): void {
			var e:String = String(arguments.shift());
			var a:Array = this._listeners.concat();
			var l:Number = a.length;
			for (var i: uint = 0; i < l; i++) a[i][e].apply(a[i], arguments);
		}

	}

}
