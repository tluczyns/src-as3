package base.flashUtils {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.display.InteractiveObject;
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.events.MouseEvent;

	public class MouseWheelForTransparentSWF extends Sprite {
		
		private var isForStage: Boolean;
		
		public function MouseWheelForTransparentSWF(isForStage: Boolean = true): void {
			this.isForStage = isForStage;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage)
		}
		
		private function onAddedToStage(e: Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			if (ExternalInterface.available) ExternalInterface.addCallback("handleWheel", this.handleWheel);		
		}
		
		public function handleWheel(event:Object): void {
			var obj: InteractiveObject;
			var pointMouse: Point = new Point(this.stage.mouseX, this.stage.mouseY)
			if (!this.isForStage) {
				var objects:Array = this.getObjectsUnderPoint(pointMouse);
				for (var i:int = objects.length - 1; i >= 0; i--) {
					if (objects[i] is InteractiveObject) {
						obj = objects[i] as InteractiveObject;
						break;
					} else {
						if (objects[i] is Shape && (objects[i] as Shape).parent) {
							obj = (objects[i] as Shape).parent;
							break;
						}
					}
				}
			} else obj = this.stage;
			obj.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, pointMouse.x, pointMouse.y, obj, event.ctrlKey, event.altKey, event.shiftKey, false, -Number(event.delta)));
		}
		
	}

}