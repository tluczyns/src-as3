﻿/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/

package com.luaye.console {
	/**
	 * @author Lu
	 */
	public class Ch {
		
		private var _c:*; // because it could be Console or C. This is the cheapest way I think...
		private var _name:String;
		
		/**
		 * Construct channel instance
		 *
		 * @param String Name of channel
		 * @param String (optional) instance of Console, leave blank to use C.
		 */
		public function Ch(n:String = null, c:Console = null){
			_name = n;
			// allowed to pass in Console here incase you want to use a different console instance from whats used in C
			_c = c?c:C;
		}
		public function add(str:*, priority:Number = 2, isRepeating:Boolean = false):void{
			_c.ch(_name, str, priority, isRepeating);
		}
		/**
		 * Add log line with priority 1 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function log(...args):void{
			_c.logch.apply(null, [_name].concat(args));
		}
		/**
		 * Add log line with priority 3 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function info(...args):void{
			_c.infoch.apply(null, [_name].concat(args));
		}
		/**
		 * Add log line with priority 5 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function debug(...args):void{
			_c.debugch.apply(null, [_name].concat(args));
		}
		/**
		 * Add log line with priority 7 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function warn(...args):void{
			_c.warnch.apply(null, [_name].concat(args));
		}
		/**
		 * Add log line with priority 9 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function error(...args):void{
			_c.errorch.apply(null, [_name].concat(args));
		}
		/**
		 * Add log line with priority 10 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public function fatal(...args):void{
			_c.fatalch.apply(null, [_name].concat(args));
		}
		
		/**
		 * Get channel name
		 * Read only
		 */
		public function get name():String{
			return _name;
		}
		/**
		 * Clear channel
		 */
		public function clear():void{
			_c.clear(_name);
		}
		/* Not worth using...
		public function set tracing(v:Boolean):void{
			var chs:Array = _c.tracingChannels;
			var i:int = chs.indexOf(name);
			if(v){
				_c.tracing = true;
				if(i<0){
					chs.push(name);
				}
			}else if(i>=0){
				chs.splice(i,1);
			}
		}
		public function get tracing():Boolean{
			if(!_c.tracing) return false;
			var chs:Array = _c.tracingChannels;
			var i:int = chs.indexOf(name);
			return i>=0;
		}*/
		
		public function toString():String{
			return "[Ch "+name+"]";
		}
	}
}
