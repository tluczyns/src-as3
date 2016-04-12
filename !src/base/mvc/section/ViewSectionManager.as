package base.mvc.section {
	import base.types.Singleton;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	//import com.luaye.console.C;
	
	public class ViewSectionManager extends Singleton {
		
		static private var _dictDescriptionViewSection: DictionaryDescriptionViewSection;
		static private var _currIndSection: String = "";
		
		static internal var dspObjContainerSection: DisplayObjectContainer;
		static public var startIndSection: String = "";
		static public var newIndSection: String = null;
		static public var oldIndSection: String = null;
		
		static public var isEngagingParallelViewSections: Boolean = false;
		static private var isNotShowFirstViewSection: Boolean;
		static public var isForceRefresh: Boolean;
		
		public function ViewSectionManager(): void {}
		
		public static function init(dspObjContainerSection: DisplayObjectContainer, startIndSection: String = "", arrMetrics: Array = null): void {
			ViewSectionManager.dspObjContainerSection = dspObjContainerSection;
			ViewSectionManager.startIndSection = startIndSection || ViewSectionManager.startIndSection;
			arrMetrics = arrMetrics || [];
			for (var i: uint = 0; i < arrMetrics.length; i++) {
				var metrics: DisplayObject = arrMetrics[i];/*Metrics*/
				dspObjContainerSection.addChild(metrics);
				metrics["parse"]();  
			}
			ModelSection.addEventListener(EventModelSection.START_CHANGE_SECTION, ViewSectionManager.changeSection, -1);
			ModelSection.init();
		}
		
		public static function addSectionDescription(descriptionViewSection: DescriptionViewSection): void {
			//trace("addSectionDescription:", descriptionViewSection.ind)
			if (!ViewSectionManager._dictDescriptionViewSection) {
				ViewSectionManager._dictDescriptionViewSection = new DictionaryDescriptionViewSection();
				ViewSectionManager.startIndSection = ViewSectionManager.startIndSection || descriptionViewSection.ind;
			}
			ViewSectionManager._dictDescriptionViewSection[descriptionViewSection.ind] = descriptionViewSection;
		}
		
		public static function removeSectionDescription(descriptionViewSection: DescriptionViewSection): void {
			ViewSectionManager._dictDescriptionViewSection[descriptionViewSection.ind] = null;
		}
		
		private static function changeSection(e: EventModelSection): void {
			var newIndSection: String = String(e.data.newIndSection);
			newIndSection = ViewSectionManager.joinIndSectionFromArrElement(ViewSectionManager.splitIndSectionFromStr(newIndSection));
			if (!ViewSectionManager._dictDescriptionViewSection[newIndSection]) {
				if (newIndSection.charAt(newIndSection.length - 1) == "0") newIndSection = newIndSection.substring(0, newIndSection.length - 1); //normalizeNewIndSectionWhenOnlyOneDescriptionWithNum
			}
			//trace("changeSection:", newIndSection, ViewSectionManager._dictDescriptionViewSection[newIndSection], ViewSectionManager.currIndSection)
			//C.log("changeSection:" + newIndSection+ ", " +  ViewSectionManager._dictDescriptionViewSection[newIndSection] + ", " + ViewSectionManager.currIndSection)
			if ((ViewSectionManager._dictDescriptionViewSection) && (ViewSectionManager._dictDescriptionViewSection[newIndSection] != undefined)) {
				if ((newIndSection != ViewSectionManager.currIndSection) || (ViewSectionManager.isForceRefresh)) ViewSectionManager.oldIndSection = ViewSectionManager.currIndSection;
				ViewSectionManager.isNotShowFirstViewSection = ((ViewSectionManager.newIndSection == null) && (ViewSectionManager.currIndSection != ""));
				ViewSectionManager.newIndSection = newIndSection;
				if (ViewSectionManager.currIndSection != "") ViewSectionManager.stopSection();
				else ViewSectionManager.startSection();
			}
		}
		
		public static function startSection(): void {
			//trace("start:" + ViewSectionManager.currIndSection + ", " +  ViewSectionManager.newIndSection); //,isSetNewIndSectionToNullWhenEqualsCurrIndSection);
			//C.log("start:" + ViewSectionManager.currIndSection + ", " +  ViewSectionManager.newIndSection)
			ViewSectionManager.isForceRefresh = false;
			if (ViewSectionManager.newIndSection != null) {
				if (ViewSectionManager.currIndSection != ViewSectionManager.newIndSection) {
					var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.currIndSection);
					var arrElementNewIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.newIndSection);
					//arrNew nie może być krótsze niż arrCurr
					arrElementCurrIndSection.push(arrElementNewIndSection[arrElementCurrIndSection.length]);
					ViewSectionManager.currIndSection = ViewSectionManager.joinIndSectionFromArrElement(arrElementCurrIndSection);
					var descriptionViewSectionNew: DescriptionViewSection = ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection];
					if (descriptionViewSectionNew != null) {
						descriptionViewSectionNew.createViewSection();
						descriptionViewSectionNew.viewSection.show();
					} else {
						ViewSectionManager.startSection();
					}
				} else {
					var newIndSection: String = ViewSectionManager.newIndSection;
					ViewSectionManager.newIndSection = null;
					ModelSection.dispatchEvent(EventModelSection.CHANGE_SECTION, {oldIndSection: ViewSectionManager.oldIndSection, newIndSection: newIndSection}); 
				}
			}
		}
		
		public static function stopSection(): void {
			//trace("stop:"+ViewSectionManager.currIndSection +", " +  ViewSectionManager.newIndSection, ViewSectionManager.isNotShowFirstViewSection, ViewSectionManager.isForceRefresh);
			//C.log("stop:" + ViewSectionManager.currIndSection + ", " +  ViewSectionManager.newIndSection)
			var descriptionViewSectionCurrent: DescriptionViewSection = DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]);
			if (((ViewSectionManager.isNewEqualsCurrentElementsIndSection()) || (ViewSectionManager.newIndSection == null)) && (!ViewSectionManager.isForceRefresh)) {
				if ((descriptionViewSectionCurrent != null) && (descriptionViewSectionCurrent.viewSection != null) && (!ViewSectionManager.isNotShowFirstViewSection)) descriptionViewSectionCurrent.viewSection.show();
				else {
					ViewSectionManager.isNotShowFirstViewSection = false;
					ViewSectionManager.startSection();
				}
			} else {
				ViewSectionManager.isNotShowFirstViewSection = false;
				var indSectionNext: String = ViewSectionManager.getSubstringIndSection(0, ViewSectionManager.getLengthIndSection() - 1);
				if ((isEngagingParallelViewSections) && (ViewSectionManager.isEqualsElementsIndSection(indSectionNext, ViewSectionManager.newIndSection)) && (ViewSectionManager.getLengthIndSection(ViewSectionManager.newIndSection) > ViewSectionManager.getLengthIndSection(indSectionNext))) {
					//if (ViewSectionManager.descriptionViewSectionEngaged) 
					DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]).isEngaged = true;
				}	
				if (DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]).isEngaged) {
					ViewSectionManager.currIndSection = indSectionNext;
					ViewSectionManager.startSection();
				}
				if ((descriptionViewSectionCurrent != null) && (descriptionViewSectionCurrent.viewSection != null))
					descriptionViewSectionCurrent.viewSection.hide();
				else ViewSectionManager.finishStopSection();
			}
		}
		
		public static function finishStopSection(descriptionViewSectionToDelete : DescriptionViewSection = null): void {
			//trace("finishStop:"+ViewSectionManager.currIndSection +", " +  ViewSectionManager.newIndSection);
			//C.log("finishStop:" + ViewSectionManager.currIndSection + ", " +  ViewSectionManager.newIndSection)
			ViewSectionManager.isForceRefresh = false;
			if (!descriptionViewSectionToDelete) descriptionViewSectionToDelete = DescriptionViewSection(ViewSectionManager._dictDescriptionViewSection[ViewSectionManager.currIndSection]);
			if (descriptionViewSectionToDelete != null) descriptionViewSectionToDelete.removeViewSection();
			if ((!descriptionViewSectionToDelete) || (!descriptionViewSectionToDelete.isEngaged)) {
				var arrElementCurrIndSection: Array = ViewSectionManager.splitIndSectionFromStr(ViewSectionManager.currIndSection);
				arrElementCurrIndSection.splice(arrElementCurrIndSection.length - 1, 1);
				ViewSectionManager.currIndSection = ViewSectionManager.joinIndSectionFromArrElement(arrElementCurrIndSection);
				if (ViewSectionManager.isNewEqualsCurrentElementsIndSection()) ViewSectionManager.startSection();
				else ViewSectionManager.stopSection();
			} else descriptionViewSectionToDelete.isEngaged = false;
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
			var arrElementIndSection: Array;
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