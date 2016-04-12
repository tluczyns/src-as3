package baseStarling.gallery {
 
	public class MultiFlowGallery extends MultiCircleGallery {
		
		public function MultiFlowGallery(arrData: Array = null, nameUnique: String = "", optionsController: OptionsControllerMulti = null, optionsVisual: OptionsVisualMulti = null): void {
			super(arrData, nameUnique, optionsController, optionsVisual);
		}
		
		override protected function createArrCountRenderableInRow(): void {
			super.createArrCountRenderableInRow();
			this.duplicateInArrLastCountRednerableRow(this.arrCountRenderableInRow);
		}
		
		private function duplicateInArrLastCountRednerableRow(arrCountRenderableInRow: Array): void {
			var lastCountRenderableInRow: * = arrCountRenderableInRow[arrCountRenderableInRow.length - 1];
			arrCountRenderableInRow.length = arrCountRenderableInRow.length + 1;
			if (lastCountRenderableInRow is Array) arrCountRenderableInRow[arrCountRenderableInRow.length - 1] = (lastCountRenderableInRow as Array).concat();
			for (var i:int = 0; i < arrCountRenderableInRow.length; i++) {
				var countRenderableInRow: * = arrCountRenderableInRow[i];
				if (countRenderableInRow is Array) this.duplicateInArrLastCountRednerableRow(countRenderableInRow as Array);
			}
		}
		
		override protected function getArrCountRenderableInRow(): Array {
			//return [new Array(2), new Array(1)]
			//return [new Array(2), new Array(2)];
			//return [new Array(new Array(2), new Array(6), new Array(6), new Array(3)), new Array(new Array(2), new Array(6), new Array(32)), new Array(new Array(2), new Array(6), new Array(3), new Array(3), new Array(3), new Array(3), new Array(3), new Array(3))];
			//return [new Array(3)];			
			return [new Array(3), new Array(3), new Array(3)];
			//return [new Array(5), new Array(4), new Array(5)];
		}
		
		override protected function initItem(item: MultiItemGallery): void {
			//if (this.optionsVisual.isAlphaManagement) item.alpha = 0;
		}
		
		override protected function get classRow(): Class {
			return MultiRowFlowGallery;
		}
		
	}

}