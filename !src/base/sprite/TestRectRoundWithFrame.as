package base.sprite {
	import flash.display.GraphicsSolidFill;
	import flash.display.Sprite;
	import base.app.InitUtils;
	import flash.display.StageScaleMode;
	import flash.display.GraphicsGradientFill;
	import flash.geom.Matrix;
	import flash.events.Event;
	
	public class TestRectRoundWithFrame extends Sprite {
		
		private var rectRoundWithFrame: RectRoundWithFrame;
		
		public function TestRectRoundWithFrame(): void {
			InitUtils.initApp(this, StageScaleMode.NO_SCALE);
			
			var graphicsFillFrame: GraphicsGradientFill = new GraphicsGradientFill();
			graphicsFillFrame.colors = [0xff0000, 0x0000ff];
			graphicsFillFrame.matrix = new Matrix();
			graphicsFillFrame.matrix.createGradientBox(300, 300, 0);
			
			this.rectRoundWithFrame = new RectRoundWithFrame(10, 20, graphicsFillFrame, 2, new GraphicsSolidFill(0x00ff00, 1), 300, 300);
			this.rectRoundWithFrame.x = this.rectRoundWithFrame.y = 50;
			this.addChild(this.rectRoundWithFrame);
			this.stage.addEventListener(Event.RESIZE, this.onStageResize)
			this.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onStageResize(e: Event):void {
			this.rectRoundWithFrame.setSize(this.stage.stageWidth - 2 * this.rectRoundWithFrame.x, this.stage.stageHeight - 2 * this.rectRoundWithFrame.y);
		}
		
	}

}