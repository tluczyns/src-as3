package base.btn {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class BtnBitmap extends Sprite {
		
		static public const THRESHOLD: uint = 2;
		
		private var bmpData: BitmapData;
		protected var bmp: Bitmap;
		
		public function BtnBitmap(bmpData: BitmapData) {
			this.bmpData = bmpData;
			this.bmp = new Bitmap(bmpData, "auto", true);
			this.addChild(this.bmp);
			 
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.addEventListener(MouseEvent.CLICK, this.onClick);
		}
		
		private function onMouseMove(e: MouseEvent): void {
			var pixel32: uint = this.bmp.bitmapData.getPixel32(this.bmp.mouseX, this.bmp.mouseY);
			this.buttonMode = ((pixel32 >>> 24) > BtnBitmap.THRESHOLD);   
		}
		
		protected function onMouseDown(event: MouseEvent): void {
			if (this.buttonMode) this.dispatchEvent(new BtnHitEvent(BtnHitEvent.DOWN));
		}
		
		protected function onMouseUp(event: MouseEvent): void {
			if (this.buttonMode) this.dispatchEvent(new BtnHitEvent(BtnHitEvent.UP));	
		}

		
		private function onClick(e:MouseEvent): void {
			if (this.buttonMode) this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED));
		}
		
		public function destroy(): void {
			this.removeEventListener(MouseEvent.CLICK, this.onClick);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			this.removeChild(this.bmp);
			this.bmp = null;
		}
		
	}

}