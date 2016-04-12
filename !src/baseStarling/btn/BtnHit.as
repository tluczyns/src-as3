package baseStarling.btn {
	import starling.display.Sprite;
	import flash.geom.Point;
	import starling.display.Shape;
	import flash.geom.Rectangle;
	import starling.events.TouchEvent;
	//import starling.core.Starling;
	import starling.events.Touch;
	import starling.display.DisplayObject;
	import starling.events.TouchPhase;
	
	public class BtnHit extends Sprite implements IBtn {
		
		protected var isOver: Boolean;
		protected var pointLocationTouch: Point;
		
		public var hit: Shape;
		
		public function BtnHit(hit: Shape = null): void {
			this.initHit(hit);
			this.isOver = false;
			this.pointLocationTouch = new Point();
			this.addTouchEvents();
		}

		private function initHit(hit: Shape = null): void {
			if (this.hit == null) { 
				if (hit != null) {
					hit.alpha = 0;
					this.addChild(hit);
					this.hit = hit;
				} else this.createGenericHit();
			}
		}
		
		public function createGenericHit(rectDimension: Rectangle = null): void {
			if (rectDimension == null) rectDimension = this.getBounds(this);
			if (this.hit == null) {
				this.hit = new Shape();
				this.hit.alpha = 0;
				this.hit.x = rectDimension.x;
				this.hit.y = rectDimension.y;
				this.hit.graphics.beginFill(0x000000, 0);
				this.hit.graphics.drawRect(0, 0, rectDimension.width + 0.1, rectDimension.height + 0.1);
				this.hit.graphics.endFill();
				this.addChild(this.hit);
			}
		}
		
		public function createGenericHitAndAddTouchEvents(rectDimension: Rectangle = null): void {
			this.createGenericHit(rectDimension);
			this.addTouchEvents();
		}
		
		public function addTouchEvents(): void {
			if (!this.hit.useHandCursor) {
				this.dispatchEvent(new EventBtnHit(EventBtnHit.OUT));
				this.hit.useHandCursor = true;
				this.hit.addEventListener(TouchEvent.TOUCH, this.onHitTouch);
				this.hit.addEventListener(TouchEvent.TOUCH, this.onHitTouchForMove);
				//Starling.current.stage.addEventListener(TouchEvent.TOUCH, this.onHitTouch);
				//Starling.current.stage.addEventListener(TouchEvent.TOUCH, this.onHitTouchForMove);
			}
		}
		
		private function onHitTouch(e: TouchEvent): void {
			var touch: Touch = e.getTouch(e.target as DisplayObject);//
			var typeEvent: String;
			if (touch) {
				touch.getLocation(this, this.pointLocationTouch);
				switch (touch.phase) {
					case TouchPhase.BEGAN: /*case TouchPhase.HOVER: */{
						this.isOver = true;  
						typeEvent = EventBtnHit.OVER; 
						break;
					}
					case TouchPhase.ENDED: {
						if (this.isOver) {
							typeEvent = EventBtnHit.RELEASE; 
							this.isOver = false;
						};
						break;
					}
					case TouchPhase.MOVED: {
						var wasOver: Boolean = this.isOver;
						this.isOver = (this.hit.hitTest(touch.getLocation(this.hit), true) != null)
						if (this.isOver != wasOver) typeEvent = [EventBtnHit.OUT, EventBtnHit.OVER][uint(this.isOver)];
						else if (this.isOver) typeEvent = EventBtnHit.MOVED;
						break;
					}
				}
			} else if (this.isOver) {
				this.isOver = false;
				typeEvent = EventBtnHit.OUT;
			}
			if (typeEvent) this.dispatchEvent(new EventBtnHit(typeEvent));
			if (typeEvent == EventBtnHit.RELEASE) this.dispatchEvent(new EventBtnHit(EventBtnHit.OUT));
		}
		
		private function onHitTouchForMove(e: TouchEvent): void {
			var touch: Touch = e.getTouch(e.target as DisplayObject);
			if ((touch) && ((touch.phase == TouchPhase.HOVER) || (touch.phase == TouchPhase.MOVED))) {
				this.hit.removeEventListener(TouchEvent.TOUCH, this.onHitTouchForMove);
				if (touch.phase == TouchPhase.HOVER) this.onHitTouch(e);
			}
		}
		
		public function removeTouchEvents(): void {
			if (this.hit.useHandCursor) {
				this.dispatchEvent(new EventBtnHit(EventBtnHit.OUT));
				this.hit.useHandCursor = false;
				this.hit.removeEventListener(TouchEvent.TOUCH, this.onHitTouch);
				this.hit.removeEventListener(TouchEvent.TOUCH, this.onHitTouchForMove);
				//Starling.current.stage.removeEventListener(TouchEvent.TOUCH, this.onHitTouch);
				//Starling.current.stage.removeEventListener(TouchEvent.TOUCH, this.onHitTouchForMove);
			}
		}
		
		protected function removeHit(): void {
			if (this.hit != null) {
				this.removeChild(this.hit);
				this.hit = null;
			}
		}
		
		override public function dispose(): void {
			this.removeTouchEvents();
			this.removeHit();
			super.dispose();
		}
		
	}

}