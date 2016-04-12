package com.danzen.utilities {
	
	// ROBIN INTRODUCTION  
	// Robin is a custom Flash AS3 class with supporting PHP to handle realtime communication
	// realtime communication is used for chats and multiuser games with avatars, etc.
	// http://robinflash.wordpress.com - by inventor Dan Zen - http://www.danzen.com
	// if you are using Robin for commercial purposes, you are welcome to donate to Dan Zen
	// donations can be made to agency@danzen.com at http://www.paypal.com
	
	// INSTALLING CLASSES
	// suggested installation:
	// create a "classes" folder on your hard drive - for example c:\classes
	// add the classes folder to your Flash class path:
	// Flash menu choose Edit > Preferences > ActionScript - ActionScript 3 Settings 
	// then use the + sign for the source path box to add the path to your classes folder	
	// put the provided com/ directory with its folders and files in the classes folder
	// the readme has more information if you need it	
		
	// USING ROBIN
	// please make sure that com/danzen/utilities/Robin.as is in a folder in your class path
	// set the configuration below to match the configuration instructions in the robin.php file
	// make sure you set up the robin.php and associated php files and run robin.php as recommended
	// the Flash side will not connect unless you have robin.php running properly
	// there is a list of methods, events and properties below for reference
	// see the example files that come with Robin to see how to work with Robin		

	// CONFIGURATION
	// the myServer variable must match the domain that is hosting your robin.php (no http://)
	// you can set myServer to "localhost" if you are running robin.php locally
	// the myPort variable needs to match what you set in the address.php for the port
			
	
    import flash.display.Sprite;
    import flash.events.*;	
	import flash.net.XMLSocket;	
	import flash.system.Security;
	import flash.utils.Timer;
	
	public class Robin extends Sprite {		

		// just put your server domain without http:// for example www.danzen.com
		private var myServer:String = "127.0.0.1";  
		//private var myServer:String = "92.43.114.69";  
		private var myPort:Number = 4041//9999;
		
		
		// CONSTRUCTOR
		// Robin(theApplicationName:String, theMaxPeople:uint = 0, theFill:Boolean = true, theStartProperties:Object = null):void
		//		constructor to connect your application to the robin.php socket for multiuser functionality
		//		robin.php must be running for this to work.  It works in your Flash authoring tool too (AS3)
		//		PARAMETERS:
		//			theApplicationName:String
		//				you make this up - it should be one word (or camel case) and probably unique for your app
		//			theMaxPeople:uint
		//				how many people are allowed per "room" - there are as many rooms as needed - 0 is virtually unlimited
		//			theFill:Boolean
		//				if someone leaves a room - set to true to fill in their location with the next person to join
		//			theStartProperties:Object
		//				you can start off with properties set - send them in an object {prop1:numValue, prop2:"String Value, etc."}		
		//		EXAMPLES:
		//			at its simplest making a new Robin object might look like this: 
		//				var myRobin:Robin = new Robin("FreezeTag");
		//			or you could add some limitations and initial conditions: 
		//				var myRobin:Robin = new Robin("FreezeTag", 10, false, {x:200, y:300, clan:"Cyborg Rabbits"});		
		
		// EVENTS
		// IOErrorEvent.IO_ERROR
		//		trouble connecting - make sure robin.php is running and you have the right domain and port (see CONFIGURATION)
		// Event.CONNECT
		//		connected to socket - you can set up your application to submit and receive data, etc.
		// DataEvent.DATA
		//		dispatched when someone in the room makes a change (not including you)
		// SyncEvent.SYNC
		//		dispatched when any data is changed including yours (use for latest properties - equivalent to Flash remote SharedObject)
		// Event.CLOSE
		//		the socket is closed - could be that robin.php stops for some reason - all data on the server will be lost
		
		// METHODS
		// setProperty(propertyName:String, propertyValue:Object):void
		// 		sets your property to the value and sends out change to all in room (distributes)
		// setProperties(objectOfPropertiesToSet:Object):void
		//		pass in an object with properties and values and it sets yours to match and distributes them
		// getProperty(propertyName:String):String
		//		returns your value for the property you pass to it
		// getProperties(propertyName:String):Array
		//		returns an array of everyone in the room's values for the property you pass to it (can include blanks! see numPeople property)
		// getPropertyNames():Array
		//		returns an array of all property names that have been distributed
		// getSenderProperty(propertyName:String):String
		//		returns the value of the property you pass it that belongs to the last person to distribute (not you)
		// getLatestValue(propertyName:String):String
		// 		returns the last distributed value for the property you pass to it - could be yours
		// getLatestValueIndex(propertyName:String):Number
		//		returns the index number of the last person to distribute a value for the property you pass to it
		// getLatestProperties(propertyName:String):Array
		//		returns an array of the last properties to be distributed (sometimes multiple properties are distributed at once)
		// appendToHistory(someText:String=""):void
		//		adds the text passed to it to the history file for the room (deleted if room is empty)
		// clearHistory():void
		//		deletes the history file for the room		
		// dispose():void
		//		removes listeners, closes connection to socket, deletes data objects
		
		// PROPERTIES (READ ONLY)		
		// applicationName:String - the name of your application
		// server:String - the server you set in the CONFIGURATION
		// port:Number - the port you set in the CONFIGURATION
		// maxPeople:Number - see CONSTRUCTOR
		// numPeople:Number - how many people are in the room - do not go by the length of a getProperties() array
		// fill:Boolean - see CONSTRUCTOR
		// startProperties:Object - see CONSTRUCTOR
		// senderIndex:Number - the index number of the last person to send out data
		// history:String - the history text for your room at the time of application start

		// PRIVATE VARIABLES
		// getter methods allow you to get these properties (less the "my" prefix)
		private var myApplicationName:String;
		private var myMaxPeople:uint;
		private var myFill:Boolean;
		private var myStartProperties:Object;
		private var mySenderIndex:Number;
		private var myHistory:String = "";

		// public methods are available to get this data
		private var myData:Object = new Object();
		private var theirData:Object = new Object();
		private var latestValues:Object = new Object();
		private var latestIndexes:Object = new Object();
		private var latestProperties:Array = [];		
		
		// internal variables
		private var mySocket:XMLSocket;
		private var initializationCheck:Boolean = false;
		private var myTimer:Timer;				
		private var connectCheck:Boolean = false;		
				
		public function Robin(
				theApplicationName:String,							  
				theMaxPeople:uint = 0, 
				theFill:Boolean = true, 
				theStartProperties:Object = null
								) { 				
		
			trace ("hi from Robin");			
			
			myApplicationName = theApplicationName;	
			if (!myApplicationName.match(/^[a-zA-Z0-9_-]+$/)) {
				trace ("----------------------------------");
				trace ("Robin Application Name: \""+myApplicationName+"\"");
				trace ("Sorry - your application name must include only a-z, A-Z, numbers, _ or -");
				trace ("----------------------------------");
				return;
			}

			myMaxPeople = (theMaxPeople == 0) ? 1000000 : theMaxPeople;			
			myFill = theFill;
			myStartProperties = theStartProperties;
						
			mySocket = new XMLSocket(myServer);
			getPolicy();
			makeConnection();
		}
		
		// --------------------  PRIVATE METHODS  -------------------------------
		
		private function getPolicy() {
			Security.loadPolicyFile("xmlsocket://" + myServer + ":" + myPort);//("http://" + myServer + "flashpolicy.xml");
			trace("xmlsocket://" + myServer + ":" + myPort)
			trace("myServer", myServer, myPort)
			mySocket.connect(myServer, myPort);
			mySocket.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event){trace ("policy")}); // nothing to do	
			mySocket.close();
		}
		
		private function makeConnection() {	
			mySocket.connect(myServer, myPort);
			mySocket.addEventListener(Event.CONNECT, handleMeta);			
			mySocket.addEventListener(Event.CLOSE, handleMeta);			
			mySocket.addEventListener(IOErrorEvent.IO_ERROR, handleMeta);			
			mySocket.addEventListener(DataEvent.DATA, incomingData);		
		}		
		
		private function handleMeta(e:Event) {	
			switch(e.type){
				case 'ioError': 
					trace ("error");
					dispatchEvent(new Event(IOErrorEvent.IO_ERROR));
				break;				
				case 'connect':
					if (!initializationCheck) {
						initializationCheck = true;
						sendData();
						myTimer = new Timer(50, 1); // need to double send for some reason
						myTimer.addEventListener(TimerEvent.TIMER, init);
						myTimer.start();					
					}
				break;				
				case 'close': 
					trace ("close");
					dispatchEvent(new Event(Event.CLOSE));
				break; 							
			} 
		}		
		
		private function init(e:TimerEvent) {			
			if (myStartProperties) {
				setProperties(myStartProperties);
			} else {				
				sendData();
			}			
		}
		
		private function incomingData(e:DataEvent) {
			
						
			// first time data is the history file
			// followed by -~^~-\n line then the latest users for the properties
			// _u_^1    // the second user was last to update
			// text^0	// the first user was the last to update the text
			// x^1 		// the second user was the last to update x and y
			// y^1
			// followed by -~^~- line then the user data with -1 as the mySenderIndex
			
			var latestData:String
			var incomingData:String;
			
			if (!connectCheck) {				
				var feed:Array = String(e.data).split("-~^~-\n");
				myHistory = decode(feed[0]);
				latestData = feed[1];
				incomingData = feed[2];	
			}	else {
				incomingData = String(e.data);
			}			
					
			// 0
			// x|y
			// _u_^12|22
			// text^test|hello
			// x^27|30
			// y^25|200
			var lines:Array = incomingData.split("\n");
			mySenderIndex = lines.shift();
			var updatedProperties:String = lines.shift();
											
			if (connectCheck == false || Number(mySenderIndex) != -1) {											
				theirData = {};
				var temp:Array;
				var prop:String;
				for (var i:uint=0; i<lines.length; i++) {
					if (lines[i] == "") {continue;}
					temp = lines[i].split("^");
					prop = temp[0];
					if (temp[1] != "") {
						theirData[prop] = decode(temp[1]).split("|");
					}
				}
			}						
			
			// set the latest information
			// note... the initial variables sent when instantiating Robin are not used for latest information
			
			if (connectCheck == false) {
				
				latestProperties = [];
				var latestLines:Array = latestData.split("\n");				
				var latestVV:Array;
				
				for (var iii:uint = 0; iii<latestLines.length; iii++) {					
					if (latestLines[iii] != "") {						
						latestVV = latestLines[iii].split("^");
						if (latestVV[0] == "_u_" && latestVV[1] != 0) {
							latestIndexes[latestVV[0]] = Number(latestVV[1]);												
							latestValues[latestVV[0]] = getProperties(latestVV[0])[Number(latestVV[1])];											
						}
					}
				}				
			} else {			
				if (updatedProperties == "") {
					// somebody left and may want to set any latestIndexes to -2
				} else {				
					latestProperties = updatedProperties.split("|");
					for (var ii:uint=0; ii<latestProperties.length; ii++) {
						if (mySenderIndex == -1) { // this is your own property
							latestValues[latestProperties[ii]] = getProperty(latestProperties[ii]);
						} else {
							latestValues[latestProperties[ii]] = getSenderProperty(latestProperties[ii]);							
						}
						latestIndexes[latestProperties[ii]] = mySenderIndex;
					}
				}	
			}
			
			
			
			dispatchEvent(new SyncEvent(SyncEvent.SYNC, false, false, []));

			if (connectCheck == false) {
				dispatchEvent(new Event(Event.CONNECT));	
				connectCheck = true;
			} else if (mySenderIndex != -1) {				
				dispatchEvent(new DataEvent(DataEvent.DATA, false, false, String(e.data)));
			}

		}			
		
		private function sendData(s:String="") {
			var f:Number;
			if (myFill) {f=1;} else {f=0;}
			var prefix:String = "%^%"+myApplicationName+"|"+myMaxPeople+"|"+f;		
			// %^%sample9|3|1^y=5^x=20
			// the %^% makes sure that if there are multiple entries in the socket buffer
			// that they can be separated in the robin.php code
									
			mySocket.send(prefix+s);			
		}			
		
		private function encode(w:String):String {
			w = w.replace(/\r\n/g,"\n");
			w = w.replace(/\n\r/g,"\n");
			w = w.replace(/\n/g,"`~`");
			w = w.replace(/\|/g,"^~^");
			return w;
		}
		
		private function decode(w:String):String {
			w = w.replace(/`~`/g,"\n");
			w = w.replace(/^~^/g,"|");
			return w;
		}		
		
		// --------------------  PUBLIC METHODS  -------------------------------

		public function setProperty(n:String, v:Object) {
			// set one of my properties at a time
			myData[n] = v;								
			sendData("^" + n + "=" + encode(String(v)));			
		}

		public function setProperties(o:Object) {
			// set a bunch of my properties at once with an object
			var vars = "";
			for (var i:Object in o) {
				myData[i] = String(o[i]);
				vars += "^" + i + "=" + encode(String(o[i]));
			}						
			sendData(vars);			
		}

		public function getProperty(w:String):String {
			// get one of my properties
			return myData[w];			
		}
		
		public function getProperties(w:String):Array {
			// get an array of their properties
			return theirData[w];
		}
		
		public function getPropertyNames():Array {
			// get a list of their property names
			var props:Array =[];
			for (var i:String in theirData) {
				props.push(i);
			}
			return props;			
		}
		
		public function getSenderProperty(w:String):String {
			if (theirData[w] && theirData[w][mySenderIndex]) {
				return theirData[w][mySenderIndex];
			} else {
				return null;
			}
		}
				
		public function getLatestValue(w:String):String {		
			if (latestValues[w]) {
				return latestValues[w];
			} else {
				return null;
			}	
		}
		
		public function getLatestValueIndex(w:String):Number {			
			return Number(latestIndexes[w]);
		}
		
		public function getLatestProperties(w:String):Array {			
			return latestProperties;
		}				
		
		public function appendToHistory(t:String="") {
			sendData("^_history_=" + encode(String(t)));
		}		
		
		public function clearHistory() {
			sendData("^_clearhistory_=");
		}			
		
		public function dispose() {
			mySocket.removeEventListener(Event.CONNECT, handleMeta);					
			mySocket.removeEventListener(IOErrorEvent.IO_ERROR, handleMeta);			
			mySocket.removeEventListener(DataEvent.DATA, incomingData);
			mySocket.close();
			mySocket.removeEventListener(Event.CLOSE, handleMeta);	
			mySocket = null;
			
			myData = null;
			theirData = null;
			latestValues = null;
			latestIndexes = null;
			latestProperties = null;			
			myHistory = null;
			
			trace ("bye from Robin");			
		}
		
		// ----------------------- PUBLIC READ ONLY PROPERTIES ---------------------
		
		public function get applicationName():String {
			return myApplicationName;
		}
		public function get server():String {
			return myServer;
		}
		public function get port():Number {
			return myPort;
		}
		public function get maxPeople():Number {
			return myMaxPeople;
		}
		public function get numPeople():Number {
			var list:Array = getProperties("_u_");
			var num:uint = 0;
			if (list != null && list.length > 0) {				
				for (var i:uint=0; i<list.length; i++) {
					if (list[i] != "") {
						num++;
					}
				}
			} 
			return num;					
		}
		public function get fill():Boolean {
			return myFill;
		}
		public function get startProperties():Object {
			return myStartProperties;
		}
		public function get senderIndex():Number {
			return mySenderIndex;
		}
		public function get history():String {
			return myHistory;
		}		
			
	
	}
	
}

