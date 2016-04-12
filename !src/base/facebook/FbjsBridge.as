////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2008 Todd Krabach (todd at krabach dot net)
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////

package base.facebook {
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;

	/**
	 *  Manages delegation of ExternalInterface calls to FBJS through the fbjs_bridge SWF.
	 */
	public class FbjsBridge {
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  Constructor
		 */
		public function FbjsBridge() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 */
		private var _callbacks:Dictionary = new Dictionary();

		/**
		 *  @private
		 */
		private var _receive:LocalConnection;

		/**
		 *  @private
		 */
		private var _receiveConnected:Boolean = false;

		/**
		 *  @private
		 */
		private var _send:LocalConnection;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  available
		//----------------------------------

		/**
		 *  Indicates whether this player has the parameters to offer the two-way FBJS bridge.
		 */
		public function get available():Boolean {
			return sendAvailable && receiveAvailable;
		}

		//----------------------------------
		//  receiveAvailable
		//----------------------------------

		/**
		 *  Indicates whether this player has the parameters to offer the FBJS -> SWF direction
		 *  of the bridge.
		 */
		public function get receiveAvailable():Boolean {
			return (null != receiveID);
		}

		//----------------------------------
		//  receiveID
		//----------------------------------

		/**
		 *  @private
		 *  Storage for the receiveID property.
		 */
		private var _receiveID:String;

		/**
		 *  The ID of the LocalConnection that the bridge sends to.
		 */
		public function get receiveID():String {
			if (!_receiveID) {
				_receiveID = generateReceiveID();
			}
			return _receiveID;
		}

		/**
		 *  @private
		 */
		public function set receiveID(value:String):void {
			if (_receiveID != value) {
				close();
				_receiveID = value;
				if (_receiveID) {
					ensureReceive();
				}
			}
		}

		//----------------------------------
		//  sendAvailable
		//----------------------------------

		/**
		 *  Indicates whether this player has the parameters to offer the SWF -> FBJS direction
		 *  of the bridge.
		 */
		public function get sendAvailable():Boolean {
			return (null != sendID);
		}

		//----------------------------------
		//  sendID
		//----------------------------------

		/**
		 *  @private
		 *  Storage for the sendID property.
		 */
		private var _sendID:String;

		/**
		 *  The ID of the LocalConnection in the bridge.
		 */
		public function get sendID():String {
			if (!_sendID) {
				_sendID = generateSendID();
			}
			return _sendID;
		}

		/**
		 *  @private
		 */
		public function set sendID(value:String):void {
			_sendID = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 *  Registers an ActionScript method as callable from the FBJS sandbox.
		 */
		public function addCallback(functionName:String, closure:Function):void {
			if (receiveAvailable) {
				ensureReceive();
				var key:String = "callback_" + functionName;
				if (!_callbacks.hasOwnProperty(key)) {
					_callbacks[key] = [];
				}
				(_callbacks[key] as Array).push(closure);
				_receive.client[functionName] = function(...arguments):void {
					if (_callbacks.hasOwnProperty(key)) {
						var parameters:Array = arguments as Array;
						(_callbacks[key] as Array).forEach(function(item:Function, index:uint, array:Array):void {
							item.apply(null, parameters);
						});
					}
				}
			}
		}

		/**
		 *  Specifies one or more domains that can send LocalConnection calls to the receiving
		 *  LocalConnection.
		 */
		public function allowDomain(... domains):void {
			if (receiveAvailable) {
				ensureReceive();
				_receive.allowDomain(domains);
			}
		}

		/**
		 *  Specifies one or more domains that can send LocalConnection calls to the receiving
		 *  LocalConnection.
		 */
		public function allowInsecureDomain(... domains):void {
			if (receiveAvailable) {
				ensureReceive();
				_receive.allowInsecureDomain(domains);
			}
		}

		/**
		 *  Calls a function exposed by the FBJS sandbox, passing zero or more arguments.
		 */
		public function call(functionName:String, ...arguments):void {
			if (sendAvailable) {
				ensureSend();
				var parameters:Array = ([sendID, "callFBJS", functionName, (arguments as Array)]);
				_send.send.apply(_send, parameters);
			}
		}

		/**
		 *  Closes (disconnects) the receiving LocalConnection.
		 */
		public function close():void {
			if (_receive && _receiveConnected) {
				_receiveConnected = false;
				_receive.close();
			}
		}

		/**
		 *  Prepares the receiving LocalConnection object to receive commands from the bridge.
		 */
		public function connect():void {
			ensureReceive();
		}

		/**
		 *  @private
		 */
		private function ensureReceive():void {
			if (!_receive) {
				_receive = new LocalConnection();
				_receive.allowDomain("apps.facebook.com", "apps.*.facebook.com");
				_receive.client = {};
			}
			if (!_receiveConnected) {
				_receiveConnected = true;
				_receive.connect(receiveID);
			}
		}

		/**
		 *  @private
		 */
		private function ensureSend():void {
			if (!_send) {
				_send = new LocalConnection();
			}
		}

		public var root: DisplayObject
		
		/**
		 *  @private
		 */
		private function generateReceiveID():String {
			if (root && root.loaderInfo) return root.loaderInfo.parameters.fb_fbjs_connection;
			else return null;
		}

		/**
		 *  @private
		 */
		private function generateSendID():String {
			if (root && root.loaderInfo) return root.loaderInfo.parameters.fb_local_connection;
			else return null;
		}
	}
}
