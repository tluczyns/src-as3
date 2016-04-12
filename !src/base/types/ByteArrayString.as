package base.types {
	import flash.utils.ByteArray;
	
    public class ByteArrayString extends ByteArray {

		public function ByteArrayString(str: String = "") {
			super();
			if ((str != "") && (str != null)) {
				this.writeMultiByte(str, "pl");
			}
		}
		
		public static function transformArrayStringToArrayByteArray(arrStr: Array): Array {
			var arrByteArrayString: Array = new Array(arrStr.length);
			for (var i: uint = 0; i < arrStr.length; i++) {
				arrByteArrayString[i] = ByteArrayString.transformStringToByteArray(arrStr[i]);
			}
			return arrByteArrayString;
		}
		
		public static function transformArrayStringToByteArray(arrStr: Array): ByteArrayString {
			var byteArrayString: ByteArrayString = new ByteArrayString();
			for (var i: uint = 0; i < arrStr.length; i++) {
				byteArrayString.writeMultiByte(arrStr[i], "pl");
			}
			return byteArrayString;
		}
		
		public static function transformStringToByteArray(str: String): ByteArrayString {
			return new ByteArrayString(str);
		}
		
		public static function fromCharCode(charCode: uint): ByteArrayString {
			var baChar: ByteArrayString = new ByteArrayString();
			baChar.writeByte(charCode);
			return baChar;
		}
		
		public function clone(): ByteArrayString {
			var str: String = "";
			for (var i: uint = 0; i < this.length; i++) {
				str += String.fromCharCode(this[i]);
			}
			return ByteArrayString.transformStringToByteArray(str);
		}
		
		public function equals(baToCompare: ByteArrayString): Boolean {
			var resEquals: Boolean;
			if (this.length != baToCompare.length) {
				resEquals = false;
			} else {
				var i: uint = 0;
				while ((i < this.length) && (this[i] == baToCompare[i])) i++;
				resEquals = (i == this.length);
			}
			return resEquals;
		}
		
		public function plus(baToAdd: ByteArrayString): ByteArrayString {
			var baSum: ByteArrayString = new ByteArrayString();
			baSum.writeBytes(this);
			baSum.writeBytes(baToAdd);
			return baSum;
		}
		
		public function plusEquals(baToAdd: ByteArrayString): void {
			this.writeBytes(baToAdd);
		}
		
		public function replace(baSearch: ByteArrayString, baReplace: ByteArrayString, countReplaces: int = 0): ByteArrayString {
			var resBa: ByteArrayString;
			var baEnd: ByteArrayString, baPre: ByteArrayString; 
			//if (baSearch.length == 1) {
			//	resBa = new ByteArrayString(this.split(baSearch).join(baReplace));
			//} else {
				var posBaSearch: int = this.indexOf(baSearch);
				if (posBaSearch == -1) {
					resBa = this;
				} else {
					resBa = new ByteArrayString();
					baEnd = this; 
					var numReplaces: uint = 0;
					do {
						posBaSearch = baEnd.indexOf(baSearch);
						baPre = baEnd.substring(0, posBaSearch);
						baEnd = baEnd.substring(posBaSearch + baSearch.length);
						resBa.plusEquals(baPre.plus(baReplace));
						numReplaces++;
					} while ((baEnd.indexOf(baSearch) != -1) && ((numReplaces < countReplaces) || (countReplaces == 0)));
					resBa.plusEquals(baEnd);
				}
			//}
			return resBa;
		}
		
		public function substring(startIndex: uint = 0, endIndex: uint = 0x7ffffff): ByteArrayString  {
			var baSubstr: ByteArrayString = new ByteArrayString();
			var length: int = endIndex - startIndex;
			if (length > 0) {
				if (length > this.length - startIndex) length = 0;
				baSubstr.writeBytes(this, startIndex, length);
			}
			return baSubstr;
		}
		
		public function substr(startIndex: uint = 0, length: uint = 0x7ffffff): ByteArrayString {
			var baSubstr: ByteArrayString = new ByteArrayString();
			if (length > 0) baSubstr.writeBytes(this, startIndex, length);
			return baSubstr;
		}
		
		public function indexOf(baSearch: ByteArrayString, startIndex: uint = 0): int {
			var ind: uint = startIndex;
			var indPrev: uint;
			var indBaSearch: uint;
			var resIndexOf: int = -1;
			while (ind < this.length) {
				indPrev = ind;
				indBaSearch = 0;
				while ((ind < this.length) && (indBaSearch < baSearch.length) && (this[ind] == baSearch[indBaSearch])) {
					ind++;
					indBaSearch++;
				}
				if (indBaSearch == baSearch.length) {
					resIndexOf = indPrev;
					ind = this.length;
				} else {
					ind = indPrev + 1;
				}
			}
			return resIndexOf;
		}
		
		public function split(delimiter: ByteArrayString): Array {
			this.position = 0;
			var arrSplit: Array = new Array();
			var indDelimiter: int = this.indexOf(delimiter, 0);
			if (indDelimiter == -1) {
				arrSplit.push(this);
			} else {
				arrSplit.push(this.substr(0, indDelimiter));
				var indNextDelimiter: int;
				while (indDelimiter != -1) {
					indNextDelimiter = this.indexOf(delimiter, indDelimiter + delimiter.length);
					if (indNextDelimiter == -1) {
						arrSplit.push(this.substring(indDelimiter + delimiter.length, this.length))
					} else {
						arrSplit.push(this.substring(indDelimiter + delimiter.length, indNextDelimiter))
					}
					indDelimiter = indNextDelimiter
				}
			}
			return arrSplit;
		}
		
		public function toLowerCase(): ByteArrayString {
			var baLowerCase: ByteArrayString = new ByteArrayString();
			for (var i: uint = 0; i < this.length; i++) {
				if ((this[i] >= 65) && (this[i] <= 90)) {
					baLowerCase.writeByte(this[i] + 32);
				} else {
					baLowerCase.writeByte(this[i]);
				}
			}
			return baLowerCase;
		}
		
		public function toUpperCase(): ByteArrayString {
			var baUpperCase: ByteArrayString = new ByteArrayString();
			for (var i: uint = 0; i < this.length; i++) {
				if ((this[i] >= 97) && (this[i] <= 122)) {
					baUpperCase.writeByte(this[i] - 32);
				} else {
					baUpperCase.writeByte(this[i]);
				}
			}
			return baUpperCase;
		}
		
	}
	
}
