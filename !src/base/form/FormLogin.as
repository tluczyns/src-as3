package base.form {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Point;
	import base.service.DescriptionCall;
	import base.btn.BtnHitAndBlockAndEnterListener;

	public class FormLogin extends Form {
		
		public var tfLogin: TextField;
		public var tfPassword: TextField;
		public var bgTfLogin: Sprite;
		public var bgTfPassword: Sprite;
		private var classBtnProcess: Class
		private var posBtnProcess: Point;
		
		public function FormLogin(descriptionCall: DescriptionCall, soName: String = "", colors: Colors = null, isEnterListener: Boolean = true, classBtnProcess: Class = null, posBtnProcess: Point = null): void {
			super(descriptionCall, soName, colors, isEnterListener);
			if (classBtnProcess == null) classBtnProcess = BtnHitAndBlockAndEnterListener;
			if (posBtnProcess == null) posBtnProcess = new Point(this.tfPassword.x + this.tfPassword.width, this.tfPassword.y + this.tfPassword.height + (this.tfPassword.y - (this.tfLogin.y + this.tfLogin.height)));
			this.classBtnProcess = classBtnProcess;
			this.posBtnProcess = posBtnProcess;
		}
		
		override protected function onAddedToStage(e: Event): void {
			super.onAddedToStage(e);
			this.addBtnProcess(this.classBtnProcess, this.posBtnProcess);
			this.addTFMessage(["Logowanie"], [{text: "Błąd połączenia z serwerem", isBadGood: 0}, {text: "Błąd logowania, błędny login lub hasło", isBadGood: 0}, {text: "Błąd logowania, konto nie zostało aktywowane", isBadGood: 0}, {text: "Zostałeś zalogowany", isBadGood: 1}], new Point(0, this.btnProcess.y + this.btnProcess.height / 2 - 10));
			this.tfPassword.displayAsPassword = true;
			this.tfLogin.restrict = this.tfPassword.restrict = "a-zA-Z0-9()[]{}<>!+-=_.,':;@";
		}
		
		override protected function initSoPropForTFs(): void {
			super.initSoPropForTFs();
			this.initSoPropForTF("strLogin", this.tfLogin);
			this.initSoPropForTF("strPassword", this.tfPassword);
		}
		
		override protected function initBgTfForTFs(): void {
			super.initBgTfForTFs();
			this.initBgTfForTF(this.bgTfLogin, this.tfLogin);
			this.initBgTfForTF(this.bgTfPassword, this.tfPassword);
		}
		
		override protected function initMessageTfForTFs(): void {
			super.initMessageTfForTFs();
			this.initMessageTfForTF(["za krótki login", "za długi login"], this.tfLogin);
			this.initMessageTfForTF(["zbyt krótkie hasło"], this.tfPassword);
		}
		
		override protected function initTFs(): void {
			super.initTFs();
			this.initTF(this.tfLogin, "wpisz login");
			this.initTF(this.tfPassword, "wpisz hasło");
		}
		
		override protected function checkIsNoData(tf: TextField): uint {
			var isNoData: uint = 0;
			if (tf == this.tfLogin) {
				var lengthStrLogin: uint = this.getTfText(this.tfLogin).length;
				isNoData = uint(lengthStrLogin < 3);
				if (isNoData == 0) isNoData = 2 * uint(lengthStrLogin > 12);
			} else if (tf == this.tfPassword) {
				isNoData = uint(this.getTfText(this.tfPassword).length < 3);
			}
			return isNoData;
		}
		
		override public function process(arrParams: Array = null): void {
			var strLogin: String = this.getTfText(this.tfLogin);
			var strPassword: String = this.getTfText(this.tfPassword);
			var arrParams: Array;
			if (this.descriptionCall.isUrlLoaderOrServiceAmf == 0) arrParams = [["module", "login"], ["login", strLogin], ["password", strPassword]];
			else if (this.descriptionCall.isUrlLoaderOrServiceAmf == 1) arrParams = [strLogin, strPassword];
			super.process(arrParams);
		}
		
	}

}