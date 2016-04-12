package baseStarling.game {
	import flash.display.Bitmap;
	/*import flash.display.Sprite;
	import flash.display.BitmapData;
	import base.bitmap.BitmapUtils;
	import flash.display.Bitmap;*/
	import base.loader.Library;
	import starling.events.Event;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	[SWF(backgroundColor = "0xffffff", frameRate = "35", width = "1280", height = "900")]
	
	public class TestAnimBgRepeat extends AnimBgRepeat {
		
		[Embed(source = "sky.jpg")]
		static private var classBmp: Class;
		
		public function TestAnimBgRepeat(): void {
			/*this.addChild(BitmapUtils.drawReflectionToBitmap(Library.getMovieClip("summerZoneAnimationSummary2013.bgBeachSmall")));
			var bmpDataSegment: BitmapData = BitmapUtils.drawWithGradientToTransparent(Library.getBitmapData("summerZoneAnimationSummary2013.bgBeachSmall"), 0, 1, 0.8);
			var bmpDataSegment: BitmapData = BitmapUtils.drawPixelate(Library.getMovieClip("summerZoneAnimationSummary2013.bgBeachSmall"), 5);
			this.addChild(new Bitmap(bmpDataSegment, "auto", true));*/
			super(Bitmap(new TestAnimBgRepeat.classBmp()).bitmapData, 0, 0);
			this.x = 100;
			this.y = 30;
			//this.width = 1280;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage)
		}
		
		private function onAddedToStage(e: Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
			this.onStageResize(null);
			TweenMax.to(this, 6, {posAnim: 5000, ease: Cubic.easeInOut, repeat: -1, yoyo: true});
		}
		
		private function onStageResize(e: Event):void {
			this.width = this.stage.stageWidth - 2 * this.x;
			this.height = this.stage.stageHeight - 2 * this.y;
		}
		
		override public function dispose(): void {
			TweenMax.killTweensOf(this);
			this.stage.removeEventListener(Event.RESIZE, this.onStageResize);
			super.dispose();
		}
		
	}

}