package base.vspm {
	import flash.display.Sprite;
	import com.greensock.TimelineMax;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	public class View extends Sprite implements IViewSection {
		
		public var content: ContentView;
		public var description: DescriptionView;
		
		protected var isHideShow: uint;
		protected var tMaxHideShow: TimelineMax;
		
		public function View(content: ContentView): void {
			this.content = content;
		}
		
		public function init(): void {
			//abstract: initialization
			if (!this.tMaxHideShow) this.alpha = 0;
		}
		
		protected function hideShowTimelineMax(isHideShow: uint): void {
			if (isHideShow == 0) {
				if (this.tMaxHideShow.totalProgress > 0) this.tMaxHideShow.reverse();
				else this.hideComplete();
			} else if (isHideShow == 1) {
				if (this.tMaxHideShow.totalProgress < 1) this.tMaxHideShow.play();
				else this.startAfterShow();
			}
		}
		
		protected function hideShowEmpty(isHideShow: uint, timeDelayStartAfterShow: Number): void {
			TweenLite.killDelayedCallsTo(this.startAfterShow);
			if (isHideShow == 0) this.hideComplete();
			else if (isHideShow == 1) TweenLite.delayedCall(timeDelayStartAfterShow, this.startAfterShow);
		}
		
		protected function hideShow(isHideShow: uint): void {
			if (this.tMaxHideShow) this.hideShowTimelineMax(isHideShow);
			else TweenLite.to(this, 0.3, {alpha: isHideShow, ease: Linear.easeNone, onComplete: [this.hideComplete, this.startAfterShow][isHideShow]});
		}
		
		public function show(): void {
			this.isHideShow = 1;
			this.hideShow(1);
		}
		
		protected function startAfterShow(): void {
			//abstract: fe. additional animation, adding listeners and mouse events
		}
		
		protected function stopBeforeHide(): void {
			//abstract: fe. removing listeners and mouse events
		}
		
		public function hide(): void {
			this.stopBeforeHide();
			this.isHideShow = 0;
			this.hideShow(0);
		}
		
		protected function hideComplete(): void {
			if (this.tMaxHideShow) this.tMaxHideShow.stop();
		}
		
	}

}