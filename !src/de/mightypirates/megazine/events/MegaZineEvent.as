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
 * Event type used by megazine.
 * 
 * @author fnuecke
 */
public class MegaZineEvent extends Event {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /**
     * Event dispatched when the cursor enters the area where clicking triggers
     * a page turn or if keeping the mouse button down a drag.
     * 
     * @eventType dragarea_enter
     */
    public static const DRAGAREA_ENTER:String = "dragarea_enter";

    /**
     * Event dispatched when the cursor leaves the area where clicking triggers
     * a page turn or if keeping the mouse button down a drag.
     * 
     * @eventType dragarea_leave
     */
    public static const DRAGAREA_LEAVE:String = "dragarea_leave";

    /**
     * Event dispatched when a child element of this page completes
     * initializing.
     * 
     * @eventType element_complete
     */
    public static const ELEMENT_COMPLETE:String = "element_complete";

    /**
     * Event dispatched when a child element of this page completes
     * initializing.
     * 
     * @eventType element_init
     */
    public static const ELEMENT_INIT:String = "element_init";

    /**
     * Dispatched when the page turning status changes.
     * 
     * @eventType flip_status_change
     */
    public static const FLIP_STATUS_CHANGE:String = "flip_status_change";

    /**
     * Dispatched to inform elements to mute themselves.
     * 
     * @eventType mute
     */
    public static const MUTE:String = "mute";

    /**
     * Even page becomes invisible.
     * 
     * @eventType invisible_even
     */
    public static const INVISIBLE_EVEN:String = "invisible_even";

    /**
     * Odd page becomes invisible.
     * 
     * @eventType invisible_odd
     */
    public static const INVISIBLE_ODD:String = "invisible_odd";

    /**
     * Dispatched when the library was loaded successfully.
     * 
     * @eventType library_complete
     */
    public static const LIBRARY_COMPLETE:String = "library_complete";

    /**
     * Dispatched when there is an error while loading the library.
     * 
     * @eventType library_error
     */
    public static const LIBRARY_ERROR:String = "library_error";

    /**
     * Dispatched when the current page changes.
     * 
     * @eventType page_change
     */
    public static const PAGE_CHANGE:String = "page_change";

    /**
     * Event dispatched when a page completes loading its elements.
     * 
     * @eventType page_complete
     */
    public static const PAGE_COMPLETE:String = "page_complete";

    /**
     * Dispatched when the correct password is entered in the password form.
     * 
     * @eventType password_correct
     */
    public static const PASSWORD_CORRECT:String = "password_correct";

    /**
     * Dispatched when slideshow starts.
     * 
     * @eventType slide_start
     */
    public static const SLIDE_START:String = "slide_start";

    /**
     * Dispatched when slideshow stops.
     * 
     * @eventType slide_stop
     */
    public static const SLIDE_STOP:String = "slide_stop";

    /**
     * Dispatched when the status changes.
     * 
     * @eventType status_change
     */
    public static const STATUS_CHANGE:String = "status_change";

    /**
     * Dispatched to inform elements to unmute themselves.
     * 
     * @eventType unmute
     */
    public static const UNMUTE:String = "unmute";

    /**
     * Dispatched page becomes visible.
     * 
     * @eventType visible_even
     */
    public static const VISIBLE_EVEN:String = "visible_even";

    /**
     * Odd page becomes visible.
     * 
     * @eventType visible_odd
     */
    public static const VISIBLE_ODD:String = "visible_odd";

    /**
     * Navigated to another page via zoom. The <code>page</code> attribute of
     * the event object will be the page of the element that corresponds to the
     * image shown in zoom mode.
     * 
     * @eventType zoom_changed
     */
    public static const ZOOM_CHANGED:String = "zoom_changed";

    /**
     * Zoom's closed.
     * 
     * @eventType zoom_closed
     */
    public static const ZOOM_CLOSED:String = "zoom_closed";

    /**
     * Zoom state changed (between opened or closed). The <code>page</code>
     * attribute of the event object will be the page of the element that
     * corresponds to the image shown in zoom mode when opening the zoom.
     * 
     * @eventType zoom_status_change
     */
    public static const ZOOM_STATUS_CHANGE:String = "zoom_status_change";

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** For page change events, if it was an instant turn */
    private var wasInstantTurn_:Boolean;

    /** For page turn completions (page state), which way it was turning */
    private var leftToRightTurn_:Boolean;

    /** Message that was logged */
    private var message_:String;

    /** Page changed to when event was fired */
    private var page_:int;

    /** Previous state */
    private var previousState_:String;

    /** Megazine state when event was fired */
    private var newState_:String;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new <code>MegaZineEvent</code>.
     * 
     * @param type
     *          the type of the event.
     * @param page
     *          the affected page, e.g. for page change events.
     * @param newState
     *          the new state (only for status change).
     * @param previousState
     *          the previous state before changing to this one (only for status
     *          change).
     * @param leftToRightTurn
     *          if the event is page turn specific, which way the turn went.
     * @param wasInstantTurn
     *          if the event is page turn specific, if the turn was instant. 
     */
    public function MegaZineEvent(type:String, page:int = 0,
            newState:String = "", previousState:String = "",
            leftToRightTurn:Boolean = false, wasInstantTurn:Boolean = false)
    {
        super(type);
        this.page_ = page;
        this.newState_ = newState;
        this.previousState_ = previousState;
        this.leftToRightTurn_ = leftToRightTurn;
        this.wasInstantTurn_ = wasInstantTurn;
    }

    // ---------------------------------------------------------------------- //
    // Getter
    // ---------------------------------------------------------------------- //
	
    /**
     * Instant page turn or not. Only used for page change events.
     */
    public function get wasInstantTurn():Boolean {
        return wasInstantTurn_;
    }

    /**
     * The page's turning direction. Only used for page status change events.
     */
    public function get leftToRightTurn():Boolean {
        return leftToRightTurn_;
    }

    /**
     * The message that was logged. Only used for message events.
     */
    public function get message():String {
        return message_;
    }

    /**
     * The page changed to when firing this event. Only used for page change
     * events.
     */
    public function get page():int {
        return page_;
    }

    /**
     * The state prior to the state change when used for status change events.
     * The previous loading state when firing this event when used for page
     * completion events.
     */
    public function get previousState():String {
        return previousState_;
    }

    /**
     * The state when firing this event when used for status change events.
     * The loading state when firing this event when used for page completion
     * events.
     */
    public function get newState():String {
        return newState_;
    }
}
} // end package
