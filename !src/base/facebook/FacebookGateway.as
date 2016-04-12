package base.facebook {
	import base.types.Singleton;
	import flash.events.EventDispatcher;
	import base.mvc.EventModel;
	import com.facebook.graph.Facebook;
	import flash.utils.setInterval;
	import flash.external.ExternalInterface;
	import base.loader.LoaderJSON;
	import base.loader.LoaderJSONEvent;
	import flash.net.URLRequestMethod;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.display.Bitmap;

	import flash.display.BitmapData;

	import flash.utils.ByteArray;
	
	public class FacebookGateway extends Singleton {
		
		static private var modelDispatcher: EventDispatcher = new EventDispatcher();
		
		static public function addEventListener(type: String, func: Function, priority: int = 0): void {
			FacebookGateway.modelDispatcher.addEventListener(type, func, false, priority);
		}
	
		static public function removeEventListener(type: String, func: Function): void {
			FacebookGateway.modelDispatcher.removeEventListener(type, func);
		}
		
		static public function dispatchEvent(type: String, data: * = null): void {
			FacebookGateway.modelDispatcher.dispatchEvent(new EventModel(type, data));
		}
		
		static public const ON_LOGIN_SUCCESS: String = "onLoginSuccess";
		static public const ON_LOGIN_ERROR: String = "onLoginError";
		static public const ON_GET_USER_SUCCESS: String = "onGetUserSuccess";
		static public const ON_GET_USER_ERROR: String = "onGetUserError";
		
		static private var idApplication: String;
		static private var session: *;
		static public var isNotLogged: Boolean;
		static public var logWhenNotLogged: Boolean;
		
		//init
		
		static public function init(idApplication: String = "", isNotLogged: Boolean = true, logWhenNotLogged: Boolean = false): void {
			if ((idApplication) && (idApplication.length)) FacebookGateway.idApplication = idApplication;
			if (FacebookGateway.idApplication) {
				FacebookGateway.isNotLogged = isNotLogged;
				FacebookGateway.logWhenNotLogged = logWhenNotLogged;
				Facebook.init(FacebookGateway.idApplication, FacebookGateway.onInit);
				//setInterval(FacebookGateway.checkLoginStatus, 10000);
			} else FacebookGateway.dispatchEvent(FacebookGateway.ON_LOGIN_ERROR);
		}
		
		/*static public function checkLoginStatus(): void {
			Facebook.getLoginStatus();
		}*/
		
		static public function onInit(session: *, fail:Object): void {
			//trace("session:", session, "fail:", fail)
			if (FacebookGateway.isNotLogged) {
				if (FacebookGateway.logWhenNotLogged) ExternalInterface.call('redirect'); //logowanie z autentyfikacją
				else FacebookGateway.dispatchEvent(FacebookGateway.ON_LOGIN_ERROR);
			} else {
				if (!session) ExternalInterface.call('redirect'); //tylko autentyfikacja
				else {
					FacebookGateway.session = session;
					FacebookGateway.dispatchEvent(FacebookGateway.ON_LOGIN_SUCCESS, session);
				}
			}
		}
		
		//get user
		
		static private var idUserToGet: String = "";
		static private var loaderJSONUser: LoaderJSON;
		
		static public function getUser(idUser: String = ""): void {
			FacebookGateway.idUserToGet = idUser || FacebookGateway.session.uid;
			Facebook.api('/' + FacebookGateway.idUserToGet, FacebookGateway.onGetUser);
		}
		
		static private function onGetUser(response: Object, fail: Object):void {
			if (response) FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_USER_SUCCESS, response);
			else {
				FacebookGateway.loaderJSONUser =  new LoaderJSON("http://graph.facebook.com/" + FacebookGateway.idUserToGet);
				FacebookGateway.loaderJSONUser.addEventListener(LoaderJSONEvent.JSON_LOADED, FacebookGateway.jsonUserLoaded);
				FacebookGateway.loaderJSONUser.addEventListener(LoaderJSONEvent.JSON_NOT_LOADED, FacebookGateway.jsonUserNotLoaded);
				FacebookGateway.loaderJSONUser.readJSON();
			}
		}
		
		static private function jsonUserLoaded(e: LoaderJSONEvent): void {
			FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_USER_SUCCESS, FacebookGateway.loaderJSONUser.data);
		}
		
		static private function jsonUserNotLoaded(e: LoaderJSONEvent): void {
			FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_USER_ERROR);
		}
		
		//friends
		
		static public const ON_GET_FRIENDS_OF_USER_SUCCESS: String = "onGetFriendsOfUserSuccess";
		static public const ON_GET_FRIENDS_OF_USER_ERROR: String = "onGetFriendsOfUserError";
		
		static private var arrFriendOfUser: Array;
		static private var arrDetailedFriendOfUser: Array;
		static private var countCallsGetDetailedFriends: uint;
		static private var isDetailedFriends: Boolean;
		static private var limitCountOfDetailedFriends: int;
		
		static public function getDetailedFriendsOfUser(idUser: String = "", limitCountOfDetailedFriends: int = 15): void {
			FacebookGateway.getFriendsOfUser(idUser, null, true, limitCountOfDetailedFriends);
		}
			
		static public function getFriendsOfUser(idUser: String = "", arrFieldFriends: Array = null, isDetailedFriends: Boolean = false, limitCountOfDetailedFriends: int = 15): void {
			idUser = idUser || FacebookGateway.session.uid;
			FacebookGateway.isDetailedFriends = isDetailedFriends;
			FacebookGateway.limitCountOfDetailedFriends = limitCountOfDetailedFriends;
			arrFieldFriends = arrFieldFriends || [];
			Facebook.api("/" + idUser + "/friends?fields=name," + arrFieldFriends.join(",") + "&", FacebookGateway.onGetFriendsOfUser);
		}
		
		static private function onGetFriendsOfUser(response: Object, fail: Object): void {
			if ((response) && (response.length)) {
				FacebookGateway.arrFriendOfUser = response as Array;
				if (FacebookGateway.isDetailedFriends) {
					FacebookGateway.arrDetailedFriendOfUser = [];
					FacebookGateway.countCallsGetDetailedFriends = 0;
					var countOfFriendsOfUser: uint = (FacebookGateway.limitCountOfDetailedFriends == -1) ? response.length : Math.min(FacebookGateway.limitCountOfDetailedFriends, response.length);
					for (var i: uint = 0; i < countOfFriendsOfUser; i++) {
						var objUser: Object = response[i];
						if (objUser.id) FacebookGateway.getDetailedFriend(objUser.id);
					}
				} FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_FRIENDS_OF_USER_SUCCESS, {arrFriendOfUser: FacebookGateway.arrFriendOfUser});
			} else FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_FRIENDS_OF_USER_ERROR);
		}
		
		static public function getDetailedFriend(idFriend: String = ""): void {
			FacebookGateway.countCallsGetDetailedFriends++;
			Facebook.api('/' + idFriend, FacebookGateway.onGetDetailedFriend);
		}
		
		static private function onGetDetailedFriend(response: Object, fail: Object): void {
			if (response) FacebookGateway.arrDetailedFriendOfUser.push(response);
			FacebookGateway.countCallsGetDetailedFriends--;
			if (FacebookGateway.countCallsGetDetailedFriends == 0) FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_FRIENDS_OF_USER_SUCCESS, {arrFriendOfUser: FacebookGateway.arrFriendOfUser, arrDetailedFriendOfUser: FacebookGateway.arrDetailedFriendOfUser});
		}
		
		//family of user (required permission "user_relationships")
		
		static public const ON_GET_FAMILY_OF_USER_SUCCESS: String = "onGetFamilyOfUserSuccess";
		static public const ON_GET_FAMILY_OF_USER_ERROR: String = "onGetFamilyOfUserError";

		static public function getFamilyOfUser(idUser: String = ""): void {
			idUser = idUser || FacebookGateway.session.uid;
			FacebookGateway.limitCountOfDetailedFriends = limitCountOfDetailedFriends;
			Facebook.api("/" + idUser + "/family", FacebookGateway.onGetFamilyOfUser);
		}
		
		static private function onGetFamilyOfUser(response: Object, fail: Object): void {
			if ((response) && (response.length)) {
				FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_FAMILY_OF_USER_SUCCESS, {arrFamilyOfUser: response as Array});
			} else FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_FAMILY_OF_USER_ERROR);
		}
		
		//photo of user
		
		static private var BA_IMG_LOADER: Loader;
		static public const ON_GET_PHOTO_OF_USER_SUCCESS: String = "onGetPhotoOfUserSuccess";
		static public const ON_GET_PHOTO_OF_USER_ERROR: String = "onGetPhotoOfUserError";

		static public function getPhotoOfUser(idUser: String = "", isSmallLargeSquare: uint = 1): void {
			idUser = idUser || FacebookGateway.session.uid;
			Facebook.api("/" + idUser + "/picture" + ["", "?type=large", "?type=square"][isSmallLargeSquare] + "&", FacebookGateway.onGetPhotoOfUser, {dataFormat: URLLoaderDataFormat.BINARY});
		}
		
		static private function onGetPhotoOfUser(response: Object, fail: Object): void {
			if ((response) && (ByteArray(response).toString().indexOf("GIF89") == -1)) { //np. "https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v1/yo/r/UlIqmHJn-SK.gif"
				FacebookGateway.BA_IMG_LOADER = new Loader();
				FacebookGateway.BA_IMG_LOADER.contentLoaderInfo.addEventListener(Event.COMPLETE, FacebookGateway.onLoadedPhotoOfUser)
				FacebookGateway.BA_IMG_LOADER.loadBytes(ByteArray(response));
			} else FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_PHOTO_OF_USER_ERROR);
		}
		
		static private function onLoadedPhotoOfUser(e: Event): void {
			FacebookGateway.dispatchEvent(FacebookGateway.ON_GET_PHOTO_OF_USER_SUCCESS, {photoOfUser: Bitmap(FacebookGateway.BA_IMG_LOADER.content)});
			FacebookGateway.BA_IMG_LOADER.unload();
			FacebookGateway.BA_IMG_LOADER = null;
		}
		
		//post on wall
		
		static public function postOnWall(strMessage: String, strPicture: String = "", urlLink: String = "", strName: String = ""): void {
			var objPostOnWall: Object = {message: strMessage};
			if (strPicture.length) objPostOnWall.picture = strPicture;
			if (urlLink.length) objPostOnWall.link = urlLink;
			if (strName.length) objPostOnWall.name = strName;
			Facebook.api("me/feed", FacebookGateway.onPostOnWall, objPostOnWall, URLRequestMethod.POST);
		}	
		
		static private function onPostOnWall(response: Object, fail: Object): void {
			//trace("onPostOnWall:" + response + ", fail:" + fail);
		}
		
		//additional
		
		static public function setCanvasSize(width: Number, height: Number):void {
			Facebook.setCanvasSize(width, height);
		}
		
		static public function getOppositeGender(gender: String): String {
			return ["male", "female"][uint(gender == "male")];	
		}
		
	}

}