package base.bitmap {
	import net.badimon.five3D.display.Bitmap3D;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.display.BlendMode;
	
	public class BitmapSprite3D extends Bitmap3D {
		
		private var spriteToDraw: Sprite
		public var blendModeForDraw: String;
		private var translateX: Number;
		private var translateY: Number;
		private var isNotRender: Boolean;
		
		public function BitmapSprite3D(spriteToDraw: Sprite, isNotRender: Boolean = false, width: Number = 0, height: Number = 0, translateX: Number = 0, translateY: Number = 0): void {
			if ((isNaN(width)) || (width == 0)) width = spriteToDraw.width;
			if ((isNaN(height)) || (height == 0)) height = spriteToDraw.height;
			this.isNotRender = isNotRender;
			this.translateX = translateX;
			this.translateY = translateY;
			super(new BitmapData(width, height, true, 0x00FFFFFF), true);
			this.spriteToDraw = spriteToDraw;
			this.addEventListener(Event.ADDED_TO_STAGE, this.addEnterFrameDrawSpriteEvent);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.removeEnterFrameDrawSpriteEvent);
		}
		
		private function addEnterFrameDrawSpriteEvent(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addEnterFrameDrawSpriteEvent);
			if (!this.isNotRender) this.addEventListener(Event.ENTER_FRAME, this.drawSprite);
		}
		
		private function removeEnterFrameDrawSpriteEvent(e: Event): void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.removeEnterFrameDrawSpriteEvent);
			if (!this.isNotRender) this.removeEventListener(Event.ENTER_FRAME, this.drawSprite);
		}
		
		public function drawSprite(e: Event = null): void {
			var matrix: Matrix = new Matrix();
			matrix.scale(this.spriteToDraw.scaleX, this.spriteToDraw.scaleY);
			matrix.translate(this.spriteToDraw.x + this.translateX, this.spriteToDraw.y + this.translateY)
			this.bitmapData.fillRect(this.bitmapData.rect, 0x00FFFFFF);
			this.bitmapData.draw(this.spriteToDraw, matrix, null, this.blendModeForDraw, null, false);
		}
		
	}

}