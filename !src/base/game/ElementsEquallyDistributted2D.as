package base.game {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	public class ElementsEquallyDistributted2D extends Sprite {
		
		private var _width: Number;
		private var _height: Number;
		private var vecElement: Vector.<DisplayObject>;
		private var dimensionColumn: Number;
		private var dimensionRow: Number;
		
		public function ElementsEquallyDistributted2D(width: Number, height: Number, countElements: uint, countElementsPerUnit: uint = 1): void {
			this._width = width;
			this._height = height;
			
			var countUnits: uint = Math.ceil(countElements / countElementsPerUnit);
			var countUnitsColumns: uint = Math.max(Math.floor(Math.pow(countUnits / (height / width), 0.5)), 1);
			var countUnitsRows: uint = Math.max(Math.floor(countUnits / countUnitsColumns), 1);
			/*for 3D
			var countUnitsDepth: uint = Math.max(Math.floor(Math.pow(countUnits * ((depth * 2) / (width * height)), 0.33)), 1);
			var countUnitsColumns: uint = Math.max(Math.floor(Math.pow(countUnits * ((width * 2) / (height * depth)), 0.33)), 1);
			var countUnitsRows: uint = Math.max(Math.floor(countUnits / countUnitsColumns), 1);*/
			countElementsPerUnit = Math.floor(countElements / countUnits);
			var countRestElements: uint = countElements - countElementsPerUnit * countUnits;
			this.vecElement = new <DisplayObject>[];
			this.dimensionColumn = this.width / countUnitsColumns;
			this.dimensionRow = this.height / countUnitsRows;
			var i: uint;
			for (var numColumn: uint = 0; numColumn < countUnitsColumns; numColumn++) {
				for (var numRow: uint = 0; numRow < countUnitsRows; numRow++) {
					for (i = 0; i < countElementsPerUnit; i++)
						this.createAndSetPosElement(numColumn, numRow);
				}
			}
			for (i = 0; i < countRestElements; i++)
				this.createAndSetPosElement(Math.floor(Math.random() * countUnitsColumns), Math.floor(Math.random() * countUnitsRows));
		}
		
		private function createAndSetPosElement(numColumn: uint, numRow: uint): void {
			var element: DisplayObject = this.createElement();
			element.x = numColumn * this.dimensionColumn + Math.random() * (this.dimensionColumn - element.width);
			element.y = numRow * this.dimensionRow + Math.random() * (this.dimensionRow - element.height);
			this.addChild(element);
			this.vecElement.push(element);
		}
		
		protected function createElement(): DisplayObject {
			return new Sprite();
		}
		
		override public function get width(): Number {
			return this._width;
		}
		
		override public function get height(): Number {
			return this._height;
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