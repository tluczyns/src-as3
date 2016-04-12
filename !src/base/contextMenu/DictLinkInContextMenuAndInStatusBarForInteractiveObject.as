package base.contextMenu {
	import flash.utils.Dictionary;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import base.contextMenu.NpContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	//import swfAddress.SWFAddress;
	
	public class DictLinkInContextMenuAndInStatusBarForInteractiveObject extends Dictionary {
		
		public static var isAddHash: Boolean = true;
		
		public function DictLinkInContextMenuAndInStatusBarForInteractiveObject() {}
		
		public static function addLinkInContextMenuAndInStatusBarForInteractiveObject(io: InteractiveObject, url: String): void {
			DictLinkInContextMenuAndInStatusBarForInteractiveObject[io.name] = url;
			addRemoveContextStatusEvents(io, 1);
		}
		
		public static function addRemoveContextStatusEvents(io: InteractiveObject, isRemoveAdd: uint): void {
			var npCM: NpContextMenu = new NpContextMenu(io);
			if (isRemoveAdd == 1) {
				npCM.addMenuItem("Otwórz w nowym oknie", false);
				npCM.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onLinkInContextMenuSelect)
			}
			if (isRemoveAdd == 0) {
				//SWFAddress.setStatus("");
				io.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
				io.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			} else if (isRemoveAdd == 1) {
				io.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
				io.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			}
		}
		
		private static function onLinkInContextMenuSelect(e: ContextMenuEvent) {
			navigateToURL(new URLRequest(["", "#"][uint(isAddHash)] + DictLinkInContextMenuAndInStatusBarForInteractiveObject[e.contextMenuOwner.name]), "_blank");
		}
		
		/*
		private static function getIOActiveElement(io: InteractiveObject): InteractiveObject {
			var shape: InteractiveObject = io["shape"];
			if (shape != null) return shape;
			else return io;
		}
		
		private static function isIOEnabled(io: InteractiveObject): Boolean {
			var isIOEnabled: Boolean = getIOActiveElement(io).hasEventListener(MouseEvent.CLICK);
			if (isIOEnabled) {
				try {
					if (!io["isEnabled"]) isIOEnabled = false;
				} catch (e: Error) { } finally { };
			}
			return isIOEnabled;
		}*/
		
		private static function onMouseOverHandler(e: MouseEvent) {
			var io: InteractiveObject = InteractiveObject(e.currentTarget);
			/*if (isIOEnabled(io))*/ //SWFAddress.setStatus(DictLinkInContextMenuAndInStatusBarForInteractiveObject[io.name]);
		}
		
		private static function onMouseOutHandler(e: MouseEvent) {
			//var io: InteractiveObject = InteractiveObject(e.currentTarget);
			/*if (isIOEnabled(io))*/ //SWFAddress.setStatus("");
		}
		
	}

}