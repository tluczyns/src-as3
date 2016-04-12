package base.vspm {
	import base.types.Singleton;
	import flash.utils.Dictionary;
	//import base.types.DictionaryExt;
	import flash.display.DisplayObjectContainer;

	public class ManagerPopup extends Singleton {
		
		//static private var _dictDescriptionViewPopup: DictionaryExt = new DictionaryExt();
		static private var _dictDescriptionViewPopup: Dictionary = new Dictionary();
		static public var dspObjContainerPopup: DisplayObjectContainer;
		
		static public function init(dspObjContainerPopup: DisplayObjectContainer): void {
			ManagerPopup.dspObjContainerPopup = dspObjContainerPopup;
			StateModel.addEventListener(EventStateModel.PARAMETERS_CHANGE, ManagerPopup.checkAndHideOrShowPopupsOnParametersChange);
		}
		
		static private function checkAndHideOrShowPopupsOnParametersChange(e: EventStateModel):void {
			for (var ind: String in ManagerPopup._dictDescriptionViewPopup) {
				var descriptionViewPopup: DescriptionViewPopup = ManagerPopup._dictDescriptionViewPopup[ind];
				descriptionViewPopup.checkAndHideShowView();
			}
		}
		
		static public function get dictDescriptionViewPopup(): Dictionary { //DictionaryExt
			return ManagerPopup._dictDescriptionViewPopup;
		}
		
	}
	
}