/*
 * Helper - Some helper methods for variable formatting
 * Copyright (C) 2007-2009 Florian Nuecke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package de.mightypirates.utils {
import com.adobe.utils.DictionaryUtil;

import flash.utils.Dictionary;

/**
 * Contains helper methods for validating values of any type, meant to be used
 * with data loaded from xml files (meaning data that might be null, in which
 * case the default value is returned). Meant to ease formatting loaded data.
 * 
 * @author fnuecke
 * @version 1.12
 */
public class Helper {

    /** For the padString method, centered padding */
    public static const PAD_CENTER:String = "pad_center";

    /** For the padString method, left padding */
    public static const PAD_LEFT:String = "pad_left";

    /** For the padString method, right padding */
    public static const PAD_RIGHT:String = "pad_right";

    
    /**
     * Search an object within an array (using a deep comparison).
     * 
     * @param haystack
     *          the array in which to search.
     * @param needle
     *          the object to search.
     * @return -1 if not found, else the index of the searched object.
     */
    public static function arrayIndexOf(haystack:Array, needle:*):int {
        var pos:int = -1;
        for (var i:int = 0;i < haystack.length; ++i) {
            if (equals(haystack[i], needle)) {
                pos = i;
                break;
            }
        }
        return pos;
    }

    /**
     * Creates a deep copy of an object. This achieved by iterating over all
     * enumerable properties of the input object and copying them into a new
     * object. If a property's value is an object, the function recurses.
     * If the input value has no enumerable properties, the copy is a flat
     * copy (maybe even just a reference to the same object).
     * 
     * @param o
     *          the object to copy.
     * @return the copied object.
     */
    public static function deepObjectCopy(o:Object):Object {
        if (o == null) return null;
        var copy:*;
        if (o is Array) {
            copy = new Array();
        } else {
            copy = new Object();
        }
        var hadProperties:Boolean = false;
        for (var key:* in o) {
            hadProperties = true;
            if (o[key] is Object) {
                copy[key] = deepObjectCopy(o[key]);
            } else {
                copy[key] = o[key];
            }
        }
        if (!hadProperties) {
            copy = o;
        }
        return copy;
    }

    /**
     * Compares two objects for equality, performing a deep comparison where
     * necessary (i.e. for arrays and objects).
     * 
     * @param a
     *          first object.
     * @param b
     *          second object.
     * @return true if the objects are equal, else false.
     */
    public static function equals(a:*, b:*):Boolean {
        if (typeof a != typeof b) return false;
		else switch (typeof a) {
            case "object":
                if (a is Array && b is Array
                        && (a as Array).length != (b as Array).length)
                {
                	return false;
                }
                // perform deep comparison
                for (var property1 : * in a) {
                    if (!(property1 in b)
                           || !equals(a[property1], b[property1]))
    	            {
    	       	        return false;
        	        }
                }
                // both ways if we don't know which element has more properties
                // (i.e. not arrays)
                if (!(a is Array)) {
                	for (var property2 : * in b) {
                		if (!(property2 in a)
                		      || !equals(a[property2], b[property2]))
        		        {
        		        	return false;
        		        }
                	}
                }
                return true;
                break;
            case "xml":
                // perform comparison on describing xml raw data
                return (a as XML).toXMLString() == (b as XML).toXMLString();
            default:
                // perform direct comparison
                return a == b;
        }
        return false;
    }

    /**
     * Tests two floating point number for almost equality (with a certain
     * margin of error).
     * 
     * @param a
     *          the first number.
     * @param b
     *          the second number.
     * @param epsilon
     *          the margin of error in which to declare both numbers equal.
     */
    public static function fpEquals(a:Number, b:Number,
            epsilon:Number = 0.000001):Boolean
    {
        return Math.abs(a - b) < epsilon;
    }
    
    /**
     * This returns the first key in a dictionary object.
     * 
     * @param d
     *          the dictionary from which to get the first key.
     * @return the first key.
     */
    public static function dictFirstKey(d:Dictionary):* {
        return DictionaryUtil.getKeys(d)[0];
    }
    
    /**
     * This returns the last key in a dictionary object.
     * 
     * @param d
     *          the dictionary from which to get the last key.
     * @return the last key.
     */
    public static function dictLastKey(d:Dictionary):* {
    	const keys:Array = DictionaryUtil.getKeys(d);
    	return keys[keys.length - 1];
    }
    
    /**
     * This returns the next key in a dictionary object, based on the given
     * current index.
     * This is an infinite run! If the end is reached it starts again at the
     * beginning.
     * 
     * @param d
     *          the dictionary from which to get the next key.
     * @param k
     *          the current key.
     * @return the next key, or null if the given key is not a key in the
     *          given dictionary.
     */
    public static function dictNextKey(d:Dictionary, k:*):* {
    	if (k == null) {
    		return null;
    	}
    	const keys:Array = DictionaryUtil.getKeys(d);
    	const pos:int = keys.indexOf(k);
    	if (pos < 0) {
    		// Key not in dictionary
    		return k;
    	} else if (pos < keys.length - 1) {
    		// Get next key
    		return keys[pos + 1];
    	} else {
    		// End of dictionary, rewind
    		return dictFirstKey(d);
    	}
    }

    /**
     * This returns the previous key in a dictionary object, based on the given
     * current index.
     * This is an infinite run! If the beginning is reached it starts again at
     * the end.
     * 
     * @param d
     *          the dictionary from which to get the previous key.
     * @param k
     *          the current key.
     * @return the next key, or null if the given key is not a key in the
     *          given dictionary.
     */
    public static function dictPrevKey(d:Dictionary, k:*):* {
        if (k == null) {
            return null;
        }
        const keys:Array = DictionaryUtil.getKeys(d);
        const pos:int = keys.indexOf(k);
        if (pos < 0) {
            // Key not in dictionary
            return k;
        } else if (pos > 0) {
        	// Get previous key
            return keys[pos - 1];
        } else {
            // Beginning of dictionary, rewind
            return dictLastKey(d);
        }
    }
    
    /**
     * Pads a string with the given char (or string) until it reaches the
     * specified length.
     * 
     * @param text
     *          the original text.
     * @param length
     *          how long the string should be afterwards.
     * @param pad
     *          padding type. See constants.
     * @param char
     *          the char to pad with.
     * @return the new string.
     */
    public static function padString(text:String, length:uint = 0,
            pad:String = PAD_LEFT, char:String = " "):String
    {
        if (text != null && char != null && char.length > 0) {
            var lastLeft:Boolean = true;
            while (text.length < length) {
                if (pad == PAD_LEFT || (pad == PAD_CENTER && !lastLeft)) {
                    lastLeft = !lastLeft;
                    text = char + text;
                } else {
                    lastLeft = !lastLeft;
                    text += char;
                }
            }
            // In case char was a string cut off what's too much
            text = text.substr(0, length);
        }
        return text;
    }

    /**
     * Rounds a number, keeping a given amount of digits.
     * 
     * @param num
     *          the number to round.
     * @param digits
     *          the number of digits to keep.
     * @param up
     *          round up or down.
     * @return the rounded number.
     */
    public static function round(num:Number, digits:uint = 4,
            up:Boolean = true):Number
    {
        var pot:Number = Math.pow(10, digits);
        num = num * pot;
        return (up ? Math.ceil(num) : Math.floor(num)) / pot;
    }

    /**
     * Sorts a dictionary by it's key values. Uses the Array.sort() method after
     * extracting the keys using the DictionaryUtils.getKeys() method. The input
     * dictionary will not be modified.
     * 
     * @param dict
     *          the dictionary which to sort.
     * @return the sorted dictionary.
     */
    public static function sortDictByKeys(dict:Dictionary):Dictionary {
        var keys:Array = DictionaryUtil.getKeys(dict);
        keys.sort();
        var d:Dictionary = new Dictionary();
        for (var key:* in keys) {
            d[key] = dict[key];
        }
        return d;
    }

    /**
     * Shortens a string to the given length by removing the middle part,
     * replacing it with "...". If a allowed string length is too short for that
     * the "..." will not be added and only the beginning of the string will be
     * returned.
     * 
     * @param text
     *          the raw string.
     * @param len
     *          the max length.
     * @return the shortened string.
     */
    public static function trimString(text:String, len:uint):String {
        if (text != null && text.length > len) {
            if (len < 5) {
                return text.substr(0, len);
            } else {
                len = (len - 3) >> 1;
                // Weighted trimming - take 1/4 of the beginning and 3/4 of the
                // ending.
                return text.substr(0, len >> 1) + "..."
                        + text.substr(text.length - len - (len >> 1),
                                len + (len >> 1));
            }
        } else {
            return text;
        }
    }

    /**
     * Trims a given character from both front and back of a string.
     * 
     * @param str
     *          the string to trim.
     * @param char
     *          the character to remove.
     * @return the trimmed string.
     */
    public static function trim(str:String, char:String = " "):String {
        return trimBack(trimFront(str, char), char);
    }

    /**
     * Trims a given character from the front of a string.
     * 
     * @param str
     *          the string to trim.
     * @param char
     *          the character to remove.
     * @return the trimmed string.
     */
    public static function trimFront(str:String, char:String):String {
        while (str.charAt(0) == char) {
            str = str.substring(1);
        }
        return str;
    }

    /**
     * Trims a given character from the back of a string.
     * 
     * @param str
     *          the string to trim.
     * @param char
     *          the character to remove.
     * @return the trimmed string.
     */
    public static function trimBack(str:String, char:String):String {
        while (str.charAt(str.length - 1) == char) {
            str = str.substring(0, str.length - 1);
        }
        return str;
    }

    /**
     * Unknown input validation and formatting for boolean values.
     * 
     * @param raw
     *          the raw data.
     * @param def
     *          the default value.
     * @return formatted data.
     */
    public static function validateBoolean(raw:*, def:Boolean):Boolean {
        if (raw != undefined && raw != null) {
            return String(raw) == "true";
        } else {
            return def;
        }
    }

    /**
     * Unknown input validation and formatting for string values.
     * 
     * @param raw
     *          the raw data.
     * @param def
     *          the default value.
     * @return formatted data.
     */
    public static function validateString(raw:*, def:String):String {
        if (raw != undefined && raw != null) {
            return String(raw);
        } else {
            return def;
        }
    }

    /**
     * Unknown input validation and formatting for integer values.
     * 
     * @param raw
     *          the raw data.
     * @param def
     *          the default value.
     * @param low
     *          minimum value, optional (type's minimum per default).
     * @param high
     *          maximum value, optional (type's maximum per default).
     * @return formatted data.
     */
    public static function validateInt(raw:*, def:int, low:int = int.MIN_VALUE,
            high:int = int.MAX_VALUE):int
    {
        if (raw != undefined && raw != null) {
            if (int(raw) < low) {
                return low;
            } else if (int(raw) > high) {
                return high;
            } else {
                return int(raw);
            }
        } else {
            return def;
        }
    }

    /**
     * Unknown input validation and formatting unsigned integer values.
     * 
     * @param raw
     *          the raw data.
     * @param def
     *          the default value.
     * @param low
     *          minimum value, optional (type's minimum per default).
     * @param high
     *          maximum value, optional (type's maximum per default).
     * @return formatted data.
     */
    public static function validateUInt(raw:*, def:uint,
            low:uint = uint.MIN_VALUE, high:uint = uint.MAX_VALUE):uint
    {
        if (raw != undefined && raw != null) {
            if (uint(raw) < low) {
                return low;
            } else if (uint(raw) > high) {
                return high;
            } else {
                return uint(raw);
            }
        } else {
            return def;
        }
    }

    /**
     * Unknown input validation and formatting floating point values.
     * 
     * @param raw
     *          the raw data.
     * @param def
     *          the default value.
     * @param low
     *          minimum value, optional (type's minimum per default).
     * @param high
     *          maximum value, optional (type's maximum per default).
     * @return formatted data.
     */
    public static function validateNumber(raw:*, def:Number,
            low:Number = -1000000,
            high:Number = 1000000):Number
    {
        if (raw != undefined && raw != null) {
            if (Number(raw) < low) {
                return low;
            } else if (Number(raw) > high) {
                return high;
            } else {
                return Number(raw);
            }
        } else {
            return def;
        }
    }
}
} // end package
