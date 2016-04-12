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

package de.mightypirates.megazine.elements {
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.gui.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.Event;

/**
 * Dispatched when the element finishes loading.
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ELEMENT_COMPLETE
 */
[Event(name = 'element_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Parent class to all elements that can be displayed on a page.
 * 
 * <p>
 * Must extend <code>MovieClip</code> for external classes, which use classes
 * extending this class as documentclass, and document classes must extend
 * <code>MovieClip</code>.
 * </p>
 * 
 * @author fnuecke
 */
public class AbstractElement extends MovieClip {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** On the odd or on the even page */
    protected var even:Boolean;

    /** Number of the element on the containing page */
    protected var number:uint;

    /** Library to get gui graphics from */
    protected var library:ILibrary;

    /**
     * The loading graphics that should be displayed while the element is
     * loading.
     */
    protected var loading:DisplayObject;

    /** Localizer class used to bind strings to text display */
    protected var localizer:Localizer;

    /** The MegaZine containing this element */
    protected var megazine:IMegaZine;

    /** The Page containing this element */
    protected var page:IPage;

    /** Tells if the container page is visible. Automatically updated. */
    protected var pageVisible:Boolean;

    /** XML data for this object */
    protected var xml:XML;
    
    /** Listener and other things cleanup support */
    protected var cleanUpSupport:CleanUpSupport;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Must never be used directly, as this class is not meant to be
     * instantiated (thus the prefix <code>Abstract</code> although there are
     * no abstract classes in AS3).
     * 
     * <p>
     * Should only be called by subclasses.
     * </p>
     * 
     * @param megazine
     *          the <code>MegaZine</code> instance this element will belong to.
     * @param localizer
     *          the <code>Localizer</code> used for this book instance.
     * @param library
     *          the <code>Library</code> to use for generating graphics.
     * @param page
     *          the <code>Page</code> this element will go onto.
     * @param even
     *          whether this element will go onto the even or odd part of the
     *          page (pages always have two sides).
     * @param xml
     *          the <code>XML</code> element describing this element.
     * @param number
     *          the number of the element in it's containing page.
     */
    public function AbstractElement(megazine:IMegaZine = null,
            localizer:Localizer = null, library:ILibrary = null,
            page:IPage = null, even:Boolean = false, xml:XML = null,
            number:uint = 0)
    {
        Constructor(megazine, localizer, library, page, even, xml, number);
    }

    /**
     * Delayed loading of the loading graphics. This is for external elements
     * (because those cannot pass the required variables to the actual
     * constructor, but instead need to initialize it delayed).
     * 
     * @param megazine
     *          the <code>MegaZine</code> instance this element will belong to.
     * @param localizer
     *          the <code>Localizer</code> used for this book instance.
     * @param library
     *          the <code>Library</code> to use for generating graphics.
     * @param page
     *          the <code>Page</code> this element will go onto.
     * @param even
     *          whether this element will go onto the even or odd part of the
     *          page (pages always have two sides).
     * @param xml
     *          the <code>XML</code> element describing this element.
     * @param number
     *          the number of the element in it's containing page.
     */
    public function Constructor(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML,
            number:uint):AbstractElement
    {
        this.megazine = megazine;
        this.localizer = localizer;
        this.library = library;
        this.page = page;
        this.even = even;
        this.xml = xml;
        this.number = number;
        cleanUpSupport = new CleanUpSupport();
		
		if (page != null) {
            // Register for page visibility changes.
            if (even) {
                cleanUpSupport.make(page, MegaZineEvent.VISIBLE_EVEN,
                        handleVisible);
                cleanUpSupport.make(page, MegaZineEvent.INVISIBLE_EVEN,
                        handleInvisible);
            } else {
                cleanUpSupport.make(page, MegaZineEvent.VISIBLE_ODD,
                        handleVisible);
                cleanUpSupport.make(page, MegaZineEvent.INVISIBLE_ODD,
                        handleInvisible);
            }
            // Initial value.
            pageVisible = page.getPageVisible(even);
		}
		if (library != null && xml != null) {
            try {
                loading = library.getInstanceOf(
                        LibraryConstants.LOADING_SIMPLE);
                loading.x = Helper.validateNumber(xml.@width, 0) * 0.5;
                loading.y = Helper.validateNumber(xml.@height, 0) * 0.5;
                if (loading.x == 0) {
                    loading.x = loading.width * 0.5;
                }
                if (loading.y == 0) {
                    loading.y = loading.height * 0.5;
                }
    			
                addChild(loading);
            } catch (er:Error) {
                Logger.log("MegaZine Element",
                        "Failed setting up loading graphics: " + er.toString(),
                        Logger.TYPE_WARNING);
            }
		}
        
        // Cleanup
        cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE, destroy);
        
        return this;
    }

    /**
     * Must be overridden by child classes.
     * 
     * <p>
     * Will be called when the element should be initialized, i.e. when basic
     * creation was completed an other, element specific actions for
     * initializing this element should be performed.
     * </p>
     * 
     * <p>
     * Call <code>super.init();</code> after performing all actions in the
     * child's <code>init()</code> function. This will take care of removing
     * the loading graphic if it still remains, and fires the
     * <code>MegaZineEvent.ELEMENT_COMPLETE</code> event.
     * </p>
     */
    public function init():void {
        if (loading != null && contains(loading)) {
        	removeChild(loading);
        }
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
                page.getNumber(even)));
    }

    /**
     * Returns the element to use for interactions such as mouseclicks when the
     * element is linked (via url) or has a hires variant. This should be
     * overridden by subclasses that have interactive content, which should stay
     * on top.
     * 
     * @return the InteractiveObject to use.
     */
    public function getInteractiveObject():InteractiveObject {
        return this;
    }

    /**
     * Used to perform clean up actions after this element should be unloaded.
     * 
     * <p>
     * Override in subclasses, but call <code>super.unload();</code>.
     * </p>
     */
    protected function destroy(e:Event):void {
    	cleanUpSupport.cleanup();
    }
    
    /**
     * Handle visiblity of pages.
     * 
     * @param e
     *      unused.
     */
    private function handleVisible(e:MegaZineEvent):void {
        pageVisible = true;
    }

    /**
     * Handle invisiblity of pages.
     * 
     * @param e
     *          unused.
     */
    private function handleInvisible(e:MegaZineEvent):void {
        pageVisible = false;
    }
    
}
} // end package
