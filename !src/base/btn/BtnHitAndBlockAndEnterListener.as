package base.btn {
	import flash.events.Event;
	import base.KeyboardControls;
	import flash.ui.Keyboard;
	
	public class BtnHitAndBlockAndEnterListener extends BtnHitAndBlock {
		
		private var classWithBtnWithEnterListener: Class;
		private var keyboardControls: KeyboardControls;
			
		public function BtnHitAndBlockAndEnterListener(classWithBtnWithEnterListener: Class): void {
			super();
			this.classWithBtnWithEnterListener = classWithBtnWithEnterListener;
			this.addEventListener(Event.ADDED_TO_STAGE, this.createKeyboardControls);
		}
		
		private function createKeyboardControls(e: Event): void	{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.createKeyboardControls);
			this.keyboardControls = new KeyboardControls({listenDisplayObject: this, arrOtherKeys: [Keyboard.ENTER], onKeyDownFunction: this.checkPressedKey,  onKeyDownScope: this});
		}
		
		protected function checkPressedKey(keyCode: uint): void {
			if ((keyCode == Keyboard.ENTER) && ((this.classWithBtnWithEnterListener == null) || (this.classWithBtnWithEnterListener.btnWithEnterListener == this))) {
				this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED));
			}
		}
		
		override public function addMouseEvents(): void {
			if (this.keyboardControls != null) this.keyboardControls.addKeyboardEvents();
			super.addMouseEvents();
		}
		
		override public function removeMouseEvents(): void {
			if (this.keyboardControls != null) this.keyboardControls.removeKeyboardEvents();
			super.removeMouseEvents();
		}
		
	}

}