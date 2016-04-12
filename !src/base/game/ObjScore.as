package base.game {
	import com.hurlant.util.Base64;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class ObjScore extends Object {
	
		private var lengthArr: uint;
		private var isInit: Boolean;
		private var _value: String;
		private var arrValue: Array;
		private var classValue: Class;
		
		public function ObjScore(value: * = 0, lengthArr: uint = 50): void {
			this.lengthArr = lengthArr;
			this.isInit = true;
			this.value = value;
		}
		
		//sprawdza tablicę dla danej wartości i zapętla aplikację, jeżeli ktoś będzie grzebał w pamięci
		private function checkAndSetBigArrayForResultPoints(arr: Array, value: String): Array {
			if (this.isInit) {
				arr = new Array(this.lengthArr);
				this.isInit = false;
			} else {
				for (var i:uint = 0; i < arr.length; i++)
					if (i > 0) if (arr[i] != arr[i - 1]) while(1) {};
			}
			for (i = 0; i < arr.length; i++) {
				arr[i] = value;
			}
			return arr;
		}
		
		public function get value(): * {
			return this.classValue(Base64.decode(this._value));
		}
		
		public function set value(value: * ): void {
			this.classValue = Class(getDefinitionByName(getQualifiedClassName(value)));
			this._value = Base64.encode(String(value));
			this.arrValue = this.checkAndSetBigArrayForResultPoints(this.arrValue, this._value);
		}		
		
	}

}