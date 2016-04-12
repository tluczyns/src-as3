package base.form {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Point;
	import base.service.DescriptionCall;
	import flash.text.TextFormat;
	import base.btn.BtnHitAndBlockAndEnterListener;
	import base.loader.URLLoaderExt;
	import base.utils.FunctionCallback;
	
	public class FormEmail extends Form {
		
		public var tfEmail: TextField;
		public var bgTfEmail: Sprite;
		private var classBtnProcess: Class;
		private var posBtnProcess: Point;
		private var isCheckIsEmailFreeExistsNotCheck: uint;
		private var isCheckedIsEmailOk: uint;
		private var descriptionCallCheckIsEmailOk: DescriptionCall;
		
		//isCheckIsEmailFreeExistsNotCheck - czy ma sprawdzać czy email jest wolny (0) (np. w newsletterach), czy email istnieje (1) (np. w odzyskiwaniu hasła) czy ma tego nie sprawdzać (2)
		public function FormEmail(descriptionCall: DescriptionCall, isCheckIsEmailFreeExistsNotCheck: uint, descriptionCallCheckIsEmailOk: DescriptionCall, soName: String = "", tFormatMessage: TextFormat = null, colors: Colors = null, colorsTfMessage: ColorsTfMessage = null, isEnterListener: Boolean = true, classBtnProcess: Class = null, posBtnProcess: Point = null): void {
			super(descriptionCall, soName, tFormatMessage, colors, colorsTfMessage, isEnterListener);
			this.isCheckIsEmailFreeExistsNotCheck = isCheckIsEmailFreeExistsNotCheck;
			this.isCheckedIsEmailOk = 2;
			if (classBtnProcess == null) classBtnProcess = BtnHitAndBlockAndEnterListener;
			if (posBtnProcess == null) posBtnProcess = new Point(this.bgTfEmail.x + this.bgTfEmail.width, this.bgTfEmail.y + this.bgTfEmail.height / 2);
			this.classBtnProcess = classBtnProcess;
			this.posBtnProcess = posBtnProcess;
		}
		
		override protected function onAddedToStage(e: Event): void {
			super.onAddedToStage(e);
			this.addBtnProcess(this.classBtnProcess, this.posBtnProcess);
			var arrTextIsBadGoodCloseMessage: Array = [{text: "Błąd połączenia z serwerem", isBadGood: 0}];
			if (this.isCheckIsEmailFreeExistsNotCheck < 2) arrTextIsBadGoodCloseMessage.push([{text: "Błąd, email istnieje już w bazie", isBadGood: 0}, {text: "Błąd, brak podanego adresu email w bazie", isBadGood: 0}][this.isCheckIsEmailFreeExistsNotCheck]);
			arrTextIsBadGoodCloseMessage.push({text: "Operacja została wykonana pomyślnie"});
			this.addTFMessage(["Zapisywanie emaila"], arrTextIsBadGoodCloseMessage, new Point(0, this.btnProcess.y + this.btnProcess.height / 2 + 2));
			this.tfEmail.restrict = "a-zA-Z0-9()[]{}<>!+\\-=_.,':;@";
		}
		
		override protected function initSoPropForTfs(): void {
			super.initSoPropForTfs();
			this.initSoPropForTf("strEmail", this.tfEmail);
		}
		
		override protected function initBgTfForTfs(): void {
			super.initBgTfForTfs();
			this.initBgTfForTf(this.bgTfEmail, this.tfEmail);
		}
		
		override protected function initMessageTfForTfs(): void {
			super.initMessageTfForTfs();
			var arrTextCloseMessage: Array = ["nieprawidłowy email"];
			if (this.isCheckIsEmailFreeExistsNotCheck < 2) arrTextCloseMessage.push(["email istnieje w bazie!", "brak emaila w bazie!"][this.isCheckIsEmailFreeExistsNotCheck]);
			this.initMessageTfForTf(arrTextCloseMessage, this.tfEmail);
		}
		
		override protected function initTfs(): void {
			super.initTfs();
			this.initTf(this.tfEmail, "wpisz email");
		}
		
		override protected function onTfChanged(event: Event): void {
			var tf: TextField = TextField(event.target);
			if (tf == this.tfEmail) this.isCheckedIsEmailOk = 2;
			super.onTfChanged(event);
		}
		
		//check is email ok
		
		private function processUrlCheckIsEmailOk(): void {
			this.isCheckedIsEmailOk = 0;
			var arrParams: Array = [["module", "checkIsEmailOk"], ["email", this.getTfText(this.tfEmail)]];
			if (this.descriptionCallCheckIsEmailOk.isUrlLoaderOrServiceAmf == 0) {
				var urlLoaderExt: URLLoaderExt = new URLLoaderExt({url: this.descriptionCallCheckIsEmailOk.strUrlOrMethod, objParams: arrParams, isGetPost: 1, callbackEnd: new FunctionCallback(this.onUrlRequestCheckIsEmailOkResult, this)});
			} else if (this.descriptionCall.isUrlLoaderOrServiceAmf == 1) {
				this.descriptionCallCheckIsEmailOk.serviceAmf.callServiceFunction(this.descriptionCallCheckIsEmailOk.strUrlOrMethod, this.onProcessUrlCheckIsEmailOkSuccess, this.onProcessUrlCheckIsEmailOkError, arrParams);
			}
		}
		
		private function onUrlRequestCheckIsEmailOkResult(isProcessed: Boolean, response: *, params: *): void {
			this.isCheckedIsEmailOk = 1;
			try {
				if (isProcessed) {
					var responseXML: XML;
					if (response is XML) responseXML = response;
					else responseXML = new XML(response);
					this.isCheckedIsEmailOk = uint(responseXML.@isEmailOk);
				}
			} catch (e: Error) {}
			this.checkIsAllDataAndShowBadTfMessageAndUnblockBtnProcess(this.tfEmail);
		}
		
		private function onProcessUrlCheckIsEmailOkSuccess(result: uint): void {
			this.isCheckedIsEmailOk = result;
			this.checkIsAllDataAndShowBadTfMessageAndUnblockBtnProcess(this.tfEmail);
		}
		
		private function onProcessUrlCheckIsEmailOkError(error: Object, typeError: uint): void {
			this.isCheckedIsEmailOk = 1;
			this.checkIsAllDataAndShowBadTfMessageAndUnblockBtnProcess(this.tfEmail);
		}
		
		override protected function checkIsNoData(tf: TextField): uint {
			var isNoData: uint = 0;
			if (tf == this.tfEmail) {
				if (this.isCheckedIsEmailOk != 2) isNoData = 2 * (1 - this.isCheckedIsEmailOk);
				else {
					isNoData = uint(!this.isEmail(this.getTfText(this.tfEmail)));
					if ((this.isCheckIsEmailFreeExistsNotCheck < 2) && (isNoData == 0)) {
						isNoData = 3;
						this.processUrlCheckIsEmailOk();
					}
				}
			}
			return isNoData;
		}
		
		//process
		
		override public function process(arrParams: Array = null): void {
			var strEmail: String = this.getTfText(this.tfEmail);
			var arrParams: Array;
			if (this.descriptionCall.isUrlLoaderOrServiceAmf == 0) arrParams = [["module", "processEmail"], ["email", strEmail]];
			else if (this.descriptionCall.isUrlLoaderOrServiceAmf == 1) arrParams = [strEmail];
			super.process(arrParams);
		}
		
	}

}