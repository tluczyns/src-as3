package base.mvc.section {
	import com.adobe.utils.ArrayUtil;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.events.MouseEvent;
	import base.mvc.swfAddress.SWFAddress;

	public class ControllerSection extends MovieClip {
		
		public static var isUnselectParentControllers: Boolean = true;
		
		private var _hitAbstract: Sprite;
		public var ind: String;
		private var _isSelected: Boolean;
		
		public static var dictIndViewSectionToArrControllerSection: Dictionary;
		{
			ControllerSection.dictIndViewSectionToArrControllerSection = new Dictionary();
			ModelSection.addEventListener(EventModelSection.CHANGE_CURR_SECTION, ControllerSection.selectAndUnselectControllerSection);
		}
		
		public function ControllerSection(controllerSectionDescription: ControllerSectionDescription, viewSectionDescription: DescriptionViewSection): void {
			this.x = controllerSectionDescription.x;
			this.y = controllerSectionDescription.y;
			if (viewSectionDescription != null) {
				this.ind = viewSectionDescription.ind;
				ViewSectionManager.addSectionDescription(viewSectionDescription);
			}
			if (viewSectionDescription != null) {
				if (ControllerSection.dictIndViewSectionToArrControllerSection[viewSectionDescription.ind] == null) ControllerSection.dictIndViewSectionToArrControllerSection[viewSectionDescription.ind] = new Array();
				ControllerSection.dictIndViewSectionToArrControllerSection[viewSectionDescription.ind].push(this);
			}
			this.addMouseEvents();
		}
		
		private static function selectAndUnselectControllerSection(e: EventModelSection): void {
			var oldIndSection: String = String(e.data.oldIndSection);
			var newIndSection: String = String(e.data.newIndSection);
			if ((ControllerSection.isUnselectParentControllers) || (!ViewSectionManager.isEqualsElementsIndSection(oldIndSection, newIndSection))) {
				var arrOldControllerSection: Array = ControllerSection.dictIndViewSectionToArrControllerSection[oldIndSection];
				if (arrOldControllerSection != null) for (var i:uint = 0; i < arrOldControllerSection.length; i++) {
					var oldControllerSection: ControllerSection	= arrOldControllerSection[i];
					if (oldControllerSection.isSelected) oldControllerSection.isSelected = false;
				}
			}
			var arrNewControllerSection: Array = ControllerSection.dictIndViewSectionToArrControllerSection[newIndSection];
			if (arrNewControllerSection != null) for (i = 0; i < arrNewControllerSection.length; i++) {
				var newControllerSection: ControllerSection = arrNewControllerSection[i];
				if (!newControllerSection.isSelected) newControllerSection.isSelected = true;
			}
		}
		
		public function get hit(): Sprite {
			return this._hitAbstract;
		}
		
		public function addMouseEvents(): void {
			if (!this.hit.buttonMode) {
				this.hit.buttonMode = true;
				this.hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.addEventListener(MouseEvent.CLICK, this.onClickHandler);
			}
		}
		
		public function removeMouseEvents(): void {
			if (this.hit.buttonMode) {
				this.hit.buttonMode = false;
				this.hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
				this.hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
				this.hit.removeEventListener(MouseEvent.CLICK, this.onClickHandler);
			}
		}
		
		protected function onMouseOverHandler(event: MouseEvent): void {}
		
		protected function onMouseOutHandler(event: MouseEvent): void {}
		
		protected function onClickHandler(event: MouseEvent): void {
			SWFAddress.setValue(this.ind);
		}
		
		public function get isSelected(): Boolean {
			return this._isSelected;
		}
		
		public function set isSelected(value: Boolean): void {
			this._isSelected = value;
		}
		
		public function destroy(): void {
			this.removeMouseEvents();
			ArrayUtil.removeValueFromArray(ControllerSection.dictIndViewSectionToArrControllerSection[this.ind], this);
		}
		
	}
	
}