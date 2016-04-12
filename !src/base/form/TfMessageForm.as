package base.form {
	import base.form.TfMessage;
	import flash.text.TextFormat;
	import flash.events.TimerEvent;
	import base.dspObj.DoOperations;
	
	public class TfMessageForm extends TfMessage {
		
		private var classForm: Form;
		
		public function TfMessageForm(classForm: Form, arrTextDurationMessage: Array, arrTextIsBadGoodCloseMessage: Array, tFormatMessage: TextFormat, colorsTfMessage: ColorsTfMessage = null): void {
			this.classForm = classForm;
			super(arrTextDurationMessage, arrTextIsBadGoodCloseMessage, tFormatMessage, colorsTfMessage);
		}
		
		override public function onTimerCompleteCloseMessage(e: TimerEvent = null): void {
			DoOperations.hideShow(this, 0, -1, this.finishHideTfMessageForm);
		}
		
		private function finishHideTfMessageForm(): void {
			this.classForm.isProcessing = false;
			this.classForm.blockUnblock(1);
			var isBadGoodCloseMessage: uint = this.arrTextIsBadGoodCloseMessage[this.typeCloseMessage].isBadGood;
			if (isBadGoodCloseMessage == 0) this.classForm.dispatchEvent(new EventForm(EventForm.PROCESSED_NEGATIVE));
			else if (isBadGoodCloseMessage == 1) this.classForm.dispatchEvent(new EventForm(EventForm.PROCESSED_POSITIVE));
		}
		
	}

}