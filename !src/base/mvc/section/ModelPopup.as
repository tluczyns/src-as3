package base.mvc.section {
	import base.types.Singleton;
	import flash.display.DisplayObjectContainer;

	public class ModelPopup extends Singleton {
		
		static public var dspObjContainerPopup: DisplayObjectContainer;
		static private var _vecDescriptionViewPopup: Vector.<DescriptionViewPopup>;
		
		static public function init(): void {
			ModelPopup._vecDescriptionViewPopup = new Vector.<DescriptionViewPopup>();
			ModelSection.addEventListener(EventModelSection.PARAMETERS_CHANGE, ModelPopup.checkAndHideOrShowPopupsOnParametersChange);
		}
		
		static public function addPopupDescription(descriptionViewPopup: DescriptionViewPopup): void {
			ModelPopup._vecDescriptionViewPopup.push(descriptionViewPopup);
		}
		
		static private function checkAndHideOrShowPopupsOnParametersChange(e: EventModelSection):void {
			for (var i: uint = 0; i < ModelPopup._vecDescriptionViewPopup.length; i++) {
				var descriptionViewPopup: DescriptionViewPopup = ModelPopup._vecDescriptionViewPopup[i];
				descriptionViewPopup.checkAndHideShowView();
			}
		}
		
		static public function get vecDescriptionViewPopup(): Vector.<DescriptionViewPopup> {
			return ModelPopup._vecDescriptionViewPopup;
		}
		
	}
	
	ModelPopup.init();
	
}