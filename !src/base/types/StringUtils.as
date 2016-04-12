package base.types {

	public class StringUtils extends Object {
		
		public function StringUtils(): void {}
		
		static public function isEmail(str: String): Boolean {
			var posAt: int = str.indexOf("@");
			var countAt: uint = 0;
			while (posAt != -1) {
				posAt = str.indexOf("@", posAt + 1);
				countAt++;
			}
			posAt = str.indexOf("@");
			var posLastDot: int = str.lastIndexOf(".");
			var arrDomains: Array = ["ac", "ad", "ae", "af", "ag", "ai", "al", "am", "an", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bm", "bn", "bo", "br", "bs", "bt", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eo", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "me", "md", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sm", "sn", "sr", "st", "sv", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "uk", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "za", "zm", "zw", "tp", "su", "yu", "bu", "bx", "fl", "wa", "biz", "com", "edu", "gov", "info", "int", "mil", "name", "net", "org", "pro", "aero", "cat", "coop", "jobs", "museum", "travel", "mobi", "arpa", "root", "post", "tel", "cym", "geo", "kid", "kids", "mail", "safe", "sco", "web", "xxx"];
			return Boolean((countAt == 1) && (posAt > 0) && (posLastDot != -1) && (posLastDot > posAt + 1) && (posLastDot < str.length - 1) && (arrDomains.indexOf(str.substring(posLastDot + 1, str.length).toLowerCase()) != -1));
		}
		
		static public function moveOneLetterWordsToNewLine(str: String): String {
			var arrWord: Array = str.split(" ");
			var strModified: String = "";
			for (var i: uint = 0; i < arrWord.length; i++) {
				if (i != arrWord.length - 1) {
					if (arrWord[i].length == 1) strModified += (arrWord[i] + String.fromCharCode(160));//\u00A0
					else strModified += (arrWord[i] + " ");
				} else {
					strModified += arrWord[i];
				}
			}
			return strModified;
		}
		
		static public function toUpperFirstToLowerRestEachWord(str: String): String {
			return str.split(" ").map(function(strElement: String, i: int, array: Array): String {return StringUtils.toUpperFirstToLowerRest(strElement)}).join(" ");
		}
		
		static public function toUpperFirstToLowerRest(str: String): String {
			return str.substring(0, 1).toUpperCase() + str.substring(1, str.length).toLowerCase();
		}
		
		static public function toUpperFirst(str: String): String {
			return str.substring(0, 1).toUpperCase() + str.substring(1);
		}
		
		static public function toLowerFirst(str: String): String {
			return str.substr(0, 1).toLowerCase() + str.substr(1);
		}
		
		static public function isUpper(char: String): Boolean {
			return ("A" <= char) && (char <= "Z") ;
		};
		
		static public function isLower(char: String): Boolean {
			return ("A" <= char) && (char <= "Z") ;
		};

		static public function toUnderscoreFromUpperOrCamelCase(str: String): String {
			var returnStr: String = "";
			var char: String;
			for (var i:int = 0; i < str.length; i++) {
				char = str.charAt(i)
				if ((i > 0) && (StringUtils.isUpper(char))) returnStr += "_";
				returnStr += char.toLocaleUpperCase();
			}
			return returnStr;
		}
		
		static public function toUpperCaseFromUnderscore(str: String): String {
			return str.split("_").map(function(strElement: String, i: int, array: Array): String {return StringUtils.toUpperFirst(strElement)}).join("");
		}
		
		static public function toCamelCaseFromUnderscore(str: String): String {
			return str.split("_").map(function(strElement: String, i: int, array: Array): String {return (i == 0) ? StringUtils.toLowerFirst(strElement) : StringUtils.toUpperFirst(strElement)}).join("");
		}
		
		static public function removeMultipleSpaces(str: String): String {
			while (str.substr(0, 1) == " ") str = str.substring(1);
			while (str.indexOf("  ") != -1) str = str.split("  ").join(" ");
			while (str.substr(-1) == " ") str = str.substr(0, str.length - 1);
			return str;
		}
		
		static public function breakSentenceAndToUpperFirstToLowerRest(str: String): String {
			var arrWord: Array = str.split(" ");
			for (var i: uint = 0; i < arrWord.length; i++) {
				arrWord[i] = StringUtils.toUpperFirstToLowerRest(arrWord[i]);
			}
			return arrWord.join(" ")
		}
		
		static public function breakSentenceToLowerCaseUnderscore(str: String): String {
			var arrWord: Array = str.split(" ");
			for (var i: uint = 0; i < arrWord.length; i++) {
				arrWord[i] = String(arrWord[i]).toLowerCase();
			}
			return arrWord.join("_")
		}
		
		static public function getDigitArray(str: String): Array {
			var arrDigit: Array = new Array(str.length);
			for (var i: uint = 0; i < str.length; i++) {
				arrDigit[i] = Number(str.charAt(i));
			}
			return arrDigit;
		}
		
		static public function createStrPrice(amountPrice: Number): String {
			var strPrice: String = String(amountPrice).replace(".", ",")
			if (strPrice.indexOf(",") == -1) strPrice += ",";
			var posComma: uint = strPrice.indexOf(",");
			var countDigitsAfterComma: uint = strPrice.length - 1 - posComma;
			var precision: uint = 2;
			if (countDigitsAfterComma > precision) {
				strPrice = strPrice.substr(0, strPrice.length - (countDigitsAfterComma - precision));
			} else if (countDigitsAfterComma < precision) {
				for (var i: uint = countDigitsAfterComma; i < precision; i++) {
					strPrice += "0";
				}
			}
			return strPrice;
		}
		
		static public function isEmpty(str: String): Boolean {
			return ((str.valueOf() == "") || (str.valueOf() == "undefined") || (str.valueOf() == "null"));
		}
		
		static public function getFileExtension(nameFile: String): String {
			return nameFile.substr(nameFile.lastIndexOf(".") + 1);
		}
		
		static public function replace(str:String, p:*= null, repl:*= null): String {
			var strSrc: String;
			do {
				strSrc = str;
				str = strSrc.replace(p, repl);
			} while (str != strSrc);
			return str;
		}
		
		static public function depolonize(str: String): String {
			var arrFrom: Array = [" ", "-", ",", "'", "\"", "&", "#", "ą", "ę", "ł", "ó", "ć", "ś", "ń", "ż", "ź", "Ą", "Ę", "Ł", "Ó", "Ć", "Ś", "Ń", "Ż", "Ź"];
			var arrTo: Array =  ["_", "_", "_", "_", "_", "_", "_", "a", "e", "l", "o", "c", "s", "n", "z", "z", "A", "E", "L", "O", "C", "S", "N", "Z", "Z"];
			for (var i: uint = 0; i < arrFrom.length; i++) str = StringUtils.replace(str, arrFrom[i], arrTo[i]);
			return str;
		}
		
		public static function addZerosBeforeNumberAndReturnString(number: uint, digitCount: uint): String {
			var numberStr: String = String(number);
			while (numberStr.length < digitCount) {
				numberStr = "0" + numberStr;
			}
			return numberStr;
		}
		
	}

}