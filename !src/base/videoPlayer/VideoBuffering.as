package base.videoPlayer {
	import flash.display.Sprite;
	import flash.text.TextField;
	import base.dspObj.DoOperations;
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.TextShortcuts;
	
	public class VideoBuffering extends Sprite {
		
		public var tfBuffering: TextField;
		
		private var tfColorA: uint;
		private var tfColorB: uint;
		public var numFramesAnimChangeColor: uint;
		
		public function VideoBuffering(): void {
			this.setColors(0xffffff, 0x000000);
			this.numFramesAnimChangeColor = 5;
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.BUFFER_EMPTY, this.onBufferEmpty);
			ModelVideoPlayer.addEventListener(EventModelVideoPlayer.BUFFER_FULL, this.onBufferFull);
			TextShortcuts.init();
			this.changeColor(0);
		}
	
		public function setColors(tfColorA: uint, tfColorB: uint): void {
			this.tfColorA = tfColorA;
			this.tfColorB = tfColorB;
		}
		
		private function onBufferEmpty(e: EventModelVideoPlayer): void {
			this.changeColor(0);
			DoOperations.hideShow(this, 1);
		}
		
		private function onBufferFull(e: EventModelVideoPlayer): void {
			DoOperations.hideShow(this, 0, 10, function() {
				try {
					Tweener.removeTweens(this.tfBuffering, "_text_color")
				} catch (e: TypeError) {} finally {};
			}, this);
		}
		
		private function changeColor(isColorAB: uint) {
			Tweener.addTween(this.tfBuffering, {_text_color: [this.tfColorA, this.tfColorB][isColorAB], time: this.numFramesAnimChangeColor, useFrames: true, transition: "easeInOutQuad", onComplete: this.changeColor, onCompleteScope: this, onCompleteParams: [1 - isColorAB]});
		}

		
		
		
		
	}

}