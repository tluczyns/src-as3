package base.loader {
	import base.utils.FunctionCallback;
    import flash.utils.Timer;
	import flash.net.*
    import flash.events.*;
    import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import base.types.StringUtils;

    public class URLLoaderExt extends URLLoader {
		
		private var callbackEnd: FunctionCallback;
		private var onLoadProgress: Function;
        private var timerTimeout:Timer;
    	
    	function URLLoaderExt(objLoaderExt: Object): void {
			var timeTimeout: uint = (objLoaderExt.timeTimeout != undefined) ? objLoaderExt.timeTimeout : 60000;
			this.callbackEnd = objLoaderExt.callbackEnd;
			this.onLoadProgress = objLoaderExt.onLoadProgress || this.onLoadProgressDefault;
			var url: String = objLoaderExt.url;
			var arrObjHeader: Array = objLoaderExt.arrObjHeader || [];
			var variables: * = objLoaderExt.variables || new URLVariables();
			var objParams: Object = objLoaderExt.objParams || { };
			var addRandomValue: Boolean = (objLoaderExt.addRandomValue != undefined) ? objLoaderExt.addRandomValue : false;
			var isGetPost: uint = (objLoaderExt.isGetPost != undefined) ? objLoaderExt.isGetPost : 1;
			var isTextBinaryVariables: uint = (objLoaderExt.isTextBinaryVariables != undefined) ? objLoaderExt.isTextBinaryVariables : 0;
			
			this.createTimeoutForNetOperation(timeTimeout);
			this.addListeners();
			this.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
            
			var request:URLRequest = new URLRequest(url);
			//{name: "pragma", value: "no-cache"}
			var i: uint;
			for (i = 0; i < arrObjHeader.length; i++) {
                var objHeader: Object = arrObjHeader[i];
				var header:URLRequestHeader = new URLRequestHeader(objHeader.name, objHeader.value);
				request.requestHeaders.push(header);
            }
			if (variables == null) variables = new URLVariables();
			if (objParams == null) objParams = {};
			if (objParams is Array) {
				var arrParams: Array = objParams as Array;
				var objParamsFromArray: Object = {};
				for (i = 0; i < arrParams.length; i++) {
					var param: Array = objParams[i];
					objParamsFromArray[param[0]] = param[1];
				}	
				objParams = objParamsFromArray;
			}
			for (var nameParam: String in objParams) {
				variables[nameParam] = objParams[nameParam];
			}
			if (addRandomValue) variables["random"] = Math.random() * 10000000;
            request.data = variables;
            request.method = [URLRequestMethod.GET, URLRequestMethod.POST][isGetPost];
			this.dataFormat = [URLLoaderDataFormat.TEXT, URLLoaderDataFormat.BINARY, URLLoaderDataFormat.VARIABLES][isTextBinaryVariables];
            try {
				this.load(request);
            } catch (error:Error) {
                trace("Unable to load requested document.");
				this.callbackEnd.callback([false, error].concat(this.callbackEnd.params));
            }
		}
      
    	private function createTimeoutForNetOperation(timeTimeout:Number = 30000): void {
            this.timerTimeout = new Timer(timeTimeout, 1);
            this.timerTimeout.addEventListener("timer", this.onTimeout);
            this.timerTimeout.start();
    	}
		
		private function onTimeout(event:TimerEvent):void {
            trace("onTimeout");
			this.destroy();
			this.callbackEnd.callback([false, event].concat(this.callbackEnd.params));
        }
    	
		private function removeTimeoutForNetOperation(): void {
			this.timerTimeout.stop();
			this.timerTimeout.removeEventListener("timer", this.onTimeout);
			this.timerTimeout = null;
		}
    	
        private function addListeners():void {
			this.addEventListener(Event.COMPLETE, this.onLoadComplete);
            this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadError);
            this.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			//this.addEventListener (HTTPStatusEvent.HTTP_RESPONSE_STATUS, this.onHTTPStatus);
        }

		private function removeListeners(): void {
			this.removeEventListener(Event.COMPLETE, this.onLoadComplete);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadError);
			this.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			//this.removeEventListener (HTTPStatusEvent.HTTP_RESPONSE_STATUS, this.onHTTPStatus);
        }
		
        private function onLoadComplete(event: Event):void {
            this.destroy();
			var vars: * ;
			try {
				//trace("onLoadComplete:", event.target.data)
				if (this.dataFormat == URLLoaderDataFormat.TEXT) vars = String(event.target.data) //new XML(event.target.data);
				else if (this.dataFormat == URLLoaderDataFormat.BINARY) vars = ByteArray(event.target.data);
				else if (this.dataFormat == URLLoaderDataFormat.VARIABLES) vars = new URLVariables(event.target.data);
			} catch (error:Error) {  
				vars = String(event.target.data)
			}
			this.callbackEnd.callback([true, vars].concat(this.callbackEnd.params));
        }

		private function onLoadProgressDefault(event:ProgressEvent): void {
			var ratioLoaded:Number = event.bytesLoaded / event.bytesTotal;
			var percentLoaded: uint = Math.round(ratioLoaded * 100);
			//trace("The img / movie has loaded in " + percentLoaded + " %");
		}
		
        private function onLoadError(event: ErrorEvent):void {
			//IOErrorEvent SecurityErrorEvent
            trace("onLoadError: " + event);
			this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, 1));
            this.destroy();
			this.callbackEnd.callback([false, event].concat(this.callbackEnd.params));
        }
		
		/*private function onHTTPStatus(event: HTTPStatusEvent):void {
			trace("onHTTPStatus: " + event);
		}*/
		
    	public function generateRandomPassword(countChars: uint): String {
    		var numChar: uint;
    		var strPassword: String = "";
    		for (var i: uint = 0; i < countChars; i++) {
    			do {
    				numChar = Math.round(Math.random() * 255);
    			} while (!(((numChar >= 65) && (numChar <= 90)) || ((numChar >= 48) && (numChar <= 57)) || ((numChar >= 97) && (numChar <= 122))));
    			strPassword += String.fromCharCode(numChar);
    		}
    		return strPassword;
    	}
		
		public function destroy(): void {
			if ((this.timerTimeout) && (this.timerTimeout.running)) {
				this.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
				this.removeListeners();
				this.removeTimeoutForNetOperation();
				this.close();
			}
		}
		
		//static utils
		
		public static function parseXMLToObject(xmlNode: XML): Object {
			//trace("xmlNode:", xmlNode)
			var obj: Object = {/*xml: xmlNode*/};
			var xmlListAttributes: XMLList = xmlNode.@*;
			//trace("xmlListAttributes:", xmlListAttributes)
			for (var i: uint = 0; i < xmlListAttributes.length(); i++)
				obj[String(xmlListAttributes[i].name())] = xmlListAttributes[i];
			var xmlListElements: XMLList = xmlNode.*;
			/*for (i = 0; i < xmlListElements.length(); i++) {
				trace("xmlListElements[i]", xmlListElements[i], nameXMLListElement)
				var nameXMLListElement: String = String(xmlListElements[i].name());
				if (nameXMLListElement == "null") nameXMLListElement = "text"; //element tekstowy
				obj[nameXMLListElement] = URLLoaderExt.parseXMLToObject(xmlListElements[i]);
			}*/
			var arrNameElementInXMLListElement: Array = [];
			var nameXMLListElement: String;
			for (i = 0; i < xmlListElements.length(); i++) {
				nameXMLListElement = String(xmlListElements[i].name());
				if (nameXMLListElement == "null") nameXMLListElement = "text"; //element tekstowy
				if (arrNameElementInXMLListElement.indexOf(nameXMLListElement) == -1) arrNameElementInXMLListElement.push(nameXMLListElement);
			}
			for (i = 0; i < arrNameElementInXMLListElement.length; i++) {
				nameXMLListElement = arrNameElementInXMLListElement[i];
				if (nameXMLListElement != "text") {
					var xmlListElementsWithSameName: XMLList = xmlNode[nameXMLListElement];
					if (xmlListElementsWithSameName.length() > 1) obj[nameXMLListElement] = [];
					for (var j: uint = 0; j < xmlListElementsWithSameName.length(); j++) {
						var objElement: Object = URLLoaderExt.parseXMLToObject(xmlListElementsWithSameName[j]);
						if (xmlListElementsWithSameName.length() > 1) obj[nameXMLListElement].push(objElement);
						else obj[nameXMLListElement] = objElement;
					}
				} else obj[nameXMLListElement] = xmlNode;
			}
			for (var attr: String in obj) {
				var classAttr: Class = Class(getDefinitionByName(getQualifiedClassName(obj[attr])));
				if ((!isNaN(Number(obj[attr]))) && (obj[attr] != "")) {
					if (Number(obj[attr]) == uint(obj[attr])) obj[attr] = uint(obj[attr]);
					else obj[attr] = Number(obj[attr]);
				} else if ((classAttr != Array) && (classAttr != Object)) {
					obj[attr] = String(obj[attr]).split("\\n").join("\n");	
					obj[attr] = String(obj[attr]).split("\r").join("");
					obj[attr] = String(obj[attr]).split("\r").join("");
					obj[attr] = StringUtils.replace(String(obj[attr]), String.fromCharCode(65440), String.fromCharCode(160));
				}
			}
			return obj;
		}
		
		static public function sortXML(source:XML, elementName:Object, fieldName:Object, options:Object = null):XML {
			// list of elements we're going to sort
			var list:XMLList=source.elements("*").(name()==elementName);
			// list of elements not included in the sort -
			// we place these back into the source node at the end
			var excludeList:XMLList=source.elements("*").(name()!=elementName);
			list= sortXMLList(list,fieldName,options);
			list += excludeList;
			source.setChildren(list);
			return source;
		}

		static public function sortXMLList(list:XMLList, fieldName:Object, options:Object = null):XMLList {
			var arr:Array = new Array();
			var ch:XML;
			for each(ch in list) arr.push(ch);
			var resultArr:Array = fieldName==null ? options==null ? arr.sort() : arr.sort(options) : arr.sortOn(fieldName, options);
			var result:XMLList = new XMLList();
			for(var i:int=0; i<resultArr.length; i++) result += resultArr[i];
			return result;
		}
		
    }
}