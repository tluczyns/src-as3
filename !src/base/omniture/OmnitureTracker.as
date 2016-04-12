package base.omniture {
	import flash.display.Sprite;
	import base.types.StringUtils;
	import com.omniture.AppMeasurement;

	public class OmnitureTracker extends Sprite {
		public static var CUSTOM_LINK:String = "o";
		public static var FILE_DOWNLOAD:String = "d";
		public static var EXIT_LINK:String = "e";
		
		private static var _xmlData:XML;
		private var _am:AppMeasurement;
		private var _account:String;
		private var _countryCode:String;
		private var _languageCode:String;
		private var _charSet:String;
		private var _currencyCode:String;
		private var _movieID:String;
		private var _division:String;
		private var _campaignName:String;
		public var useDebug:Boolean;
		
		public function OmnitureTracker(data: Object): void {
			_account 		= String(data.account.text);
			_countryCode 	= String(data.country.text);
			_languageCode 	= String(data.language.text);
			_charSet 		= String(data.charSet.text);
			_currencyCode 	= String(data.currencyCode.text);
			_movieID 		= String(data.movieID.text);
			_division 		= String(data.division.text);
			_campaignName 	= String(data.campaignName.text);
						
			_am = new AppMeasurement();
			
			/* Specify the Report Suite ID(s) to track here */
			_am.account = _account;
		
			/* You may add or alter any code config here */
			_am.pageName = "";
			_am.pageURL = "";
		
			_am.charSet =  _charSet;
			_am.currencyCode = _currencyCode;
			
			/*** last update 2011-01-11  ***/
			_am.trackingServer = "nmetrics.samsung.com";
			_am.trackingServerSecure = "smetrics.samsung.com";
		
			/* Turn on and configure ClickMap tracking here */
			_am.trackClickMap = true;
			_am.movieID = _movieID;
		
			/* Turn on and configure debugging here */
			_am.debugTracking = useDebug;
			_am.trackLocal = true;
		
			/* WARNING: Changing any of the below variables will cause drastic changes
			to how your visitor data is collected.  Changes should only be made
			when instructed to do so by your account manager.*/
			_am.visitorNamespace = "samsung";
			_am.dc = "112";
			
			//_am.delayTracking = 500;
			addChild( _am );
		}
		
		//nowa funkcja do nowych projektów
		public function trackPageview(pageName:String):void {
			//TŁ
			pageName = StringUtils.replace(pageName, "/", "_"); //":"
			pageName = StringUtils.replace(pageName, "\\", "_"); //":"
			if (pageName.charAt(0) == "_") pageName = pageName.substr(1); //":"
			//end TŁ
			_am.channel = _countryCode + ":campaign";
			_am.pageName = _countryCode + ":campaign:" + _division + ":" + _campaignName + ":" + pageName;	
			_am.prop1 = _countryCode;
			_am.prop2 = _countryCode + ":campaign";
			_am.prop3 = _countryCode + ":campaign:" + _division;
			_am.prop4 = _countryCode + ":campaign:" + _division + ":" + _campaignName;
			_am.prop5 = _countryCode + ":campaign:" + _division + ":" + _campaignName + ":" + pageName;
			var pageNameHier: String = StringUtils.replace(pageName, ":", "_"); //">"
			_am.hier1 = _countryCode + ">campaign>" + _division + ">" + _campaignName + ">" + pageNameHier;
			_am.eVar1 = _countryCode;
			_am.eVar2 = _countryCode + ":campaign";
			_am.eVar3 = _countryCode + ":campaign:" + _division;
			_am.eVar4 = _countryCode + ":campaign:" + _division + ":" + _campaignName;
			_am.eVar5 = _countryCode + ":campaign:" + _division + ":" + _campaignName + ":" + pageName;
			_am.eVar33 = null;
			_am.events = null;
			_am.track();
			//trace( "channel : " + _am.channel, "\npageName : " + _am.pageName, "\nhier1 : " + _am.hier1, "\nprop1 : " + _am.prop1, "\nprop2 : " + _am.prop2, "\nprop3 : " + _am.prop3, "\nprop4 : " + _am.prop4, "\nprop5 : " + _am.prop5 );
		}
		
		
		public function trackLink(file:String, linkType:String, linkName:String): void	{
			_am.eVar33 = _countryCode + ":" + _campaignName + ":" + linkName;
			_am.events = "event45";
			_am.channel = null;
			_am.pageName = null;
			_am.hier1 = null;
			_am.prop1 = null;
			_am.prop2 = null;
			_am.prop3 = null;
			_am.prop4 = null;
			_am.prop5 = null;
			_am.eVar1 = null;
			_am.eVar2 = null;
			_am.eVar3 = null;
			_am.eVar4 = null;
			_am.eVar5 = null;
			_am.trackLink(file, linkType, linkName);
			//trace(linkName + " link tracking: ", _am.eVar33, file, linkType);
		}
	}	
}
