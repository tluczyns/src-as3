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
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.Localizer;

import flash.display.*;
import flash.text.TextField;

/**
 * A loading bar with progress display and a label for text output.
 * 
 * @author fnuecke
 */
public class LoadingBar extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The actual bar, used for positioning the mask */
    private var barMain:DisplayObject;

    /** The mask for the loading bar graphics (moved according to percent) */
    private var barMask:Shape;

    /** The text field to output the status text to */
    private var barTextField:TextField;

    /** Original width, sans mask */
    private var baseWidth_:Number;

    /** Localizer to get the "Loading... $1" text from */
    private var localizer:Localizer;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new progress bar.
     * 
     * @param library
     *          the library from which to get the base graphics.
     * @param format
     *          the base text format, if blank the set status will be displayed
     *          directly, if not the string $1 will be replaced with the status.
     */
    public function LoadingBar(library:ILibrary, localizer:Localizer = null) {
        this.localizer = localizer;
		
        var gui:DisplayObjectContainer = library.getInstanceOf(
                LibraryConstants.LOADING_BAR) as DisplayObjectContainer;
        barMain = gui["barMain"] as DisplayObject;
        barTextField = gui["barText"] as TextField;
		
        // Remember original width.
        baseWidth_ = gui.width;
		
        // Create the mask
        barMask = new Shape();
        barMask.graphics.beginFill(0xFF00FF);
        barMask.graphics.drawRect(0, 0, barMain.width, barMain.height);
        barMask.graphics.endFill();
        barMask.y = barMain.y;
        barMask.x = barMain.x - barMain.width;
        gui.addChild(barMask);
        barMain.mask = barMask;
		
        percent = 0;
		
        addChild(gui);
    }

    // ---------------------------------------------------------------------- //
    // Setter
    // ---------------------------------------------------------------------- //
	
    /** Set the percentual value */
    public function set percent(percent:Number):void {
        barMask.x = barMain.x - (1.0 - percent) * barMain.width;
        if (localizer != null) {
            barTextField.text = localizer.getLangString(localizer.language,
                    "LNG_LOADING_ZOOM").
                            replace(/\$1/, Math.round(percent * 100));
        } else {
            barTextField.text = String(Math.round(percent * 100)) + "%";
        }
    }

    /** The original width, sans mask */
    public function get baseWidth():Number {
        return baseWidth_;
    }
}
} // end package
