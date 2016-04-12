/*
Hook Logger Copyright 2010 Hook L.L.C.
For licensing questions contact hook: http://www.byhook.com

 This file is part of Hook Logger.

Hook Logger is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
at your option) any later version.

Hook Logger is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Hook Logger.  If not, see <http://www.gnu.org/licenses/>.
*/

package com.jac.log 
{
	import flash.utils.getTimer;

	/**
	 * An object used to parse and store a Stack Trace for easy manipulation.
	 */
	public class ParsedStackTrace
	{//ParsedStackTrace Class
	
		private var _className:String;
		private var _functionName:String;
		private var _lineNumber:String;
		private var _fullTrace:String;
		private var _isGood:Boolean;
		private var _hasLineNumber:Boolean;
		private var _logTime:uint;
		private var _classPath:String;
		
		/**
		 * Constructor for object.  Takes the passed in stack trace, parses it, and stores the results into properties.
		 * @param	stackTrace the Stack Trace to parse.
		 */
		public function ParsedStackTrace(stackTrace:String) 
		{//ParsedStackTrace
			
			//Set defaults
			_isGood = false;
			_hasLineNumber = false;
			_logTime = getTimer();
			
			_fullTrace = stackTrace;
			
			//Parse it
			if (stackTrace == null)
			{//no good
				return;
			}//no good
			else
			{//good
				var lines:Array = _fullTrace.split("\n");
				var relevantLine:String = lines[4];
				var startIndex:int;
				var endIndex:int;
				var culledLine:String;
				
				//set flag
				_isGood = true;
				
				//Grab class path
				startIndex = relevantLine.indexOf("at");
				endIndex = relevantLine.indexOf("::");
				
				_classPath = relevantLine.substring(startIndex + 3, endIndex);
				
				//Grab class name
				startIndex = relevantLine.indexOf("::");
				endIndex = relevantLine.indexOf("/");
				if (endIndex == -1)
				{//full length
					endIndex = relevantLine.length;
				}//full length
				
				_className = relevantLine.substring(startIndex + 2, endIndex);
				
				//Grab function name
				culledLine = relevantLine.substring(endIndex + 1, relevantLine.length);
				if (culledLine.length > 0)
				{//function name
					startIndex = culledLine.indexOf("::");
					endIndex = culledLine.lastIndexOf(")");
					_functionName = culledLine.substring(startIndex + 1, endIndex + 1);
				}//function name
				else
				{//constructor
					_functionName = "";
				}//constructor
				
				//Try to get line number
				startIndex = relevantLine.lastIndexOf(":");
				_lineNumber = relevantLine.substring(startIndex + 1, relevantLine.length - 1);
				if (!isNaN(parseInt(lineNumber)))
				{//
					_hasLineNumber = true;
				}//
				else
				{//set -1
					_lineNumber = "No Line Number";
					_hasLineNumber = false;
				}//set -1
			}//good
			
		
		}//ParsedStackTrace
		
		/**
		 * Converts the properties of the ParsedStackTrace object into a formatted string for easy reading.
		 * 
		 * @param	showFullStackTrace if <code>true</code> the raw stack trace will be returned in addition to the properties.  This is <code>false</code> by default.
		 * @return a formatted string version of the ParsedStackTrace and its properties.
		 */
		public function toString(showFullStackTrace:Boolean = false):String 
		{//toString
			var result:String = "";
			
			result += ("isGood: " + _isGood);
			result += ("hasLineNumber: " + _hasLineNumber);
			result += ("Time: " + _logTime + "\n");
			result += ("Class: " + _classPath + "." + _className + "\n");
			result += ("Function: " + _functionName + "\n");
			result += ("Line: " + _lineNumber + "\n");
			
			if (showFullStackTrace)
			{//add full trace
				result += ("\n" + _fullTrace);
			}//add full trace
			
			return result;
			
		}//toString
		
		/**
		 * Returns the parsed class name from the Stack Trace.
		 * 
		 * @return the class name
		 */
		public function get className():String { return _className; }
		
		/**
		 * Returns the function name parsed from the Stack Trace.
		 * @return the function name.
		 */
		public function get functionName():String { return _functionName; }
		
		/**
		 * Returns the line number from the parsed Stack Trace.
		 * @return the line number.
		 */
		public function get lineNumber():String { return _lineNumber; }
		
		/**
		 * Returns the raw passed in Stack Trace.
		 * 
		 * @return the raw passed in Stack Trace.
		 */
		public function get fullTrace():String { return _fullTrace; }
		
		/**
		 * Flag that indicates if the parsing was successful.
		 * 
		 * @return <code>true</code> if the parse was a success, and <code>false</code> otherwise.
		 */
		public function get isGood():Boolean { return _isGood; }
		
		/**
		 * Flag that indicates whether or not a line number was provided in the Stack Trace.
		 * @return <code>true</code> if a line number was provided, and <code>false</code> otherwise.
		 */
		public function get hasLineNumber():Boolean { return _hasLineNumber; }
		
		/**
		 * Returns the time the ParsedStackTrace object was created.
		 * 
		 * @return the time the ParsedStackTrace object was created.
		 */
		public function get logTime():uint { return _logTime; }
		
		/**
		 * Returns the class path provided in the Stack Trace.
		 * 
		 * @return the class path provided in the stack trace.
		 */
		public function get classPath():String { return _classPath; }
		
		
	}//ParsedStackTrace Class

}