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

package de.mightypirates.megazine.gui {
import de.mightypirates.megazine.Settings;
import de.mightypirates.megazine.interfaces.*;

import flash.display.*;
import flash.text.TextField;

/**
 * For page number display left and right to page navigation.
 * 
 * @author fnuecke
 */
public class PageNumber extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Book instance this belongs to. */
    private var megazine:IMegaZine;

    /** Settings to use */
    private var settings:Settings;

    /** The label for displaying the page number */
    private var numberTextField:TextField;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Initialize a new page number display.
     * 
     * @param megazine
     *          book instance this element belongs to.
     * @param library
     *          graphics library to obtain graphics from.
     * @param settings
     *          settings to use.
     * @throws an error if it fails to get the graphics from the library.
     */
    public function PageNumber(megazine:IMegaZine, library:ILibrary,
            settings:Settings)
    {
        this.megazine = megazine;
        this.settings = settings;
        var gui:DisplayObject = library.getInstanceOf(
                LibraryConstants.PAGE_NUMBER);
        addChild(gui);
        numberTextField = gui["label"];
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Sets the number for this page number display.
     * 
     * @param number
     *          the number to display.
     */
    internal function setNumber(number:uint):void {
        if (number < 1 || number > megazine.pageCount) {
            numberTextField.text = "-";
        } else {
            numberTextField.text = String(number + settings.pageOffset);
        }
    }
}
} // end package
