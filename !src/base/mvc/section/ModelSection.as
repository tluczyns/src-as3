package base.mvc.section {
	import base.types.Singleton;
	import flash.events.EventDispatcher;
	import base.mvc.swfAddress.SWFAddress;
	import base.mvc.swfAddress.SWFAddressEvent;
	//import com.google.analytics.GATracker;
	//import base.omniture.OmnitureTracker;

	public class ModelSection extends Singleton {
		
		private static var modelDispatcher: EventDispatcher = new EventDispatcher();
		
		private static var _parameters: Object	= {}
		public static var gaTracker: *; //GATracker;
		public static var omnitureTracker: *; //OmnitureTracker;
		
		public static function init(): void {
			if (!SWFAddress.hasEventListener(SWFAddressEvent.CHANGE))
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, ModelSection.handleSWFAddress);
		}
		
		public static function addEventListener(type: String, func: Function, priority: int = 0): void {
			ModelSection.modelDispatcher.addEventListener(type, func, false, priority);
		}
		
		public static function removeEventListener(type: String, func: Function): void {
			ModelSection.modelDispatcher.removeEventListener(type, func);
		}
		
		public static function dispatchEvent(type: String, data: * = null): void {
			ModelSection.modelDispatcher.dispatchEvent(new EventModelSection(type, data));
		}
		
		public static function get parameters(): Object { 
			return ModelSection._parameters;
		}
		
		static public function trackPageview(indPage: String): void {
			//trace("trackPageview:", indPage)
			if (ModelSection.gaTracker) ModelSection.gaTracker["trackPageview"](indPage);
			if (ModelSection.omnitureTracker) ModelSection.omnitureTracker["trackPageview"](indPage);
		}
		
		private static function handleSWFAddress(e: SWFAddressEvent): void {
			/*var currentSwfAddressValue: String = SWFAddress.getValue();
			if ((currentSwfAddressValue != ModelSection.currentSwfAddressValue) || (ViewSectionManager.isForceReload)) {*/
			var oldParameters: Object = ModelSection._parameters;
			ModelSection._parameters = SWFAddress.getParametersObject();
			var currentSwfAddressPath: String = SWFAddress.getPath();
			//trace("SWFAddress.getValue():", SWFAddress.getValue())
			var indSectionAlias: String = ViewSectionManager.joinIndSectionFromArrElement(ViewSectionManager.splitIndSectionFromStr(currentSwfAddressPath));
			var indSection: String;
			if ((LoaderXMLContentViewSection.dictAliasIndToIndSection) && (LoaderXMLContentViewSection.dictAliasIndToIndSection[indSectionAlias])) indSection = LoaderXMLContentViewSection.dictAliasIndToIndSection[indSectionAlias];
			else indSection = indSectionAlias;
			if ((indSection != "") && (indSection != ViewSectionManager.currIndSection)) {
				var descriptionViewSection: DescriptionViewSection = ViewSectionManager.dictDescriptionViewSection[indSection];
				if ((descriptionViewSection) && (descriptionViewSection is DescriptionViewSectionWithContent)) {
					var contentViewSection: ContentViewSection = DescriptionViewSectionWithContent(descriptionViewSection).content;
					if ((!uint(contentViewSection.isNotOmniture)) && (!((uint(contentViewSection.isOnlyForwardOmniture)) && (ViewSectionManager.isEqualsElementsIndSection(indSection, ViewSectionManager.currIndSection)))))
						ModelSection.trackPageview(indSectionAlias);
				}
			}
			if ((indSection == "") && (ViewSectionManager.startIndSection != "")) SWFAddress.setValue(ViewSectionManager.startIndSection);
			else ModelSection.dispatchEvent(EventModelSection.START_CHANGE_SECTION, {oldIndSection: ViewSectionManager.currIndSection, newIndSection: indSection});
			ModelSection.dispatchEvent(EventModelSection.PARAMETERS_CHANGE, {oldParameters: oldParameters, oldIndSection: ViewSectionManager.currIndSection, newIndSection: indSection});
		}
		
	}

}