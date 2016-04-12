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

package de.mightypirates.megazine {
import de.mightypirates.megazine.elements.*;
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

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
 * Dispatched when the element was instantiated (either by loading an external
 * swf or by creating a new instance of an object). This happens before the
 * element actually finishes loading (ELEMENT_COMPLETE).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ELEMENT_INIT
 */
[Event(name = 'element_init',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Wrapper for actual element display objects, handles loading/unloading the
 * element. Also handles possibly required reloading on language changes. In
 * that case the element is unloaded and attached to the element loader queue.
 * This class is used as a static refernce to an element defined in xml. It is
 * only created once in the lifetime of a MegaZine object, contrary to the
 * actual elements, which might be unloaded an reloaded as necessary (e.g. when
 * the containing page is not within valid range and needs to be unloaded to
 * free memory).
 * 
 * @author fnuecke
 */
internal class Element extends EventDispatcher implements IElement {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /**
     * The highest possible loading priority. This is used to have an upper
     * limit for priorities, so we know how much to subtract when prioritizing
     * elements on currently displayed pages.
     */
    private static const MAX_PRIORITY:int = 50;

    /**
     * List of internal elements, i.e. of elements that are not loaded from swf
     * files but instantiated from classes.
     */
    private static const INTERNAL_ELEMENTS:Array = new Array("area", "img",
            "nav", "snd", "txt");

    /** The belonging classes - must be at the same position in the array. */
    private static const INTERNAL_CLASSES:Array = new Array(Area, Image,
            Navigation, Audio, Text);

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /**
     * The actual element this wrapper represents.
     * May be null in which case the element is not currently loaded.
     */
    private var element_:AbstractElement;

    /** The number of the element in the containing page */
    private var number:uint;

    /** Library for graphics */
    private var library:ILibrary;

    /** The loader object used for loading external elements */
    private var loader:Loader;

    /** The localizer used for localizing strings */
    private var localizer:Localizer;

    /** The main owning megazine */
    private var megazine:MegaZine;

    /** Element is on an even or on an odd page */
    private var isOnEvenPage:Boolean;

    /** The page containing the element */
    private var page:IPage;

    /** Loading priority of the element. Defaults to ten. Lower = earlier. */
    private var priority_:int;

    /** Unique id for this element't title */
    private var uid:String;

    /** The XML data for this element */
    private var xml:XML;

    /** Listener cleanup support */
    private var cleanupSupport:CleanUpSupport;

    /** The last used elementloader (set by the loader) */
    internal var elementLoader:ElementLoader;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new element wrapper.
     * 
     * @param megazine
     * @param localizer
     * @param library
     * @param xml
     * @param page
     * @param even
     * @param number
     */
    public function Element(megazine:MegaZine, localizer:Localizer,
            library:ILibrary, xml:XML, page:IPage, even:Boolean, number:uint)
    {
        this.megazine = megazine;
        this.localizer = localizer;
        this.library = library;
        this.xml = xml;
        this.page = page;
        this.number = number;
        this.isOnEvenPage = even;
        cleanupSupport = new CleanUpSupport();
		
        // Loading priority. Set default priority.
        switch (xml.name().toString()) {
            case "vid":
                priority_ = 20;
                break;
            case "snd":
                priority_ = 15;
                break;
            case "img":
                priority_ = 10;
                break;
            case "area":
            case "nav":
            case "txt":
                priority_ = 5;
                break;
            default:
                priority_ = 10;
                break;
        }
        priority_ = Helper.validateInt(xml.@priority, priority_, 0,
                MAX_PRIORITY);
		
        // If we have an id, register self with megazine
        var id:String = Helper.validateString(xml.@id, "");
        if (id != "") megazine.registerElement(this, id);
		
        // Generate unique id
        uid = "element_" + xml.name() + "_title_" + (new Date().time).toString()
                + int(Math.random() * 1000000).toString();
		
        // Localization stuff... set current language if possible, register
        // listener.
        var defLang:String = localizer.defaultLanguage;
        for each (var attrib:XML in xml.attributes()) {
            // Data on default attribute.
            var defName:String = Helper.validateString(attrib.name(), "");
            var defValue:String = Helper.validateString(attrib, "");
			
            // Test if an entry for the default value exists, if not append.
            var exists:Boolean = false;
            for each (var locAttrib:XML in xml.elements(defName)) {
                var locLang:String = Helper.validateString(locAttrib.@lang, "");
                if (locLang == localizer.defaultLanguage) {
                    exists = true;
                    break;
                }
            }
			
            if (!exists) {
                xml.appendChild("<" + defName + " lang=\"" + defLang + "\">"
                        + defValue + "</" + defName + ">");
            }
        }
		
        setAttributesToLanguage(localizer.language);
        localizer.addEventListener(LocalizerEvent.LANGUAGE_CHANGED,
                handleLanguageChange, false, 0, true);
    }

    // ---------------------------------------------------------------------- //
    // Properties
    // ---------------------------------------------------------------------- //
	
    /**
     * Gets the actual element associated with this one. May be null if not
     * loaded.
     */
    public function get element():AbstractElement {
        return element_;
    }

    /** Tells whether this element is on an even page or not. */
    public function get even():Boolean {
        return isOnEvenPage;
    }

    /**
     * The elements priority while loading. Lower = more important / earlier.
     * The return value is dependant on the distance of the containing page to
     * the current page, to prioritize the pages currently visible.
     */
    public function get priority():int {
        if (isOnEvenPage) {
            return priority_ + (Math.abs(megazine.currentLogicalPage
                    - page.getNumber(true)) * (MAX_PRIORITY + 1));
        } else {
            return priority_ + (Math.abs(megazine.currentLogicalPage
                    - (page.getNumber(false) + 1)) * (MAX_PRIORITY + 1));
        }
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Load the element. If the element is already loading, loading is cancelled
     * and restarted.
     */
    public function load():void {
        // First unload...
        unload();
        
        // Element type / name
        var name:String = String(xml.name());
		
        Logger.log("MegaZine Element", "    Page "
                + page.getNumber(isOnEvenPage) + ": "
                + "Loading Element of type '" + name + "'.");
		
        // Check if it's a built in element.
        var id:int = INTERNAL_ELEMENTS.indexOf(name);
        if (id >= 0) {
            try {
                // Create the object from a class and set it up
                element_ = new INTERNAL_CLASSES[id](megazine, localizer,
                        library, page, isOnEvenPage, xml, number);
                setupElement();
            } catch (er:Error) {
                dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false,
                        false, "Dynamic instantiation for element of type '"
                        + name + "' failed: " + er.toString()));
                if (er.getStackTrace() != null) {
                    Logger.log("Warning", er.getStackTrace(),
                            Logger.TYPE_WARNING);
                }
            }
        } else {
            // No, load the element swf file
            try {
                loader = new Loader();
                cleanupSupport.make(loader.contentLoaderInfo, Event.COMPLETE,
                        handleLoadComplete);
                cleanupSupport.make(loader.contentLoaderInfo,
                        IOErrorEvent.IO_ERROR, handleLoadError);
                loader.load(new URLRequest(megazine.getAbsPath("elements/"
                        + name + ".swf")), new LoaderContext(true));
            } catch (er:SecurityError) {
                dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false,
                        false, "Loading of element of type '" + name
                        + "' failed (security error)."));
                if (er.getStackTrace() != null) {
                    Logger.log("Warning", er.getStackTrace(),
                            Logger.TYPE_WARNING);
                }
            }
        }
    }

    /**
     * Error loading external element.
     * 
     * @param e
     *          unused.
     */
    private function handleLoadError(e:IOErrorEvent):void {
        loader = null;
        dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
                "Failed loading external element of type '" + xml.name()
                + "'."));
    }

    /**
     * Done loading external element.
     * 
     * @param e
     *          unused.
     */
    private function handleLoadComplete(e:Event):void {
        //_loader = null;
        // Setup and call the init function if it exists
        try {
            // Initialize the loaded element and set it up
            element_ = (e.target.loader.getChildAt(0) as AbstractElement).
                    Constructor(megazine, localizer, library, page,
                            isOnEvenPage, xml, number);
            setupElement();
        } catch (er:Error) {
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
                    "Loaded element of type '" + xml.name()
                    + "' was invalid."));
            if (er.getStackTrace() != null) {
            	Logger.log("Warning", er.getStackTrace(), Logger.TYPE_WARNING);
            }
        }
    }

    /** Basic setup like positioning and tooltip */
    private function setupElement():void {
    	
        // Add listener to wait for loading completion
        cleanupSupport.make(element_, MegaZineEvent.ELEMENT_COMPLETE,
                handleElementLoaded);
		
        // Position / title / link
        element_.x = Helper.validateInt(xml.@left, 0);
        element_.y = Helper.validateInt(xml.@top, 0);
		
        var url:String = Helper.validateString(xml.@url, "");
		
        var numLangs:uint = 0;
        // Check for title attribute. Handle it as a default entry.
        var title:String = Helper.validateString(xml.@title, null);
        if (title != null && title != "") {
            localizer.registerString(null, uid, title);
            numLangs++;
        }
		// Then check for child title elements.
        for each (var lang:XML in xml.elements("title")) {
            var langID:String = Helper.validateString(lang.@lang, "");
            if (langID != "" && lang.toString() != "") {
                localizer.registerString(langID, uid, lang.toString());
                numLangs++;
            }
        }
        // Create tooltip if we have a title.
        if (numLangs > 0) {
            // Create blank tooltip
            var tt:ToolTip = new ToolTip("", element_.getInteractiveObject());
            localizer.registerObject(tt, "text", uid);
        }
		
        // Create a link from the element
        if (url != "") {
            url = megazine.getAbsPath(url, ["http://", "https://", "file://",
									   "ftp://", "mailto:", "anchor:"]);
            var target:String = Helper.validateString(xml.@target, "_blank");
            // Check if a title was not defined, if so display the link address
            if (title == null && numLangs == 0) {
                new ToolTip(url, element_);
            }
            // Enable button mode (hand cursor) if it's a sprite.
            if (element_.getInteractiveObject() is Sprite) {
                (element_.getInteractiveObject() as Sprite).buttonMode = true;
            }
            cleanupSupport.make(element_.getInteractiveObject(),
                    MouseEvent.CLICK,
                    function(e:MouseEvent):void {
                        // Check if it is a link to an anchor
                        if (url.search("anchor:") == 0) {
                            // Internal link
                            megazine.gotoAnchor(url.slice(7));
                        } else {
                            // External link
                            try {
                                navigateToURL(new URLRequest(url), target);
                            } catch (ex:Error) {
                                Logger.log("MegaZine Page",
                                        "Error navigating to url '"
                                        + Helper.trimString(url, 30) + "': "
                                        + ex.toString(), Logger.TYPE_WARNING);
                            }
                        }
                    });
        }
		
        // Dispatch event to notifiy that the "physical" element exists.
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_INIT,
                page.getNumber(isOnEvenPage)));
		
        // Initialize it to trigger loading
        element_.init();
    }

    /**
     * Loading of the actual element complete, forward the event.
     * 
     * @param e
     *          used for type and page.
     */
    private function handleElementLoaded(e:MegaZineEvent):void {
		
        // If load was cancelled (element = null) stop here.
        if (element_ == null) {
            return;
        }
		
        // If relative positiong was given overwrite absolute positioning after
        // the final width is known.
        var align:Array = Helper.validateString(xml.@position, "").
                replace(/  /g, "").split(" ");
        if (align.length > 0) {
            for each (var alignSub:String in align) {
                switch (alignSub.replace(/ /g, "")) {
                    case "left":
                        element_.x = 0;
                        break;
                    case "right":
                        element_.x = megazine.pageWidth - element_.width;
                        break;
                    case "center":
                        element_.x = (megazine.pageWidth - element_.width)
                                * 0.5;
                        break;
                    case "top":
                        element_.y = 0;
                        break;
                    case "bottom":
                        element_.y = megazine.pageHeight - element_.height;
                        break;
                    case "middle":
                        element_.y = (megazine.pageHeight - element_.height)
                                * 0.5;
                        break;
                }
            }
        }
		
        dispatchEvent(new MegaZineEvent(e.type, e.page));
    }

    /**
     * Used for elements to reload content if localized versions exist.
     * 
     * @param e
     *          unused.
     */
    private function handleLanguageChange(e:LocalizerEvent):void {
        // Update attributes to localized settings.
        if (setAttributesToLanguage(localizer.language)
                && (element != null || loader != null))
        {
            if (elementLoader != null) {
                unload();
                elementLoader.addElement(this);
            } else {
                // Load directly
                load();
            }
        }
    }

    /**
     * Helper method trying to set the source attribute to the child element
     * that holds the url for the current language.
     * 
     * @param lang
     *          the language to set the attributes to.
     * @return true if it was changed, else false.
     */
    private function setAttributesToLanguage(lang:String):Boolean {
        // Shortcut to default language.
        var defLang:String = localizer.defaultLanguage;
        // Remember attribute specific changes, to avoid overriding with
        // default value.
        var attribChanged:Dictionary = new Dictionary();
        // Any change at all?
        var change:Boolean = false;
		
        for each (var locAttrib:XML in xml.elements()) {
            // Data on localized attribute.
            var locLang:String = Helper.validateString(locAttrib.@lang, "");
            if (locLang == "") continue; // not a localized attribute
            var locName:String = Helper.validateString(locAttrib.name(), "");
            var locValue:String = Helper.validateString(locAttrib, "");
			
            if (locValue != Helper.validateString(xml.attribute(locName), "")) {
                // Value differs from current one.
                if (locLang == lang) {
                    // Found wanted language, update attribute.
                    xml.@[locName] = locValue;
                    change = true;
                    attribChanged[locName] = true;
                } else if (locLang == defLang && !attribChanged[locName]) {
                    // Set to default (may be overridden again, but won't
                    // override)
                    xml.@[locName] = locValue;
                    change = true;
                }
            }
        }
		
        return change;
    }

    /**
     * Onload the element. If the element is loading the loading progress
     * is cancelled. If the element is not loaded nothing happens.
     */
    public function unload():void {
        cleanupSupport.cleanup();
        if (element_ != null) {
            // Remove from stage and null self.
            if (element_.parent != null
                    && element_.parent.contains(element_))
            {
                element_.parent.removeChild(element_);
            }
            if (element_.mask != null
                    && element_.mask.parent != null
                    && element_.mask.parent.contains(element_.mask))
            {
                element_.mask.parent.removeChild(element_.mask);
            }
            try {
                element_["unloadAndStop"]();
            } catch (ex:Error) { 
            }
            element_ = null;
        }
        if (loader != null) {
            // Cancel loading.
            try {
                loader.close();
            } catch (er:Error) {
            }
            try {
                loader["unloadAndStop"]();
            } catch (ex:Error) {
                loader.unload();
            } finally {
                loader = null;
            }
        }
        if (elementLoader != null) {
            elementLoader.removeElement(this);
        }
    }
}
} // end package
