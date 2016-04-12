package base.btn {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	public class BtnTimeline extends BtnHitWithEvents {
		
		public function BtnTimeline(hit: Sprite = null): void {
			MovieClip(this).stop();
			super(hit);
		}
		
		override public function setElementsOnOutOver(isOutOver: uint): void {
			var targetNumFrame: uint = [1, MovieClip(this).totalFrames][isOutOver];
			TweenMax.to(MovieClip(this), Math.abs(targetNumFrame - MovieClip(this).currentFrame), {frame: targetNumFrame, useFrames: true, ease: Linear.easeNone});
		}
		
	}

}