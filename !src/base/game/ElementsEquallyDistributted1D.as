package base.game {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	public class ElementsEquallyDistributted1D extends Sprite {
		
		private var _dimension: Number;
		private var vecElement: Vector.<DisplayObject>;
		private var dimensionUnit: Number;
		
		
		
		public function ElementsEquallyDistributted1D(dimension: Number, countElements: uint, countElementsPerUnit: uint = 1): void {
			this._dimension = dimension;
			
			
			var countUnits: uint = Math.ceil(countElements / countElementsPerUnit);
			
			
			countElementsPerUnit = Math.floor(countElements / countUnits);
			var countRestElements: uint = countElements - countElementsPerUnit * countUnits;
			this.vecElement = new <DisplayObject>[];
			this.dimensionUnit = this._dimension / countUnits;
			
			var i: uint;
			for (var numUnit: uint = 0; numUnit < countUnits; numUnit++) {
				
				for (i = 0; i < countElementsPerUnit; i++)
						this.createAndSetPosElement(numUnit);
						
			}
			for (i = 0; i < countRestElements; i++)
				this.createAndSetPosElement(Math.floor(Math.random() * countUnits));
		}
		
		private function createAndSetPosElement(numUnit: uint): void {
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
			return this._dimension;
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