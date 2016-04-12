package base.vspm {
	import base.loader.URLLoaderExt;

	public dynamic class ContentViewSection extends ContentView {
		
		public var order: uint;
		public var depth: uint;
		
		public function ContentViewSection(xmlContent: XML, order: uint, depth: uint): void {
			super(xmlContent);
			this.order = order;
			this.depth = depth;
		}
		
	}

}