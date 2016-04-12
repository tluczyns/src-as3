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
import flash.display.*;
import flash.events.IEventDispatcher;

/**
 * Dispatched when the page completes loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_COMPLETE
 */
[Event(name = 'page_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the odd part of the page becomes visible (the one displayed
 * on the left).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.VISIBLE_ODD
 */
[Event(name = 'visible_odd',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the odd part of the page becomes invisible (the one displayed
 * on the left).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.INVISIBLE_ODD
 */
[Event(name = 'invisible_odd',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the even part of the page becomes visible (the one displayed
 * on the right).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.VISIBLE_EVEN
 */
[Event(name = 'visible_even',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the even part of the page becomes invisible (the one
 * displayed on the right).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.INVISIBLE_EVEN
 */
[Event(name = 'invisible_even',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the state of the page changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.STATUS_CHANGE
 */
[Event(name = 'status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Interface for the Page class, to be used in elements. Especially for external
 * objects, to reduce file size (by only importing the interface and not the
 * actual class with all the code). The actual class is not needed by external
 * elements because they do not need to instantiate new Page objects.
 * 
 * @author fnuecke
 */
public interface IPage extends IEventDispatcher {

    /**
     * Get the anchor of this page, if it has one. If it has no anchor, an empty
     * string is returned.
     * 
     * @param even
     *          for the even or for the odd part of this page.
     * @return the anchor for the page.
     */
    function getAnchor(even:Boolean):String;

    /**
     * Get this page's background color.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return this page's background color.
     */
    function getBackgroundColor(even:Boolean):uint;

    /**
     * Get the page's number. Note that this returns the indexed page number,
     * i.e. the count starts at 0.
     * 
     * @return the page number
     */
    function getNumber(even:Boolean):uint;

    /**
     * Get the BitMap object that is used for rendering the thumbnail.
     * This BitMap is updated automatically.
     * 
     * @return the BitMap with the thumbnail.
     */
    function getPageThumbnail(even:Boolean):Bitmap;

    /**
     * Get whether the even or odd page is visible or not.
     * @param even Even or odd page.
     * @return Visible or nor.
     */
    function getPageVisible(even:Boolean):Boolean;

    /**
     * Tells whether the page is a stiff or a normal page.
     */
    function get isStiff():Boolean;

    /**
     * Get the <code>DisplayObjectContainer</code> for the even part of this
     * page. This container may be used to manually add elements so the page.
     * Note that it will also contain all actual elements as defined in the
     * book, which may also be unloaded / reloaded as required.
     */
    function get pageEven():DisplayObjectContainer;

    /**
     * Get the <code>DisplayObjectContainer</code> for the odd part of this
     * page. This container may be used to manually add elements so the page.
     * Note that it will also contain all actual elements as defined in the
     * book, which may also be unloaded / reloaded as required.
     */
    function get pageOdd():DisplayObjectContainer;

    /**
     * Gets the page's current state. Possible values are defined in the
     * Constants class.
     */
    function get state():String;
}
} // end package
