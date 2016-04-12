package base.game {
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	[SWF(backgroundColor = "0x000000", frameRate = "40", width = "960", height = "550")]
	public class TestElementsEquallyDistributted2D extends ElementsEquallyDistributted {
		
		public function TestElementsEquallyDistributted2D() {
			//super(new <Number>[520], 20, 1);
			//super(new <Number>[100, 520], 200, 1);
			super(new <Number>[this.stage.stageWidth, this.stage.stageHeight, 12000], 1200, 1);
			var element: DisplayObject; 
			for (var i: uint = 0; i < this.vecElement.length; i++) {
				element = this.vecElement[i];
				element.x = Math.random() * this.stage.stageWidth;
				element.y = Math.random() * this.stage.stageHeight;
			//	element.z = Math.random() * 2000;
			}
			this.transform.perspectiveProjection = new PerspectiveProjection();
			this.transform.perspectiveProjection.projectionCenter = new Point(this.stage.stageWidth / 2, this.stage.stageHeight / 2);
			this.addEventListener(Event.ENTER_FRAME, this.onEF);
		}
		
		private function onEF(e: Event): void {
			//this.transform.perspectiveProjection.fieldOfView -= 0.1;
			for (var i: uint = 0; i < this.vecElement.length; i++)
				DisplayObject(this.vecElement[i]).z -= 10;
		}
		
		override protected function createElement(): DisplayObject {
			var shp: Shape = new Shape();
			shp.graphics.beginFill(0xffffff, 1);
			//shp.graphics.drawRect(0, 0, 10, 10);
			shp.graphics.drawCircle(0, 0, 2);
			shp.graphics.endFill();
			return shp;
		}
		
	}

}