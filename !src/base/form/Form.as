package base.form {
	import flash.display.Sprite;
	import base.service.DescriptionCall;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import base.btn.IBtnBlock;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import base.btn.BtnHitEvent;
	import base.types.ArrayExt;
	import flash.net.SharedObject;
	import com.greensock.TweenNano;
	import com.greensock.easing.Linear;
	import base.dspObj.DoOperations;
	import base.utils.FunctionCallback;
	import com.hurlant.util.Base64;
	import base.loader.URLLoaderExt;
	import base.service.ExternalInterfaceExt;
	
	public class Form extends Sprite {
		
		static protected var COUNT_FRAMES_CHANGE_COLOR: uint = 3;
		
		protected var descriptionCall: DescriptionCall;
		private var soName: String;
		protected var tFormatMessage: TextFormat;
		protected var colors: Colors;
		protected var colorsTfMessage: ColorsTfMessage;
		protected var isEnterListener: Boolean;
		private var dictTfToSoProp: Dictionary;
		private var dictTfToBgTf: Dictionary;
		private var dictTfToTfInit: Dictionary;
		protected var dictTfToTfMessageForTf: Dictionary;
		protected var dictTfToStrInit: Dictionary;
		private var dictTfToIsNoData: Dictionary;
		protected var arrTf: Array;
		protected var tfMessage: TfMessageForm;
		public var isProcessing: Boolean;
		public var btnProcess: IBtnBlock;
		private var idCallProcessForm: int;
		
		public function Form(descriptionCall: DescriptionCall, soName: String = "", tFormatMessage: TextFormat = null, colors: Colors = null, colorsTfMessage: ColorsTfMessage = null, isEnterListener: Boolean = true): void {
			this.descriptionCall = descriptionCall;
			this.soName = soName;
			this.tFormatMessage = tFormatMessage ? tFormatMessage : new TextFormat("Times New Roman", 18, 0x5BA5E9);
			this.colors = colors;
			this.colorsTfMessage = colorsTfMessage ? colorsTfMessage : new ColorsTfMessage();
			this.isEnterListener = isEnterListener;
			this.initSoPropForTfs();
			this.initBgTfForTfs();
			this.initTfForTfs();
			this.dictTfToTfInit
			this.initMessageTfForTfs();
			this.initTfs();
			if ((this.soName != "") && (this.soName != null)) this.getSoPropSharedObjectAndSetTf();
			this.isProcessing = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.blockUnblock(1);
		}
		
		protected function initSoPropForTfs(): void { 
			this.dictTfToSoProp = new Dictionary();	
		}
		
		protected function initSoPropForTf(soPropName: String, tfToSetSoProp: TextField): void {
			this.dictTfToSoProp[tfToSetSoProp] = soPropName;
		}
		
		protected function initBgTfForTfs(): void { 
			this.dictTfToBgTf = new Dictionary();	
		}
		
		protected function initBgTfForTf(bgTf: DisplayObject, tfToSetBg: TextField): void {
			this.dictTfToBgTf[tfToSetBg] = bgTf;
		}
		
		protected function initMessageTfForTfs(): void {
			this.dictTfToTfMessageForTf = new Dictionary();	
		}
		
		protected function initMessageTfForTf(arrStrBadMessage: Array, tfToSetMessage: TextField, posMessageTf: Point = null): void {
			var tfMessageForTf: TfMessageFormForTf = new TfMessageFormForTf(arrStrBadMessage, this.tFormatMessage, this.colorsTfMessage.colorBadCloseMessage);
			var dspForPositionMessageTf: DisplayObject;
			if (this.dictTfToBgTf[tfToSetMessage] != null) dspForPositionMessageTf = this.dictTfToBgTf[tfToSetMessage];
			else dspForPositionMessageTf = tfToSetMessage;
			if (!posMessageTf) posMessageTf = new Point(dspForPositionMessageTf.x + dspForPositionMessageTf.width + 5, dspForPositionMessageTf.y + (dspForPositionMessageTf.height - tfMessageForTf.height) / 2);
			tfMessageForTf.x = posMessageTf.x;
			tfMessageForTf.y = posMessageTf.y;
			this.addChild(tfMessageForTf);
			this.dictTfToTfMessageForTf[tfToSetMessage] = tfMessageForTf;
		}
		
		protected function initTfs(): void {
			this.arrTf = new Array();
			this.dictTfToStrInit = new Dictionary();
			this.dictTfToIsNoData = new Dictionary();
		}
		
		protected function initTf(tf: TextField, strInitTf: String): void {
			tf.tabIndex = this.arrTf.length + 1;
			tf.focusRect = false;
			this.addStrInitForTf(tf, strInitTf);
			this.addListenersForTf(tf);
			this.arrTf.push(tf);
		}
		
		private function addStrInitForTf(tf: TextField, strInitTf: String): void {
			tf.text = strInitTf;
			this.dictTfToStrInit[tf] = strInitTf;
		}
		
		protected function addListenersForTf(tf: TextField): void {
			tf.addEventListener(FocusEvent.FOCUS_IN, this.onTfFocusIn);
			tf.addEventListener(FocusEvent.FOCUS_OUT, this.onTfFocusOut);
			tf.addEventListener(Event.CHANGE, this.onTfChanged);
			if (this.isEnterListener) tf.addEventListener(KeyboardEvent.KEY_UP, this.onTfKeyUpHandler)
		}
		
		protected function removeListenersForTf(tf: TextField): void {
			tf.removeEventListener(FocusEvent.FOCUS_IN, this.onTfFocusIn);
			tf.removeEventListener(FocusEvent.FOCUS_OUT , this.onTfFocusOut);
			tf.removeEventListener(Event.CHANGE, this.onTfChanged);
			if (this.isEnterListener) tf.removeEventListener(KeyboardEvent.KEY_UP, this.onTfKeyUpHandler)
			
		}
		
		private function onTfFocusIn(e: FocusEvent): void {
			var tf: TextField  = TextField(e.target);
			if (tf.text == this.dictTfToStrInit[tf]) tf.text = "";
		}
		
		private function onTfFocusOut(e: FocusEvent): void {
			var tf: TextField  = TextField(e.target);
			if (tf.text == "") tf.text = this.dictTfToStrInit[tf];
			this.showBadTfMessage(tf);
		}
		
		protected function onTfChanged(event: Event): void {
			var tf: TextField  = TextField(event.target);
			this.checkIsAllDataAndShowBadTfMessageAndUnblockBtnProcess(tf);
		}
		
		protected function onTfKeyUpHandler(e: KeyboardEvent): void {
			var tf: TextField  = TextField(e.target);
			if (e.keyCode == 13) {
				if (this.checkIsAllData()) this.process();
				else if ((this.checkIsNoData(tf) == 0) && (tf.tabIndex < this.arrTf.length)) this.stage.focus = this.arrTf[tf.tabIndex];
			}
		}
		
		protected function checkIsAllDataAndShowBadTfMessageAndUnblockBtnProcess(tf: TextField): void {
			this.checkIsAllDataAndUnblockBtnProcess();
			this.showBadTfMessage(tf);
		}
		
		protected function showBadTfMessage(tf: TextField): void {
			if (this.dictTfToTfMessageForTf[tf] != null) {
				var messageFormForTf: TfMessageFormForTf = TfMessageFormForTf(this.dictTfToTfMessageForTf[tf]);
				if (this.dictTfToIsNoData[tf] > 0)
					messageFormForTf.showAndCloseMessage(this.dictTfToIsNoData[tf] - 1);
				else messageFormForTf.closeMessage();
			}
		}
		
		protected function addTfMessage(arrTextDurationMessage: Array, arrTextIsBadGoodCloseMessage: Array, posTfMessage: Point): void {
			this.tfMessage = new TfMessageForm(this, arrTextDurationMessage, arrTextIsBadGoodCloseMessage, this.tFormatMessage, this.colorsTfMessage);
			this.tfMessage.x = Math.round(posTfMessage.x);
			this.tfMessage.y = Math.round(posTfMessage.y);
			this.addChild(this.tfMessage);
		}
		
		protected function addBtnProcess(classBtnProcess: Class, posBtnProcess: Point, ...paramsBtnProcess): void {
			this.btnProcess = new classBtnProcess(paramsBtnProcess);
			this.btnProcess.x = posBtnProcess.x;
			this.btnProcess.y = posBtnProcess.y;
			this.addChild(Sprite(this.btnProcess));
			this.btnProcess.addEventListener(BtnHitEvent.CLICKED, this.onBtnProcessClicked);
			this.idCallProcessForm = -1;
			this.checkIsAllDataAndUnblockBtnProcess();
		}
		
		private function removeBtnProcess(): void {
			this.btnProcess.destroy();
			this.removeChild(DisplayObject(this.btnProcess));
			this.btnProcess = null;
		}
		
		private function onBtnProcessClicked(e: BtnHitEvent): void {
			this.process();
		}
		
		protected function getTfText(tf: TextField): String {
			return (tf.text == this.dictTfToStrInit[tf]) ? "" : tf.text;
		}
		
		protected function isEmail(strEmail: String): Boolean {
			var posAt: int = strEmail.indexOf("@");
			var countAt: uint = 0;
			while (posAt != -1) {
				posAt = strEmail.indexOf("@", posAt + 1);
				countAt++;
			}
			posAt = strEmail.indexOf("@");
			var posLastDot: int = strEmail.lastIndexOf(".");
			var arrDomains: ArrayExt = new ArrayExt("ac", "ad", "ae", "af", "ag", "ai", "al", "am", "an", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bm", "bn", "bo", "br", "bs", "bt", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eo", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "me", "md", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sk", "sl", "sm", "sn", "sr", "st", "sv", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "uk", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "za", "zm", "zw", "tp", "su", "yu", "bu", "bx", "fl", "wa", "biz", "com", "edu", "gov", "info", "int", "mil", "name", "net", "org", "pro", "aero", "cat", "coop", "jobs", "museum", "travel", "mobi", "arpa", "root", "post", "tel", "cym", "geo", "kid", "kids", "mail", "safe", "sco", "web", "xxx");
			return Boolean((countAt == 1) && (posAt > 0) && (posLastDot != -1) && (posLastDot > posAt + 1) && (posLastDot < strEmail.length - 1) && (arrDomains.isInArray(strEmail.substring(posLastDot + 1, strEmail.length).toLowerCase())));
		}
		
		protected function checkIsNoData(tf: TextField): uint {
			return 0;
		}
		
		protected function checkIsAllData(): Boolean {
			var isAllData: Boolean = true;
			for (var i: uint = 0; i < this.arrTf.length; i++) {
				var tf: TextField = this.arrTf[i];
				var bgTf: DisplayObject = this.dictTfToBgTf[tf];
				var isNoDataInTf: uint = this.checkIsNoData(tf);
				this.dictTfToIsNoData[tf] = isNoDataInTf;
				var isDataBadOkForDisplay: uint = uint((isNoDataInTf == 0) || (isNoDataInTf >= 3));
				if (this.colors != null) {
					if ((this.colors.colorTfBad != -1) && (this.colors.colorTfOk != -1)) DoOperations.setColor(tf, [this.colors.colorTfBad, this.colors.colorTfOk][isDataBadOkForDisplay], Form.COUNT_FRAMES_CHANGE_COLOR);
					if ((bgTf) && (this.colors.colorBgTfBad != -1) && (this.colors.colorBgTfOk != -1)) DoOperations.setColor(bgTf, [this.colors.colorBgTfBad, this.colors.colorBgTfOk][isDataBadOkForDisplay], Form.COUNT_FRAMES_CHANGE_COLOR);
				}
				if (isNoDataInTf > 0) isAllData = false;
			}
			return isAllData;
		}
		
		public function checkIsAllDataAndUnblockBtnProcess(): void {
			if (this.btnProcess) {
				var isAllData: Boolean = this.checkIsAllData();
				if (isAllData) this.btnProcess.addMouseEvents();
				else this.btnProcess.removeMouseEvents();	
			}
		}
		
		internal function unblockAndCheckIsAllDataAndUnblockBtnProcess(): void {
			this.blockUnblock(1);
			this.checkIsAllDataAndUnblockBtnProcess();
		}
		
		private function blockUnblockTextFields(isBlockUnblock: uint): void {
			for (var i: uint = 0; i < this.arrTf.length; i++) {
				var tfToBlockUnblock: TextField = this.arrTf[i];
				if (isBlockUnblock == 0) {
					tfToBlockUnblock.type = "dynamic";
					tfToBlockUnblock.selectable = false;
					this.removeListenersForTf(tfToBlockUnblock);
				} else if ((isBlockUnblock == 1) && (!this.isProcessing)) {
					tfToBlockUnblock.type = "input";
					tfToBlockUnblock.selectable = true;
					this.addListenersForTf(tfToBlockUnblock);
				}
			}
		}
		
		public function blockUnblock(isBlockUnblock: uint): void {
			if ((isBlockUnblock == 1) && (this.isProcessing)) isBlockUnblock = 0;
			this.blockUnblockTextFields(isBlockUnblock);
			if (isBlockUnblock == 0) {
				if (this.btnProcess) this.btnProcess.removeMouseEvents();
			} else if (isBlockUnblock == 1) {
				if (this.btnProcess) {
					if (this.checkIsAllData()) this.btnProcess.addMouseEvents() 
					else this.btnProcess.removeMouseEvents();
				}
				if ((this.arrTf.length > 0) && (this.stage != null)) {
					var tf: TextField = this.arrTf[0];
					this.stage.focus = tf;
					tf.setSelection(0, tf.length);
				}
			}
		}
		
		//////process url and show/hide process message
		
		public function process(arrParams: Array = null): void {
			this.isProcessing = true;
			this.tfMessage.showDurationMessage(0);
			this.blockUnblock(0);
			if ((this.soName != "") && (this.soName != null)) this.copyStrToSoPropSharedObject();
			this.processUrl(arrParams);
		}
		
		protected function processUrl(arrParams: Array = null): void {
			if (this.descriptionCall.isUrlLoaderServiceAmfExternalInterface == 0) {
				var arrObjHeader: Array;
				if (this.descriptionCall.authorizationDataForUrlLoader)
					arrObjHeader = [{name: "Authorization", value:  "Basic " + Base64.encode(this.descriptionCall.authorizationDataForUrlLoader)}];
				var urlLoaderExt: URLLoaderExt = new URLLoaderExt({url: this.descriptionCall.strUrlOrMethod, objParams: arrParams, isGetPost: 1, callbackEnd: new FunctionCallback(this.onUrlRequestResult, this), arrObjHeader: arrObjHeader});
			} else if (this.descriptionCall.isUrlLoaderServiceAmfExternalInterface == 1) {
				arrParams.unshift(this.descriptionCall.strUrlOrMethod, this.onProcessFormSuccess, this.onProcessFormError);
				this.idCallProcessForm = this.descriptionCall.serviceAmf.callServiceFunction.apply(this.descriptionCall.serviceAmf, arrParams);
				//this.idCallProcessForm = this.descriptionCall.serviceAmf.callServiceFunction(this.descriptionCall.strUrlOrMethod, this.onProcessFormSuccess, this.onProcessFormError, arrParams);
			} else if (this.descriptionCall.isUrlLoaderServiceAmfExternalInterface == 2) {
				ExternalInterfaceExt.addCallback("onExternalInterfaceResult", this);
				arrParams.unshift(this.descriptionCall.strUrlOrMethod);
				ExternalInterfaceExt.call.apply(ExternalInterfaceExt, arrParams);
			}
		}
		
		public function onExternalInterfaceResult(result: uint = 1): void {
			this.showAndCloseProcessFormMessage(true, result);
		}
		
		protected function onUrlRequestResult(isProcessed: Boolean, response: *, params: *): void {
			var result: int = -1;
			try {
				if (isProcessed) {
					var responseXML: XML
					if (response is XML) responseXML = response;
					else responseXML = new XML(response);
					result = uint(responseXML.@result);
				}
			} catch (e: Error) {}
			this.showAndCloseProcessFormMessage(isProcessed, result);
		}
		
		private function onProcessFormSuccess(result: * ): void {
			this.showAndCloseProcessFormMessage(true, result);
		}
		
		private function onProcessFormError(error: Object, typeError: uint): void {
			this.showAndCloseProcessFormMessage(false);
		}
		
		protected function showAndCloseProcessFormMessage(isProcessed: Boolean, result: * = -1): void {
			this.idCallProcessForm = -1;
			var typeMessage: uint;
			if (isProcessed) typeMessage = int(result) + 1;
			else typeMessage = 0;
			this.tfMessage.showAndCloseMessage(typeMessage);
		}
		
		//////
		
		protected function getSoPropSharedObjectAndSetTf(): void {
			var so: SharedObject = SharedObject.getLocal(this.soName, "/");
			if (so != null) {
				for (var tf: * in this.dictTfToSoProp) {
					tf = TextField(tf);
					var soPropName: String = this.dictTfToSoProp[tf];
					var str: String = ((so.data[soPropName] != undefined) ? so.data[soPropName]: null);
					tf.text = (str != null) ? str : this.dictTfToStrInit[tf];	
				}
				so.flush();
				so.close();
			}
		}
		
		private function copyStrToSoPropSharedObject(): void {
			var so: SharedObject = SharedObject.getLocal(this.soName, "/");
			if (so != null) {
				for (var tf: * in this.dictTfToSoProp) {
					tf = TextField(tf);
					var soPropName: String = this.dictTfToSoProp[tf];
					so.data[soPropName] = this.getTfText(tf);
				}
				so.flush();
				so.close();
			}
		}
		
		public function hideShow(isHideShow: uint): void {
			if ((isHideShow == 0) && (this.alpha > 0)) {
				this.alpha -= 0.01;
				this.blockUnblock(0);
				DoOperations.hideShow(this, 0);
			} else if ((isHideShow == 1) && (this.alpha < 1)) {
				DoOperations.hideShow(this, 1, -1, this.blockUnblock, [1]);
			}
		}
		
		override public function get height(): Number {
			return this.btnProcess.y + this.btnProcess.height;
		}
		
		public function destroy(): void {
			this.blockUnblock(0);
			if (this.idCallProcessForm != -1) this.descriptionCall.serviceAmf.abort(this.idCallProcessForm);
			else if (this.descriptionCall.isUrlLoaderServiceAmfExternalInterface == 2) ExternalInterfaceExt.removeCallback("onExternalInterfaceResult");
			if (this.tfMessage) this.tfMessage.destroy();
			if (this.btnProcess) this.removeBtnProcess();
		}
		
	}

}