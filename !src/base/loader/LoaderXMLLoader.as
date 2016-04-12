package base.loader {
	import base.loader.LoaderXML;
	import base.omniture.OmnitureTracker;
	import base.loader.URLLoaderExt;

	public class LoaderXMLLoader extends LoaderXML {
		
		static public var loader: Object;
		static public var omnitureTracker: OmnitureTracker;
		
		function LoaderXMLLoader(): void {}
		
		override public function loadXML(pathXML: String): void {
			super.loadXML(pathAssets + "xml/loader.xml");
		}
		
		override protected function parseXML(xmlNode: XML): void {
			LoaderXMLLoader.loader = URLLoaderExt.parseXMLToObject(xmlNode);
			if (LoaderXMLLoader.loader.omniture) LoaderXMLLoader.omnitureTracker = new OmnitureTracker(LoaderXMLLoader.loader.omniture);
		}
		
	}
	
}