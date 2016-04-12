package base.facebook {
	import flash.display.Sprite;
	import base.mvc.EventModel;

	public class Example extends Sprite {
		
		public function Example(): void {
			this.initFacebookApplication();
		}
		
		private function initFacebookApplication(): void {
			var idApplication: String = root.loaderInfo.parameters.idApplication || "";
			if (idApplication) {
				FacebookGateway.addEventListener(FacebookGateway.ON_LOGIN_SUCCESS, this.onFacebookLoginSuccess);
				FacebookGateway.addEventListener(FacebookGateway.ON_LOGIN_ERROR, this.onFacebookLoginError);
				//FacebookGateway.openLoginWhenNotLogged = true;
				FacebookGateway.init(idApplication);
			}
		}
		
		private function onFacebookLoginSuccess(e: EventModel): void {
			trace("login success:", e.data)
			FacebookGateway.addEventListener(FacebookGateway.ON_GET_USER_SUCCESS, this.onFacebookGetUserSuccess);
			FacebookGateway.getUser();
		}
		
		private function onFacebookLoginError(e: EventModel): void {
			trace("login error")
		}
		
		private function onFacebookGetUserSuccess(e: EventModel): void {
			for (var i: String in e.data)	trace("i:", i, "user[i]", e.data[i]);
		}
		
	}

}