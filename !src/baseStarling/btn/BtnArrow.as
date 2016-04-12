package baseStarling.btn {
	import starling.display.DisplayObject;
	import starling.display.Shape;
	import flash.geom.Rectangle;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	
	public class BtnArrow extends BtnHitAndBlockWithEvents {
		
		public var isPrevNext: uint;
		private var posXYInitArrow: Number;
		protected var moveXYArrow: Number;
		protected var countFramesAnimArrow: Number;
		private var isMoveXOrY: uint;
		
		public var arrow: DisplayObject;
		
		public function BtnArrow(isPrevNext: uint, isMoveXOrY: uint = 0, arrow: DisplayObject = null, moveXYArrow: Number = 3, countFramesAnimArrow: Number = 5, hit: Shape = null): void {
			this.isPrevNext = isPrevNext;
			this.isMoveXOrY = isMoveXOrY;
			this.moveXYArrow = moveXYArrow;
			this.countFramesAnimArrow = countFramesAnimArrow;
			super(hit);
			this.initArrow(arrow);
			this.posXYInitArrow = this.arrow[["x", "y"][this.isMoveXOrY]];
			if (this.isPrevNext == 0) {
				this.arrow[["scaleX", "scaleY"][this.isMoveXOrY]] = -1;
				this.arrow[["x", "y"][this.isMoveXOrY]] = this.posXYInitArrow + this.arrow[["width", "height"][this.isMoveXOrY]] //+ this.moveXYArrow;
			}
		}
		
		override public function createGenericHit(rectDimension: Rectangle = null): void {
			this.hit = new Shape();
			this.hit.graphics.beginFill(0xffffff, 0);
			this.hit.graphics.drawRect(0, 0, this.arrow.x + this.arrow.width + [this.moveXYArrow, 0][this.isMoveXOrY], this.arrow.y + this.arrow.height + [0, this.moveXYArrow][this.isMoveXOrY]);
			this.hit.graphics.endFill();
			this.addChild(this.hit);
		}
		
		private function initArrow(arrow: DisplayObject = null): void {
			if ((this.arrow == null) && (arrow != null)) {
				this.addChild(arrow);
				this.setChildIndex(arrow, this.numChildren - 2);
				this.arrow = arrow;
			}
		}
		
		override public function setElementsOnOutOver(isOutOver: uint): void {
			var onComplete: Function = null;
			if (isOutOver == 1) onComplete = this.animArrow;
			var objTween: Object = {useFrames: uint(this.countFramesAnimArrow >= 1), ease: [Quad.easeIn, Quad.easeOut][isOutOver], onComplete: onComplete};
			objTween[["x", "y"][this.isMoveXOrY]] = this.posXYInitArrow + [0, this.moveXYArrow][isOutOver] + [this.arrow[["width", "height"][this.isMoveXOrY]], 0][this.isPrevNext];
			TweenLite.to(this.arrow, this.countFramesAnimArrow / 2, objTween);
		}
		
		private function animArrow(): void {
			var objTween: Object = {useFrames: uint(this.countFramesAnimArrow >= 1), ease: Sine.easeIn, yoyo: true, repeat: -1};
			objTween[["x", "y"][this.isMoveXOrY]] = this.posXYInitArrow - this.moveXYArrow + [this.arrow[["width", "height"][this.isMoveXOrY]], 0][this.isPrevNext];
			TweenMax.to(this.arrow, this.countFramesAnimArrow, objTween);
		}
		
	}

}