/*
 * MegaZine 3 - A Flash application for easy creation of book-like webpages.
 * Copyright (C) 2007-2009 Florian Nuecke
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

package de.mightypirates.megazine.interfaces {
import flash.display.DisplayObject;

/**
 * Interface for the swf loaded containing the actual library items.
 * 
 * @author fnuecke
 */
public interface ILibrarySWF {

    // ---------------------------------------------------------------------- //
    // Init for custom navigation
    // ---------------------------------------------------------------------- //
	
    /**
     * Initialization function if the navigation contains a custom navigation.
     * Tries to call a function named <code>megazineSetup</code> in the code
     * defined in the fla from which the library was compiled.
     * 
     * @param megazine
     *          the book instance this belongs to.
     * @param currentPage
     *          the current page in the book.
     * @param library
     *          the library to use (which in turn uses this swf).
     */
    function init(megazine:IMegaZine, currentPage:uint, library:ILibrary):void;

    // ---------------------------------------------------------------------- //
    // Getter
    // ---------------------------------------------------------------------- //
	
    /**
     * Provides new instances of elements in the library.
     * 
     * @param type
     *          the id of the element to get. Use constants from the
     *          <code>LibraryConstants</code> class.
     * @see LibraryConstants
     */
    function getInstanceOf(type:String):DisplayObject;

    /** Version number of the library. */
    function getVersion():Number;

    /**
     * Tells if this library contains a custom navigation to replace the normal
     * one.
     */
    function isCustom():Boolean;

    /** Returns the width and height of buttons. */
    function getButtonSize():uint;

    /**
     * Returns the width of page buttons (height must be equal to that of normal
     * buttons).
     */
    function getPageButtonWidth():uint;
}
} // end package
