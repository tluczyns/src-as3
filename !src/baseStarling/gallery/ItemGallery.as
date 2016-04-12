package baseStarling.gallery {
	import baseStarling.btn.BtnHitWithEvents;
	import flash.display.Shape;
	import baseStarling.btn.EventBtnHit;
	
	public class ItemGallery extends BtnHitWithEvents {
		
		public var num: uint;
		protected var objData: Object;
		public var time: Number;
		
		public function ItemGallery(num: Number, objData: Object = null, hit: Shape = null): void {
			this.objData = objData;
			this.num = num;
			this.draw();
			super(hit);
			this.addEventListener(EventBtnHit.RELEASE, this.onRelease);
		}
		
		protected function draw(): void {
			/*this.graphics.beginFill(uint(this.objData), 1);
			this.graphics.drawRect(-10, -10, 20, 20);
			this.graphics.endFill();*/
		}
		
		protected function removeDraw(): void {
			//this.graphics.clear();
		}
		
		public function render(time: Number, timeOne: Number): void {
			/*this.scaleX = this.scaleY = 3 * (1 - Math.abs(0.5 - time))
			this.x = -50 + time * 300;
			this.rotationY = - 90 + time * 180;*/
		}
		
		public function set selected(value: Boolean): void {
			//trace("value:", value)
		}
		
		protected function onRelease(e: EventBtnHit): void {
			this.dispatchEvent(new EventGallery(EventGallery.SELECTED_ITEM_CHANGED, this.num, true));
		}
		
		override public function destroy(): void {
			this.removeEventListener(EventBtnHit.RELEASE, this.onRelease);
			this.removeDraw();
			super.destroy();
		}
		
	}

}