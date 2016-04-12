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

package de.mightypirates.megazine.events {
import flash.events.Event;

/**
 * Event fired by the navigation when a button is pressed.
 * 
 * @author fnuecke
 */
public class NavigationEvent extends Event {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /**
     * Button in the navigation bar was clicked. Which type exactly is
     * determined by the subtypes. They are not directly used as the type to
     * make it easier registering for this event (otherwise one would have to
     * register a listener for every possible button).
     * 
     * @eventType button_click
     */
    public static const BUTTON_CLICK:String = "button_click";

    /**
     * [subtype] Go to fullscreen mode.
     */
    public static const FULLSCREEN:String = "fullscreen";

    /**
     * [subtype] Go to specified page.
     */
    public static const GOTO_PAGE:String = "goto_page";

    /**
     * [subtype] Open the dialog box to enter to which page to go.
     */
    public static const GOTO_PAGE_DIALOG:String = "goto_page_dialog";

    /**
     * [subtype] Help button was pressed.
     */
    public static const HELP:String = "help";

    /**
     * [subtype] Mute all sounds.
     */
    public static const MUTE:String = "mute";

    /**
     * [subtype] Go to first page in book.
     */
    public static const PAGE_FIRST:String = "page_first";

    /**
     * [subtype] Go to last page in book.
     */
    public static const PAGE_LAST:String = "page_last";

    /**
     * [subtype] Go to next page in book.
     */
    public static const PAGE_NEXT:String = "page_next";

    /**
     * [subtype] Go to prev page in book.
     */
    public static const PAGE_PREV:String = "page_prev";

    /**
     * [subtype] Pause slideshow.
     */
    public static const PAUSE:String = "pause";

    /**
     * [subtype] Start slideshow.
     */
    public static const PLAY:String = "play";

    /**
     * [subtype] Return to normal mode (from fullscreen mode).
     */
    public static const RESTORE:String = "restore";

    /**
     * [subtype] Open settings dialog.
     */
    public static const SETTINGS:String = "settings";

    /**
     * [subtype] Unmute sounds.
     */
    public static const UNMUTE:String = "unmute";

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** For go to page events, the page number */
    private var page_:uint;

    /** The subtype, more specifically the id of the button that was pressed. */
    private var subtype_:String;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new navigation event. The base type will always be that of
     * {@link #BUTTON_CLICK}.
     * 
     * @param type
     *          the id of the button that was pressed, see constants.
     * @param page
     *          if it's a goto page event, which page to go to.
     */
    public function NavigationEvent(type:String, page:uint = 0) {
        super(BUTTON_CLICK);
        subtype_ = type;
        page_ = page;
    }

    // ---------------------------------------------------------------------- //
    // Getter
    // ---------------------------------------------------------------------- //
	
    /**
     * The page number for go to page events.
     */
    public function get page():uint {
        return page_;
    }

    /**
     * The subtype, more specifically the id of the button that was pressed.
     */
    public function get subtype():String {
        return subtype_;
    }
}
} // end package
