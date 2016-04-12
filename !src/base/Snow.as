package base {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Snow extends MovieClip {
		private var numFramesWhenOneToAdd: Number = 25;
		private var currFrameWhenOneToAdd: Number = 1;
		
		public function Snow() {
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}

		private function onEnterFrame(event: Event) {
			if (currFrameWhenOneToAdd == numFramesWhenOneToAdd) {
				currFrameWhenOneToAdd = 1;
				this.addSnowFlake();
			} else {
				currFrameWhenOneToAdd++;
			}
		}

		private function addSnowFlake() {
			var snowFlakeAnim = new SnowFlakeAnim();
			var margin: Number = 50;
			var widthContainer: Number = 600 + Math.max((this.parent.x - margin) * 2, 0);
			snowFlakeAnim.x = - (this.parent.x - margin) + Math.floor(Math.random() * widthContainer);
			//snowFlakeAnim.x = Math.floor(Math.random() * 600)
			var parentY: Number = this.parent.y;
			snowFlakeAnim.y = -parentY;
			snowFlakeAnim.height += (parentY * 2);
			var scale: Number = 0.6 + Math.random() * 0.4;
			snowFlakeAnim.scaleX = scale;
			snowFlakeAnim.scaleY = scale;
			//snowFlakeAnim.cacheAsBitmap = true;
			this.addChild(snowFlakeAnim);
		}

	}
	
}