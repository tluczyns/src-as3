package base {
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import base.types.ArrayExt;
	
	public class KeyboardControls {

		private var listenDisplayObject: DisplayObject;
		public var dictIsPressedKey: Dictionary;
		private var isFirstUpDown: uint, isFirstLeftRight: uint;
		public var isNoneUpDown: int, isNoneLeftRight: int;
		private var onEnterFrameFunction: Function, onEnterFrameScope: Object;
		private var onKeyDownFunction: Function, onKeyDownScope: Object;
		private var onKeyUpFunction: Function, onKeyUpScope: Object;
		private var arrOrderUpDownLeftRightKeys: ArrayExt;
		
		public function KeyboardControls(initObj: Object) {
			//listenDisplayObject: DisplayObject, arrOtherKeys: Array = null, onEnterFrameFunction: Function = null, onEnterFrameScope: Object = null, onKeyUpFunction: Function = null, onKeyUpScope: Object = null, onKeyDownFunction: Function = null, onKeyDownScope: Object = null
			this.listenDisplayObject = initObj.listenDisplayObject;
			this.onEnterFrameFunction = initObj.onEnterFrameFunction;
			this.onEnterFrameScope = (initObj.onEnterFrameScope != null) ? initObj.onEnterFrameScope : listenDisplayObject;
			this.onKeyDownFunction = initObj.onKeyDownFunction;
			this.onKeyDownScope = (initObj.onKeyDownScope != null) ? initObj.onKeyDownScope : listenDisplayObject;
			this.onKeyUpFunction = initObj.onKeyUpFunction;
			this.onKeyUpScope = (initObj.onKeyUpScope != null) ? initObj.onKeyUpScope : listenDisplayObject;
			var arrCursorKeys: Array = [Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT];
			var arrWSADKeys: Array = [87, 83, 65, 68];
			this.dictIsPressedKey = new Dictionary();
			for (var i: Number = 0; i < arrCursorKeys.length; i++) {
				this.dictIsPressedKey[arrCursorKeys[i]] = false;
			}
			for (i = 0; i < arrWSADKeys.length; i++) {
				this.dictIsPressedKey[arrWSADKeys[i]] = false;
			}
			var arrOtherKeys: Array =  initObj.arrOtherKeys;
			if (arrOtherKeys == null) {
				arrOtherKeys = [];
			}
			for (i = 0; i < arrOtherKeys.length; i++) {
				if (getDefinitionByName(getQualifiedClassName(arrOtherKeys[i])) == String) {
					 arrOtherKeys[i] = arrOtherKeys[i].charCodeAt();
				}
				this.dictIsPressedKey[arrOtherKeys[i]] = false;
			}
			this.isNoneUpDown = -1;
			this.isNoneLeftRight = -1;
			this.arrOrderUpDownLeftRightKeys = new ArrayExt();
			this.addKeyboardEvents();
		}
		
		private function onEnterFrameHandler(event:Event): void {
			if (this.onEnterFrameFunction != null) {
				this.onEnterFrameFunction.apply(this.onEnterFrameScope, [ { cursorUpDown: this.isNoneUpDown, cursorLeftRight: this.isNoneLeftRight } ]);
			}
		}
		
		private function setCurrentCursorKeys(): void {
			var isPressedKeyUp: Object = (this.dictIsPressedKey[Keyboard.UP] || this.dictIsPressedKey[87]);
			var isPressedKeyDown: Object = (this.dictIsPressedKey[Keyboard.DOWN] || this.dictIsPressedKey[83]);
			var isPressedKeyLeft: Object = (this.dictIsPressedKey[Keyboard.LEFT] || this.dictIsPressedKey[65]);
			var isPressedKeyRight: Object = (this.dictIsPressedKey[Keyboard.RIGHT] || this.dictIsPressedKey[68]);
			if ((isPressedKeyUp) && (isPressedKeyDown)) {
				this.isNoneUpDown = this.isFirstUpDown;
			} else if (isPressedKeyUp) {
				this.isNoneUpDown = 0;
			} else if (isPressedKeyDown) {
				this.isNoneUpDown = 1;
			} else {
				this.isNoneUpDown = -1
			}
			if ((isPressedKeyLeft) && (isPressedKeyRight)) {
				this.isNoneLeftRight = this.isFirstLeftRight;
			} else if (isPressedKeyLeft) {
				this.isNoneLeftRight = 0;
			} else if (isPressedKeyRight) {
				this.isNoneLeftRight = 1;
			} else {
				this.isNoneLeftRight = -1
			}
		}
		
        private function onKeyDownHandler(event:KeyboardEvent): void {
			if (this.dictIsPressedKey.hasOwnProperty(event.keyCode)) {
				this.dictIsPressedKey[event.keyCode] = true;
			}
			if ((event.keyCode == Keyboard.UP) || (event.keyCode == 87)) {
				this.removeAndAddToArrOrderKeys(0);
				this.isFirstUpDown = 0;
			} else if ((event.keyCode == Keyboard.DOWN) || (event.keyCode == 83)) {
				this.removeAndAddToArrOrderKeys(1);
				this.isFirstUpDown = 1;
			}
			if ((event.keyCode == Keyboard.LEFT) || (event.keyCode == 65)) {
				this.removeAndAddToArrOrderKeys(2);
				this.isFirstLeftRight = 0;
			} else if ((event.keyCode == Keyboard.RIGHT) || (event.keyCode == 68)) {
				this.removeAndAddToArrOrderKeys(3);
				this.isFirstLeftRight = 1;
			}
			this.setCurrentCursorKeys();
			if (this.onKeyDownFunction != null) {
				this.onKeyDownFunction.apply(this.onKeyDownScope, [event.keyCode]);
			}
        }

        private function onKeyUpHandler(event:KeyboardEvent): void {
			if (this.dictIsPressedKey.hasOwnProperty(event.keyCode)) {
				this.dictIsPressedKey[event.keyCode] = false;
			}
			if ((event.keyCode == Keyboard.UP) || (event.keyCode == 87)) {
				this.arrOrderUpDownLeftRightKeys.remove(0);
			} else if ((event.keyCode == Keyboard.DOWN) || (event.keyCode == 83)) {
				this.arrOrderUpDownLeftRightKeys.remove(1);
			} else if ((event.keyCode == Keyboard.LEFT) || (event.keyCode == 65)) {
				this.arrOrderUpDownLeftRightKeys.remove(2);
			} else if ((event.keyCode == Keyboard.RIGHT) || (event.keyCode == 68)) {
				this.arrOrderUpDownLeftRightKeys.remove(3);
			}
			this.setCurrentCursorKeys();
			if (this.onKeyUpFunction != null) {
				this.onKeyUpFunction.apply(this.onKeyUpScope, [event.keyCode]);
			}
        }
		
		private function removeAndAddToArrOrderKeys(isUpDownLeftRight: uint): void {
			this.arrOrderUpDownLeftRightKeys.remove(isUpDownLeftRight);
			this.arrOrderUpDownLeftRightKeys.push(isUpDownLeftRight);
		}
		
		public function get isNoneUpDownLeftRight(): int {
			var isNoneUpDownLeftRight: int;
			if (this.arrOrderUpDownLeftRightKeys.length > 0) isNoneUpDownLeftRight = this.arrOrderUpDownLeftRightKeys[this.arrOrderUpDownLeftRightKeys.length - 1];
			else isNoneUpDownLeftRight = -1;
			return isNoneUpDownLeftRight;
		}
		
		public function addKeyboardEvents(): void {
			this.listenDisplayObject.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDownHandler);
			this.listenDisplayObject.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUpHandler);
			this.listenDisplayObject.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
		}
		
		public function removeKeyboardEvents(): void {
			this.listenDisplayObject.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDownHandler);
			this.listenDisplayObject.stage.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUpHandler);
			this.listenDisplayObject.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
		}
		
		public function destroy(): void {
			this.removeKeyboardEvents();
		}
		
	}

}