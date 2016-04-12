package base.mvc.section {
	import base.loader.URLLoaderExt;

	public dynamic class ContentViewSection extends Object {
		
		public var order: uint;
		public var depth: uint;
		
		public function ContentViewSection(xmlContent: XML, order: uint, depth: uint): void {
			var objContent: Object = URLLoaderExt.parseXMLToObject(xmlContent);
			for (var i: String in objContent) {
				this[i] = objContent[i];
			}
			this.order = order;
			this.depth = depth;
		}
		
	}

}