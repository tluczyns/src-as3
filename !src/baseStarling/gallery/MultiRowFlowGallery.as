package baseStarling.gallery {
	import starling.display.Sprite;

	public class MultiRowFlowGallery extends MultiRowCircleGallery {
		
		public function MultiRowFlowGallery(funcGetNumInRowForRenderableSelected: Function, containerItem: Sprite, optionsVisual: OptionsVisualMulti, optionsController: OptionsControllerMulti): void {
			super(funcGetNumInRowForRenderableSelected, containerItem, optionsVisual, optionsController);
		}
		
		override public function setArrCountRenderableInRow(arrCountRenderableInRow: Array): void {
			this.vecNumInRow = new Vector.<uint>();
			this.arrCountRenderableInRow = arrCountRenderableInRow;
		}
		
		override protected function manageArrRenderableInRow(arrCountRenderableInRow: Array): void {
			//trace("manageArrRenderableInRow:", arrCountRenderableInRow.length, this.vecRenderableInRow.length, this.numRenderableFirst, this.vecNumInDimension)
			this.removeRenderableInRow(arrCountRenderableInRow)
			this.addRenderableInRow(arrCountRenderableInRow);
		}
		
		private function removeRenderableInRow(arrCountRenderableInRow: Array): void {
			this.arrCountRenderableInRow = arrCountRenderableInRow;
			var renderableInRow: IRenderable;
			var numInDimensionRenderableToRemove: uint;
			//trace("removeRenderableInRow:", arrCountRenderableInRow.length, this.vecRenderableInRow.length, this.numRenderableFirst, this.vecNumInDimension)
			for (var i: int = 0; i < this.vecRenderableInRow.length; i++) {
				renderableInRow = this.vecRenderableInRow[i];
				this.setNumInRowInRenderableInRow(renderableInRow, i);
				numInDimensionRenderableToRemove = renderableInRow.vecNumInDimension[this.vecNumInDimension.length];
				//trace("item:", this.numRenderableFirst, renderableInRow, i, numInDimensionRenderableToRemove, renderableInRow.vecNumInDimension);
				if (renderableInRow is MultiItemGallery) {
					if (!this.isRenderableInRow(numInDimensionRenderableToRemove, i)) {
						//trace("removeChild:", numInDimensionRenderableToRemove, i)
						if (this.containerItem.contains(MultiItemGallery(renderableInRow))) this.containerItem.removeChild(MultiItemGallery(renderableInRow));
						this.vecRenderableInRow.splice(i--, 1);
					}
				} else if (renderableInRow is MultiRowFlowGallery) {
					var arrCountRenderableInSubRow: Array = this.getArrCountRenderableInSubRow(numInDimensionRenderableToRemove, i);
					MultiRowFlowGallery(renderableInRow).removeRenderableInRow(arrCountRenderableInSubRow);
					if (arrCountRenderableInSubRow.length == 0) {
						//trace("remove row:", i, this.vecRenderableInRow)
						this.vecRenderableInRow.splice(i--, 1);
					}
				}
			}
		}
		
		override protected function isRenderableNotOnRightEdgeOfRow(numRenderableInRow: uint): Boolean {
			return ((numRenderableInRow < this.arrCountRenderableInRow.length - 1) || (this.timeControl % 1 > 0));
			//return (numRenderableInRow != MathExt.minDiff(this.timeControl, this.numRenderableFirst, this.arrCountRenderableInRow.length) + this.numInRowForRenderableSelected + 1);
		}
		
		private function getArrCountRenderableInSubRow(numRenderableInDimension: uint, numRenderableInRow: int = -1): Array {
			var arrCountRenderableInSubRow: Array;
			if (this.arrCountRenderableInRow.length == 0) arrCountRenderableInSubRow = [];
			else {
				if (numRenderableInRow > -1) {
					if ((this.isRenderableNotOnRightEdgeOfRow(numRenderableInRow))
					 &&	(numRenderableInDimension == (this.numRenderableFirst + numRenderableInRow) % this.vecRenderable.length)
					 && (((numRenderableInDimension >= this.numRenderableFirst) && (numRenderableInDimension < this.numRenderableFirst + this.arrCountRenderableInRow.length))
					  || (numRenderableInDimension < this.arrCountRenderableInRow.length - (this.vecRenderable.length - this.numRenderableFirst))))
						arrCountRenderableInSubRow = this.arrCountRenderableInRow[numRenderableInRow];
					else arrCountRenderableInSubRow = [];
				} else {
					if ((numRenderableInDimension >= this.numRenderableFirst) && (numRenderableInDimension < this.numRenderableFirst + this.arrCountRenderableInRow.length))
						arrCountRenderableInSubRow = this.arrCountRenderableInRow[numRenderableInDimension - this.numRenderableFirst];
					else if (numRenderableInDimension < this.arrCountRenderableInRow.length - (this.vecRenderable.length - this.numRenderableFirst))
						arrCountRenderableInSubRow = this.arrCountRenderableInRow[numRenderableInDimension + (this.vecRenderable.length - this.numRenderableFirst)];
				}
			}
			return arrCountRenderableInSubRow;
		}
		
		private function addRenderableInRow(arrCountRenderableInRow: Array): void {
			this.arrCountRenderableInRow = arrCountRenderableInRow;
			//trace("addRenderableInRow:", this.arrCountRenderableInRow.length, this.vecRenderableInRow.length, this.numRenderableFirst, this.vecNumInDimension)
			var renderableInRow: IRenderable;
			var numInDimensionRenderableToAdd: uint;
			for (var i: int = 0; i < this.vecRenderableInRow.length; i++) {
				renderableInRow = this.vecRenderableInRow[i];
				if (renderableInRow is MultiRowFlowGallery) {
					numInDimensionRenderableToAdd = renderableInRow.vecNumInDimension[this.vecNumInDimension.length];
					var arrCountRenderableInSubRow: Array = this.getArrCountRenderableInSubRow(numInDimensionRenderableToAdd, i);
					MultiRowFlowGallery(renderableInRow).addRenderableInRow(arrCountRenderableInSubRow);
				}
			}
			//zawsze  this.vecRenderableInRow.length <= arrCountRenderableInRow.length
			var countRenderableToAdd: int = this.arrCountRenderableInRow.length - this.vecRenderableInRow.length;
			if (countRenderableToAdd > 0) {
				var numCurrentFirstRenderableInRow: uint = (this.numRenderableFirst + countRenderableToAdd) % this.vecRenderable.length;
				var numCurrentLastRenderableInRow: int = this.numRenderableFirst - 1;
				if (this.vecRenderableInRow.length > 0) {
					renderableInRow = this.vecRenderableInRow[0];
					numCurrentFirstRenderableInRow = renderableInRow.vecNumInDimension[this.vecNumInDimension.length];
					renderableInRow = this.vecRenderableInRow[this.vecRenderableInRow.length - 1];
					numCurrentLastRenderableInRow = renderableInRow.vecNumInDimension[this.vecNumInDimension.length];
				}
				//trace("numCurrent:", numCurrentFirstRenderableInRow, numCurrentLastRenderableInRow)
				numInDimensionRenderableToAdd = numCurrentFirstRenderableInRow;
				var countRenderableToAddAtStart: uint;
				if (numInDimensionRenderableToAdd >= this.numRenderableFirst) countRenderableToAddAtStart = numInDimensionRenderableToAdd - this.numRenderableFirst;
				else countRenderableToAddAtStart = numInDimensionRenderableToAdd + (this.vecRenderable.length - this.numRenderableFirst);
				if (numInDimensionRenderableToAdd != this.numRenderableFirst) {
					for (i = 0; i < this.vecRenderableInRow.length; i++) { //tutaj raczej zawsze this.vecRenderableInRow.length równe jest 0
						renderableInRow = this.vecRenderableInRow[i];
						this.setNumInRowInRenderableInRow(renderableInRow, i + countRenderableToAddAtStart);
					}	
				}
				while (numInDimensionRenderableToAdd != this.numRenderableFirst) {
					numInDimensionRenderableToAdd = ((numInDimensionRenderableToAdd > 0) ? numInDimensionRenderableToAdd : this.vecRenderable.length) - 1;
					countRenderableToAddAtStart--;
					if (this.isRenderableNotOnRightEdgeOfRow(countRenderableToAddAtStart))
						this.vecRenderableInRow.unshift(this.addRenderable(numInDimensionRenderableToAdd, countRenderableToAddAtStart))
					countRenderableToAdd--;
				}
				numInDimensionRenderableToAdd = (numCurrentLastRenderableInRow < this.vecRenderable.length - 1) ? (numCurrentLastRenderableInRow + 1) : 0;
				while (countRenderableToAdd > 0) {
					if (this.isRenderableNotOnRightEdgeOfRow(this.vecRenderableInRow.length))
						this.vecRenderableInRow.push(this.addRenderable(numInDimensionRenderableToAdd, this.vecRenderableInRow.length));
					numInDimensionRenderableToAdd = (numInDimensionRenderableToAdd < this.vecRenderable.length - 1) ? (numInDimensionRenderableToAdd + 1) : 0;
					countRenderableToAdd--;
				}
			}
			//trace("kon add:", this.arrCountRenderableInRow.length, this.vecRenderableInRow.length); 
		}
		
		private function addRenderable(numInDimensionRenderableToAdd: uint, numRenderableInRow: uint): IRenderable {
			var renderableToAdd: IRenderable = this.vecRenderable[numInDimensionRenderableToAdd];
			this.setNumInRowInRenderableInRow(renderableToAdd, numRenderableInRow);
			if (renderableToAdd is MultiItemGallery) {
				//trace("addChild:", numInDimensionRenderableToAdd, numRenderableInRow)
				this.containerItem.addChild(MultiItemGallery(renderableToAdd));
				this.isForceRenderParentRow = true;
			} else if (renderableToAdd is MultiRowFlowGallery) {
				var arrCountRenderableInSubRow: Array = this.getArrCountRenderableInSubRow(numInDimensionRenderableToAdd, numRenderableInRow);
				//trace("add row:", numInDimensionRenderableToAdd, numRenderableInRow)
				MultiRowFlowGallery(renderableToAdd).addRenderableInRow(arrCountRenderableInSubRow);
			}
			return renderableToAdd;
		}
		
		override public function dispose(): void {
			super.dispose();
		}
		
	}

}