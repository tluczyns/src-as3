package base.math {
	import flash.geom.Point;
	
    public class MathExt {

		public static const TO_RADIANS:Number = Math.PI / 180;
		public static const TO_DEGREES:Number = 180 / Math.PI;
		
    	public static function getSign(number: Number):Number {
    		if (number == 0) return 1;
    		else return number / Math.abs(number);
    	}
		
		//floorRange(13.5, 4) = 12, floorRange(-7.3, 5) = -10
		static public function floorRange(val: Number, range: Number): Number {
			return Math.floor(val / range) * range;
		}

		//moduloRangePositive(-7.3, 5) = 2.7, moduloRangePositive(8, 5) = 3
		static public function moduloPositive(val: Number, range: Number): Number {
			return val - MathExt.floorRange(val, range);
		}
    	
		//moduloOnePositive(5.25) = 0.25, moduloOnePositive(-5.25) = 0.75
		static public function moduloOnePositive(val: Number): Number {
			return val - Math.floor(val);
		}
		
    	public static function randomBool():Boolean {
             return (Math.random() > 0.5);    	
    	}
		
		public static function getDigitArray(number: uint): Array {
			var lengthNumber: Number = String(Math.floor(number)).length;
			var arrDigit: Array = new Array(lengthNumber);
			for (var i: uint = 0; i < lengthNumber; i++) {
				arrDigit[i] = Math.floor(number / (Math.pow(10, lengthNumber - i - 1))) % 10
			}
			return arrDigit;
		}
		
		public static function distanceBetweenTwoPoints(point1: Point, point2: Point): Number {
			return Math.pow(Math.pow(point1.x - point2.x, 2) + Math.pow(point1.y - point2.y, 2), 0.5);
		}
		
		//ró¿nica k¹tów ze znakiem (stopnie)
		public static function getAngleSmallestDifference(angle1: Number, angle2: Number): Number {
			var diff: Number;
			angle1 = (angle1 + 360) % 360;
			angle2 = (angle2 + 360) % 360;
			if (Math.abs(angle1 - angle2) > 180) {
				if (angle1 < 180) { //angle2 jest wiêksze od 180
					diff = - (angle1 + (360 - angle2));
				} else { //angle1 jest wiêksze od 180
					diff = angle2 + (360 - angle1);
				}
			} else {
				diff = angle2 - angle1;
			}
			return diff;
		}
		
		//ró¿nica k¹tów bezwzglêdna (radiany)
		static public function minDiffAngle(angle1: Number, angle2: Number): Number {
			angle1 = (angle1 + (Math.PI * 2)) % (Math.PI * 2);
			angle2 = (angle2 + (Math.PI * 2)) % (Math.PI * 2);
			return MathExt.minDiff(angle1, angle2, Math.PI * 2);
		}
		
		
		//2 minDiff 7 w range 8 = 3
		static public function minDiff(val1: Number, val2: Number, range: Number): Number {
			var diff: Number = Math.abs(val1 - val2) % range;
			return Math.min(diff, range - diff);
		}
		
		//2 minDiffWithSign 7 w range 8 = -3, 0 minDiffWithSign 1.25 w range 1.5 = 0.25
		static public function minDiffWithSign(val1: Number, val2: Number, range: Number): Number {
			var diff:Number = (val1 - val2) % range;
			if (diff != diff % (range / 2))
				diff = ((diff < 0) ? diff + range : diff - range) % range;
			return diff;
		}
		
		//roundPrecision(1.95583, 2);  // 1.96
		public static function roundPrecision(val: Number, precision: int): Number {
			var powPrecision: Number = Math.pow(10, precision);
			return (Math.round(val * powPrecision) / powPrecision);
		}
		
		public static function equals(val1: Number, val2: Number, precision: int): Boolean {
			return Boolean(MathExt.roundPrecision(val1, precision) == MathExt.roundPrecision(val2, precision));
		}
		
		public static function equalsWithMarginError(val1: Number, val2: Number, marginError: Number): Boolean {
			return (Math.abs(val1 - val2) < marginError);
		}
		
		
		//d³ugoœæ przeciwprostok¹tnej
		public static function hypotenuse(leg1: Number, leg2: Number): Number {
			return Math.pow(Math.pow(leg1, 2) + Math.pow(leg2, 2), 0.5);
		}
	/*	
		public static function getClosestDistantPointToElipse(elipse: Point, elipseCenterPoint: Point): Point {
			return Math.pow(Math.pow(leg1, 2) + Math.pow(leg2, 2), 0.5);
		}*/
		
		public static function polarToCartesian(radius:Number, angle:Number):Point {
			return new Point(radius * Math.cos(angle * Math.PI / 180), radius * Math.sin(angle * Math.PI / 180));
		}
		
		//numChannel; 0-alpha, 1-red, 2-green, 3-blue
		public static function extractChannel(color: uint, numChannel: uint = 0): Number {
			var channel: Number = (color >> ((3 - numChannel) * 8)) & 0xFF;
			if (numChannel == 0) channel = (channel || 0xFF) / 255; //alpha równe 0 to jest 1;
			return channel;
		}
		
		static public function splitRGB(color: uint): Array {			
			return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff];
		}
		
		static public function joinRGB(arrChannel: Array): uint {			
			return arrChannel[0] << 16 | arrChannel[1] << 8 | arrChannel[2];
		}
		
		static public function convertColorHTMLToUint(colorHTML: String): uint {
			return uint(colorHTML.replace("#", "0x"));
		}
		
		static public function addZerosBeforeNumberAndReturnString(number: *, digitCount: uint): String {
			var numberStr: String = String(number);
			while (numberStr.length < digitCount) {
				numberStr = "0" + numberStr;
			}
			return numberStr;
		}
		
		static public function convertColorUintToHTML(color: uint) : String {
            var arrRGBColor: Array = MathExt.splitRGB(color);
            var colorHTML: String = "#";
			for (var i:int = 0; i < arrRGBColor.length; i++) colorHTML += MathExt.addZerosBeforeNumberAndReturnString(uint(arrRGBColor[i]).toString(16), 2);
            return colorHTML;
        }
		
		static public function log2(val: Number): Number {
			return Math.log(val) * Math.LOG2E;
		}
		
		static public function log10(val: Number): Number {
			return Math.log(val) * Math.LOG10E;
		}
		
    }
}