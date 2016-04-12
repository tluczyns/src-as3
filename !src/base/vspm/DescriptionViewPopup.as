package base.vspm {
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	//import base.types.DictionaryExt;

	public class DescriptionViewPopup extends DescriptionView {
		
		public var objParamsWithValuesToShow: Object;
		
		public function DescriptionViewPopup(ind: String, nameClass: Class, content: ContentViewPopup, objParamsWithValuesToShow: Object, x: Number = 0, y: Number = 0, containerViewSection: DisplayObjectContainer = null): void {
			this.objParamsWithValuesToShow = objParamsWithValuesToShow || {};
			super(ind, nameClass, content, x, y, containerViewSection); 
		}
		
		override protected function getDictDescriptionViewInManager(): Dictionary { //DictionaryExt
			return ManagerPopup.dictDescriptionViewPopup;
		}
		
		internal function checkAndHideShowView(): void {
			var isHideShow: uint = 1;
			for (var param: String in this.objParamsWithValuesToShow) {
				var valueParam: * = this.objParamsWithValuesToShow[param];
				var classValueParam: Class;
				if (valueParam == undefined) valueParam = 0;
				if ((!isNaN(Number(valueParam))) && (valueParam != "")) classValueParam = Number;
				else classValueParam = String;
				var valueParamModel: * = StateModel.parameters[param]
				if (valueParamModel == undefined) valueParamModel = 0;
				if (classValueParam(valueParamModel) != classValueParam(valueParam)) isHideShow = 0;
			}
			if (isHideShow == 0) { 
				if (this.view) this.view.hide();
			} else if (isHideShow == 1) this.createView();
		}
		
		override protected function createViewInstance(): View { //ViewPopup
			return new this.nameClass(this.content);
		}
		
		override protected function getDefaultContainerView(): DisplayObjectContainer {
			return ManagerPopup.dspObjContainerPopup;
		}
		
		override public function createView(): void {
			if (this.view == null) super.createView();
			if (this.view) {
				this.trackPageView();
				this.view.show();
			}
		}
		
		private function trackPageView(): void {
			if (!uint(this.content.isNotTrack)) 
				StateModel.trackPageview("popup_" + this.ind);
		}
		
	}

}