package base.mvc.section {
	import base.loader.URLLoaderExt;

	public dynamic class ContentViewPopup extends Object {
		
		public function ContentViewPopup(xmlContent: XML): void {
			var objContent: Object = URLLoaderExt.parseXMLToObject(xmlContent);
			for (var i: String in objContent) {
				this[i] = objContent[i];
			}
		}
		
	}

}