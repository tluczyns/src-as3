package base.mvc.section {
	import flash.display.DisplayObjectContainer;

	public class DescriptionViewPopup extends Object {
		
		private var objParamsWithValuesToShow: Object;
		public var ind: String;
		public var nameClass: Class;
		public var x: Number;
		public var y: Number;
		public var containerPopup: DisplayObjectContainer;
		public var viewPopup: ViewPopup;
		
		public function DescriptionViewPopup(objParamsWithValuesToShow: Object, ind: String, nameClass: Class, x: Number = 0, y: Number = 0, containerPopup: DisplayObjectContainer = null): void {
			this.objParamsWithValuesToShow = objParamsWithValuesToShow || {};
			this.ind = ind;
			this.nameClass = nameClass;
			this.x = x;
			this.y = y;
			this.containerPopup = containerPopup;
			this.viewPopup = null;
			ModelPopup.addPopupDescription(this);
		}
		
		internal function checkAndHideShowView(): void {
			var isHideShow: uint = 1;
			for (var param: String in this.objParamsWithValuesToShow) {
				var valueParam: * = this.objParamsWithValuesToShow[param];
				var classValueParam: Class;
				if (valueParam == undefined) valueParam = 0;
				if ((!isNaN(Number(valueParam))) && (valueParam != "")) classValueParam = Number;
				else classValueParam = String;
				var valueParamModel: * = ModelSection.parameters[param]
				if (valueParamModel == undefined) valueParamModel = 0;
				if (classValueParam(valueParamModel) != classValueParam(valueParam)) isHideShow = 0;
			}
			if (isHideShow == 0) {
				if (this.viewPopup) this.viewPopup.hide();
			} else if (isHideShow == 1) this.createAndShowViewPopup();
		}
		
		protected function createViewPopupInstance(): ViewPopup {
			return new this.nameClass();
		}
		
		private function getContainerViewPopup(): DisplayObjectContainer {
			return (this.containerPopup != null) ? this.containerPopup : ModelPopup.dspObjContainerPopup;
		}
		
		private function createAndShowViewPopup(): void {
			if (this.viewPopup == null) this.createViewPopup();
			this.viewPopup.show();
		}

		private function createViewPopup(): void {
			var containerPopup: DisplayObjectContainer = this.getContainerViewPopup();
			this.viewPopup = this.createViewPopupInstance();
			this.viewPopup.descriptionViewPopup = this;
			this.viewPopup.x = this.x;
			this.viewPopup.y = this.y;
			containerPopup.addChild(this.viewPopup);
			containerPopup.setChildIndex(this.viewPopup, containerPopup.numChildren - 1);
			this.viewPopup.init();
			this.trackPageView();
		}
		
		protected function trackPageView(): void {
			ModelSection.trackPageview("popup_" + this.ind);
		}
		
		public function removeViewPopup(): void {
			var containerPopup: DisplayObjectContainer = this.getContainerViewPopup();
			if (this.viewPopup != null) {
				containerPopup.removeChild(this.viewPopup);
				this.viewPopup = null;
			}
		}
		
	}

}