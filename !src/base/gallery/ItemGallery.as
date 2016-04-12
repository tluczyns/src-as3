package base.gallery {
	import base.btn.BtnHitWithEvents;
	import flash.display.Sprite;
	import base.btn.BtnHitEvent;
	
	public class ItemGallery extends BtnHitWithEvents {
		
		public var num: uint;
		protected var objData: Object;
		public var time: Number;
		
		public function ItemGallery(num: Number, objData: Object = null, hit: Sprite = null): void {
			this.objData = objData;
			this.num = num;
			this.draw();
			super(hit);
			this.addEventListener(BtnHitEvent.CLICKED, this.onClickedHandler);
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
		
		protected function onClickedHandler(e: BtnHitEvent): void {
			this.dispatchEvent(new EventGallery(EventGallery.SELECTED_ITEM_CHANGED, this.num, true));
		}
		
		override public function destroy(): void {
			this.removeEventListener(BtnHitEvent.CLICKED, this.onClickedHandler);
			this.removeDraw();
			super.destroy();
		}
		
	}

}