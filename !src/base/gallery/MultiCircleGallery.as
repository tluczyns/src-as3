package base.gallery {
	import flash.display.Sprite;
	import base.types.DictionaryExt;
	import flash.events.Event;
	//swf address gateway
	import base.vspm.StateModel;
	import base.vspm.EventStateModel;
	import base.math.MathExt;
	import base.vspm.SWFAddress;
	//controllers
	//arrow
	import base.vspm.EventModel;
	//mousewheel
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import base.service.ExternalInterfaceExt;
	//automate change items
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.setInterval;

	public class MultiCircleGallery extends Sprite {
		
		static public const BASE_NAME_PARAMETER_ID_ITEM_GALLERY: String = "ig";
		static public const ARR_CHAR_DIMENSION_TO_ID_WHEN_CLONE: Array = ["u", "v", "w", "x", "y", "z"];	
		
		private var arrData: Array;
		protected var arrCountRenderableInRow: Array;
		protected var arrItem:  Array;
		public var containerItem: Sprite;
		private var row: MultiRowCircleGallery;
		//item
		protected var nameParamItem: String;
		private var idItemSequentGeneric: uint;
		protected var dictIdToIdWithSuff: DictionaryExt;
		//row
		private var vecOfVecRowInDimension: Vector.<Vector.<MultiRowCircleGallery>>;
		private var dictIdToVecNumInDimension: DictionaryExt;
		protected var dictVecNumInDimensionToId: DictionaryExt;
		//swf address gateway
		public var idItemSelected: String;
		private var isCreatedEventSelectItemChanged: Boolean;
		
		protected var optionsController: OptionsControllerMulti;
		protected var optionsVisual: OptionsVisualMulti;
		
		public function MultiCircleGallery(arrData: Array = null, nameUnique: String = "", optionsController: OptionsControllerMulti = null, optionsVisual: OptionsVisualMulti = null): void {
			//arrData = [[0xff0000, 0xff0000, 0x00ff00, 0x0000ff, 0x000000], [0xff00ff, 0x00ffff, 0xffff00, 0xff0077], [0x7700ff, 0xff0077, 0xff77ff, 0xff7777], [0x333333, 0x666666, 0x999999, 0xcccccc]];
			//arrData = [[0xff0000, 0x00ff00, 0x0000ff], [0xffff00, 0xff0077, 0x541466], [0x666666, 0x999999, 0xcccccc], [0x000000]];
			//arrData = [[0xff0000, 0x00ff00, 0x0000ff], [0xffff00, 0xff0077], [0x999999, 0xcccccc]];
			//arrData = [[0xff0000, 0x00ff00], [0xffff00, 0xff0077]];
			/*var lenX: uint = 300;
			var lenY: uint = 300;
			arrData = new Array(lenX);
			for (var i:int = 0; i < lenX; i++) {
				arrData[i] = new Array(lenY);
				for (var j:int = 0; j < lenY; j++) {
					arrData[i][j] = Math.floor(Math.random() * 16777216);
				}
			}*/
			/*arrData = [[[0xff0000, 0x00ff00, 0x0000ff, 0x000000], [0xff0000, 0x00ff00, 0x0000ff, 0x000000], [0xff0000, 0x00ff00, 0x0000ff, 0x000000], [0xff0000, 0x00ff00, 0x0000ff, 0x000000]], 
			[[0xff00ff, 0x00ffff, 0xffff00, 0xff0077], [0xff00ff, 0x00ffff, 0xffff00, 0xff0077], [0xff00ff, 0x00ffff, 0xffff00, 0xff0077], [0xff00ff, 0x00ffff, 0xffff00, 0xff0077]],
			[[0x7700ff, 0xff0077, 0xff77ff, 0xff7777], [0x7700ff, 0xff0077, 0xff77ff, 0xff7777], [0x7700ff, 0xff0077, 0xff77ff, 0xff7777], [0x7700ff, 0xff0077, 0xff77ff, 0xff7777]], 
			[[0x333333, 0x666666, 0x999999, 0xcccccc], [0x333333, 0x666666, 0x999999, 0xcccccc], [0x333333, 0x666666, 0x999999, 0xcccccc], [0x333333, 0x666666, 0x999999, 0xcccccc]]];*/
			if (arrData && arrData.length) {
				this.arrData = arrData;
				this.nameParamItem = MultiCircleGallery.BASE_NAME_PARAMETER_ID_ITEM_GALLERY + nameUnique; //item_gallery
				this.optionsController = optionsController || new OptionsControllerMulti();
				if (this.arrData.length == 1) this.optionsController.isAutoChangeItem = false;
				this.optionsVisual = optionsVisual || new OptionsVisualMulti();
				this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false);
			} else throw new Error("no or empty data");
		}
		
		protected function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.createArrCountRenderableInRow();
			this.createItems();
			this.createRow();
			if (this.optionsController.isArrow) this.createVecArrows();
			this.createEventSelectItemChanged();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			this.createControllers();
			//setInterval(this.selectPrevNextItemInDimension, 2000, 1, 1);
			//setInterval(this.selectPrevNextItemInDimension, 1500, 0, 0);
			//setInterval(this.selectPrevNextItemInDimension, 1600, 1, 0);
		}
		
		private function cloneArrData(srcData: Object, numDimension: uint, isForArrCountRenderableInRow: Boolean, suffStrToIdWhenClone: String = ""): Object {
			var cpData: Object;
			if ((srcData is Array) && (srcData.length)) {
				var lengthCpData: uint = srcData.length;
				if (!isForArrCountRenderableInRow) {
					var minLengthArrItem: uint = this.getMaxLengthCountRenderableInRowInDimension(numDimension);
					while (lengthCpData < minLengthArrItem) lengthCpData += srcData.length;
				}
				cpData = new Array(lengthCpData);
				//clone id, aby się nie powtarzały id gdy duplikujemy dane, aby wypełniły arrCountRenderable
				var countAddCharToIdWhenClone: uint; 
				var addSuffStrToIdWhenClone: String;
				var addCharDimensionToIdWhenClone: String = MultiCircleGallery.ARR_CHAR_DIMENSION_TO_ID_WHEN_CLONE[numDimension];
				var numData: uint = 0;
				var srcSubData: Object;
				var objGetSubData: Object;
				for (var i: uint = 0; i < lengthCpData; i++) {
					objGetSubData = this.getSubData(srcData, numData, (i >= srcData.length));
					srcSubData = objGetSubData.srcSubData;
					numData = (objGetSubData.numData + 1) % srcData.length;
					addSuffStrToIdWhenClone = addCharDimensionToIdWhenClone + String(i);
					cpData[i] = this.cloneArrData(srcSubData, numDimension + 1, isForArrCountRenderableInRow, suffStrToIdWhenClone + addSuffStrToIdWhenClone);
				}
			} else {
				if (isForArrCountRenderableInRow) cpData = null;
				else {
					var idWithSuff: String;
					if ((srcData.propertyIsEnumerable("id")) && (srcData.id)) idWithSuff = srcData.id + suffStrToIdWhenClone;
					else {
						idWithSuff = "gen" + String(this.idItemSequentGeneric++);
						srcData = {value: srcData, id: idWithSuff}; 
					}
					//trace("id:", idWithSuff)
					if (!this.dictIdToIdWithSuff[srcData.id]) this.dictIdToIdWithSuff[srcData.id] = idWithSuff;
					var classForItem: Class = this.getClassForItem(srcData.id, srcData);
					var item: MultiItemGallery = new classForItem(idWithSuff, this.nameParamItem, srcData);
					this.initItem(item);
					cpData = item;
				}
			}
			return cpData;
		}
		
		protected function getSubData(srcData: Object, numData: uint, isCloned: Boolean): Object {
			return {srcSubData: srcData[numData % srcData.length], numData: numData};
		}
		
		//arrCountRederableInRow
		
		protected function createArrCountRenderableInRow(): void {
			this.arrCountRenderableInRow = this.getArrCountRenderableInRow();
		}
		
		protected function getArrCountRenderableInRow(): Array {
			return this.cloneArrData(this.arrData, 0, true) as Array;
		}
		
		private function getMaxLengthCountRenderableInRowInDimension(numDimension: uint): uint {
			return this.getMaxLengthCountRenderableInRowInDimensionInner(this.arrCountRenderableInRow, numDimension);
		}
		
		private function getMaxLengthCountRenderableInRowInDimensionInner(arrCountRenderableInRow: Array, countLeftDimensionToExplore: uint): uint {
			var maxLengthCountRenderableInRowInDimension: uint = 0;
			if (countLeftDimensionToExplore == 0) maxLengthCountRenderableInRowInDimension = arrCountRenderableInRow.length;
			else if (countLeftDimensionToExplore > 0) {
				for (var i: uint = 0; i < arrCountRenderableInRow.length; i++) {
					var objCountRenderableInRow: Object = arrCountRenderableInRow[i];
					if (objCountRenderableInRow is Array)
						maxLengthCountRenderableInRowInDimension = Math.max(maxLengthCountRenderableInRowInDimension, this.getMaxLengthCountRenderableInRowInDimensionInner(objCountRenderableInRow as Array, countLeftDimensionToExplore - 1));
				}
			}
			return maxLengthCountRenderableInRowInDimension;
		}
		
		//items
		
		protected function createItems(): void {
			this.containerItem = new Sprite();
			this.addChild(this.containerItem);
			this.idItemSequentGeneric = 0;
			this.dictIdToIdWithSuff = new DictionaryExt();
			this.arrItem = this.cloneArrData(this.arrData, 0, false) as Array;
		}
		
		protected function getClassForItem(id: String, objData: Object): Class {
			return MultiItemGallery;
		}
		
		protected function initItem(item: MultiItemGallery): void {
			
		}
		
		private function removeItems(): void {
			//this.removeItemsSub(this.arrItem);
			this.removeChild(this.containerItem);
			this.containerItem = null;
		}
		
		/*private function removeItemsSub(arrItem: Array): void {
			var subArrItem: *;
			var item: MultiItemGallery;
			for (var i: uint = 0; i < arrItem.length; i++) {
				subArrItem = arrItem[i];
				if ((subArrItem is Array) && (subArrItem.length)) this.removeItemsSub(subArrItem);
				else {
					item = MultiItemGallery(subArrItem);
					this.removeItem(item);
				}
			}
			arrItem = [];
		}
		
		protected function removeItem(item: MultiItemGallery): void {
			item.destroy();
			if (this.containerItem.contains(item)) this.containerItem.removeChild(item);
			item = null;
		}*/	
		
		//row
		
		private function createRow(): void {
			this.vecOfVecRowInDimension = new <Vector.<MultiRowCircleGallery>> [new Vector.<MultiRowCircleGallery>()];
			this.dictIdToVecNumInDimension = new DictionaryExt();
			this.dictVecNumInDimensionToId = new DictionaryExt();
			this.row = this.createRowSub(this.arrItem, new Vector.<uint>());
			this.row.setArrCountRenderableInRow(this.arrCountRenderableInRow);
		}
		
		protected function get classRow(): Class {
			return MultiRowCircleGallery;
		}
		
		protected function getNumInRowForRenderableSelected(lengthArrCountRenderableInRow: uint, vecNumInRow: Vector.<uint>): uint {
			//var add: uint = 0;
			//if ((vecNumInRow) && (vecNumInRow.length > 0)) add = vecNumInRow[vecNumInRow.length - 1]
			return Math.floor((lengthArrCountRenderableInRow - 1) / 2) //+ add;
		}
		
		private function createRowSub(arrItem: Array, vecNumInDimension: Vector.<uint>): MultiRowCircleGallery {
			var row: MultiRowCircleGallery = new classRow(this.getNumInRowForRenderableSelected, this.containerItem, this.optionsVisual, this.optionsController);
			this.vecOfVecRowInDimension[vecNumInDimension.length].push(row);
			var subArrItem: *;
			var subVecNumInDimension: Vector.<uint>;
			var rendarable: IRenderable;
			var item: MultiItemGallery;
			for (var i: uint = 0; i < arrItem.length; i++) {
				subArrItem = arrItem[i];
				subVecNumInDimension = vecNumInDimension.concat(new <uint>[i]);
				if ((subArrItem is Array) && (subArrItem.length)) {
					if (this.vecOfVecRowInDimension.length < subVecNumInDimension.length + 1) {
						this.vecOfVecRowInDimension.length = subVecNumInDimension.length + 1;
						this.vecOfVecRowInDimension[subVecNumInDimension.length] = new Vector.<MultiRowCircleGallery>();
					}
					rendarable = this.createRowSub(subArrItem as Array, subVecNumInDimension);
					MultiRowCircleGallery(rendarable).parentRow = row;
				} else {
					rendarable = IRenderable(subArrItem);
					item = MultiItemGallery(rendarable);
					item.vecNumInDimension = subVecNumInDimension;
					this.dictIdToVecNumInDimension[item.id] = item.vecNumInDimension;
					this.dictVecNumInDimensionToId[item.vecNumInDimension] = item.id;
				}
				row.vecRenderable[i] = rendarable;
			}
			row.initAfterSetVecRenderable(vecNumInDimension);
			return row;
		}
		
		private function removeRow(): void {
			this.row.destroy();
			this.vecOfVecRowInDimension = null;
		}
		
		//////////changing Items//////////
		
		//event select item changed and gateway from swfaddress to change idItemSelected
		
		public function createEventSelectItemChanged(): void {
			if (!this.isCreatedEventSelectItemChanged) {
				this.isCreatedEventSelectItemChanged = true;
				StateModel.init();
				StateModel.addEventListener(EventStateModel.PARAMETERS_CHANGE, this.selectItem, 110);
				this.selectItem(null);
			}
		}
		
		public function removeEventSelectItemChanged(): void {
			if (this.isCreatedEventSelectItemChanged) {
				this.isCreatedEventSelectItemChanged = false;
				StateModel.removeEventListener(EventStateModel.PARAMETERS_CHANGE, this.selectItem);
			}
		}
		
		private function isEmptyIdItemSelected(idItemSelected: String): Boolean {
			return ((Number(idItemSelected) == 0) || (idItemSelected == null) || (idItemSelected == "undefined") || (idItemSelected == ""));
		}
		
		
		protected function selectItem(e: EventStateModel): void {
			var idItemSelected: String = StateModel.parameters[this.nameParamItem];
			//idItemSelected = "generic11";
			var vecNumInDimensionItemToSelect: Vector.<uint>;
			if (Number(idItemSelected) != 0) vecNumInDimensionItemToSelect = this.dictIdToVecNumInDimension[idItemSelected]; //idItemSelected == null lub idItemSelected == "" lub inne //e.data as Vector.<uint>;
			//trace("idItemSelected:", idItemSelected, vecNumInDimensionItemToSelect)
			if (!vecNumInDimensionItemToSelect) {
				//trace("idItemSelected2:", idItemSelected, this.dictIdToIdWithSuff[idItemSelected]);	
				if (!this.isEmptyIdItemSelected(idItemSelected)) {
					var indCloneCharInId: int = idItemSelected.indexOf(MultiCircleGallery.ARR_CHAR_DIMENSION_TO_ID_WHEN_CLONE[0]);
					if (indCloneCharInId > -1) idItemSelected = idItemSelected.substring(0, indCloneCharInId);
				}
				//trace("idItemSelected3:", idItemSelected, this.dictIdToIdWithSuff[idItemSelected]);	
				if ((this.isEmptyIdItemSelected(idItemSelected)) || (this.dictIdToIdWithSuff[idItemSelected])) {
					if (!this.dictIdToIdWithSuff[idItemSelected]) idItemSelected = this.getIdItemDefault(); 
					idItemSelected = this.dictIdToIdWithSuff[idItemSelected];
					vecNumInDimensionItemToSelect = this.dictIdToVecNumInDimension[idItemSelected]
				} 
				//trace("idItemSelected4:", idItemSelected, vecNumInDimensionItemToSelect);	
				if (!vecNumInDimensionItemToSelect) vecNumInDimensionItemToSelect = this.getVecNumInDimensionItemDefault(); 
				this.setCurrentSwfAddressValueWithId(vecNumInDimensionItemToSelect, 0);
			} else {
				if (idItemSelected != this.idItemSelected) {
					this.idItemSelected = idItemSelected;
					this.selectRenderablesInAllDimensions(vecNumInDimensionItemToSelect);
					if ((this.optionsController.isAutoChangeItem) && (!this.isSelectFromAuto)) this.waitAndSetAutoChangeItemOnItemChanged();
				}
			}
		}
		
		//item selected at start
		protected function getIdItemDefault(): String {
			return "";
		}
		
		protected function getVecNumInDimensionItemDefault(): Vector.<uint> {
			var vecNumInDimensionItemDefault: Vector.<uint> = new Vector.<uint>(this.vecOfVecRowInDimension.length);
			for (var i: uint = 0; i < this.vecOfVecRowInDimension.length; i++)
				vecNumInDimensionItemDefault[i] = 0;
			return vecNumInDimensionItemDefault;
		}
		
		//set state of gallery from vecNumInDimensionItemSelected
		
		private function selectRenderablesInAllDimensions(vecNumInDimensionItemSelected: Vector.<uint>): void {
			if (this.optionsController.isSelectSingleOrAllInDimension == 0) this.selectSingleRenderableInAllDimensions(vecNumInDimensionItemSelected);
			else if (this.optionsController.isSelectSingleOrAllInDimension == 1) this.selectAllRenderablesInAllDimensions(vecNumInDimensionItemSelected);
		}
		
		private function selectSingleRenderableInAllDimensions(vecNumInDimension: Vector.<uint>): void {
			this.selectSingleRenderableInDimension(this.row, vecNumInDimension);
		}
		
		private function selectSingleRenderableInDimension(rowToSelect: MultiRowCircleGallery, vecNumInDimension: Vector.<uint>): void {
			if (vecNumInDimension.length > 0) {
				var numInDimensionToSelect: uint = vecNumInDimension[0];
				rowToSelect.numSelected = numInDimensionToSelect;
				if (vecNumInDimension.length > 1) this.selectSingleRenderableInDimension(MultiRowCircleGallery(rowToSelect.vecRenderable[numInDimensionToSelect]), vecNumInDimension.slice(1));
			}
		}
		
		private function selectAllRenderablesInAllDimensions(vecNumInDimension: Vector.<uint>): void {
			var vecRowInDimension: Vector.<MultiRowCircleGallery>;
			var addNumInDimensionToSelect: int;
			//var numInDimension: uint;
			var rowToSelect: MultiRowCircleGallery = this.row;
			for (var i: uint = 0; i < vecNumInDimension.length; i++) {
				vecRowInDimension = this.vecOfVecRowInDimension[i];
				addNumInDimensionToSelect = MathExt.minDiffWithSign(vecNumInDimension[i], rowToSelect.numSelected, rowToSelect.vecRenderable.length);
				//numInDimension = vecNumInDimension[i];
				for (var j: uint = 0; j < vecRowInDimension.length; j++) {
					var rowInDimension: MultiRowCircleGallery = vecRowInDimension[j];
					rowInDimension.numSelected = MathExt.moduloPositive(rowInDimension.numSelected + addNumInDimensionToSelect, rowInDimension.vecRenderable.length) //numInDimension
				}
				if (i < vecNumInDimension.length - 1) rowToSelect = MultiRowCircleGallery(rowToSelect.vecRenderable[rowToSelect.numSelected])
			}
		}
		
		//controllers swfaddress changing items (obtain proper id and set swfaddress with it)
		
		protected function setCurrentSwfAddressValueWithId(vecNumInDimensionItemToSelect: Vector.<uint>, isFromDefaultMouseWheelAuto: uint, isPrevNext: int = -1, numDimension: int = -1): void {
			var idItemToSelect: String = this.dictVecNumInDimensionToId[vecNumInDimensionItemToSelect];
			var objParamItem: Object = {};
			objParamItem[this.nameParamItem] = idItemToSelect;
			SWFAddress.setCurrentSwfAddressValueWithParameters(objParamItem, false);			
		}
		
		//stary sposób, działa, ale bez użycia swfaddress i this.idNumItemSelected 
		/*protected function selectPrevNextItemInDimension(isPrevNext: uint, numDimension: uint): void {
			var vecRowInDimension: Vector.<MultiRowCircleGallery> = this.vecOfVecRowInDimension[numDimension];
			if (vecRowInDimension) {
				for (var i: uint = 0; i < vecRowInDimension.length; i++) {
					var rowInDimension: MultiRowCircleGallery = vecRowInDimension[i];
					rowInDimension.selectPrevNextItem(isPrevNext);
				}
			}
		}*/

		protected function selectPrevNextItemInDimension(isPrevNext: uint, numDimension: uint, idItemSelected: String = ""): void {
			idItemSelected = idItemSelected || this.idItemSelected;
			var vecNumInDimensionItemSelected: Vector.<uint> = this.dictIdToVecNumInDimension[idItemSelected];
			if (numDimension < vecNumInDimensionItemSelected.length) {
				var rowInDimensionSelected: MultiRowCircleGallery = this.row;
				for (var i: uint = 0; i < numDimension; i++) rowInDimensionSelected = MultiRowCircleGallery(rowInDimensionSelected.vecRenderable[vecNumInDimensionItemSelected[i]]);
				var rowInDimensionToSelect: MultiRowCircleGallery = rowInDimensionSelected;
				var vecNumInDimensionItemToSelect: Vector.<uint> = vecNumInDimensionItemSelected.concat();
				for (i = numDimension; i < vecNumInDimensionItemSelected.length; i++) {
					var numInDimensionSelected: uint = vecNumInDimensionItemSelected[i];
					var numInDimensionToSelect: uint;
					if (i == numDimension) numInDimensionToSelect = MathExt.moduloPositive(numInDimensionSelected + [-1, 1][isPrevNext], rowInDimensionSelected.vecRenderable.length);
					else numInDimensionToSelect = rowInDimensionSelected.numSelected
					vecNumInDimensionItemToSelect[i] = numInDimensionToSelect;
					if (i < vecNumInDimensionItemSelected.length - 1) {
						rowInDimensionSelected = MultiRowCircleGallery(rowInDimensionSelected.vecRenderable[numInDimensionSelected]);
						rowInDimensionToSelect = MultiRowCircleGallery(rowInDimensionToSelect.vecRenderable[numInDimensionToSelect]);
					}
				}
				this.setCurrentSwfAddressValueWithId(vecNumInDimensionItemToSelect, 1, isPrevNext, numDimension);
			}
		}
		
		protected function selectPrevNextItem(isPrevNext: uint, idItemSelected: String = ""): void {
			idItemSelected = idItemSelected || this.idItemSelected;
			var vecNumInDimensionItemSelected: Vector.<uint> = this.dictIdToVecNumInDimension[idItemSelected];
			var vecNumInDimensionItemToSelect: Vector.<uint> = vecNumInDimensionItemSelected.concat();
			
			var rowInDimensionSelected: MultiRowCircleGallery = this.row;
			for (var i: uint = 0; i < vecNumInDimensionItemSelected.length - 1; i++)
				rowInDimensionSelected = MultiRowCircleGallery(rowInDimensionSelected.vecRenderable[vecNumInDimensionItemSelected[i]]);
			var numDimensionToChangeItemSelected: int = vecNumInDimensionItemSelected.length - 1;
			var isPrevNextInParentRow: Boolean = true;
			while ((rowInDimensionSelected) && (((isPrevNext == 0) && (rowInDimensionSelected.numSelected == 0)) || ((isPrevNext == 1) && (rowInDimensionSelected.vecRenderable) && (rowInDimensionSelected.numSelected == rowInDimensionSelected.vecRenderable.length - 1)))) {
				rowInDimensionSelected = rowInDimensionSelected.parentRow;
				numDimensionToChangeItemSelected--;
			}
			var numInDimensionToSelect: uint;	
			if (rowInDimensionSelected == null) {
				rowInDimensionSelected = this.row;
				numDimensionToChangeItemSelected = 0;
				numInDimensionToSelect = [rowInDimensionSelected.vecRenderable.length - 1, 0][isPrevNext];
			} else numInDimensionToSelect = vecNumInDimensionItemSelected[numDimensionToChangeItemSelected] + [-1, 1][isPrevNext]; 
			vecNumInDimensionItemToSelect[numDimensionToChangeItemSelected] = numInDimensionToSelect; //rowInDimensionSelected.numSelected =
			for (i = numDimensionToChangeItemSelected + 1; i < vecNumInDimensionItemSelected.length; i++) {
				rowInDimensionSelected = MultiRowCircleGallery(rowInDimensionSelected.vecRenderable[numInDimensionToSelect]);
				vecNumInDimensionItemToSelect[i] = [rowInDimensionSelected.vecRenderable.length - 1, 0][isPrevNext];
			}
			this.setCurrentSwfAddressValueWithId(vecNumInDimensionItemToSelect, 2, isPrevNext);
		}
		
		//controllers
		
		public function createControllers(): void {
			trace("this.optionsController.isAutoChangeItem:", this.optionsController.isAutoChangeItem)
			if (this.arrData.length > 1) {
				if (this.optionsController.isArrow) this.addEventsToVecArrows();
				if (this.optionsController.isMouseWheel) this.initMouseWheel();
				if (this.optionsController.isAutoChangeItem) this.initAutoChangeItem();
			}
		}
		
		public function removeControllers(): void {
			if (this.arrData.length > 1) {
				if (this.optionsController.isAutoChangeItem) this.removeAutoChangeItem();
				if (this.optionsController.isMouseWheel) this.removeMouseWheel();
				if (this.optionsController.isArrow) this.removeEventsFromVecArrows();
			}
		}
		
		//arrows
		
		public var containerVecArrows: Sprite;
		private var vecArrows: Vector.<ArrowsGalleryMulti>;
		
		protected function getVecClassArrows(): Vector.<Class> {
			return new Vector.<Class>();
		}
		
		private function createVecArrows(): void {
			this.containerVecArrows = new Sprite();
			this.addChild(this.containerVecArrows);
			this.vecArrows = new Vector.<ArrowsGalleryMulti>();
			if (this.arrData.length > 1) {
				var vecClassArrows: Vector.<Class> = this.getVecClassArrows();
				this.vecArrows = new Vector.<ArrowsGalleryMulti>(vecClassArrows.length);
				for (var i: uint = 0; i < vecClassArrows.length; i++) {
					var classArrows: Class = vecClassArrows[i];
					var arrows: ArrowsGalleryMulti = new classArrows(i, this);
					this.containerVecArrows.addChild(arrows);
					this.vecArrows[i] = arrows;
				}
			}
		}
		
		private function removeVecArrows(): void {
			for (var i: uint = 0; i < this.vecArrows.length; i++) {
				var arrows: ArrowsGalleryMulti = this.vecArrows[i];
				arrows.destroy();
				this.containerVecArrows.removeChild(arrows);
				arrows = null;
			}
			this.vecArrows = new Vector.<ArrowsGalleryMulti>();
			this.removeChild(this.containerVecArrows);
			this.containerVecArrows = null;
		}
		
		private function addEventsToVecArrows(): void { 
			for (var i: uint = 0; i < this.vecArrows.length; i++) {
				var arrows: ArrowsGalleryMulti = this.vecArrows[i];
				arrows.addEventListener(ArrowsGalleryMulti.ON_ARROWS_CLICKED, this.onArrowsClicked);
			}
		}
		
		private function onArrowsClicked(e: EventModel):void {
			this.selectPrevNextItemInDimension(e.data.isPrevNext, e.data.dimension);
		}
		
		private function removeEventsFromVecArrows(): void { 
			for (var i: uint = 0; i < this.vecArrows.length; i++) {
				var arrows: ArrowsGalleryMulti = this.vecArrows[i];
				arrows.removeEventListener(ArrowsGalleryMulti.ON_ARROWS_CLICKED, this.onArrowsClicked);
			}
		}
		
		//mouse wheel
		
		private var isActiveWheel: Boolean;
		
		private function initMouseWheel(): void {
			this.isActiveWheel = true;
			if (this.optionsController.isHandleMouseWheelInternallyFromJS == 0) {
				var intrObjForMouseWheel: InteractiveObject;
				if (this.optionsController.isSetMouseWheelOnStage) intrObjForMouseWheel = this.stage;
				else intrObjForMouseWheel = this.containerItem;
				intrObjForMouseWheel.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			} else if (this.optionsController.isHandleMouseWheelInternallyFromJS == 1) {
				ExternalInterfaceExt.call("setMouseWheelEnabled", 1);
				ExternalInterfaceExt.addCallback("onMouseWheelJS", this);
			}
		}
		
		private function onMouseWheel(e: MouseEvent): void {
			ExternalInterfaceExt.call("blockMouseWheelInBrowser");
			e.stopPropagation();
			this.processMouseWheel(uint(e.delta < 0));
		}
		
		public function onMouseWheelJS(delta: int, deltaX: int, deltaY: int): void {
			this.processMouseWheel(uint(delta < 0))
		}
		
		private function processMouseWheel(isWheelPrevNext: uint): void {
			if (this.isActiveWheel) {
				this.isActiveWheel = false;
				this.selectItemOnMouseWheel(isWheelPrevNext)
				setTimeout(this.setActiveWheel, 200);
			}
		}
		
		protected function selectItemOnMouseWheel(isWheelPrevNext: uint): void {
			this.selectPrevNextItemInDimension(isWheelPrevNext, 1);
			/*if (this.stage) {
				var factorDirectionalDiagonalTLToBR: Number = this.stage.stageHeight / this.stage.stageWidth;
				var isAboveDiagonalTLToBR: Boolean =  (this.stage.mouseX * factorDirectionalDiagonalTLToBR > this.stage.mouseY)
				var factorDirectionalDiagonalBLToTR: Number = - this.stage.stageHeight / this.stage.stageWidth;
				var isAboveDiagonalBLToTR: Boolean =  (this.stage.mouseX * factorDirectionalDiagonalBLToTR + this.stage.stageHeight > this.stage.mouseY)
				var numDimension: uint = uint(isAboveDiagonalTLToBR != isAboveDiagonalBLToTR)
				this.selectPrevNextItemInDimension((numDimension == 1) ? (1 - isWheelPrevNext) : isWheelPrevNext, numDimension);
			}*/
		}
		
		private function setActiveWheel(): void {
			this.isActiveWheel = true;
		}
		
		private function removeMouseWheel(): void {
			if (this.optionsController.isHandleMouseWheelInternallyFromJS == 0) {
				var intrObjForMouseWheel: InteractiveObject;
				if (this.optionsController.isSetMouseWheelOnStage) intrObjForMouseWheel = this.stage;
				else intrObjForMouseWheel = this.containerItem;
				intrObjForMouseWheel.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			} else if (this.optionsController.isHandleMouseWheelInternallyFromJS == 1) { 
				ExternalInterfaceExt.call("setMouseWheelEnabled", 0);
				ExternalInterfaceExt.removeCallback("onMouseWheelJS");
			}
		}
		
		//automate change items
		
		private var timeoutChangeItemFirstTime: uint;
		private var intervalChangeItem: uint;
		private var isSelectFromAuto: Boolean;
		
		private function initAutoChangeItem(): void {
			this.waitAndSetAutoChangeItemOnItemChanged();
		}
		
		protected function waitAndSetAutoChangeItemOnItemChanged(): void {
			clearInterval(this.intervalChangeItem);
			clearTimeout(this.timeoutChangeItemFirstTime);
			this.timeoutChangeItemFirstTime = setTimeout(this.changeItemFirstTime, this.optionsController.timeChangeItemFirstTime);
		}
		
		private function changeItemFirstTime(): void {
			this.selectItemOnAuto();
			clearInterval(this.intervalChangeItem);
			this.intervalChangeItem = setInterval(this.selectItemOnAuto, this.optionsController.timeChangeItem);
		}
		
		protected function selectItemOnAuto(): void {
			this.isSelectFromAuto = true;
			this.selectPrevNextItem(1);
			this.isSelectFromAuto = false;
		}
		
		private function removeAutoChangeItem(): void {
			clearInterval(this.intervalChangeItem);
			clearTimeout(this.timeoutChangeItemFirstTime);
		}
		
		//destroy
		
		private function onRemovedFromStage(e: Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			this.destroy();
		}
		
		public function destroy(): void {
			if ((this.arrData && this.arrData.length) && (this.stage)) {
				//this.removeControllers();
				this.removeEventSelectItemChanged();
				if (this.optionsController.isArrow) this.removeVecArrows();
				this.removeRow();
				this.removeItems();
			}
		}
		
	}
	
}