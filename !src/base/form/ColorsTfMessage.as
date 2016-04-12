package base.form {

	public class ColorsTfMessage {
		
		public var colorDurationMessage: int;
		public var colorBadCloseMessage: int;
		public var colorGoodCloseMessage: int;
		
		public function ColorsTfMessage(colorDurationMessage: int = 0, colorBadCloseMessage: int = 0, colorGoodCloseMessage: int = 0): void {
			this.colorDurationMessage = colorDurationMessage || 0x000000;
			this.colorBadCloseMessage = colorBadCloseMessage || 0xFF0000;
			this.colorGoodCloseMessage = colorGoodCloseMessage || 0x009900;
		}
		
	}

}