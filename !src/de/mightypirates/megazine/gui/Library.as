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
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.system.LoaderContext;

/**
 * Dispatched when the library fails loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.LIBRARY_ERROR
 */
[Event(name = 'library_error',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the library finishes loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.LIBRARY_COMPLETE
 */
[Event(name = 'library_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * This class acts as an interface to SWF files which have the LibrarySWF class
 * as their document class. It can be used to load graphics from these SWF
 * files.
 * 
 * @author fnuecke
 */
public class Library extends EventDispatcher implements ILibrary {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Version number of the library */
    private static const VERSION:Number = 1.040;

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The method used for obtaining new instances from the loaded library */
    private var factory_:ILibrarySWF;

    /** The loader used to load the swf */
    private var loader:Loader;

    /** Path to the library to load */
    private var path:String;

    /** Already the second try? */
    private var isSecondTry:Boolean = false;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new library, based on the file at the given url.
     * 
     * @param path
     *          url to the swf used as a resource.
     */
    public function Library(path:String) {
        this.path = path;
        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                handleLoadComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
                handleLoadError);
    }

    // ---------------------------------------------------------------------- //
    // Getter
    // ---------------------------------------------------------------------- //
	
    /**
     * Returns a new instance of the graphics object of the given type.
     * 
     * @param id
     *          the type of the object. See constants.
     * @return a new instance of the type, or null if invalid.
     */
    public function getInstanceOf(id:String):DisplayObject {
        if (factory_) {
            return factory_.getInstanceOf(id) as DisplayObject;
        } else {
            return null;
        }
    }

    /**
     * The factory swf itself. Normally the getInstanceOf method should be used.
     */
    public function get factory():ILibrarySWF {
        return factory_;
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Start loading the library.
     * 
     * @param path
     *          path from which to load the library. May be used to override the
     *          path set in the constructor.
     */
    public function load(path:String = ""):void {
        if (path) {
            this.path = path;
        }
		
        try {
            loader.load(new URLRequest(this.path), new LoaderContext(true));
        } catch (e:SecurityError) {
            Logger.log("Library",
                    "Could not load the library due to a security error.",
                    Logger.TYPE_WARNING);
            dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
        }
    }

    /**
     * Completed loading the swf.
     * 
     * @param e
     *          used to get the content of the swf.
     */
    private function handleLoadComplete(e:Event):void {
        // Remove listeners
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,
                handleLoadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,
                handleLoadError);
		
        try {
            // Get the actual library movieclip
            factory_ = loader.getChildAt(0) as ILibrarySWF;
            // Check version
            if (factory_.getVersion() < VERSION) {
                retry();
            } else {
                // Successfully loaded. Try calling the method.
                try {
                    factory_.getInstanceOf("TEST");
                } catch (ex:Error) {
                    factory_ = null;
                    Logger.log("Library",
                            "Loaded interface graphics library is invalid: "
                            + ex.toString(), Logger.TYPE_WARNING);
                    dispatchEvent(new MegaZineEvent(
                            MegaZineEvent.LIBRARY_ERROR));
                    return;
                }
				
                // If we come here the loading process was successful
                dispatchEvent(new MegaZineEvent(
                        MegaZineEvent.LIBRARY_COMPLETE));
            }
        } catch (ex:Error) {
            retry();
            return;
        }
    }

    /**
     * Retry loading, this time avoid cache.
     */
    private function retry():void {
        if (isSecondTry) {
            // Outdated even after loading uncached version.
            var versionInfo:String = "";
            try {
                versionInfo = "outdated (found: "
                        + String(factory_.getVersion())
                        + ", required: " + String(VERSION) + ").";
            } catch (ex:Error) {
                versionInfo = "invalid.";
            }
            Logger.log("Library", "Found version of interface graphics is "
                    + versionInfo, Logger.TYPE_WARNING);
            dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
        } else {
            // Outdated, try to avoid loading from cache.
            factory_ = null;
            isSecondTry = true;
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(
                    Event.COMPLETE, handleLoadComplete);
            loader.contentLoaderInfo.addEventListener(
                    IOErrorEvent.IO_ERROR, handleLoadError);
            try {
                // Browser based? If yes, avoid cache.
                var delimiter : String = path.indexOf("?") >= 0 ? "&" : "?";
                switch (Capabilities.playerType.toLowerCase()) {
                    case "plugin":
                    case "activex":
                        // Browser, random.
                        loader.load(new URLRequest(path + delimiter +
                                "r=" + Math.round(Math.random() * 1000000)),
                                new LoaderContext(true));
                        break;
                    default:
                        // Standalone player or IDE.
                        loader.load(new URLRequest(path),
                                new LoaderContext(true));
                        break;
                }
            } catch (e:SecurityError) {
                Logger.log("Library",
                        "Could not load the interface graphics due to a "
                        + "security error.", Logger.TYPE_WARNING);
                dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
            }
        }
    }

    /**
     * An error occured loading the swf.
     * @param e used to generate the log message.
     */
    private function handleLoadError(e:Event):void {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,
                handleLoadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,
                handleLoadError);
        Logger.log("Library", "Error loading the interface graphics: "
                + e.toString(), Logger.TYPE_WARNING);
        dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
    }
}
} // end package
