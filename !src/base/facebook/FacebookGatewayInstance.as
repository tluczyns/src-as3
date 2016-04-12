package base.facebook {
	import base.types.Singleton;
	import flash.events.EventDispatcher;
	import base.vspm.EventModel;
	import com.facebook.graph.Facebook;
	import flash.utils.setInterval;
	import flash.external.ExternalInterface;
	import base.loader.LoaderJSON;
	import base.loader.LoaderJSONEvent;
	import flash.net.URLRequestMethod;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.display.Bitmap;
	
	public class FacebookGatewayInstance extends EventDispatcher {
		
		static public const ON_LOGIN_SUCCESS: String = "onLoginSuccess";
		static public const ON_LOGIN_ERROR: String = "onLoginError";
		static public const ON_GET_USER_SUCCESS: String = "onGetUserSuccess";
		static public const ON_GET_USER_ERROR: String = "onGetUserError";
		
		private var idApplication: String;
		private var session: *;
		public var isNotLogged: Boolean;
		public var logWhenNotLogged: Boolean;
		
		public function FacebookGatewayInstance(): void {}
		
		//init
		
		public function init(idApplication: String = "", isNotLogged: Boolean = true, logWhenNotLogged: Boolean = false): void {
			if ((idApplication) && (idApplication.length)) this.idApplication = idApplication;
			if (this.idApplication) {
				this.isNotLogged = isNotLogged;
				this.logWhenNotLogged = logWhenNotLogged;
				Facebook.init(this.idApplication, this.onInit);
				//setInterval(this.checkLoginStatus, 10000);
			} else this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_LOGIN_ERROR));
		}
		
		/*public function checkLoginStatus(): void {
			Facebook.getLoginStatus();
		}*/
		
		public function onInit(session: *, fail:Object): void {
			//trace("session:", session, "fail:", fail)
			if (this.isNotLogged) {
				if (this.logWhenNotLogged) ExternalInterface.call('redirect'); //logowanie z autentyfikacją
				else this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_LOGIN_ERROR));
			} else {
				if (!session) ExternalInterface.call('redirect'); //tylko autentyfikacja
				else {
					this.session = session;
					this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_LOGIN_SUCCESS, session));
				}
			}
		}
		
		//get user
		
		private var idUserToGet: String = "";
		private var loaderJSONUser: LoaderJSON;
		
		public function getUser(idUser: String = ""): void {
			this.idUserToGet = idUser || this.session.uid;
			Facebook.api('/' + this.idUserToGet, this.onGetUser);
		}
		
		private function onGetUser(response: Object, fail: Object):void {
			if (response) this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_USER_SUCCESS, response));
			else {
				this.loaderJSONUser =  new LoaderJSON("http://graph.facebook.com/" + this.idUserToGet);
				this.loaderJSONUser.addEventListener(LoaderJSONEvent.JSON_LOADED, this.jsonUserLoaded);
				this.loaderJSONUser.addEventListener(LoaderJSONEvent.JSON_NOT_LOADED, this.jsonUserNotLoaded);
				this.loaderJSONUser.readJSON();
			}
		}
		
		private function jsonUserLoaded(e: LoaderJSONEvent): void {
			this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_USER_SUCCESS, this.loaderJSONUser.data));
		}
		
		private function jsonUserNotLoaded(e: LoaderJSONEvent): void {
			this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_USER_ERROR));
		}
		
		//friends
		
		static public const ON_GET_FRIENDS_OF_USER_SUCCESS: String = "onGetFriendsOfUserSuccess";
		static public const ON_GET_FRIENDS_OF_USER_ERROR: String = "onGetFriendsOfUserError";
		
		private var arrFriendOfUser: Array;
		private var arrDetailedFriendOfUser: Array;
		private var countCallsGetDetailedFriends: uint;
		private var isDetailedFriends: Boolean;
		private var limitCountOfDetailedFriends: int;
		
		public function getDetailedFriendsOfUser(idUser: String = "", limitCountOfDetailedFriends: int = 15): void {
			this.getFriendsOfUser(idUser, null, true, limitCountOfDetailedFriends);
		}
			
		public function getFriendsOfUser(idUser: String = "", arrFieldFriends: Array = null, isDetailedFriends: Boolean = false, limitCountOfDetailedFriends: int = 15): void {
			idUser = idUser || this.session.uid;
			this.isDetailedFriends = isDetailedFriends;
			this.limitCountOfDetailedFriends = limitCountOfDetailedFriends;
			arrFieldFriends = arrFieldFriends || [];
			Facebook.api("/" + idUser + "/friends?fields=name," + arrFieldFriends.join(",") + "&", this.onGetFriendsOfUser);
		}
		
		private function onGetFriendsOfUser(response: Object, fail: Object): void {
			if ((response) && (response.length)) {
				this.arrFriendOfUser = response as Array;
				if (this.isDetailedFriends) {
					this.arrDetailedFriendOfUser = [];
					this.countCallsGetDetailedFriends = 0;
					var countOfFriendsOfUser: uint = (this.limitCountOfDetailedFriends == -1) ? response.length : Math.min(this.limitCountOfDetailedFriends, response.length);
					for (var i: uint = 0; i < countOfFriendsOfUser; i++) {
						var objUser: Object = response[i];
						if (objUser.id) this.getDetailedFriend(objUser.id);
					}
				} this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_FRIENDS_OF_USER_SUCCESS, {arrFriendOfUser: this.arrFriendOfUser}));
			} else this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_FRIENDS_OF_USER_ERROR));
		}
		
		public function getDetailedFriend(idFriend: String = ""): void {
			this.countCallsGetDetailedFriends++;
			Facebook.api('/' + idFriend, this.onGetDetailedFriend);
		}
		
		private function onGetDetailedFriend(response: Object, fail: Object): void {
			if (response) this.arrDetailedFriendOfUser.push(response);
			this.countCallsGetDetailedFriends--;
			if (this.countCallsGetDetailedFriends == 0) this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_FRIENDS_OF_USER_SUCCESS, {arrFriendOfUser: this.arrFriendOfUser, arrDetailedFriendOfUser: this.arrDetailedFriendOfUser}));
		}
		
		//family of user (required permission "user_relationships")
		
		static public const ON_GET_FAMILY_OF_USER_SUCCESS: String = "onGetFamilyOfUserSuccess";
		static public const ON_GET_FAMILY_OF_USER_ERROR: String = "onGetFamilyOfUserError";

		public function getFamilyOfUser(idUser: String = ""): void {
			idUser = idUser || this.session.uid;
			this.limitCountOfDetailedFriends = limitCountOfDetailedFriends;
			Facebook.api("/" + idUser + "/family", this.onGetFamilyOfUser);
		}
		
		private function onGetFamilyOfUser(response: Object, fail: Object): void {
			if ((response) && (response.length)) {
				this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_FAMILY_OF_USER_SUCCESS, {arrFamilyOfUser: response as Array}));
			} else this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_FAMILY_OF_USER_ERROR));
		}
		
		//photo of user
		
		private var baImgLoader: Loader;
		static public const ON_GET_PHOTO_OF_USER_SUCCESS: String = "onGetPhotoOfUserSuccess";
		static public const ON_GET_PHOTO_OF_USER_ERROR: String = "onGetPhotoOfUserError";

		public function getPhotoOfUser(idUser: String = "", isSmallLargeSquare: uint = 1): void {
			idUser = idUser || this.session.uid;
			Facebook.api("/" + idUser + "/picture" + ["", "?type=large", "?type=square"][isSmallLargeSquare] + "&", this.onGetPhotoOfUser, {dataFormat: URLLoaderDataFormat.BINARY});
		}
		
		private function onGetPhotoOfUser(response: Object, fail: Object): void {
			if ((response) && (ByteArray(response).toString().indexOf("GIF89") == -1)) { //np. "https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v1/yo/r/UlIqmHJn-SK.gif"
				this.baImgLoader = new Loader();
				this.baImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadedPhotoOfUser)
				this.baImgLoader.loadBytes(ByteArray(response));
			} else this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_PHOTO_OF_USER_ERROR));
		}
		
		private function onLoadedPhotoOfUser(e: Event): void {
			this.dispatchEvent(new EventModel(FacebookGatewayInstance.ON_GET_PHOTO_OF_USER_SUCCESS, {photoOfUser: Bitmap(this.baImgLoader.content)}));
			this.baImgLoader.unload();
			this.baImgLoader = null;
		}
		
		//post on wall
		
		public function postOnWall(strMessage: String, strPicture: String = "", urlLink: String = "", strName: String = ""): void {
			var objPostOnWall: Object = {message: strMessage};
			if (strPicture.length) objPostOnWall.picture = strPicture;
			if (urlLink.length) objPostOnWall.link = urlLink;
			if (strName.length) objPostOnWall.name = strName;
			Facebook.api("me/feed", this.onPostOnWall, objPostOnWall, URLRequestMethod.POST);
		}	
		
		private function onPostOnWall(response: Object, fail: Object): void {
			//trace("onPostOnWall:" + response + ", fail:" + fail);
		}
		
		//additional
		
		public function setCanvasSize(width: Number, height: Number):void {
			Facebook.setCanvasSize(width, height);
		}
		
		public function getOppositeGender(gender: String): String {
			return ["male", "female"][uint(gender == "male")];	
		}
		
	}

}