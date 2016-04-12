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
import de.mightypirates.megazine.elements.AbstractElement;

/**
 * Dispatched when the an error occurs while loading an element.
 * 
 * @eventType flash.events.IOErrorEvent.IO_ERROR
 */
[Event(name = 'ioError', type = 'flash.events.IOErrorEvent')]

/**
 * Dispatched when the element completely finished loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ELEMENT_COMPLETE
 */
[Event(name = 'element_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the element was instantiated (either by loading an external swf
 * or by creating a new instance of an object). This happens before the element
 * actually finishes loading (ELEMENT_COMPLETE).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ELEMENT_INIT
 */
[Event(name = 'element_init',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Interface for the element wrapper class.
 * 
 * @author fnuecke
 */
public interface IElement {

    /**
     * Gets the actual element associated with this one. May be null if not
     * loaded.
     */
    function get element():AbstractElement;

    /** Tells whether this element is on an even page or not. */
    function get even():Boolean;

    /**
     * The elements priority while loading. Lower = more important / earlier.
     * The return value is dependant on the distance of the containing page to
     * the current page, to prioritize the pages currently visible.
     */
    function get priority():int;

    /**
     * Load the element. If the element is already loading, loading is cancelled
     * and restarted.
     */
    function load():void;

    /**
     * Onload the element. If the element is loading the loading progress
     * is cancelled. If the element is not loaded nothing happens.
     */
    function unload():void;
}
} // end package
