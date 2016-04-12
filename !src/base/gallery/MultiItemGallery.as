package base.gallery {
	import base.btn.BtnHitWithEvents;
	import flash.display.Sprite;
	import base.btn.BtnHitEvent;
	import base.math.MathExt;
	import flash.text.TextField;
	import base.tf.TextFieldUtils;
	import flash.text.TextFormat;
	import base.vspm.SWFAddress;
	
	public class MultiItemGallery extends BtnHitWithEvents implements IRenderable {
		
		public var id: String;
		private var nameParamItem: String;
		protected var objData: Object;
		private var _vecNumInDimension: Vector.<uint>;
		protected var startNumDimensionToRender: uint;
		protected var vecTimeRender: Vector.<Number>;
		protected var vecTimeTotal: Vector.<Number>;
		private var _vecNumInRow: Vector.<uint>;
		protected var _selected: Boolean;
		
		private var tf: TextField;
		
		public function MultiItemGallery(id: String, nameParamItem: String, objData: Object = null, hit: Sprite = null): void {
			this.id = id;
			this.nameParamItem = nameParamItem;
			this.objData = objData;
			this.vecTimeRender = new Vector.<Number>();
			this.vecTimeTotal = new Vector.<Number>();
			super(hit);
			//ModelSection.addEventListener(EventModelSection.PARAMETERS_CHANGE, this.selectItem);
			this.addEventListener(BtnHitEvent.CLICKED, this.onClicked);
		}
		
		static public function getIdWithoutSuff(id: String): String {
			var indCloneCharInId: int = id.indexOf(MultiCircleGallery.ARR_CHAR_DIMENSION_TO_ID_WHEN_CLONE[0]);
			var idWithoutStuff: String = id;
			if (indCloneCharInId > -1)
				idWithoutStuff = idWithoutStuff.substring(0, indCloneCharInId);
			return idWithoutStuff;
		}
		
		public function get idWithoutSuff(): String {
			return MultiItemGallery.getIdWithoutSuff(this.id);
		}
		
		protected function draw(): void {
			this.graphics.beginFill(uint(this.objData.value), 1);
			this.graphics.drawRect(-50, -50, 100, 100);
			this.graphics.endFill();
			this.tf = TextFieldUtils.createTextField(new TextFormat(null, 20, 0xffffff, null, null, null, null, null, "center"), 0, 1);
			this.tf.width = 100;
			this.tf.x = this.tf.y = -50;
			this.addChild(this.tf);
			this.setChildIndex(this.hit, this.numChildren - 1)
			this.hit.graphics.clear();
			this.hit.graphics.copyFrom(this.graphics)
		}
		
		public function renderInternal(vecTimeRender: Vector.<Number>, startNumDimensionToRender: uint, vecTimeTotal: Vector.<Number>): void {
			//trace("item render: ", vecTimeRender, startNumDimensionToRender, this.vecTimeRender)
			this.startNumDimensionToRender = startNumDimensionToRender;
			this.vecTimeRender.length = Math.max(this.vecTimeRender.length, startNumDimensionToRender + vecTimeRender.length);
			this.vecTimeTotal.length = Math.max(this.vecTimeTotal.length, startNumDimensionToRender + vecTimeTotal.length);
			for (var i: uint = 0; i < vecTimeRender.length; i++) {
				this.vecTimeRender[startNumDimensionToRender + i] = vecTimeRender[i];
				this.vecTimeTotal[startNumDimensionToRender + i] = vecTimeTotal[i];
			}
			i = 0;
			while ((i < this.vecTimeRender.length) && (this.vecTimeRender[i] == 0)) i++;
			this.selected = (i == this.vecTimeRender.length);
			this.render();
		}
		
		protected function render(): void {
			for (var i: uint = 0; i < vecTimeRender.length; i++) {
				vecTimeRender[i] = MathExt.roundPrecision(vecTimeRender[i], 2)
			}
			this.tf.text = String(vecTimeRender) + "\n" + String(this.vecNumInRow) + "\n" + String(this.vecNumInDimension);
			//this.tf.text = String(this.vecNumInRow);
			for (i = 0; i < this.vecTimeRender.length; i++) {
				var timeRender: Number = this.vecTimeRender[i];
				var timeTotal: Number = this.vecTimeTotal[i];
				//var numDimensionToRender: uint = startNumDimensionToRender + i;
				switch(i) {
					case 0: this.y = (timeRender + 2) * 150; break;
					case 1: this.x = (timeRender + 2) * 250; break;
					//case 2: this.z = (timeRender + 2) * 250; this.z = (timeRender + 2) * 100; break;
				}
			}
			//trace("pos:", this.x, this.y, this.parent, this.vecNumInDimension)
			//this.scaleX = this.scaleY = 3 * (1 - Math.abs(0.5 - time))
			//this.rotationY = - 90 + time * 180;
		}
		
		protected function removeDraw(): void {
			//this.graphics.clear();
		}
		
		//selected
		
		/*private function selectItem(e: EventGalleryMulti): void {
			var idItemSelected: String = ModelSection.parameters[this.nameParamItem];
			if (idItemSelected)
				this.selected = (idItemSelected == this.id)
		}*/
		
		protected function get selected(): Boolean {
			return this._selected;
		}
		
		protected function set selected(value: Boolean): void {
			this._selected = value;
			//TextFieldUtils.changeTFormatPropsInTf(this.tf, {color: [0xffffff, 0x000000][uint(value)]})
		}
		
		//
		
		public function get vecNumInDimension(): Vector.<uint> {return this._vecNumInDimension;}
		
		public function set vecNumInDimension(value: Vector.<uint>): void { 
			this._vecNumInDimension = value; 
			this.draw();
		}
		
		public function get vecNumInRow(): Vector.<uint> {return this._vecNumInRow;}
		
		public function set vecNumInRow(value: Vector.<uint>): void {this._vecNumInRow = value;}
		
		protected function onClicked(e: BtnHitEvent): void {
			if (!this.selected) {
				SWFAddress.setCurrentSwfAddressValueWithParameters(this.prepareObjParamItemForClick(), false);
			} else this.onClickedWhenSelected();	
		}
		
		protected function prepareObjParamItemForClick(): Object {
			var objParamItem: Object = {};
			objParamItem[this.nameParamItem] = this.id;
			return objParamItem;
		}
		
		protected function onClickedWhenSelected(): void {}
		
		override public function destroy(): void {
			this.removeEventListener(BtnHitEvent.CLICKED, this.onClicked);
			//ModelSection.removeEventListener(EventModelSection.PARAMETERS_CHANGE, this.selectItem);
			this.removeDraw();
			super.destroy();
		}
		
	}

}