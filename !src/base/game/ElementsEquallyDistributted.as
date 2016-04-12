package base.game {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	public class ElementsEquallyDistributted extends Sprite {
		
		static private const VEC_NAME_COORDINATE: Vector.<String> = new <String>["x", "y", "z"];
		static private const VEC_NAME_DIMENSION: Vector.<String> = new <String>["width", "height"];
		
		private var vecValueDimension: Vector.<Number>;
		private var countDimensions: uint;
		private var vecCountUnit: Vector.<uint>;
		protected var vecElement: Vector.<DisplayObject>;
		private var vecValueUnit: Vector.<Number>;
		
		public function ElementsEquallyDistributted(vecValueDimension: Vector.<Number>, countElements: uint, countElementsPerUnit: uint = 1): void {
			if (!vecValueDimension || !vecValueDimension.length) throw new Error("no dimension");
			this.vecValueDimension = vecValueDimension;
			this.countDimensions = this.vecValueDimension.length;
			var countUnits: uint = Math.ceil(countElements / countElementsPerUnit);
			this.vecCountUnit = new Vector.<uint>(this.countDimensions);
			/*if (this.countDimensions == 1) {
				this.vecCountUnit[0] = countUnits;
			} else {*/
				for (var i: uint = 0; i < this.countDimensions; i++) {
					var multiplicationOtherDimensionValues: Number = 1;
					for (var j: uint = 0; j < this.countDimensions; j++)
						if (j != i) multiplicationOtherDimensionValues *= this.vecValueDimension[j];
						//trace(((this.vecValueDimension[i] * (this.countDimensions - 1)) / multiplicationOtherDimensionValues), 1 / this.countDimensions)
					this.vecCountUnit[i] = Math.max(Math.floor(Math.pow(countUnits * (Math.pow(this.vecValueDimension[i], this.countDimensions - 1) / multiplicationOtherDimensionValues), 1 / this.countDimensions)), 1);
				}
			//}
			countElementsPerUnit = Math.floor(countElements / countUnits);
			var countRestElements: uint = countElements - countElementsPerUnit * countUnits;
			this.vecElement = new <DisplayObject>[];
			this.vecValueUnit = new Vector.<Number>(this.countDimensions);
			var vecCurrIndexUnit: Vector.<int> = new Vector.<int>(this.countDimensions);
			for (i = 0; i < this.countDimensions; i++) {
				this.vecValueUnit[i] = this.vecValueDimension[i] / this.vecCountUnit[i];
				vecCurrIndexUnit[i] = -1;
			}
			this.iterateThroughUnitAndCreateAndSetPosElement(-1, vecCurrIndexUnit);
			for (i = 0; i < countRestElements; i++) {
				for (j = 0; j < this.countDimensions; j++) 
					vecCurrIndexUnit[j] = Math.floor(Math.random() * this.vecCountUnit[j])
				this.createAndSetPosElement(vecCurrIndexUnit);
			}
		}
		
		private function iterateThroughUnitAndCreateAndSetPosElement(currIndexDimension: int, vecCurrIndexUnit: Vector.<int>): void {
			currIndexDimension++;
			for (var i: uint = 0; i < this.vecCountUnit[currIndexDimension]; i++) {
				vecCurrIndexUnit[currIndexDimension] = i;
				if (currIndexDimension < this.countDimensions - 1)
					this.iterateThroughUnitAndCreateAndSetPosElement(currIndexDimension, vecCurrIndexUnit);
				else this.createAndSetPosElement(vecCurrIndexUnit);
			}
		}
		
		private function createAndSetPosElement(vecCurrIndexUnit: Vector.<int>): void {
			var element: DisplayObject = this.createElement();
			var dimensionElement: Number;
			for (var i: uint = 0; i < this.countDimensions; i++) {
				if (i < 2) dimensionElement = element[VEC_NAME_DIMENSION[i]];
				else dimensionElement = 0;
				element[VEC_NAME_COORDINATE[i]] = vecCurrIndexUnit[i] * this.vecValueUnit[i] + Math.random() * (this.vecValueUnit[i] - dimensionElement);
			}
			this.addChild(element);
			this.vecElement.push(element);
		}
		
		protected function createElement(): DisplayObject {
			return new Sprite();
		}
		
		override public function get width(): Number {
			return this.vecValueDimension[0];
		}
		
		override public function get height(): Number {
			var _height: Number;
			if (this.countDimensions > 1) _height = this.vecValueDimension[1];
			else _height = super.height;
			return _height;
		}
		
		public function get depth(): Number {
			var _depth: Number = 0;
			if (this.countDimensions > 2) _depth = this.vecValueDimension[2];
			return _depth;
		}
		
		public function destroy(): void {
			for (var i: uint = 0; i < this.vecElement.length; i++) {
				var element: DisplayObject = this.vecElement[i];
				this.removeChild(element);
				element = null;
			}
			this.vecElement = new <DisplayObject>[];
		}
		
	}

}