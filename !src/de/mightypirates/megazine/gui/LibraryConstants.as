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

/**
 * Only contains constants for the library class. This is so that as few classes
 * have to imported in the fla providing the graphics.
 * 
 * @author fnuecke
 */
public final class LibraryConstants {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** The default background image */
    public static const BACKGROUND:String = "background";

    /** The default background image for bars (e.g. scroll bars) */
    public static const BAR_BACKGROUND:String = "bar_background";

    /** The button for navigating to the previous image in a gallery */
    public static const BUTTON_ARROW_LEFT:String = "button_arrow_left";

    /** The button for navigating to the next image in a gallery */
    public static const BUTTON_ARROW_RIGHT:String = "button_arrow_right";

    /** The close button */
    public static const BUTTON_CLOSE:String = "button_close";

    /** Fullscreen button (go to fullscreen) */
    public static const BUTTON_FULLSCREEN:String = "button_fullscreen";

    /** Show the goto page textbox */
    public static const BUTTON_GOTO:String = "button_goto";

    /**
     * Show the tutorial messages again, and show them until they are clicked.
     */
    public static const BUTTON_HELP:String = "button_help";

    /** Mute button (mute sounds for objects that support it) */
    public static const BUTTON_MUTE:String = "button_mute";

    /** Page button, used to jump to a page directly via the page navigation */
    public static const BUTTON_PAGE:String = "button_page";

    /** First page button, jump to the first page */
    public static const BUTTON_PAGE_FIRST:String = "button_page_first";

    /** Last page button, jump to the last page */
    public static const BUTTON_PAGE_LAST:String = "button_page_last";

    /** Next page button, go to next page */
    public static const BUTTON_PAGE_NEXT:String = "button_page_next";

    /** Previous page button, go to previous page */
    public static const BUTTON_PAGE_PREV:String = "button_page_prev";

    /** Pause button, stop the automatic slideshow */
    public static const BUTTON_PAUSE:String = "button_pause";

    /** Play button, start the automatic slideshow */
    public static const BUTTON_PLAY:String = "button_play";

    /** Restore button, leave fullscreen mode */
    public static const BUTTON_RESTORE:String = "button_restore";

    /** Rotate zoom image left (counter clock wise) */
    public static const BUTTON_ROTATE_LEFT:String = "button_rotate_left";

    /** Rotate zoom image right (clock wise) */
    public static const BUTTON_ROTATE_RIGHT:String = "button_rotate_right";

    /** Settings button, open settings dialog */
    public static const BUTTON_SETTINGS:String = "button_settings";

    /** Scroll button, the knob for scroll bars */
    public static const BUTTON_SCROLL:String = "button_scroll";

    /** Unmute button, revoke muting for objects that support it */
    public static const BUTTON_UNMUTE:String = "button_unmute";

    /** Zoom button for images */
    public static const BUTTON_ZOOM:String = "button_zoom";

    /** The cursor showed when hinting a left turn */
    public static const CURSOR_TURN_LEFT:String = "cursor_turn_left";

    /** The cursor showed when hinting a right turn */
    public static const CURSOR_TURN_RIGHT:String = "cursor_turn_right";

    /** The cursor showed when hovering a zoomable image */
    public static const CURSOR_ZOOM:String = "cursor_zoom";

    /** Direct jump to page by entering a number text box */
    public static const GOTO_PAGE:String = "goto_page";

    /** A progress bar used for showing loading progress */
    public static const LOADING_BAR:String = "loading_bar";

    /** Simple loading graphics for elements */
    public static const LOADING_SIMPLE:String = "loading_simple";

    /** The password form in case the book is password "protected" */
    public static const PASSWORD_FORM:String = "password_form";

    /** Page number display (left and right to navigation) */
    public static const PAGE_NUMBER:String = "page_number";

    /** Settings dialog base */
    public static const SETTINGS:String = "settings";
}
} // end package
