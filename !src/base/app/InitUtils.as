package base.app {
	import base.types.Singleton;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.display.Shape;

	public class InitUtils extends Singleton {
		
		private static var scaleMode: String;
		private static var rectMask: Rectangle;
		
		public static function initApp(iObj: DisplayObjectContainer, scaleMode: String = "noScale"/*StageScaleMode.NO_SCALE*/, rectMask: Rectangle = null): void {
			InitUtils.scaleMode = scaleMode;
			InitUtils.rectMask = rectMask;
			InitUtils.setupContextMenu(iObj);
			InitUtils.setupStageAndMask(iObj);
		}
		
		public static function setupContextMenu(iObj: InteractiveObject): void {
            var contextMenu: ContextMenu = new ContextMenu();
            contextMenu.hideBuiltInItems();
            iObj.contextMenu = contextMenu;
		}
		
		public static function setupStageAndMask(dspObjContainer: DisplayObjectContainer): void {
			if (dspObjContainer.stage) InitUtils.setupStageAndMaskOnAddedToStage({target: dspObjContainer});
			else dspObjContainer.addEventListener(Event.ADDED_TO_STAGE, InitUtils.setupStageAndMaskOnAddedToStage);
		}
		
		private static function setupStageAndMaskOnAddedToStage(e: Object): void {
			var dspObjContainer: DisplayObjectContainer = DisplayObjectContainer(e.target);
			dspObjContainer.removeEventListener(Event.ADDED_TO_STAGE, InitUtils.setupStageAndMaskOnAddedToStage);
			InitUtils.setupStage(dspObjContainer);
			InitUtils.addMask(dspObjContainer);
		}
		
		private static function setupStage(dspObj: DisplayObject): void {
			dspObj.x = 0;
			dspObj.y = 0;
			dspObj.stage.align = StageAlign.TOP_LEFT;
            dspObj.stage.scaleMode = InitUtils.scaleMode;
            dspObj.stage.quality = StageQuality.HIGH;
            dspObj.stage.focus = dspObj.stage;
		}
		
		private static function addMask(dspObjContainer: DisplayObjectContainer): void {
			//InitUtils.rectMask = new Rectangle(0, 0, dspObjContainer.stage.stageWidth, dspObjContainer.stage.stageHeight);
			if (InitUtils.rectMask != null) {
				var mask: Shape = new Shape();
				mask.graphics.beginFill(0xFFFFFF, 1);
				mask.graphics.drawRect(InitUtils.rectMask.x, InitUtils.rectMask.y, InitUtils.rectMask.width, InitUtils.rectMask.height);
				mask.graphics.endFill();
				dspObjContainer.addChild(mask);
				dspObjContainer.setChildIndex(mask, 0);
				dspObjContainer.mask = mask;
			}
		}
		
	}
	
}