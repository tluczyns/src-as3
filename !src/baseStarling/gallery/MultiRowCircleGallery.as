package baseStarling.gallery {
	import flash.events.EventDispatcher;
	import starling.display.Sprite;
	import base.math.MathExt;
	import com.greensock.TweenMax;
	
	public class MultiRowCircleGallery extends EventDispatcher implements IRenderable {
		
		private var funcGetNumInRowForRenderableSelected: Function;
		private var isFirstTimeSetNumSelected: Boolean;
		private var _numSelected: int;
		private var _vecNumInDimension: Vector.<uint>;
		public var vecRenderable: Vector.<IRenderable>;
		
		private var timeTotal: Number;
		private var _timeControl : Number = 0;
		
		private var _arrCountRenderableInRow: Array;
		protected var vecRenderableInRow: Vector.<IRenderable>;
		internal var numInRowForRenderableSelected: int;
		private var _vecNumInRow: Vector.<uint>;
		protected var numRenderableFirst: uint;
		
		public var parentRow: MultiRowCircleGallery;
		protected var isForceRenderParentRow: Boolean = false;
		
		protected var containerItem: Sprite;
		private var optionsVisual: OptionsVisualMulti;
		private var optionsController: OptionsControllerMulti;
		
		public function MultiRowCircleGallery(funcGetNumInRowForRenderableSelected: Function, containerItem: Sprite, optionsVisual: OptionsVisualMulti, optionsController: OptionsControllerMulti): void {
			this.funcGetNumInRowForRenderableSelected = funcGetNumInRowForRenderableSelected;
			this._numSelected = -1;
			this._arrCountRenderableInRow = [];
			this.vecRenderable = new Vector.<IRenderable>();
			this.vecRenderableInRow = new Vector.<IRenderable>();
			this.containerItem = containerItem;
			this.optionsVisual = optionsVisual;
			this.optionsController = optionsController;
		}
		
		public function initAfterSetVecRenderable(vecNumInDimension: Vector.<uint>): void {
			this._vecNumInDimension = vecNumInDimension;
			this.timeTotal = this.vecRenderable.length;
			this.isFirstTimeSetNumSelected = true;
		}
		
		public function setArrCountRenderableInRow(arrCountRenderableInRow: Array): void {
			this.vecNumInRow = new Vector.<uint>();
			this.arrCountRenderableInRow = arrCountRenderableInRow;
			this.vecRenderableInRow.length = this.vecRenderable.length;
			var renderableInRow: IRenderable;
			for (var i: uint = 0; i < this.vecRenderable.length; i++) {
				renderableInRow = this.vecRenderable[i];
				this.vecRenderableInRow[i] = renderableInRow;
				if (renderableInRow is MultiRowCircleGallery)
					MultiRowCircleGallery(renderableInRow).setArrCountRenderableInRow(this.arrCountRenderableInRow[i]);
				else if (renderableInRow is MultiItemGallery)
					this.containerItem.addChild(MultiItemGallery(renderableInRow));
			}
		}
		
		/*public function selectPrevNextItem(isPrevNext: uint): void {
			if (isPrevNext == 0) this.numSelected = (this.numSelected > 0) ? this.numSelected - 1 : this.vecRenderable.length - 1;
			else if (isPrevNext == 1) this.numSelected = (this.numSelected < this.vecRenderable.length - 1) ? this.numSelected + 1 : 0;
		}*/
		
		public function get numSelected(): int {
			return this._numSelected;
		}
		
		public function set numSelected(value: int): void {
			//trace("numSelected:", value, this._numSelected, this.numInRowForRenderableSelected, this.vecNumInDimension, this.vecRenderable.length)
			//if ((this._numSelected != -1) && (this.vecRenderable[this._numSelected] is MultiItemGallery)) MultiItemGallery(this.vecRenderable[this._numSelected]).selected = false;
			this._numSelected = value;
			//if (this.vecRenderable[this._numSelected] is MultiItemGallery) MultiItemGallery(this.vecRenderable[this._numSelected]).selected = true;	
			var timeNumSelected: Number = MathExt.moduloPositive(value, this.timeTotal);
			var diffTimeGlobal: Number = MathExt.minDiffWithSign(timeNumSelected, this._timeControl, this.timeTotal);
			TweenMax.to(this, this.isFirstTimeSetNumSelected ? 0 : Math.max(this.optionsVisual.timeMoveOneRenderable, Math.pow(Math.abs(diffTimeGlobal) * this.optionsVisual.timeMoveOneRenderable, 0.5)), {timeControl: this._timeControl + diffTimeGlobal, ease: this.optionsVisual.easeMoveRenderables});
			//trace("tween timeControl:", this._timeControl, timeNumSelectedNormalized, diffTimeGlobal, this.timeTotal);
			this.isFirstTimeSetNumSelected = false;
		}
		
		public function get timeControl(): Number {
			return this._timeControl;
		}
		
		public function set timeControl(value: Number): void {
			this._timeControl = MathExt.moduloPositive(value, this.timeTotal)
			//this.numRenderableFirst = Math.floor(this.timeControl);
			//if (this.optionsController.isArrow) this.setPositionArrowsOnItem();
			if ((this.arrCountRenderableInRow) && (this.arrCountRenderableInRow.length > 0)) {
				//trace("set timecontrol:", this.vecNumInDimension, "; ", this.vecNumInRow)
				this.manageArrRenderableInRow(this.arrCountRenderableInRow);
				this.renderFromCurrent();
			}
		}
		
		public function get vecNumInDimension(): Vector.<uint> {return this._vecNumInDimension;}
		
		public function set vecNumInDimension(value: Vector.<uint>): void { this._vecNumInDimension = value; }
		
		public function get vecNumInRow(): Vector.<uint> {return this._vecNumInRow;}
		
		public function set vecNumInRow(value: Vector.<uint>): void {this._vecNumInRow = value;}
		
		public function get arrCountRenderableInRow(): Array {
			return this._arrCountRenderableInRow;
		}
		
		public function set arrCountRenderableInRow(value: Array): void {
			this._arrCountRenderableInRow = value;
			this.numInRowForRenderableSelected = this.funcGetNumInRowForRenderableSelected.apply(null, [value.length, this.vecNumInRow]);
			this.numRenderableFirst = MathExt.moduloPositive(Math.floor(this.timeControl) - this.numInRowForRenderableSelected, this.vecRenderable.length);
		}
		
		//manageArrRenderableInRow
		
		protected function manageArrRenderableInRow(arrCountRenderableInRow: Array): void {
			this.arrCountRenderableInRow = this.arrCountRenderableInRow;
			for (var i: uint = 0; i < this.vecRenderableInRow.length; i++) {
				this.vecRenderableInRow[i] = this.vecRenderable[(this.numRenderableFirst + i) % this.vecRenderable.length];
			}
			this.setVecNumInRowInRenderables();
		}
		
		protected function setVecNumInRowInRenderables(): void {
			var renderableInRow: IRenderable;
			for (var i: uint = 0; i < this.vecRenderableInRow.length; i++)
				this.setNumInRowInRenderableInRow(this.vecRenderableInRow[i], i);
		}
		
		protected function setNumInRowInRenderableInRow(renderableInRow: IRenderable, numRenderableInRow: uint): void {
			if (!renderableInRow.vecNumInRow) renderableInRow.vecNumInRow = new Vector.<uint>();
			renderableInRow.vecNumInRow.length = Math.max(renderableInRow.vecNumInRow.length, this.vecNumInRow.length + 1)
			for (var i: uint = 0; i < this.vecNumInRow.length; i++)
				renderableInRow.vecNumInRow[i] = this.vecNumInRow[i];
			renderableInRow.vecNumInRow[this.vecNumInRow.length] = numRenderableInRow;
		}
		
		protected function isRenderableInRow(numRenderableInDimension: uint, numRenderableInRow: uint): Boolean {
			return (this.isRenderableNotOnRightEdgeOfRow(numRenderableInRow)
			 && (numRenderableInDimension == (this.numRenderableFirst + numRenderableInRow) % this.vecRenderable.length) 
			 && (((numRenderableInDimension >= this.numRenderableFirst) && (numRenderableInDimension < this.numRenderableFirst + this.arrCountRenderableInRow.length)) || (numRenderableInDimension < this.arrCountRenderableInRow.length - (this.vecRenderable.length - this.numRenderableFirst))));
		}
		
		protected function isRenderableNotOnRightEdgeOfRow(numRenderableInRow: uint): Boolean {
			return true;
		}
		
		//render
		
		private function renderFromCurrent(): void {
			this.renderInternal(new Vector.<Number>(), this._vecNumInDimension.length, new Vector.<Number>());
		}
		
		public function renderInternal(vecTimeRender: Vector.<Number>, startNumDimensionToRender: uint, vecTimeTotal: Vector.<Number>): void {
			//trace("start")
			//this.vecNumInRow = vecNumInRow;
			if (this.isForceRenderParentRow && this.parentRow) {
				this.isForceRenderParentRow = false;
				this.parentRow.isForceRenderParentRow = true;
				//trace("go parent")
				this.parentRow.renderFromCurrent();
			} else {
				var renderableInRow: IRenderable;
				//trace("row render: ", vecTimeRender, startNumDimensionToRender, this.vecRenderableInRow)
				for (var i: uint = 0; i < this.vecRenderableInRow.length; i++) {
					renderableInRow = this.vecRenderableInRow[i];
					if (renderableInRow is MultiRowCircleGallery) MultiRowCircleGallery(renderableInRow).isForceRenderParentRow = false;
					renderableInRow.renderInternal(vecTimeRender.concat(new <Number>[i - this.numInRowForRenderableSelected - this.timeControl % 1]), startNumDimensionToRender, vecTimeTotal.concat(new <Number>[this.timeTotal]));
				}
			}
		}
		
		//dispose
		
		public function dispose(): void {
			var renderable: IRenderable;
			for (var i: int = 0; i < this.vecRenderable.length; i++) {
				renderable = this.vecRenderable[i];
				var numRenderableInRow: int = i - this.numRenderableFirst;
				if (numRenderableInRow < 0) numRenderableInRow = this.vecRenderable.length + numRenderableInRow;
				renderable.dispose();
				if (this.isRenderableInRow(i, numRenderableInRow))
					if ((renderable is MultiItemGallery) && (this.containerItem.contains(MultiItemGallery(renderable)))) this.containerItem.removeChild(MultiItemGallery(renderable));
				renderable = null;
			}
			this.arrCountRenderableInRow = [];
			this.vecRenderableInRow = null;
			this.vecRenderable = null;
		}
		
	}

}