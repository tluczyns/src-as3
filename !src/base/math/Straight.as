package base.math {
	import flash.geom.Point;
	
	public class Straight extends Object {
		
		public var factorDirectional: Number;
		public var shift: Number;
		
		public function Straight(factorDirectional: Number, shift: Number): void {
			this.factorDirectional = factorDirectional;
			this.shift = shift;
		}
		
		static public function createStraightFromPoints(point1: Point, point2: Point): Straight {
			return new Straight((point2.y - point1.y) / (point2.x - point1.x), (point2.x * point1.y - point1.x * point2.y) / (point2.x - point1.x));
		}
		
		static public function calculatePointIntersectionOfTwoStraights(str1: Straight, str2: Straight): Point {
			return new Point((str2.shift - str1.shift) / (str1.factorDirectional - str2.factorDirectional), (str1.factorDirectional * str2.shift - str2.factorDirectional * str1.shift) / (str1.factorDirectional - str2.factorDirectional));
		}
		
		static public function calculateStraightPerpendicularToStraightAndPassingPoint(str: Straight, point: Point): Straight {
			var factorDirectional: Number = - 1 / str.factorDirectional;
			return new Straight(factorDirectional, point.y - factorDirectional * point.x);
		}
		
		static public function calculatePointIntersectionOfStraightAndStraightPerpendicularToStraightAndPassingPoint(str: Straight, point: Point): Point {
			return Straight.calculatePointIntersectionOfTwoStraights(str, Straight.calculateStraightPerpendicularToStraightAndPassingPoint(str, point));
		}
		
		
	}

}