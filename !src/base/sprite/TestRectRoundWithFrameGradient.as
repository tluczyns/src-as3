package base.sprite {
	import flash.display.GradientType;
	import flash.display.Sprite;
	import base.app.InitUtils;
	import flash.display.StageScaleMode;
	import flash.display.GraphicsGradientFill;
	import flash.geom.Matrix;
	import flash.events.Event;
	
	public class TestRectRoundWithFrameGradient extends Sprite {
		
		private var rectRoundWithFrameGradient: RectRoundWithFrameGradient;
		
		public function TestRectRoundWithFrameGradient(): void {
			InitUtils.initApp(this, StageScaleMode.NO_SCALE);
			
			/*var graphicsFillFrame: GraphicsGradientFill = new GraphicsGradientFill(GradientType.RADIAL,);
			graphicsFillFrame.colors = [0xff0000, 0x0000ff];
			graphicsFillFrame.matrix = new Matrix();
			graphicsFillFrame.matrix.createGradientBox(300, 300, 0);*/
			
			this.rectRoundWithFrameGradient = new RectRoundWithFrameGradient(200, [0x000000, 0x000000], [0, 1], [100, 255], false, 300, 300);
			//this.rectRoundWithFrameGradient = new RectRoundWithFrameGradient(200, [0xff0000, 0x0000ff], [1, 1], [100, 255], false, 300, 300);
			//this.rectRoundWithFrameGradient = new RectRoundWithFrameGradient(200, [0x00ff00, 0xff0000, 0x0000ff], [1, 1, 1], [0, 100, 255], false, 300, 300);
			this.rectRoundWithFrameGradient.x = this.rectRoundWithFrameGradient.y = 50;
			this.addChild(this.rectRoundWithFrameGradient);
			this.stage.addEventListener(Event.RESIZE, this.onStageResize)
			this.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onStageResize(e: Event):void {
			this.rectRoundWithFrameGradient.setSize(this.stage.stageWidth - 2 * this.rectRoundWithFrameGradient.x, this.stage.stageHeight - 2 * this.rectRoundWithFrameGradient.y);
		}
		
	}

}