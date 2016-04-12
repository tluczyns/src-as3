package base.vspm {
	import base.types.Singleton;
	import flash.events.EventDispatcher;
	//import com.google.analytics.GATracker;
	//import base.omniture.OmnitureTracker;

	public class StateModel extends Singleton {
		
		private static var dispatcher: EventDispatcher = new EventDispatcher();
		
		private static var _parameters: Object	= {}
		public static var gaTracker: *; //GATracker;
		public static var omnitureTracker: *; //OmnitureTracker;
		
		public static function init(): void {
			if (!SWFAddress.hasEventListener(SWFAddressEvent.CHANGE))
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, StateModel.handleSWFAddress);
		}
		
		public static function addEventListener(type: String, func: Function, priority: int = 0): void {
			StateModel.dispatcher.addEventListener(type, func, false, priority);
		}
		
		public static function removeEventListener(type: String, func: Function): void {
			StateModel.dispatcher.removeEventListener(type, func);
		}
		
		public static function dispatchEvent(type: String, data: * = null): void {
			StateModel.dispatcher.dispatchEvent(new EventStateModel(type, data));
		}
		
		public static function get parameters(): Object { 
			return StateModel._parameters;
		}
		
		static public function trackPageview(indPage: String): void {
			//trace("trackPageview:", indPage)
			if (StateModel.gaTracker) StateModel.gaTracker["trackPageview"](indPage);
			if (StateModel.omnitureTracker) StateModel.omnitureTracker["trackPageview"](indPage);
		}
		
		private static function handleSWFAddress(e: SWFAddressEvent): void {
			/*var currentSwfAddressValue: String = SWFAddress.getValue();
			if ((currentSwfAddressValue != StateModel.currentSwfAddressValue) || (ManagerSection.isForceReload)) {*/
			var oldParameters: Object = StateModel._parameters;
			StateModel._parameters = SWFAddress.getParametersObject();
			var currentSwfAddressPath: String = SWFAddress.getPath();
			//trace("SWFAddress.getValue():", SWFAddress.getValue())
			var indSectionAlias: String = ManagerSection.joinIndSectionFromArrElement(ManagerSection.splitIndSectionFromStr(currentSwfAddressPath));
			var indSection: String;
			if ((LoaderXMLContentView.dictAliasIndToIndSection) && (LoaderXMLContentView.dictAliasIndToIndSection[indSectionAlias])) indSection = LoaderXMLContentView.dictAliasIndToIndSection[indSectionAlias];
			else indSection = indSectionAlias;
			if ((indSection != "") && (indSection != ManagerSection.currIndSection)) {
				var descriptionViewSection: DescriptionViewSection = ManagerSection.dictDescriptionViewSection[indSection];
				if (descriptionViewSection) {
					var contentViewSection: ContentViewSection = ContentViewSection(descriptionViewSection.content);
					if ((contentViewSection) && (!uint(contentViewSection.isNotTrack)) && (!((uint(contentViewSection.isOnlyForwardTrack)) && (ManagerSection.isEqualsElementsIndSection(indSection, ManagerSection.currIndSection)))))
						StateModel.trackPageview(indSectionAlias);
				}
			}
			if ((indSection == "") && (ManagerSection.startIndSection != "")) SWFAddress.setValue(ManagerSection.startIndSection);
			else StateModel.dispatchEvent(EventStateModel.START_CHANGE_SECTION, {oldIndSection: ManagerSection.currIndSection, newIndSection: indSection});
			StateModel.dispatchEvent(EventStateModel.PARAMETERS_CHANGE, {oldParameters: oldParameters, oldIndSection: ManagerSection.currIndSection, newIndSection: indSection});
		}
		
	}

}