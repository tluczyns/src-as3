package base.gallery {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import base.math.MathExt;
	import base.btn.BtnArrow;
	import base.btn.BtnHitEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	public class CircleGallery extends Sprite {
		
		protected var arrData: Array;
		public var arrItem: Array;
		protected var containerItem: Sprite;
		protected var arrItemInField: Array;
		private var numFieldForItemSelected: uint;
		protected var numItemSelected: int;
		private var numFirstItemSelected: uint;
		
		protected var timeOne: Number;
		private var timeTotal: Number;
		protected var _time: Number;
		public var optionsController: OptionsController;
		protected var optionsVisual: OptionsVisual;
				
		public function CircleGallery(arrData: Array = null, numFieldForItemSelected: int = -1, optionsController: OptionsController = null, optionsVisual: OptionsVisual = null, numFirstItemSelected: uint = 0): void {
			/*arrData = [0xff0000, 0x00ff00, 0x0000ff, 0xff00ff, 0x00ffff, 0xffff00];
			this.x = this.y = 300;*/
			this.arrData = arrData;
			if ((this.arrData) && (this.arrData.length)) {
				this.optionsController = optionsController || new OptionsController();
				this.optionsVisual = optionsVisual || new OptionsVisual();
				this.arrItemInField = new Array(this.lengthArrItemInField);
				this.createItems();
				this.numFieldForItemSelected = (numFieldForItemSelected == -1) ? Math.ceil((this.lengthArrItemInField - 1) / 2) - 1 : numFieldForItemSelected;
				this.numFirstItemSelected = numFirstItemSelected;
				this.timeOne = 1 / this.arrItemInField.length;//this.lengthArrItemInField - 1//this.arrItemInField.length;
				this.timeTotal = this.timeOne * this.arrItem.length;
				this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			}// else throw new Error("no or empty data");
		}
		
		protected function get lengthArrItemInField(): Number {
			return this.arrData.length;
		}
		
		private function createItems(): void {
			var countItems: uint = 0;
			do countItems += this.arrData.length;
			while (countItems < this.arrItemInField.length); //ręczne zduplikowanie itemów, jeśli jest ich za mało, aby wypełnić wszystkie pola
			this.arrItem = new Array(countItems);
			this.containerItem = new Sprite();
			var classForItem: Class = this.getClassForItem();
			for (var i: uint = 0; i < countItems; i++) {
				var item: ItemGallery = new classForItem(i, this.arrData[i % this.arrData.length]);
				this.initItem(item);
				this.arrItem[i] = item;
			}
			this.addChild(this.containerItem);
		}
		
		protected function getClassForItem(): Class {
			return ItemGallery;
		}
		
		protected function initItem(item: ItemGallery): void {
			this.containerItem.addChild(item);
		}
		
		private function removeItems(): void {
			for (var i: uint = 0; i < this.arrItem.length; i++) {
				var item: ItemGallery = this.arrItem[i];
				item.destroy();
				if (this.containerItem.contains(item)) this.containerItem.removeChild(item);
			}
			this.arrItem = [];
			this.removeChild(this.containerItem);
		}
		
		protected function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.showItems();
		}
		
		protected function showItems(): void {
			this.setInitialTime();
			this.addControllers();
			this.addEventListener(EventGallery.RENDER, this.onRender)
		}
		
		private function onRender(e: EventGallery):void {
			this.time = this.time;
		}
		
		private function setInitialTime(): void {
			this._time = MathExt.moduloPositive( -this.numFieldForItemSelected * this.timeOne, this.timeTotal);
			this.numItemSelected = -1;
			this.addEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.onItemSelected)
			this.dispatchEvent(new EventGallery(EventGallery.SELECTED_ITEM_CHANGED, this.numFirstItemSelected));
		}
		
		private function addControllers(): void {
			if (this.arrData.length > 1) {
				if (this.optionsController.isArrow) this.createArrows();
				if (this.optionsController.isMouseWheel) this.initMouseWheel();
				if (this.optionsController.isAutoChangeItem) this.initAutoChangeItem();
			}
			this.dispatchEvent(new EventGallery(EventGallery.SELECTED_ITEM_CHANGED, this.numFirstItemSelected));
		}
		
		//arrows
		
		private var containerBtnArrow: Sprite;
		protected var arrBtnArrowPrevNext: Array;
		
		private function createArrows(): void {
			this.arrBtnArrowPrevNext = new Array(2);
			this.containerBtnArrow = new Sprite();
			for (var i: uint = 0; i < this.arrBtnArrowPrevNext.length; i++) {
				var classBtnArrowPrevNext: Class = this.getClassForBtnArrowPrevNext();
				var btnArrowPrevNext: BtnArrow = new classBtnArrowPrevNext(i);
				btnArrowPrevNext.isEnabled = true;
				btnArrowPrevNext.addEventListener(BtnHitEvent.CLICKED, this.onBtnArrowClicked);
				this.containerBtnArrow.addChild(btnArrowPrevNext);	
				this.arrBtnArrowPrevNext[i] = btnArrowPrevNext;
			}
			this.addChild(this.containerBtnArrow);
			this.setPositionArrowsInit();
		}
		
		protected function getClassForBtnArrowPrevNext(): Class {
			return BtnArrow;
		}
		
		protected function setPositionArrowsInit(): void { }
		
		protected function setPositionArrowsOnItem(): void {}

		protected function onBtnArrowClicked(e: BtnHitEvent): void {
			this.selectPrevNextItem(BtnArrow(e.target).isPrevNext);
		}
		
		private function removeArrows(): void {
			for (var i: uint = 0; i < this.arrBtnArrowPrevNext.length; i++) {
				var btnArrowPrevNext: BtnArrow = this.arrBtnArrowPrevNext[i];
				btnArrowPrevNext.destroy();
				this.containerBtnArrow.removeChild(btnArrowPrevNext);
				btnArrowPrevNext = null;
			}
			this.arrBtnArrowPrevNext = [];
			this.removeChild(this.containerBtnArrow);
		}
		
		//mouse wheel
		
		private var isActiveWheel: Boolean;
		
		private function initMouseWheel(): void {
			this.isActiveWheel = true;
			var intrObjForMouseWheel: InteractiveObject;
			if (this.optionsController.isSetMouseWheelOnStage) intrObjForMouseWheel = this.stage;
			else intrObjForMouseWheel = this.containerItem;
			intrObjForMouseWheel.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
		}
		
		private function onMouseWheel(e: MouseEvent): void {
			e.stopPropagation();
			if (this.isActiveWheel) {
				this.isActiveWheel = false;
				this.selectPrevNextItem(uint(e.delta < 0));
				setTimeout(this.setActiveWheel, 50);
			}
		}
		
		private function setActiveWheel(): void {
			this.isActiveWheel = true;
		}
		
		private function removeMouseWheel(): void {
			var intrObjForMouseWheel: InteractiveObject;
			if (this.optionsController.isSetMouseWheelOnStage) intrObjForMouseWheel = this.stage;
			else intrObjForMouseWheel = this.containerItem;
			intrObjForMouseWheel.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
		}
		
		//mouse move
		
		//automate change items
		
		private var timeoutChangeItemFirstTime: uint;
		private var intervalChangeItem: uint;
		
		private function initAutoChangeItem(): void {
			this.addEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.waitAndSetAutoChangeItemOnItemChanged)
		}
		
		private function waitAndSetAutoChangeItemOnItemChanged(e: EventGallery): void {
			clearInterval(this.intervalChangeItem);
			clearTimeout(this.timeoutChangeItemFirstTime);
			this.timeoutChangeItemFirstTime = setTimeout(this.changeItemFirstTime, this.optionsController.timeChangeItemFirstTime);
		}
		
		private function changeItemFirstTime(): void {
			this.autoChangeItem();
			clearInterval(this.intervalChangeItem);
			this.intervalChangeItem = setInterval(this.autoChangeItem, this.optionsController.timeChangeItem);
		}
		
		private function autoChangeItem(): void {
			this.removeEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.waitAndSetAutoChangeItemOnItemChanged);
			this.selectPrevNextItem(1);
			this.addEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.waitAndSetAutoChangeItemOnItemChanged);
		}
		
		private function removeAutoChangeItem(): void {
			clearInterval(this.intervalChangeItem);
			clearTimeout(this.timeoutChangeItemFirstTime);
			this.removeEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.waitAndSetAutoChangeItemOnItemChanged)
		}
		
		//changing Items
		
		private function selectPrevNextItem(isPrevNext: uint): void {
			var numItemSelected: uint;
			if (isPrevNext == 0) numItemSelected = (this.numItemSelected > 0) ? this.numItemSelected - 1 : this.arrItem.length - 1;
			else if (isPrevNext == 1) numItemSelected = (this.numItemSelected < this.arrItem.length - 1) ? this.numItemSelected + 1 : 0;
			this.dispatchEvent(new EventGallery(EventGallery.SELECTED_ITEM_CHANGED, numItemSelected));
		}
		
		protected function onItemSelected(e: EventGallery): void {
			var numItemSelected: uint = uint(e.data);
			//if (numItemSelected != this.numItemSelected) {
				if (this.numItemSelected != -1) ItemGallery(this.arrItem[this.numItemSelected]).selected = false;
				this.numItemSelected = numItemSelected;
				ItemGallery(this.arrItem[this.numItemSelected]).selected = true;
				var timeNumItemSelected: Number = MathExt.moduloPositive((this.numItemSelected - this.numFieldForItemSelected) * this.timeOne, this.timeTotal);
				var diffTimeGlobal: Number = MathExt.minDiffWithSign(timeNumItemSelected, this.time, this.timeTotal);
				TweenMax.to(this, Math.abs(diffTimeGlobal) / this.timeOne * this.optionsVisual.timeMoveOneItem, {time: this.time + diffTimeGlobal, ease: Quad.easeOut});
				if (this.optionsController.isArrow) this.setPositionArrowsOnItem();
			//}
		}
		
		public function get time(): Number {
			return this._time;
		} 
		
		public function set time(value: Number): void {
			this._time = MathExt.moduloPositive(value, this.timeTotal) + 0.000001;
			var numItemFirst: Number = Math.floor(this._time / this.timeOne);
			var itemInField: ItemGallery;
			var i: uint;
			//set time
			for (i = 0; i < this.arrItemInField.length; i++) {
				itemInField = this.arrItem[(numItemFirst + i) % this.arrItem.length];
				itemInField.time = this.timeOne * (i + 1) - this._time % this.timeOne;
			}
			this.manageArrItemInField(numItemFirst);
			//render
			for (i = 0; i < this.arrItemInField.length; i++) {
				itemInField = this.arrItem[(numItemFirst + i) % this.arrItem.length];
				itemInField.render(itemInField.time, this.timeOne);
				this.arrItemInField[i] = itemInField;
			}
			//depth management
			if (this.optionsVisual.isDepthManagement) {
				/*var countDoubleItemsFromSelected: uint = MathExt.minDiff(this.numFieldForItemSelected, 0, this.arrItemInField.length)
				for (i = 0; i < this.arrItemInField.length; i++) {
					itemInField = this.arrItemInField[i];
					var diffItemInFieldAndItemSelected: uint = Math.abs(this.numFieldForItemSelected - i);
					this.containerItem.setChildIndex(itemInField, this.arrItemInField.length - (diffItemInFieldAndItemSelected + Math.min(diffItemInFieldAndItemSelected, countDoubleItemsFromSelected) - uint(i < this.numFieldForItemSelected)) - 1 + Math.round(itemInField.time));
				}*/
				var timeForItemSelected: Number = (this.numFieldForItemSelected + 1) / this.arrItemInField.length;
				var arrDiffTimeForItemInField: Array = new Array(this.arrItemInField.length);
				for (i = 0; i < this.arrItemInField.length; i++) {
					itemInField = this.arrItemInField[i];
					arrDiffTimeForItemInField[i] = {numItemInField: i, diffTime: MathExt.minDiff(itemInField.time, timeForItemSelected, 1)};
				}
				arrDiffTimeForItemInField.sortOn("diffTime", Array.NUMERIC | Array.DESCENDING);
				for (i = 0; i < arrDiffTimeForItemInField.length; i++) {
					itemInField = this.arrItemInField[arrDiffTimeForItemInField[i].numItemInField];
					this.containerItem.setChildIndex(itemInField, i);
				}
			}
			if (this.arrItemInField.length < this.lengthArrItemInField) this.arrItemInField.length = this.lengthArrItemInField;
		}
		
		protected function manageArrItemInField(numItemFirst: Number): void {}
		
		public function destroy(): void {
			if ((this.arrData) && (this.arrData.length)) {
				this.removeItems();
				this.removeEventListener(EventGallery.SELECTED_ITEM_CHANGED, this.onItemSelected);
				if (this.arrData.length > 1) {
					if (this.optionsController.isAutoChangeItem) this.removeAutoChangeItem();
					if (this.optionsController.isMouseWheel) this.removeMouseWheel();
					if (this.optionsController.isArrow) this.removeArrows();
				}
				TweenMax.killTweensOf(this);
			}
		}
		
	}

}