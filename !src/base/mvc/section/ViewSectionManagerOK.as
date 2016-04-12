package base.mvc.section {
	import base.types.Singleton;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	
	public class ViewSectionManager extends Singleton {
		
		private static var _dictDescriptionViewSection: DictionaryDescriptionViewSection;
		private static var _currIndSection: String = "";
		internal static var dspObjContainerSection: DisplayObjectContainer;
		public static var startIndSection: String;
		public static var newIndSection: String = null;
		public static var oldIndSection: String = null;
		
		public function ViewSectionManager(): void {}
		
		public static function init(dspObjContainerSection: DisplayObjectContainer, startIndSection: String = "", arrMetrics: Array = null): void {
			ViewSectionManager.dspObjContainerSection = dspObjContainerSection;
			ViewSectionManager.startIndSection = startIndSection || ViewSectionManager.startIndSection;
			ModelSection.init();
			arrMetrics = arrMetrics || [];
			for (var i: uint = 0; i < arrMetrics.length; i++) {
				var metrics: DisplayObject = arrMetrics[i];/*Metrics*/
				dspObjContainerSection.addChild(metrics);
				metrics["parse"]();  
			}
			ModelSection.addEventListener(EventModelSection.START_CHANGE_SECTION, ViewSectionManager.changeSection, -1);
		}
		
		public static function addSectionDescription(viewSectionDescription: DescriptionViewSection): void {
			//trace("addSectionDescription:", viewSectionDescription.ind)
			if (!ViewSectionManager._dictDescriptionViewSection) {
				ViewSectionManager._dictDescriptionViewSection = new DictionaryDescriptionViewSection();
				ViewSectionManager.startIndSection = ViewSectionManager.startIndSection || viewSectionDescription.ind;
			}
			ViewSectionManager._dictDescriptionViewSection[viewSectionDescription.ind] = viewSectionDescription;
		}
		
		public static function removeSectionDescription(viewSectionDescription: DescriptionViewSection): void {
			ViewSectionManager._dictDescriptionViewSection[viewSectionDescription.ind] = null;
		}
		
		private static function changeSection(e: EventModelSection): void {
			var newIndSection: String = String(e.data.newIndSection);
			newIndSection = ViewSectionManager.joinIndSectionFromArrElement(ViewSectionManager.splitIndSectionFromStr(newIndSection));
			if (!ViewSectionManager._dictDescriptionViewSection[newIndSection]) {
				if (newIndSection.charAt(newIndSection.length - 1) == "0") newIndSection = newIndSection.substring(0, newIndSection.length - 1); //normalizeNewIndSectionWhenOnlyOneDescriptionWithNum
			}
			//trace("changeSection:", newIndSection, ViewSectionManager._dictDescriptionViewSection[newIndSection], ViewSectionManager.currIndSection)
			if ((ViewSectionManager._dictDescriptionViewSection) && (ViewSectionManager._dictDescriptionViewSection[newIndSection] != undefined)) {
				ViewSectionManager.oldIndSection = ViewSectionManager.currIndSection;
				ViewSectionManager.newIndSection = newIndSection;
				if (ViewSectionManager.currIndSection != "") ViewSectionManager.stopSection();
				else ViewSectionManager.startSection();
			}
		}
		
		public static function startSection(isSetNewIndSectionToNullWhenEqualsCurrIndSection: Boolean = true): void {
			//trace("start:"+ViewSectionManager.currIndSection + ", " +  ViewSectionManager.newIndSection, isSetNewIndSectionToNullWhenEqualsCurrIndSection);
			if (ViewSectionManager.newIndSection != null) {
				if (ViewSectionManager.currIndSection != ViewSectionManager.newIndSection) {
					var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.currIndSection);
					var arrElementNewIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.newIndSection);
					//arrNew nie może być krótsze niż arrCurr
					arrElementCurrIndSection.push(arrElementNewIndSection[arrElementCurrIndSection.length]);
					ViewSectionManager.currIndSection = ViewSectionManager.joinIndSectionFromArrElement(arrElementCurrIndSection);
					var viewSectionDescriptionNew: DescriptionViewSection = ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection];
					if (viewSectionDescriptionNew != null) {
						viewSectionDescriptionNew.createViewSection();
						viewSectionDescriptionNew.viewSection.show();
					} else ViewSectionManager.startSection();
				} else if (isSetNewIndSectionToNullWhenEqualsCurrIndSection) ViewSectionManager.newIndSection = null;
				ViewSectionManager.checkIsStrictEqualsAndDispatchChangeSectionEvent();
			}
		}
		
		private static function stopSection(): void {
			//trace("stop:"+ViewSectionManager.currIndSection +", " +  ViewSectionManager.newIndSection);
			var viewSectionDescriptionCurrent: DescriptionViewSection = DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]);
			if (ViewSectionManager.isNewEqualsCurrentElementsIndSection()) {
				if ((viewSectionDescriptionCurrent != null) && (viewSectionDescriptionCurrent.viewSection != null)) viewSectionDescriptionCurrent.viewSection.show();
				else ViewSectionManager.startSection();
			} else {
				if ((viewSectionDescriptionCurrent != null) && (viewSectionDescriptionCurrent.viewSection != null)) viewSectionDescriptionCurrent.viewSection.hide();
				else ViewSectionManager.finishStopSection();
			}
		}
		
		public static function finishStopSection(): void {
			//trace("finishStop:"+ViewSectionManager.currIndSection +", " +  ViewSectionManager.newIndSection);
			var viewSectionDescriptionToDelete: DescriptionViewSection = DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]);
			if (viewSectionDescriptionToDelete != null) viewSectionDescriptionToDelete.removeViewSection();
			var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.currIndSection);
			arrElementCurrIndSection.splice(arrElementCurrIndSection.length - 1, 1);
			ViewSectionManager.currIndSection = ViewSectionManager.joinIndSectionFromArrElement(arrElementCurrIndSection);
			if (ViewSectionManager.isNewEqualsCurrentElementsIndSection()) ViewSectionManager.startSection();
			else ViewSectionManager.stopSection();
		}
		
		private static function checkIsStrictEqualsAndDispatchChangeSectionEvent(): void {
			if ((ViewSectionManager.currIndSection == ViewSectionManager.newIndSection) || (ViewSectionManager.newIndSection == null))
				ModelSection.dispatchEvent(EventModelSection.CHANGE_SECTION, {oldIndSection: ViewSectionManager.oldIndSection, newIndSection: ViewSectionManager.newIndSection}); 
		}
		
		private static function isNewEqualsCurrentElementsIndSection(): Boolean {
			return ViewSectionManager.isEqualsElementsIndSection(ViewSectionManager.currIndSection, ViewSectionManager.newIndSection);
		}
		//czy current jest zawarty w new
		public static function isEqualsElementsIndSection(parCurrIndSection: String, parNewIndSection: String): Boolean {
			var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(parCurrIndSection);
			var arrElementNewIndSection: Array = ViewSectionManager.splitIndSectionFromStr(parNewIndSection);
			var i: uint = 0;
			while ((i < arrElementCurrIndSection.length) && (i < arrElementNewIndSection.length) && (arrElementCurrIndSection[i] == arrElementNewIndSection[i])) i++;
			return ((i >= arrElementCurrIndSection.length))//|| (ViewSectionManager.currIndSection == ""));
		}
		
		public static function getEqualsElementsIndSection(parCurrIndSection: String, parNewIndSection: String): String {
			var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(parCurrIndSection);
			var arrElementNewIndSection: Array = ViewSectionManager.splitIndSectionFromStr(parNewIndSection);
			var i: uint = 0;
			while ((i < arrElementCurrIndSection.length) && (i < arrElementNewIndSection.length) && (arrElementCurrIndSection[i] == arrElementNewIndSection[i])) i++;
			if (i >= arrElementCurrIndSection.length) return ViewSectionManager.joinIndSectionFromArrElement(arrElementNewIndSection.slice(0, i));
			else return "";
		}
		
		internal static function joinIndSectionFromArrElement(arrElementIndSection: Array): String {
			var strIndSection: String = arrElementIndSection.join("/");
			if (strIndSection.charAt(0) == "/") strIndSection = strIndSection.substring(1, strIndSection.length);
			if (strIndSection.charAt(strIndSection.length - 1) == "/") strIndSection = strIndSection.substring(0, strIndSection.length - 1);
			return strIndSection;
		}
		
		public static function splitIndSectionFromStr(strIndSection: String): Array {
			var arrElementIndSection: Array
			if (strIndSection == null) arrElementIndSection = [];
			else arrElementIndSection = strIndSection.split("/");
			if ((arrElementIndSection.length == 1) && (arrElementIndSection[0] == "")) arrElementIndSection = [];
			return arrElementIndSection;
		}
		
		public static function get dictDescriptionViewSection(): DictionaryDescriptionViewSection {
			return ViewSectionManager._dictDescriptionViewSection;
		}
		
		public static function getCurrentDescriptionViewSection(): DescriptionViewSection {
			return ViewSectionManager.dictDescriptionViewSection[ViewSectionManager.currIndSection];
		}
		
		public static function get currIndSection(): String {
			return ViewSectionManager._currIndSection;
		}
		
		public static function set currIndSection(value: String): void {
			if (value != ViewSectionManager._currIndSection) {
				var oldIndSection: String = ViewSectionManager._currIndSection;
				ViewSectionManager._currIndSection = value;
				ModelSection.dispatchEvent(EventModelSection.CHANGE_CURR_SECTION, {currIndSection: value, oldIndSection: oldIndSection, newIndSection: value}); 
			}
		}
		
		public static function getElementIndSection(numElement: uint, indSection: String = null): String {
			if (indSection == null) indSection = ViewSectionManager.currIndSection;
			var arrElementIndSection: Array = ViewSectionManager.splitIndSectionFromStr(indSection);
			var strElementIndSection: String = "";
			if (numElement < arrElementIndSection.length) strElementIndSection = arrElementIndSection[numElement];
			return strElementIndSection;
		}
		
		public static function getLengthIndSection(indSection: String = null): uint {
			if (indSection == null) indSection = ViewSectionManager.currIndSection;
			return ViewSectionManager.splitIndSectionFromStr(indSection).length;
		}
		
		public static function getSubstringIndSection(start: uint = 0, length: int = -1, indSection: String = null): String {
			if (indSection == null) indSection = ViewSectionManager.currIndSection;
			if (length == -1) length = ViewSectionManager.getLengthIndSection(indSection);
			var substringIndSection: String = "";
			for (var i: uint = start; i < start + length; i++)
				substringIndSection += (ViewSectionManager.getElementIndSection(i, indSection) + ["/", ""][uint(i == start + length - 1)]);
			return substringIndSection;
		}
		
	}

}