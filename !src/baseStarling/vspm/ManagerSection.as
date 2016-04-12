package baseStarling.vspm {
	import base.types.Singleton;
	import flash.utils.Dictionary;
	//import base.types.DictionaryExt;
	import starling.display.DisplayObjectContainer;
	//import com.luaye.console.C;
	
	public class ManagerSection extends Singleton {
		
		//static private var _dictDescriptionViewSection: DictionaryExt = new DictionaryExt();
		static private var _dictDescriptionViewSection: Dictionary = new Dictionary();
		static private var _currIndSection: String = "";
		
		static public var dspObjContainerSection: DisplayObjectContainer;
		static public var startIndSection: String = "";
		static public var newIndSection: String = null;
		static public var oldIndSection: String = null;
		
		static public var isEngagingParallelViewSections: Boolean = false;
		static private var isNotShowFirstViewSection: Boolean;
		static public var isForceRefresh: Boolean;
		
		public function ManagerSection(): void {}
		
		public static function init(dspObjContainerSection: DisplayObjectContainer, startIndSection: String = ""): void {
			ManagerSection.dspObjContainerSection = dspObjContainerSection;
			ManagerSection.startIndSection = startIndSection || ManagerSection.startIndSection;
			StateModel.addEventListener(EventStateModel.START_CHANGE_SECTION, ManagerSection.changeSection, -1);
			StateModel.init();
		}
		
		public static function removeSectionDescription(descriptionViewSection: DescriptionViewSection): void {
			ManagerSection._dictDescriptionViewSection[descriptionViewSection.ind] = null;
		}
		
		private static function changeSection(e: EventStateModel): void {
			var newIndSection: String = String(e.data.newIndSection);
			newIndSection = ManagerSection.joinIndSectionFromArrElement(ManagerSection.splitIndSectionFromStr(newIndSection));
			if (!ManagerSection._dictDescriptionViewSection[newIndSection]) {
				if (newIndSection.charAt(newIndSection.length - 1) == "0") newIndSection = newIndSection.substring(0, newIndSection.length - 1); //normalizeNewIndSectionWhenOnlyOneDescriptionWithNum
			}
			//trace("changeSection:", newIndSection, ManagerSection._dictDescriptionViewSection[newIndSection], ManagerSection.currIndSection)
			//C.log("changeSection:" + newIndSection+ ", " +  ManagerSection._dictDescriptionViewSection[newIndSection] + ", " + ManagerSection.currIndSection)
			if ((ManagerSection._dictDescriptionViewSection) && (ManagerSection._dictDescriptionViewSection[newIndSection] != undefined)) {
				if ((newIndSection != ManagerSection.currIndSection) || (ManagerSection.isForceRefresh)) ManagerSection.oldIndSection = ManagerSection.currIndSection;
				ManagerSection.isNotShowFirstViewSection = ((ManagerSection.newIndSection == null) && (ManagerSection.currIndSection != ""));
				ManagerSection.newIndSection = newIndSection;
				if (ManagerSection.currIndSection != "") ManagerSection.stopSection();
				else ManagerSection.startSection();
			}
		}
		
		public static function startSection(): void {
			//trace("start:" + ManagerSection.currIndSection + ", " +  ManagerSection.newIndSection); //,isSetNewIndSectionToNullWhenEqualsCurrIndSection);
			//C.log("start:" + ManagerSection.currIndSection + ", " +  ManagerSection.newIndSection)
			ManagerSection.isForceRefresh = false;
			if (ManagerSection.newIndSection != null) {
				if (ManagerSection.currIndSection != ManagerSection.newIndSection) {
					var arrElementCurrIndSection: Array = ManagerSection.splitIndSectionFromStr(ManagerSection.currIndSection);
					var arrElementNewIndSection: Array = ManagerSection.splitIndSectionFromStr(ManagerSection.newIndSection);
					//arrNew nie może być krótsze niż arrCurr
					arrElementCurrIndSection.push(arrElementNewIndSection[arrElementCurrIndSection.length]);
					ManagerSection.currIndSection = ManagerSection.joinIndSectionFromArrElement(arrElementCurrIndSection);
					var descriptionViewSectionNew: DescriptionViewSection = ManagerSection._dictDescriptionViewSection[ManagerSection.currIndSection];
					if (descriptionViewSectionNew) {
						descriptionViewSectionNew.createView();
						if (descriptionViewSectionNew.view) descriptionViewSectionNew.view.show();
					}
					if ((!descriptionViewSectionNew) || (!descriptionViewSectionNew.view)) ManagerSection.startSection();
				} else {
					var newIndSection: String = ManagerSection.newIndSection;
					ManagerSection.newIndSection = null;
					StateModel.dispatchEvent(EventStateModel.CHANGE_SECTION, {oldIndSection: ManagerSection.oldIndSection, newIndSection: newIndSection}); 
				}
			}
		}
		
		public static function stopSection(): void {
			//trace("stop:"+ManagerSection.currIndSection +", " +  ManagerSection.newIndSection, ManagerSection.isNotShowFirstViewSection, ManagerSection.isForceRefresh);
			//C.log("stop:" + ManagerSection.currIndSection + ", " +  ManagerSection.newIndSection)
			var descriptionViewSectionCurrent: DescriptionViewSection = DescriptionViewSection(ManagerSection._dictDescriptionViewSection[ManagerSection.currIndSection]);
			if (((ManagerSection.isNewEqualsCurrentElementsIndSection()) || (ManagerSection.newIndSection == null)) && (!ManagerSection.isForceRefresh)) {
				if ((descriptionViewSectionCurrent != null) && (descriptionViewSectionCurrent.view != null) && (!ManagerSection.isNotShowFirstViewSection)) descriptionViewSectionCurrent.view.show();
				else {
					ManagerSection.isNotShowFirstViewSection = false;
					ManagerSection.startSection();
				}
			} else {
				ManagerSection.isNotShowFirstViewSection = false;
				var indSectionNext: String = ManagerSection.getSubstringIndSection(0, ManagerSection.getLengthIndSection() - 1);
				if ((isEngagingParallelViewSections) && (ManagerSection.isEqualsElementsIndSection(indSectionNext, ManagerSection.newIndSection)) && (ManagerSection.getLengthIndSection(ManagerSection.newIndSection) > ManagerSection.getLengthIndSection(indSectionNext))) {
					//if (ManagerSection.descriptionViewSectionEngaged) 
					DescriptionViewSection(ManagerSection._dictDescriptionViewSection[ManagerSection.currIndSection]).isEngaged = true;
				}	
				if (DescriptionViewSection(ManagerSection._dictDescriptionViewSection[ManagerSection.currIndSection]).isEngaged) {
					ManagerSection.currIndSection = indSectionNext;
					ManagerSection.startSection();
				}
				if ((descriptionViewSectionCurrent != null) && (descriptionViewSectionCurrent.view != null))
					descriptionViewSectionCurrent.view.hide();
				else ManagerSection.finishStopSection();
			}
		}
		
		public static function finishStopSection(descriptionViewSectionToDelete : DescriptionViewSection = null): void {
			//trace("finishStop:"+ManagerSection.currIndSection +", " +  ManagerSection.newIndSection);
			//C.log("finishStop:" + ManagerSection.currIndSection + ", " +  ManagerSection.newIndSection)
			ManagerSection.isForceRefresh = false;
			if (!descriptionViewSectionToDelete) descriptionViewSectionToDelete = DescriptionViewSection(ManagerSection._dictDescriptionViewSection[ManagerSection.currIndSection]);
			if (descriptionViewSectionToDelete != null) descriptionViewSectionToDelete.removeView();
			if ((!descriptionViewSectionToDelete) || (!descriptionViewSectionToDelete.isEngaged)) {
				var arrElementCurrIndSection: Array = ManagerSection.splitIndSectionFromStr(ManagerSection.currIndSection);
				arrElementCurrIndSection.splice(arrElementCurrIndSection.length - 1, 1);
				ManagerSection.currIndSection = ManagerSection.joinIndSectionFromArrElement(arrElementCurrIndSection);
				if (ManagerSection.isNewEqualsCurrentElementsIndSection()) ManagerSection.startSection();
				else ManagerSection.stopSection();
			} else descriptionViewSectionToDelete.isEngaged = false;
		}
		
		private static function isNewEqualsCurrentElementsIndSection(): Boolean {
			return ManagerSection.isEqualsElementsIndSection(ManagerSection.currIndSection, ManagerSection.newIndSection);
		}
		//czy current jest zawarty w new
		public static function isEqualsElementsIndSection(parCurrIndSection: String, parNewIndSection: String): Boolean {
			var arrElementCurrIndSection: Array = ManagerSection.splitIndSectionFromStr(parCurrIndSection);
			var arrElementNewIndSection: Array = ManagerSection.splitIndSectionFromStr(parNewIndSection);
			var i: uint = 0;
			while ((i < arrElementCurrIndSection.length) && (i < arrElementNewIndSection.length) && (arrElementCurrIndSection[i] == arrElementNewIndSection[i])) i++;
			return ((i >= arrElementCurrIndSection.length))//|| (ManagerSection.currIndSection == ""));
		}
		
		public static function getEqualsElementsIndSection(parCurrIndSection: String, parNewIndSection: String): String {
			var arrElementCurrIndSection: Array = ManagerSection.splitIndSectionFromStr(parCurrIndSection);
			var arrElementNewIndSection: Array = ManagerSection.splitIndSectionFromStr(parNewIndSection);
			var i: uint = 0;
			while ((i < arrElementCurrIndSection.length) && (i < arrElementNewIndSection.length) && (arrElementCurrIndSection[i] == arrElementNewIndSection[i])) i++;
			if (i >= arrElementCurrIndSection.length) return ManagerSection.joinIndSectionFromArrElement(arrElementNewIndSection.slice(0, i));
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
		
		public static function get dictDescriptionViewSection(): Dictionary { //DictionaryExt
			return ManagerSection._dictDescriptionViewSection;
		}
		
		public static function getCurrentDescriptionViewSection(): DescriptionViewSection {
			return ManagerSection.dictDescriptionViewSection[ManagerSection.currIndSection];
		}
		
		public static function get currIndSection(): String {
			return ManagerSection._currIndSection;
		}
		
		public static function set currIndSection(value: String): void {
			if (value != ManagerSection._currIndSection) {
				var oldIndSection: String = ManagerSection._currIndSection;
				ManagerSection._currIndSection = value;
				StateModel.dispatchEvent(EventStateModel.CHANGE_CURR_SECTION, {currIndSection: value, oldIndSection: oldIndSection, newIndSection: value}); 
			}
		}
		
		public static function getElementIndSection(numElement: uint, indSection: String = null): String {
			if (indSection == null) indSection = ManagerSection.currIndSection;
			var arrElementIndSection: Array = ManagerSection.splitIndSectionFromStr(indSection);
			var strElementIndSection: String = "";
			if (numElement < arrElementIndSection.length) strElementIndSection = arrElementIndSection[numElement];
			return strElementIndSection;
		}
		
		public static function getLengthIndSection(indSection: String = null): uint {
			if (indSection == null) indSection = ManagerSection.currIndSection;
			return ManagerSection.splitIndSectionFromStr(indSection).length;
		}
		
		public static function getSubstringIndSection(start: uint = 0, length: int = -1, indSection: String = null): String {
			if (indSection == null) indSection = ManagerSection.currIndSection;
			if (length == -1) length = ManagerSection.getLengthIndSection(indSection);
			else length = Math.min(length, ManagerSection.getLengthIndSection(indSection));
			var substringIndSection: String = "";
			for (var i: uint = start; i < start + length; i++)
				substringIndSection += (ManagerSection.getElementIndSection(i, indSection) + ["/", ""][uint(i == start + length - 1)]);
			return substringIndSection;
		}
		
	}

}