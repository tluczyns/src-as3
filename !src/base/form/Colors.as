package base.form {
	
	public class Colors {
		
		public var colorTfOk: int = -1;
		public var colorTfBad: int = -1;
		public var colorBgTfOk: int = -1;
		public var colorBgTfBad: int = -1;
		
		public function Colors(colorTfOk: int = 0x000000, colorTfBad: int = 0xFFFFFF, colorBgTfOk: int = 0xFFFFFF, colorBgTfBad: int = 0xE65152): void {
			this.colorTfOk = colorTfOk;
			this.colorTfBad = colorTfBad;
			this.colorBgTfOk = colorBgTfOk;
			this.colorBgTfBad = colorBgTfBad;
		}
		
	}

}