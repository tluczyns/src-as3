package base.videoPlayer {
	import flash.display.Sprite;
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;

	public class ControllerSoundBar extends Sprite {
		
		public var sideTop: Sprite;
		public var center: Sprite;
		public var sideBottom: Sprite;
		
		public function ControllerSoundBar(): void {
			ColorShortcuts.init();
		}
		
		override public function set height(value: Number): void {
			this.center.height = value - this.sideTop.height - this.sideBottom.height;
			this.sideBottom.y = this.center.y + this.center.height + this.sideBottom.height;
		}
		
		internal function addRemoveTweenBrightness(isRemoveAdd: uint): void {
			var targetBrightness: Number = [0, 1][isRemoveAdd];
			Tweener.removeTweens(this, "_brightness");
			Tweener.addTween(this, {_brightness: targetBrightness, time: 10, useFrames: true, transition: "easeOutQuad"});
		}
		
		internal function addTweenColor(targetColor: uint): void {
			Tweener.removeTweens(this, "_color");
			Tweener.addTween(this, {_color: targetColor, time: 10, useFrames: true, transition: "easeOutQuad"});
		}
		
		
	}
	
}