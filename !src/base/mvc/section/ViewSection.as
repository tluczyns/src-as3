package base.mvc.section {
	import flash.display.MovieClip;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	public class ViewSection extends MovieClip implements IViewSection {
		
		public var descriptionViewSection: DescriptionViewSection;
		
		protected var isHideShow: uint;
		protected var tMaxHideShow: TimelineMax;
		
		public function ViewSection(): void {}
		
		public function init(): void {
		}
		
		protected function isDifferentIndSections(isHideShow: uint): Boolean {
			/*var currIndSection: String = [ViewSectionManager.currIndSection, ViewSectionManager.oldIndSection][isHideShow];
			var newIndSection: String = [ViewSectionManager.newIndSection, ViewSectionManager.currIndSection][isHideShow];	
			return (currIndSection != newIndSection);*/
			return (ViewSectionManager.oldIndSection != ViewSectionManager.newIndSection);
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
			TweenMax.killDelayedCallsTo(this.startAfterShow);
			if (isHideShow == 0) this.hideComplete();
			else if (isHideShow == 1) TweenMax.delayedCall(timeDelayStartAfterShow, this.startAfterShow);
		}
		
		protected function hideShow(isHideShow: uint): void {
			if (this.tMaxHideShow) this.hideShowTimelineMax(isHideShow);
			else TweenMax.to(this, 0.4, {alpha: isHideShow, ease: Linear.easeNone, onComplete: [this.hideComplete, this.startAfterShow][isHideShow]});
		}
		
		public function show(): void {
			//trace(getFunctionName(new Error());
			/*if (this.isDifferentIndSections(1)) */
			this.isHideShow = 1;
			this.hideShow(1);
		}
		
		public function startAfterShow(): void {
			ViewSectionManager.startSection();
			//abstrakcyjna, np. dodatkowe animacje, dodawanie zdarzeń myszy
		}
		
		public function stopBeforeHide(): void {
			//abstrakcyjna, np. dodatkowe animacje, usuwanie zdarzeń myszy
		}
		
		public function hide(): void {
			//if (this.isDifferentIndSections(0)) {
				this.stopBeforeHide();
				this.isHideShow = 0;
				this.hideShow(0);
			//}
		}
		
		public function hideComplete(): void {
			if (this.tMaxHideShow) this.tMaxHideShow.stop();
			ViewSectionManager.finishStopSection(this.descriptionViewSection);
		}
		
	}

}