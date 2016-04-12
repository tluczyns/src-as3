package base.vspm {
	import base.loader.URLLoaderExt;

	public dynamic class ContentView extends Object {
		
		public function ContentView(xmlContent: XML): void {
			var objContent: Object = URLLoaderExt.parseXMLToObject(xmlContent);
			for (var i: String in objContent) {
				this[i] = objContent[i];
			}
		}
		
	}

}