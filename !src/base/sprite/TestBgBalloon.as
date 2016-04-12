package base.sprite {
	import flash.display.Sprite;
	import base.app.InitUtils;
	import flash.display.StageScaleMode;
	import flash.display.GraphicsGradientFill;
	import flash.geom.Matrix;
	import flash.display.GraphicsSolidFill;
	import flash.events.Event;
	
	public class TestBgBalloon extends Sprite {
		
		private var bgBalloon: BgBalloon;
		private var graphicsFillFrame: GraphicsGradientFill;
		
		public function TestBgBalloon(): void {
			InitUtils.initApp(this, StageScaleMode.NO_SCALE);
			
			this.graphicsFillFrame = new GraphicsGradientFill();
			this.graphicsFillFrame.colors = [0xff0000, 0x0000ff];
			this.graphicsFillFrame.matrix = new Matrix();
			this.graphicsFillFrame.matrix.createGradientBox(300, 300, 0);
			
			this.bgBalloon = new BgBalloon(5, 10, this.graphicsFillFrame, 1, new GraphicsSolidFill(0xffffff, 1), 60, 50, -50, 100, 300, 300);
			this.bgBalloon.x = this.bgBalloon.y = 50;
			this.addChild(this.bgBalloon);
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
			this.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onStageResize(e: Event): void {
			var width: Number = this.stage.stageWidth - 2 * this.bgBalloon.x;
			var height: Number = this.stage.stageHeight - 2 * this.bgBalloon.y;
			this.graphicsFillFrame.matrix.createGradientBox(width, height, 0);
			this.bgBalloon.setSize(width, height);
		}
		
	}

}