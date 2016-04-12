package base.mvc.section {
	import base.loader.LoaderXML;
	import flash.utils.Dictionary;
	import base.loader.URLLoaderExt;
	import base.types.StringUtils;
	import flash.utils.getDefinitionByName;
	import base.flashUtils.FlashUtils;
	import flash.utils.getQualifiedClassName;

	public class LoaderXMLContentViewSection extends LoaderXML {
		
		private var prefixClass: String;
		private var filenameXML: String;
		static public var content: Object;
		static public var dictIndViewSectionToArrDescriptionSubViewSection: Dictionary = new Dictionary();
		static public var dictIndToAliasIndSection: Dictionary;
		static public var dictAliasIndToIndSection: Dictionary;
		
		function LoaderXMLContentViewSection(prefixClass: String): void {
			this.prefixClass = prefixClass;
		}
		
		override public function parseXML(xmlNode: XML): void {
			this.initDictIndAliasViewSection();
			this.parseXMLPopup(xmlNode);
			var xmlContent: XML = this.parseXMLSection(xmlNode, "", "", 0);
			this.createObjFromXMLContent(xmlContent);
			ViewSectionManager.addSectionDescription(new DescriptionViewSectionWithContent("empty", ViewSectionEmpty, null));
			if ((xmlNode.@isSection) || (xmlNode.@isSectionAndContent)) {
				var objClasses: Object = this.getObjClassContentAndViewSection(xmlNode.name());
				if (objClasses.classViewSection)
					ViewSectionManager.addSectionDescription(new DescriptionViewSectionWithContent("", objClasses.classViewSection, new objClasses.classContentViewSection(xmlContent), 0, 0));
			}
		}
		
		private function initDictIndAliasViewSection(): void {
			if (!LoaderXMLContentViewSection.dictIndToAliasIndSection) LoaderXMLContentViewSection.dictIndToAliasIndSection = new Dictionary();
			if (!LoaderXMLContentViewSection.dictAliasIndToIndSection) LoaderXMLContentViewSection.dictAliasIndToIndSection = new Dictionary();
		}
		
		private function createObjFromXMLContent(xmlContent: XML): void {
			var content: Object = URLLoaderExt.parseXMLToObject(xmlContent);
			if (!LoaderXMLContentViewSection.content) LoaderXMLContentViewSection.content = content;
			else for (var prop: String in content)
				LoaderXMLContentViewSection.content[prop] = content[prop];
		}
		
		private function parseXMLSection(xmlSection: XML, predIndSection: String, predIndSectionAlias: String, depth: uint): XML {
			if (xmlSection.toString() != "") {
				if (predIndSectionAlias == "") predIndSectionAlias = predIndSection;
				var xmlListSubSection: XMLList = xmlSection.*.((attribute("isSection") == "1") || (attribute("isSectionAndContent") == "1"));
				var arrSuffIndSubSectionInXMLListSubSection: Array = [];
				var xmlSubSection: XML;
				var suffIndSubSection: String;
				for (var i: uint = 0; i < xmlListSubSection.length(); i++) {
					xmlSubSection = xmlListSubSection[i];
					suffIndSubSection = xmlSubSection.name();
					if (arrSuffIndSubSectionInXMLListSubSection.indexOf(suffIndSubSection) == -1) arrSuffIndSubSectionInXMLListSubSection.push(suffIndSubSection);
				}
				//iterate through subsections
				var order: uint = 0;
				LoaderXMLContentViewSection.dictIndViewSectionToArrDescriptionSubViewSection[predIndSection] = new Array();
				for (i = 0; i < arrSuffIndSubSectionInXMLListSubSection.length; i++) {
					suffIndSubSection = arrSuffIndSubSectionInXMLListSubSection[i];
					var objClasses: Object = this.getObjClassContentAndViewSection(suffIndSubSection);
					var xmlListSubSectionWithSameName: XMLList = xmlSection[suffIndSubSection];
					//trace("xmlListSubSectionWithSameName:", objClasses.contentSubViewSection, xmlListSubSectionWithSameName)
					var indSubSection: String = ((predIndSection == "") ? "" : predIndSection + "/") + suffIndSubSection;
					var indSubSectionWithWoNum: String;
					for (var j: uint = 0; j < xmlListSubSectionWithSameName.length(); j++) {
						var strWoNumSubSection: String = [String(j), ""][uint(xmlListSubSectionWithSameName.length() == 1)]
						indSubSectionWithWoNum = indSubSection + strWoNumSubSection;
						xmlSubSection = xmlListSubSectionWithSameName[j];
						var suffIndSubSectionAlias: String = this.getSuffIndSectionAlias(xmlSubSection);
						if (suffIndSubSectionAlias == "") suffIndSubSectionAlias = suffIndSubSection + strWoNumSubSection;
						var indSubSectionAlias: String = ((predIndSectionAlias == "") ? "" : predIndSectionAlias + "/") + suffIndSubSectionAlias;
						xmlSubSection = this.parseXMLSection(xmlSubSection, indSubSectionWithWoNum, indSubSectionAlias, depth + 1);
						var descriptionSubViewSectionWithContent: DescriptionViewSectionWithContent;
						var contentSubViewSection: ContentViewSection = new objClasses.classContentViewSection(xmlSubSection, order, depth);
						LoaderXMLContentViewSection.dictIndToAliasIndSection[indSubSectionWithWoNum] = indSubSectionAlias;
						if (xmlListSubSectionWithSameName.length() == 1) LoaderXMLContentViewSection.dictIndToAliasIndSection[indSubSectionWithWoNum + "0"] = indSubSectionAlias;
						LoaderXMLContentViewSection.dictAliasIndToIndSection[indSubSectionAlias] = indSubSectionWithWoNum;
						if (xmlListSubSectionWithSameName.length() == 1)
							descriptionSubViewSectionWithContent = new DescriptionViewSectionWithContent(indSubSection, objClasses.classViewSection, contentSubViewSection);
						else descriptionSubViewSectionWithContent = new DescriptionViewSectionWithContentAndNum(indSubSection, objClasses.classViewSection, contentSubViewSection, j);
						LoaderXMLContentViewSection.addSectionDescription(predIndSection, descriptionSubViewSectionWithContent, objClasses.classViewSection)
						order++;
						if (!uint(xmlListSubSectionWithSameName[j].@isSectionAndContent)) xmlListSubSectionWithSameName[j] = "empty";
					}
					//if (!uint(xmlSection[suffIndSubSection].@isSectionAndContent)) delete xmlSection[suffIndSubSection];
				}
			}
			return xmlSection;
		}
		
		static public function addSectionDescription(indSection: String, descriptionViewSectionWithContent: DescriptionViewSectionWithContent, classViewSection: Class): void {
			if (classViewSection) ViewSectionManager.addSectionDescription(descriptionViewSectionWithContent);
			if (!LoaderXMLContentViewSection.dictIndViewSectionToArrDescriptionSubViewSection[indSection]) 
				LoaderXMLContentViewSection.dictIndViewSectionToArrDescriptionSubViewSection[indSection] = new Array();
			LoaderXMLContentViewSection.dictIndViewSectionToArrDescriptionSubViewSection[indSection].push(descriptionViewSectionWithContent);
		}
		
		private function getObjClassContentAndViewSection(suffIndSection: String): Object {
			var suffIndSectionCode: String = StringUtils.toUpperCaseFromUnderscore(suffIndSection);
			try {
				var classContentViewSection: Class = Class(getDefinitionByName(this.prefixClass + ".content.Content" + suffIndSectionCode));
			} catch (e: Error) { }
			if ((!classContentViewSection) || (!FlashUtils.isSuperclass(classContentViewSection, ContentViewSection))) classContentViewSection = ContentViewSection;
			try {
				var classViewSection: Class = Class(getDefinitionByName(this.prefixClass + ".viewSection.ViewSection" + suffIndSectionCode));
			} catch (e: Error) { }
			return {classContentViewSection: classContentViewSection, classViewSection: classViewSection};
		}
		
		private function getSuffIndSectionAlias(xmlSection: XML): String {
			var objSection: Object = URLLoaderExt.parseXMLToObject(xmlSection);
			var objSuffIndSectionAlias: * = objSection.name || objSection.label || objSection.title || "";
			if (getDefinitionByName(getQualifiedClassName(objSuffIndSectionAlias)) == Object) objSuffIndSectionAlias = Object(objSuffIndSectionAlias).text;
			var suffIndSectionAlias: String = StringUtils.depolonize(String(objSuffIndSectionAlias)).toLowerCase();
			suffIndSectionAlias = suffIndSectionAlias.replace("%", "");
			return suffIndSectionAlias;
		}
		
		static public function getArrDescriptionSubViewSectionForIndSection(indSection: String): Array {
			return LoaderXMLContentViewSection.dictIndViewSectionToArrDescriptionSubViewSection[indSection] || [];
		}
		
		//popup
		
		private function parseXMLPopup(xmlPopup: XML): void {
			var xmlListSubPopup: XMLList = xmlPopup.*;	
			var xmlSubPopup: XML;
			var suffIndSubPopup: String;
			for (var i: uint = 0; i < xmlListSubPopup.length(); i++) {
				xmlSubPopup = xmlListSubPopup[i];
				suffIndSubPopup = xmlSubPopup.name();
				if (uint(xmlSubPopup.@isPopup)) {
					var objClasses: Object = this.getObjClassContentAndViewPopup(suffIndSubPopup);
					var contentSubViewPopup: ContentViewPopup = new objClasses.classContentViewPopup(xmlSubPopup);
					var objParamsWithValuesToShow: Object = {};
					//if (contentSubViewPopup.objParamsWithValuesToShow) objParamsWithValuesToShow = JSON.parse(contentSubViewPopup.objParamsWithValuesToShow);
					var descriptionSubViewSectionWithContent: DescriptionViewPopupWithContent = new DescriptionViewPopupWithContent(objParamsWithValuesToShow, suffIndSubPopup, objClasses.classViewPopup, contentSubViewPopup);
				} else this.parseXMLPopup(xmlSubPopup);
			}
		}
		
		private function getObjClassContentAndViewPopup(suffIndPopup: String): Object {
			var suffIndPopupCode: String = StringUtils.toUpperCaseFromUnderscore(suffIndPopup);
			try {
				var classContentViewPopup: Class = Class(getDefinitionByName(this.prefixClass + ".content.ContentPopup" + suffIndPopupCode));
			} catch (e: Error) { }
			if ((!classContentViewPopup) || (!FlashUtils.isSuperclass(classContentViewPopup, ContentViewPopup))) classContentViewPopup = ContentViewPopup;
			try {
				var classViewPopup: Class = Class(getDefinitionByName(this.prefixClass + ".viewPopup.ViewPopup" + suffIndPopupCode));
			} catch (e: Error) { }
			return {classContentViewPopup: classContentViewPopup, classViewPopup: classViewPopup};
		}
		
	}
	
}