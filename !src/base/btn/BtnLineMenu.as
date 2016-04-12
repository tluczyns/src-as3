package base.btn {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.TweenNano;
	import com.greensock.easing.*;
	import com.adobe.utils.ArrayUtil;
	
	public class BtnLineMenu extends Sprite {
		
		public var maskTfActive: Sprite;
		public var tfActive: TextField;
		public var rectMove: Sprite;
		public var tfBg: TextField;
		public var arrHit: Array;
		private var numPointed: int;
		private var numActive: int;
		protected var isNotClicked: Boolean = false;
		protected var arrNumHitNotToSetActive: Array = [];
		
		public function BtnLineMenu(strLabel: String, arrWidthHit: Array): void {			
			this.tfActive.text = "";
			this.tfActive.autoSize = TextFieldAutoSize.LEFT;
			this.tfActive.text = strLabel
			this.tfActive.mask = this.maskTfActive;
			this.tfBg.text = "";
			this.tfBg.autoSize = TextFieldAutoSize.LEFT;
			this.tfBg.text = strLabel;
			
			this.arrHit = new Array(arrWidthHit.length);
			var totalWidthHit: Number = 0;
			for (var i:uint = 0; i < arrWidthHit.length; i++) {
				var hit: MovieClip = this.addHit(i, arrWidthHit[i]);
				hit.x = totalWidthHit;
				totalWidthHit += arrWidthHit[i];
				hit.y = this.maskTfActive.y;
				this.arrHit[i] = hit;
			}
			this.addMouseEvents();
			this.numActive = -1;
			this.numPointed = -1;
			this.maskTfActive.x = this.maskTfActive.width = this.rectMove.x = this.rectMove.width = 0;
		}
		
		private function addHit(num: uint, widthHit: Number): MovieClip {
			var hit: MovieClip = new MovieClip();
			hit.num = num;
			hit.graphics.lineStyle(0, 0, 0);
			hit.graphics.beginFill(0xFFFFFF, 0);
			hit.graphics.moveTo(0, 0);
			hit.graphics.lineTo(widthHit, 0);
			hit.graphics.lineTo(widthHit, this.maskTfActive.height);
			hit.graphics.lineTo(0, this.maskTfActive.height);
			hit.graphics.lineTo(0, 0);
			hit.graphics.endFill();
			this.addChild(hit);
			return hit;
		}
		
		public function addMouseEvents(): void {
			if ((this.arrHit != null) && (this.arrHit.length > 0) && (!MovieClip(this.arrHit[0]).buttonMode)) {
				for (var i: uint = 0; i < this.arrHit.length; i++) {
					var hit: MovieClip = this.arrHit[i];
					hit.buttonMode = true;
					hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
					hit.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
					hit.addEventListener(MouseEvent.CLICK, this.onClickHandler);
					hit.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
					hit.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				}
			}
		}
		
		public function removeMouseEvents(): void {
			if ((this.arrHit != null) && (this.arrHit.length > 0) && (MovieClip(this.arrHit[0]).buttonMode)) {
				for (var i:uint = 0; i < this.arrHit.length; i++) {
					var hit: MovieClip = this.arrHit[i];
					hit.buttonMode = false;
					hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverHandler);
					hit.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutHandler);
					hit.removeEventListener(MouseEvent.CLICK, this.onClickHandler);
					if (hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
						hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
						hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
					}
				}
			}
		}

		private function animMaskTfActiveRectMoveToPointed(): void {
			var pointedHit: Object;
			if (this.numPointed > -1) pointedHit = this.arrHit[this.numPointed];
			else pointedHit = {x: 0, width: 0};
			var objSpr: Object = {maskTfActive: this.maskTfActive, rectMove: this.rectMove};
			for (var i: String in objSpr) {
				var spr: Sprite = objSpr[i]; 
				TweenNano.killTweensOf(spr);
				TweenNano.to(spr, 10, {x: pointedHit.x, width: pointedHit.width, useFrames: true, ease: Quart.easeInOut});
			}
		}
		
		private function onMouseOverHandler(event: MouseEvent, isFromMouse: Boolean = true): void {
			var hit: MovieClip = MovieClip(event.currentTarget)
			if (hit.num != this.numPointed) {
				this.numPointed = hit.num;
				this.animMaskTfActiveRectMoveToPointed();
			}
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OVER, {num: this.numPointed, isFromMouse: isFromMouse}));
		}
		
		private function onMouseOutHandler(event: MouseEvent, isFromMouse: Boolean = true): void {
			if (this.numActive != this.numPointed) {
				this.numPointed = this.numActive;
				this.animMaskTfActiveRectMoveToPointed();
			}
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OUT, {num: this.numPointed, isFromMouse: isFromMouse}));
		}
		
		public function onClickHandler(event: MouseEvent): void {
			var numHitClicked: int;
			if (event != null) {
				var hit: MovieClip = MovieClip(event.currentTarget);
				if ((!ArrayUtil.arrayContainsValue(this.arrNumHitNotToSetActive, hit.num)) && (hit.num != this.numActive)) {
					this.numActive = hit.num;
					this.onMouseOverHandler(event, !this.isNotClicked);
				} else {
					this.dispatchEvent(new BtnHitEvent(BtnHitEvent.OVER, {num: this.numPointed, isFromMouse: !this.isNotClicked}));
				}
				numHitClicked = hit.num;
			} else {
				this.numActive = -1;
				this.onMouseOutHandler(event, !this.isNotClicked);
				numHitClicked = -1;
			}
			if (!this.isNotClicked)	this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED, {num: numHitClicked}));
			else this.isNotClicked = false;
		}
		
		private function onMouseOverForMouseMoveHandler(event: MouseEvent): void {
			var hit: MovieClip = MovieClip(event.currentTarget)
			if (hit.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
				hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
			}
		}
		
		protected function onMouseMoveHandler(event: MouseEvent): void {
			var hit: MovieClip = MovieClip(event.currentTarget)
			hit.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveHandler);
			hit.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverForMouseMoveHandler);
			this.onMouseOverHandler(event);
		}
		
	}

}