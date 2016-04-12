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

/**
 * This class just holds some constants used in the <code>MegaZine</code> and
 * <code>Page</code> classes, to make them available when using the interfaces
 * only.
 * 
 * @author fnuecke
 */
public class Constants {

    // ---------------------------------------------------------------------- //
    // MegaZine
    // ---------------------------------------------------------------------- //
    
    /**
     * Fatal error occured while loading, meaning the megazine was not loaded
     * completely.
     */
    public static const MEGAZINE_STATUS_ERROR:String = "status_error";

    /**
     * Currently loading the xml data containing setup information and page
     * data.
     */
    public static const MEGAZINE_STATUS_LOADING:String = "status_loading";

    /** Not yet started loading. */
    public static const MEGAZINE_STATUS_PREINIT:String = "status_preinit";

    /** Loading cancelled by removing the element from stage prematurely. */
    public static const MEGAZINE_STATUS_CANCELLED:String = "status_cancelled";

    /**
     * The XML was loaded and parsed. So was the GUI. The MegaZine is now ready
     * for turning pages and all user interaction. If enabled GUI is shown.
     * Page content may or may not be loaded. As it might be impossible to tell
     * when all pages are loaded (e.g. when only loading a given number of pages
     * in range of the current one, which is the preferred loading model) there
     * is no "complete" state.
     */
    public  static const MEGAZINE_STATUS_READY:String = "status_ready";

    /** At least one page is currently turning / is currently being dragged. */
    public static const MEGAZINE_FLIP_STATUS_BUSY:String = "flip_status_busy";

    /** No page(s) are turning / is being dragged. */
    public static const MEGAZINE_FLIP_STATUS_READY:String = "flip_status_ready";

    /** Zoom is currently closed. */
    public static const MEGAZINE_ZOOM_STATUS_CLOSED:String =
            "zoom_status_closed";

    /** Zoom is currently open. */
    public static const MEGAZINE_ZOOM_STATUS_OPEN:String = "zoom_status_open";

    // ---------------------------------------------------------------------- //
    // Page
    // ---------------------------------------------------------------------- //
    
    /** Page is currently being dragged */
    public static const PAGE_DRAGGING:String = "dragging";

    /** A page is currently being dragged by the user (lmb is down) */
    public static const PAGE_DRAGGING_USER:String = "dragging_user";

    /** Page is waiting and ready for action */
    public static const PAGE_READY:String = "ready";

    /** Page is currently going back where it came from */
    public static const PAGE_RESTORING:String = "restoring";

    /** Page moves on to where its destined to go */
    public static const PAGE_TURNING:String = "turning";

    /** Page is not loaded (contains no elements) */
    public static const PAGE_UNLOADED:String = "unloaded";

    /** Page is loading */
    public static const PAGE_LOADING:String = "loading";

    /**
     * Page is loading, but only to generate a thumbnail (will be unloaded after
     * load).
     */
    public static const PAGE_LOADING_THUMB:String = "loading2";

    /** Page is loaded (all elements are loaded) */
    public static const PAGE_LOADED:String = "loaded";
}
} // end package
