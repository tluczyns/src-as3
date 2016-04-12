package base.videoPlayerIsolated {
	
	public dynamic class Metadata extends Object {
		
		public var width: Number;
		public var height: Number;
		public var seekPoints: Number;
		public var frameRate: Number;
		public var duration: Number;
		
		public function Metadata(width: Number = 0, height: Number = 0): void {
			this.width = width;
			this.height = height;
		}
		
		public function clone(): Metadata {
			var cloneMetadata: Metadata = new Metadata(this.width, this.height);
			return cloneMetadata;
		}
		
	}

}