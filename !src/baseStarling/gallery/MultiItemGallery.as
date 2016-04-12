package baseStarling.gallery {
	import baseStarling.btn.BtnHitWithEvents;
	import starling.display.Shape;
	import starling.text.TextField;
	import baseStarling.btn.EventBtnHit;
	import baseStarling.tf.TextFieldUtils;
	import starling.utils.HAlign;
	import base.math.MathExt;
	import baseStarling.vspm.SWFAddress;
	
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
		
		private var shp: Shape;
		private var tf: TextField;
		
		public function MultiItemGallery(id: String, nameParamItem: String, objData: Object = null, hit: Shape = null): void {
			this.id = id;
			this.nameParamItem = nameParamItem;
			this.objData = objData;
			this.vecTimeRender = new Vector.<Number>();
			this.vecTimeTotal = new Vector.<Number>();
			super(hit);
			//ModelSection.addEventListener(EventModelSection.PARAMETERS_CHANGE, this.selectItem);
			this.addEventListener(EventBtnHit.RELEASE, this.onRelease);
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
			this.shp = new Shape();
			this.shp.graphics.beginFill(uint(this.objData.value), 1);
			this.shp.graphics.drawRect(-50, -50, 100, 100);
			this.shp.graphics.endFill();
			this.addChild(this.shp);
			this.tf = TextFieldUtils.createTextField({width: 100, height: 100, fontSize: 17, color: 0xffffff, hAlign: HAlign.CENTER, multiline: true});
			this.tf.x = this.tf.y = -50;
			this.addChild(this.tf);
			this.setChildIndex(this.hit, this.numChildren - 1)
			this.hit.graphics.clear();
			this.hit.graphics.beginFill(0, 0);
			this.hit.graphics.drawRect(-50, -50, 100, 100);
			this.hit.graphics.endFill();
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
			this.renderItem();
		}
		
		protected function renderItem(): void {
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
			this.removeChild(this.shp);
			this.shp.graphics.clear();
			this.shp.dispose();
			this.shp = null;
			this.removeChild(this.tf);
			this.tf.dispose();
			this.tf = null;
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
		
		protected function onRelease(e: EventBtnHit): void {
			if (!this.selected) {
				SWFAddress.setCurrentSwfAddressValueWithParameters(this.prepareObjParamItemForClick(), false);
			} else this.onReleaseWhenSelected();	
		}
		
		protected function prepareObjParamItemForClick(): Object {
			var objParamItem: Object = {};
			objParamItem[this.nameParamItem] = this.id;
			return objParamItem;
		}
		
		protected function onReleaseWhenSelected(): void {}
		
		override public function dispose(): void {
			this.removeEventListener(EventBtnHit.RELEASE, this.onRelease);
			//ModelSection.removeEventListener(EventModelSection.PARAMETERS_CHANGE, this.selectItem);
			this.removeDraw();
			super.dispose();
		}
		
	}

}