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
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.gui.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import com.adobe.utils.ArrayUtil;

import flash.display.*;
import flash.errors.IllegalOperationError;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import flash.ui.*;
import flash.utils.*;

/**
 * Dispatched when the cursor enters the draggable area.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_CHANGE
 */
[Event(name = 'dragarea_enter',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the cursor leaves the draggable area.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_CHANGE
 */
[Event(name = 'dragarea_leave',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the slideshow starts.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.SLIDE_START
 */
[Event(name = 'slide_start',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the slideshow stops.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.SLIDE_STOP
 */
[Event(name = 'slide_stop',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the current page changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_CHANGE
 */
[Event(name = 'page_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when a page finishes loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_COMPLETE
 */
[Event(name = 'page_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the all sounds should be muted.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.MUTE
 */
[Event(name = 'mute',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when all sounds should be unmuted.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.UNMUTE
 */
[Event(name = 'unmute',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the status changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.STATUS_CHANGE
 */
[Event(name = 'status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the page turning state changes (pages turning <-> no pages
 * turning).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.FLIP_STATUS_CHANGE
 */
[Event(name = 'flip_status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the gallery image changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ZOOM_CHANGED
 */
[Event(name = 'zoom_changed',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the zoom mode is opened or closed.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ZOOM_STATUS_CHANGE
 */
[Event(name = 'zoom_status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Represents a book with all it's pages and settings and stuff.
 * 
 * <p>
 * Can be controlled using the public methods to navigate to different pages.
 * Some methods, such as getThumbnailsFor, getAbsPath are mainly meant to be
 * used by element classes or other internal classes, but may prove to be of use
 * for external use as well.
 * </p>
 * 
 * <p>
 * Loaded pages are stored in two base containers, one for the odd, one for the
 * even pages. Depending on the current turning direction one overlaps the
 * other. Individual page visibility is handled as well - this is done by
 * checking twice, once for odd, once for even pages, starting from the current
 * ones. If a page is transparent we continue to check for the next page and so
 * on. All other pages are made invisible.
 * </p>
 * 
 * <p>
 * Basic hierarchy goes as such:
 * <pre>
 *                              o
 *                              |
 *                         +----------+       +---------------+   +----------+
 *            +------------| MegaZine |-------|  DragHandler  |---| DragPath |
 *       +----+----+       +----------+       +---------------+   +----------+
 *       | Chapter |            |            /       |
 *       +----+----+       +----------+-----+ +---------------+
 *            +------------|   Page   |-------|  PageLoader   |
 *                         +----------+       +---------------+
 *                              |                    |
 *                         +----------+       +---------------+
 *                         | Element  |-------| ElementLoader |
 *                         +----------+       +---------------+
 *                              |
 *                     +-----------------+
 *                     | AbstractElement |
 *                     +-----------------+
 *                      |       |       |
 *                 +-------+ +------+
 *                 | Image | | Area |  . . .
 *                 +-------+ +------+
 * </pre>
 * </p>
 * 
 * <p>
 * With all the stuff in de.mightypirates.megazin.gui.* attached somewhat to
 * MegaZine, and the Localizer (and Logger) being somewhat attached to pretty
 * much everything.
 * </p>
 * 
 * @author fnuecke
 */
public class MegaZine extends Sprite implements IMegaZine {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** MegaZine Release Version (displayed in console) */
    private static const VERSION:String = "1.38";
    
    /**
     * The unique identifier of this MegaZine distribution.
     * 
     * When you continue developing with the sources under the GPL license you
     * can leave this field be. If you own a commercial license, please insert
     * your uid here.
     */
    private static const LICENSE_UID:String =
            "1749917934d4edd79a95e7227d5f8d5e";

    /** Reserved anchor names */
    private static const RESERVED_ANCHORS:Array = new Array("first", "last",
            "prev", "next");


    // ---------------------------------------------------------------------- //
    // Variables (internally generated)
    // ---------------------------------------------------------------------- //
	
	static public var stage: Stage;
	
    /** Absolute path to the swf file containing the megazine */
    private var absolutePath:String;

    /** The background fade (the gradient behind the book) */
    private var backgroundFader:Shape;

    /**
     * Blocker sprite used to block clicks in the area where page turns and
     * drags work.
     */
    private var blocker:Sprite;

    /**
     * List of colors for pages, i.e. the list of colors for page knobs in
     * the navigation bar for every page.
     */ 
    private var buttonColors:Array;

    /**
     * A list of chapters in this book. There has to be at least one chapter.
     */
    private var chapters:Array;

    /**
     * Current main page (always an even number, i.e. the number of the right
     * visible page
     */
    private var currentPage_:uint = 0;

    /** Allow dragging of pages? */
    private var draggingEnabled_:Boolean = true;

    /**
     * Handles page dragging. Has its own event listeners to react to user mouse
     * input. As this object only supports "gotoPage" the anchors and
     * next/first/last/prev page methods reside in the megazine object and call
     * the gotoPage method in the dragHandler in turn.
     */
    private var dragHandler:DragHandler;

    /**
     * A list of elements that were given an id.
     * 
     * -> AbstractElement
     */
    private var idToElement:Dictionary;
	
    /** Current state of page flipping. */

    private var flipState_:String = Constants.MEGAZINE_FLIP_STATUS_READY;

    /**
     * Known image galleries.
     * This maps gallery names to a Dictionary containing references to IPages,
     * being the containing pages of the actual gallery images. Those map to an
     * dictionary of actual hires entries, each entry being a dictionary mapping
     * a language id to a path.
     * 
     * -> Dictonary -> Dictionary -> Dictionary
     */
    private var galleries:Dictionary;
	
    /** The help window */

    private var helpWindow:Help;

    /**
     * Language strings used throughout the megazine for the interface. Loaded
     * manually from an extra xml file if needed. Else fills with default values
     * (in english).
     */
    private var localizer_:Localizer;

    /** The graphics library, used to get elements for the interface */
    private var library:Library;

    /** The muted state of the megazine */
    private var isMuted_:Boolean = false;

    /**
     * The navigation display object (page navigation, including fullscreen and
     * mute buttons as well as the actual pagination to jump to a certain page).
     */
    private var navigation:Navigation;

    /**
     * Page anchor mapping (page name to number), filled while parsing the page
     * xml, this will contain a list of strings (the anchor names) pointing to
     * uints (the page numbers). Anchors to chapters are stored here, too,
     * pointing to the first page of the chapter.
     * 
     * Object {isPage:Boolean, (p:Page, even:Boolean|c:Chapter)}
     */
    private var anchors:Dictionary;
	
    /** Container object to hold everything used to display the pages. */

    private var pageContainer_:Sprite;

    /**
     * The page loader. Created once the xml is parsed. It is then responsible
     * for loading all pages that should be currently stored in memory. There
     * are two models: load all and load partial. In the first case all pages
     * are loaded and kept in memory, in the second only a given number remains
     * loaded at a time, pages out of range will be discarded to save memory.
     */
    private var pageLoader:PageLoader;

    /**
     * The array holding all page objects, index is the page number. Because a
     * page object consists of an odd an an even page (front and back) two
     * following entries are always the same, i.e 0 and 1 point to the same Page
     * object, 2 and 3 point to the same one and so on.
     * 
     * -> Page
     */
    private var pages:Array;
	
    /**
     * Holds all even pages, needed for fast depth changes when the page turn
     * direction changes. Like this only the containers of the even and odd
     * pages have to be swapped.
     */

    private var pagesEven:DisplayObjectContainer;

    /**
     * Holds all odd pages, needed for fast depth changes when the page turn
     * direction changes. Like this only the containers of the even and odd
     * pages have to be swapped.
     */
    private var pagesOdd:DisplayObjectContainer;

    /** The password form for entering the password if one is specified. */
    private var passwordForm:PasswordForm;

    /** Timer for updating page container positions (for covers) */
    private var positionTimer:Timer;

    /**
     * Image data for the reflection, updated only when visible, draws the whole
     * area of the two pages, i.e. everything from the top left corner to the
     * bottom right corner of the book.
     */
    private var reflectionData:BitmapData;

    /** Page reflections, the actual bitmap used for display. */
    private var reflectionImage:Bitmap;

    /** Instance settings */
    private var settings:Settings;

    /** The settings dialog */
    private var settingsDialog:SettingsDialog;

    /**
     * Slideshow timer, when running turns pages automatically. Timing can
     * differ from page to page (specified in xml).
     */
    private var slideTimer:Timer;

    /** The current state of this instance, see constants */
    private var state_:String = Constants.MEGAZINE_STATUS_PREINIT;

    /** Target page container position offset (for covers) */
    private var targetPagePosition:Number = 0;

    /** Path to the interface swf (containing navigation, loading bar...) */
    private var uiPath:String;

    /** The xml data holding all info on this instance */
    private var xmlData:XML;

    /** Path to the xml file containing the data for this megazine */
    private var xmlPath:String;

    /** The container for the zoom view */
    private var zoomContainer:ZoomContainer;

    /** Was in fullscreen before opening zoom mode? */
    private var zoomPreviouslyFullscreen:Boolean;

    /** Current state of zoom mode (open or closed). */
    private var zoomState_:String = Constants.MEGAZINE_ZOOM_STATUS_CLOSED;
    
    /** Global cleanup support */
    private var cleanUpSupport:CleanUpSupport;
    
    /**
     * Clean up all listeners of the book and possibly gui elements when the
     * book is removed from the stage?
     */ 
    private var destroyOnRemove_:Boolean = true;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Constructor, creates a new MegaZine instance.
     * 
     * @param xmlPath
     *          the path to the xml file to be used for building the MegaZine.
     * @param uiPath
     *          the path to the .swf that contains ui elements.
     * @param delayLoad
     *          do not start loading when added to stage if set to true.
     */
    public function MegaZine(xmlPath:String = "megazine.xml",
							 uiPath:String = "interface.swf",
							 delayLoad:Boolean = false) {
		
        // Initialize some variables
        //_self = this;
        this.xmlPath = xmlPath;
        this.uiPath = uiPath;
		
        // Back to defaults if nothing was given.
        this.xmlPath ||= "megazine.xml";
        this.uiPath ||= "interface.swf";
		
        galleries = new Dictionary();
        pages = new Array();
        chapters = new Array();
        anchors = new Dictionary();
        buttonColors = new Array();
        idToElement = new Dictionary(true);
        
        cleanUpSupport = new CleanUpSupport();
		
        // Create page containers, hide initially.
        pageContainer_ = new Sprite();
        // Invisible until pw correct or no pw
        pageContainer_.visible = false;
        pagesEven = new Sprite();
        pagesOdd = new Sprite();
        pageContainer_.addChild(pagesEven);
        pageContainer_.addChild(pagesOdd);
        addChild(pageContainer_);
		
        // Create the draghandler
        dragHandler = new DragHandler(this, pages, pagesEven, pagesOdd);
        // Forward page change events and update currentpage.
        cleanUpSupport.make(dragHandler, MegaZineEvent.PAGE_CHANGE,
                handlePageChange);
        cleanUpSupport.make(dragHandler, MegaZineEvent.STATUS_CHANGE,
                handleDragStateChange);
        // Forward draggable area events.
        cleanUpSupport.make(dragHandler, MegaZineEvent.DRAGAREA_ENTER,
                handleDragAreaEnter);
        cleanUpSupport.make(dragHandler, MegaZineEvent.DRAGAREA_LEAVE,
                handleDragAreaLeave);
		
		// Disable dragging initially.
        draggingEnabled = false;
        
        // Slide Timer setup
        slideTimer = new Timer(5000);
        cleanUpSupport.addTimer(slideTimer);
        cleanUpSupport.make(slideTimer, TimerEvent.TIMER, handleSlideTimer);
		
        // Page positioning timer
        positionTimer = new Timer(30);
        cleanUpSupport.addTimer(positionTimer);
        cleanUpSupport.make(positionTimer, TimerEvent.TIMER,
                handlePositionTimer);
		
        // Begin loading if allowed and stage is known, else wait for
        // stage / manual triggering.
        if (!delayLoad) {
            if (stage) {
                load();
            } else {
                // Wait until added to stage before initializing mouse
                // event listeners and refreshes.
                cleanUpSupport.make(this, Event.ADDED_TO_STAGE,
                        handleAddedToStage);
            }
        }
		
        // Contextmenu
      /*  contextMenu = new ContextMenu();
        contextMenu.hideBuiltInItems();*/
        
        // Items...
        //createContextEntry("About MegaZine 3", visitHomepage);
        //createContextEntry("Check license validity", validateLicenseUID);
    }
    
    /**
     * Cleans up all listeners and internal references used by the book and
     * makes it ready for garbage collection.
     */
    public function destroy():void {
        cleanUpSupport.cleanup();
        for each (var p:Page in pages) {
        	p.destroy();
        }
    }
    

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * Returns the anchor name of the page currently being displayed.
     * 
     * <p>
     * If the page has no anchor defined, the anchor of the chapter is returned.
     * If the chapter has no anchor defined, null is returned.
     * </p>
     * 
     * <p>
     * This first checks for an anchor in the left page, then in the right page
     * (or the other way round when in right to left mode).
     * </p>
     */
    public function get currentAnchor():String {
    	var pageLeft:Page = (currentPage_ > 0)
    	        ? (pages[currentPage_ - 1] as Page)
    	        : null; 
    	var pageRight:Page = (currentPage_ < pages.length)
    	        ? (pages[currentPage_] as Page)
    	        : null;
    	if (leftToRight) { 
        	return ((pageLeft != null)
        	                ? (pageLeft.getAnchor(false)
        	                        || pageLeft.chapter.anchor) : null)
        	        || ((pageRight != null)
        	                ? (pageRight.getAnchor(true)
        	                        || pageRight.chapter.anchor) : null);
    	} else {
            return ((pageRight != null)
                            ? (pageRight.getAnchor(true)
                                    || pageRight.chapter.anchor) : null)
                    || ((pageLeft != null)
                            ? (pageLeft.getAnchor(false)
                                    || pageLeft.chapter.anchor) : null);
    	}
    }

    /**
     * Returns the number of the currently 'focused' page, i.e. the page the
     * book is opened on when there is no page turn active.
     * 
     * <p>
     * If a page is turned this will hold the future main page. If multiple
     * pages are turned it will be updated rapidly and always return
     * <i>current</i> main page.
     * </p>
     * 
     * <p>
     * This will always be an even number, i.e. the number of the page on the
     * right, starting the count at 0.
     * </p>
     * 
     * <p>
     * This is the actual <i>index</i>, and will always return the number of the
     * page counting from the left, i.e. this number is not aware of the reading
     * order!
     * </p>
     */
    public function get currentLogicalPage():uint {
        return currentPage_;
    }
    
    /**
     * Returns the number of the currently 'focused' page, i.e. the page the
     * book is opened on when there is no page turn active.
     * 
     * <p>
     * If a page is turned this will hold the future main page. If multiple
     * pages are turned it will be updated rapidly and always return
     * <i>current</i> main page.
     * </p>
     * 
     * <p>
     * This will always be an even number, i.e. the number of the page on the
     * right, starting the count at 0.
     * </p>
     * 
     * <p>
     * This is the "outer" page number, i.e. this number is not aware of the
     * reading order!
     * </p>
     */
    public function get currentPage():uint {
    	return l2r(currentPage_);
    }

    /**
     * Determine whether to clean up when the book is removed from stage or not.
     * The default is true. Note that removing the book from the stage then
     * renders the book unfunctional for further use!
     */
    public function get destroyOnRemove():Boolean {
        return destroyOnRemove_;
    }
    
    /**
     * Determine whether to clean up when the book is removed from stage or not.
     * The default is true. Note that removing the book from the stage then
     * renders the book unfunctional for further use!
     */
    public function set destroyOnRemove(destroy:Boolean):void {
        destroyOnRemove_ = destroy;
    }
    
    /**
     * Whether to currently allow mouse interaction with pages.
     */
    public function get draggingEnabled():Boolean {
        return draggingEnabled_;
    }

    /**
     * Whether to currently allow mouse interaction with pages.
     */
    public function set draggingEnabled(enabled:Boolean):void {
        draggingEnabled_ = enabled;
        if (!enabled) {
        	dragHandler.enabled = false;
        }
		else if ((helpWindow == null || !helpWindow.visible)
		      && (settingsDialog == null || !settingsDialog.visible))
        {
        	dragHandler.enabled = true;
        }
        if (blocker != null) {
            blocker.mouseEnabled = draggingEnabled_;
        }
    }

    /**
     * Get the current page flipping state of this instance (turning or not).
     * 
     * @see de.mightypirates.megazine.interfaces.Constants
     */
    public function get flipState():String {
        return flipState_;
    }

    /**
     * Tells whether the book is read from left to right (true) or right to left
     * (false). This might trhow a nullpointer exception if the settings have
     * not yet been loaded.
     */
    public function get leftToRight():Boolean {
        return settings.readingOrderLTR;
    }

    /**
     * The localizer instance used throughout the book to localize GUI
     * elements / page elements.
     */
    public function get localizer():Localizer {
        return localizer_;
    }

    /**
     * The mute state for all elements that support it.
     */
    public function get muted():Boolean {
        return isMuted_;
    }

    /**
     * Sets mute state for all elements that support it by firing a
     * MegaZineEvent.MUTE event.
     */
    public function set muted(mute:Boolean):void {
        isMuted_ = mute;
        // Then fire an event for all elements that are registered to it
        if (mute) {
            dispatchEvent(new MegaZineEvent(MegaZineEvent.MUTE));
        } else {
            dispatchEvent(new MegaZineEvent(MegaZineEvent.UNMUTE));
        }
        var so:SharedObject = SharedObject.getLocal("megazine3");
        so.data.isMuted = mute;
    }

    /**
     * Get the number of pages in the book.
     * 
     * @return the number of pages in the book.
     */
    public function get pageCount():uint {
        return pages.length;
    }

    /**
     * Get the default height for pages.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function get pageHeight():uint {
        return settings.pageHeight;
    }

    /**
     * Get the pages offset for the book, i.e. the number added to the actual
     * page number before it is displayed below the book.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function get pageOffset():int {
        return settings.pageOffset;
    }

    /**
     * Get the default width for pages.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function get pageWidth():uint {
        return settings.pageWidth;
    }

    /**
     * Get the current setting for reflection useage.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function get reflection():Boolean {
        return settings.useReflection;
    }

    /**
     * Set the reflection useage.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function set reflection(enabled:Boolean):void {
        settings.useReflection = enabled;
    }

    /**
     * Get the state of shadow useage for pages.
     * This might throw a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function get shadows():Boolean {
        return settings.pageUseShadows;
    }

    /**
     * Set the state of shadow useage for pages.
     * This might trhow a nullpointer exception if the settings have not yet
     * been loaded.
     */
    public function set shadows(enabled:Boolean):void {
        settings.pageUseShadows = enabled;
    }

    /**
     * Get the current state of this instance.
     * 
     * @see de.mightypirates.megazine.interfaces.Constants
     */
    public function get state():String {
        return state_;
    }

    /**
     * The underlying XML data used to describe the book, starting at the root
     * node (book). This is the raw form of the XML data as loaded from file.
     * This will return null if the XML data has not been loaded yet. The
     * xml will be completely interpreted after it was loaded, but changes to
     * this datastructure may have an effect, due to stored references
     * nontheless, so they are not recommended, to avoid inconsistencies with
     * other components accessing this variable later on.
     */
    public function get xml():XML {
        return xmlData;
    }

    /**
     * Get the current zoom state of this instance (open or closed).
     * 
     * @see de.mightypirates.megazine.interfaces.Constants
     */
    public function get zoomState():String {
        return zoomState_;
    }


    // ---------------------------------------------------------------------- //
    // Internal
    // ---------------------------------------------------------------------- //
    
    /**
     * Returns the display object container holding all page relevant display
     * objects.
     */
    internal function get pageContainer():Sprite {
        return pageContainer_;
    }

    /**
     * Set the current state of this instance, triggers notification.
     * 
     * @param state
     *          the new state for this instance
     */
    private function setState(_state:String):void {
        var e:MegaZineEvent = new MegaZineEvent(MegaZineEvent.STATUS_CHANGE, 0,
                _state, this.state_);
        this.state_ = _state;
        dispatchEvent(e);
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    // ---------------------------------------------------------------------- //
    // Getter
    // ---------------------------------------------------------------------- //
	
    /**
     * Converts relative paths to absolute paths, using the location of the swf
     * holding the megazine as the base location all paths are relative to.
     * If the url starts with one of the allowed protocol types assume the url
     * is already absolute and return it as it was, else add the absolute path
     * component and return it.
     * 
     * @param url
     *          the original path/url.
     * @param protocols
     *          array of allowed protocols that will be recognized. Per default
     *          the following protocols are recognized: http, https, file.
     *          Protocols must be defined with the completely, i.e. up to the
     *          point where the actual address starts.<br/>
     *          E.g. http is defined as http://
     * @return the absolute path to the location specified in the given url.
     */
    public function getAbsPath(url:String, protocols:Array = null):String {
        if (!protocols) protocols = ["http://", "https://", "file://"];
        for each (var prot:String in protocols) {
            if (url.search(prot) == 0) {
                return url;
            }
        }
        return absolutePath + url;
    }

    /**
     * Returns the element referred to by the given id. If no such element is
     * known the function returns null.
     * 
     * @param id
     *          the id of the element.
     * @return the element (the wrapper class, actually, so you'll have to check
     *          yourself if it's actually loaded.
     */
    public function getElementById(id:String):IElement {
        return idToElement[id];
    }

    /**
     * Returns the page with the given number. If the number is invalid, null is
     * returned.
     * 
     * <p>
     * This function is <i>not</i> reading order aware, i.e. the given number is
     * treated as an index, which is always the page number as if the book were
     * left to right, starting at 0.
     * </p>
     * 
     * @param page
     *          the number of the page to get. Must be between 0 and
     *          pageCount - 1.
     * @return the page with the given number, or null if the number is invalid.
     */
    public function getPage(page:uint):IPage {
        if (page < 0 || page >= pages.length) {
            return null;
        }
        return pages[page];
    }

    /**
     * Looks up the anchor associated with this page. If it exists, returns
     * that, if not it looks for the anchor of the opposite page. If that
     * doesn't exist, either, returns null.
     * 
     * <p>
     * This function is <i>not</i> reading order aware, i.e. the given number is
     * treated as an index, which is always the page number as if the book were
     * left to right, starting at 0.
     * </p>
     * 
     * @param page
     *          the page for which to look up the anchor.
     * @return the anchor associated with the given page.
     */
    public function getPageAnchor(page:uint):String {
    	// Ignore invalid pages.
    	if (page < 0 || page > pages.length) {
    		return null;
    	}
    	var even:Boolean = (page & 1) == 0;
    	var anchor:String = (pages[page] as Page).getAnchor(even);
    	if (anchor == null) {
    		// Look at the opposite page.
    		if (even) {
    			// Was even, look left
    			if (page - 1 > 0) {
    				anchor = (pages[page - 1] as Page).getAnchor(false);
    			}
    		} else {
    			// Was odd, look right
    			if (page + 1 < pages.length) {
    				anchor = (pages[page + 1] as Page).getAnchor(true);
    			}
    		}
    	}
    	return anchor;
    }

    /**
     * Gets the thumbnails for the left and right page for the given page.
     * 
     * @param page
     *          the page number for which to get the left and right page.
     * @return an array with the left page at 0 and the right at 1.
     */
    public function getThumbnailsForPage(page:int):Array {
        // Make it an even page number
        page += page & 1;
        // Request prioritized generation
        pageLoader.prioritizeThumbForPage(page);
        // Return bitmaps...
        return [pages[page - 1] != null ? (pages[page - 1] as Page).
                getPageThumbnail(false) : null, pages[page] != null
                        ? (pages[page] as Page).getPageThumbnail(true)
                        : null];
    }

    // ---------------------------------------------------------------------- //
    // Loading
    // ---------------------------------------------------------------------- //
	
    /**
     * Begin loading the megazine. Only has an effect while the megazine is in
     * the PREINIT state. Starts loading the xml file with the megazine
     * configuration and parses it plus generates all pages defined. Then loads
     * the gui and sounds.
     * 
     * <p>
     * After that the state is changed to READY. At the same time the actual
     * content for the pages is loaded.
     * </p>
     * 
     * <p>
     * If not specified otherwise in the constructor, this method is
     * automatically called as soon as the megazine object is added to the
     * stage.
     * </p>
     * 
     * @param xml
     *          XML data may be given directly, in which case it won't try to
     *          load external data (which might have been specified in the
     *          constructor).
     */
    public function load(xml:XML = null):void {
        if (!stage) {
            throw new Error("Must be added to stage first.");
        }
		MegaZine.stage = stage;
		
        if (state == Constants.MEGAZINE_STATUS_PREINIT
                || state == Constants.MEGAZINE_STATUS_ERROR)
        {
			
			
            Logger.log("MegaZine", "MegaZine Version " + VERSION
                    + " initialized.", Logger.TYPE_SYSTEM_NOTICE);
			
			
            // Listen to removed from stage to cancel loading
            cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
                    handleRemoveFromStage);
			
            // Keyboard event listeners (arrow navigation)
            cleanUpSupport.make(stage, KeyboardEvent.KEY_DOWN,
                    handleKeyPressed);
			
            // Redrawing
            cleanUpSupport.make(this, Event.ENTER_FRAME, redraw);
			
            // Get absolute path
            // Replace backslashes with slashes for ie in windows -.-
            absolutePath = loaderInfo.loaderURL.replace(/[\\]/g, "/");
            absolutePath = absolutePath.slice(0, absolutePath.indexOf("?"));
            absolutePath = absolutePath.slice(0, absolutePath.lastIndexOf("/"))
                    + "/";
            xmlPath = getAbsPath(xmlPath);
            uiPath = getAbsPath(uiPath);
			
            // Create graphics library (unloaded for now)
            library = new Library(uiPath);
			
            if (xml == null) {
			
                // Begin loading the xml data
                var xmlLoader:URLLoader = new URLLoader();
                cleanUpSupport.make(xmlLoader, Event.COMPLETE, handleXmlLoadComplete);
                cleanUpSupport.make(xmlLoader, IOErrorEvent.IO_ERROR,
                        handleXmlLoadError);
				
				
                Logger.log("MegaZine", "Begin loading XML data from file '"
                        + Helper.trimString(xmlPath, 40) + "'.");
				
				
                setState(Constants.MEGAZINE_STATUS_LOADING);
				
                try {
                    // Browser based? If yes, avoid cache.
                    var delimiter:String =
                            xmlPath.indexOf("?") >= 0 ? "&" : "?";
                    switch (Capabilities.playerType.toLowerCase()) {
                        case "plugin":
                        case "activex":
                            // Browser, random.
                            xmlLoader.load(new URLRequest(xmlPath + delimiter
                                    + "r="
                                    + Math.round(Math.random() * 1000000)));
                            break;
                        default:
                            // Standalone player or IDE.
                            xmlLoader.load(new URLRequest(xmlPath));
                            break;
                    }
                } catch (er:Error) {
                    Logger.log("MegaZine", "Could not load XML data: "
                            + er.toString(), Logger.TYPE_ERROR);
                    createErrorMessage(
                            "<b>Error</b><br/>Could not load XML data: "
                            + er.toString());
                    setState(Constants.MEGAZINE_STATUS_ERROR);
                }
            } else {
				
                // XML given, no need to load.
                Logger.log("MegaZine", "XML given via argument.");
				
				
                // Initialize the xml object with the loaded data.
                XML.ignoreComments = true;
                XML.ignoreWhitespace = true;
                XML.ignoreProcessingInstructions = false;
				
                // Copy given xml (encapsulation)
                xmlData = new XML(xml);
				
                // Parse it.
                parseXml();
            }
        } else {
            Logger.log("MegaZine", "MegaZine already loaded or loading.");
        }
    }

    /**
     * Load the gui.
     */
    private function loadGUI():void {
		
        Logger.log("MegaZine", "Begin loading interface graphics from '"
                + Helper.trimString(uiPath, 30) + "'.");
		
        cleanUpSupport.make(library, MegaZineEvent.LIBRARY_COMPLETE,
                handleLibraryComplete);
        cleanUpSupport.make(library, MegaZineEvent.LIBRARY_ERROR,
                handleLibraryError);
        library.load();
    }

    /**
     * Scoping workaround... load with a slight to delay so as not to overload
     * the vm.
     * 
     * @param xmlLoader
     *          loader to use.
     * @param from
     *          file to load.
     */
    private function loadLocalizationDelayed(xmlLoader:URLLoader,
            from:URLRequest):void
    {
        setTimeout(function():void { 
            xmlLoader.load(from); 
        }, 250 + (int)(Math.random() * 250));
    }

    /**
     * Precaller triggering the page loading...
     */
    private function loadPageContent():void {
        // Position pages.
        updatePagePosition(true);
        
        // Begin loading as many pages parallely as allowed.
        pageLoader = new PageLoader(this, currentPage_, pages, dragHandler,
                settings);
        
        // Set state to ready
        setState(Constants.MEGAZINE_STATUS_READY);
        
        // Log it...
        Logger.log("MegaZine", "Engine ready and beginning loading elements.");
    }


    // ---------------------------------------------------------------------- //
    // Setup
    // ---------------------------------------------------------------------- //

    /**
     * Called once the xml is completely loaded. Starts parsing the loaded the
     * loaded xml, loading the settings, performing basic setup and initializing
     * the chapters + pages.
     */
    private function parseXml():void {
		
        // And begin parsing it
        Logger.log("MegaZine", "Begin parsing XML data.");
		
		
        // Settings
        Logger.log("MegaZine", "  Parsing settings...");
		
        // Initialize global settings.
        settings = new Settings(this, xmlData);
		
        // Specially parsed settings.
		
        // Use localized strings if given
        var langAr:Array = (Helper.validateString(xmlData.@lang, "en").
                replace(/ /g, "") || "en").split(",");
		
        // Create the localizer.
        localizer_ = new Localizer(langAr[0], settings.langWarn);
		
		// Then load all languages.
        for each (var langID:String in langAr) {
            // Build url
            var langPath:String = getAbsPath(
                    settings.langPath + "lang." + langID + ".xml");
            // Browser based? If yes, avoid cache.
            var delimiter:String = langPath.indexOf("?") >= 0 ? "&" : "?";
            switch (Capabilities.playerType.toLowerCase()) {
                case "plugin":
                case "activex":
                    // Browser, random.
                    langPath += delimiter + "r="
                            + Math.round(Math.random() * 1000000);
                    break;
            }
			
            Logger.log("MegaZine", "Begin loading localized strings from file '"
                    + Helper.trimString(langPath, 40) + "'.");
			
            // Begin loading the xml data
            var xmlLoader:URLLoader = new URLLoader();
            cleanUpSupport.make(xmlLoader, Event.COMPLETE,
                    handleLocalizationComplete);
            cleanUpSupport.make(xmlLoader, IOErrorEvent.IO_ERROR,
                    function(e:IOErrorEvent):void {
                        Logger.log("MegaZine",
                                "Could not load XML data for localization: "
                                        + e.text, Logger.TYPE_WARNING);
                    });
            try {
                // Load delayed, so the visual setup does not get slowed down by
                // loading the xml files.
                loadLocalizationDelayed(xmlLoader, new URLRequest(langPath));
            } catch (er:Error) {
                Logger.log("MegaZine",
                        "Could not load XML data for localization: "
                        + er.toString(), Logger.TYPE_WARNING);
            }
        }
		
        // If it's only one language do not show button in navigation
        settings.buttonHide["language"] =
                Boolean(settings.buttonHide["language"]) || (langAr.length < 2);
		
        // Settings end.
        Logger.log("MegaZine", "  Done parsing settings.");
		
		
        // Do the basic setup, now that we have the settings.
        Logger.log("MegaZine", "  Initializing variables and graphics...");
		
        setupGraphics();
		
        // Initialization end.
        Logger.log("MegaZine", "  Done initializing...");
		
		
        Logger.log("MegaZine", "  Parsing chapters and pages...");
		
        // Loop through all chapters.
        for each (var chapter:XML in xmlData.elements("chapter")) {
            // Create the chapter.
            if (leftToRight) {
                addChapter(chapter);
            } else {
            	addChapterAt(chapter, 0);
            }
            
            Logger.log("MegaZine", "    Parsing chapter... done.");
        }
		
        // Startpage given? If yes try to go to it.
        currentPage_ = Helper.validateInt(xmlData.@startpage, 1, 1,
                pages.length + 1) - 1;
        // Make sure it's an even number...
        currentPage_ += currentPage_ & 1;
        // Invert if left to right.
        currentPage_ = l2r(currentPage_);
        
        // Pass the read settings on to the drag handler
        dragHandler.setup(settings, currentPage_);
		
		
        Logger.log("MegaZine",
                "  Done parsing and instantiating chapters and pages.");
		
		
        Logger.log("MegaZine", "Done parsing XML.");
		
        // Begin loading gui
        loadGUI();
    }

    /**
     * Registers an element with a certain id, to be referred to by other
     * actionscript code. If an element with that ID was already registered it
     * will be overwritten.
     * 
     * @param element
     *          the element to register.
     * @param id
     *          the id of the element by which to reference it.
     */
    internal function registerElement(element:IElement, id:String):void {
        idToElement[id] = element;
    }

    /**
     * Allow pages containing images with hires images belonging to a gallery to
     * register those images. In general, it can be used to register gallery
     * images which can then be cycled through when opening a gallery via the
     * openZoom function.
     * 
     * @param gallery
     *          the name of the gallery.
     * @param page
     *          the page on which the image resides.
     * @param elementNumber
     *          the number of the element representing the gallery image in
     *          its containing page.
     * @param paths
     *          the (localized) urls to the image. Entry format:
     *          paths[langID] = pathURL
     */
    private function registerGalleryImage(gallery:String, page:uint,
            elementNumber:uint, paths:Dictionary):void
    {
        // Create array for gallery if it does not exist
        if (galleries[gallery] == null) {
            galleries[gallery] = new Dictionary();
        }
        // Create array for element entries if it does not exist
        if (galleries[gallery][page] == null) {
            galleries[gallery][page] = new Dictionary();
        }
        // Set or update
        galleries[gallery][page][elementNumber] = paths;
    }

    /**
     * Auxiliary function for parseXML, sets up graphics and such.
     */
    private function setupGraphics():void {
        // Click blocker in border area.
        blocker = new Sprite();
        blocker.mouseEnabled = draggingEnabled_;
        blocker.graphics.beginFill(0xFFFFFF, 0);
        var dragRange:uint = settings.dragRange;
        if (settings.ignoreSides) {
            blocker.graphics.drawRect(0, 0, dragRange, dragRange);
            blocker.graphics.drawRect(0, pageHeight - dragRange,
                    dragRange, dragRange);
            blocker.graphics.drawRect(pageWidth * 2 - dragRange, 0,
                    dragRange, dragRange);
            blocker.graphics.drawRect(pageWidth * 2 - dragRange,
                    pageHeight - dragRange, dragRange, dragRange);
        } else {
            blocker.graphics.drawRect(0, 0, dragRange, pageHeight);
            blocker.graphics.drawRect(pageWidth * 2 - dragRange, 0,
                    dragRange, pageHeight);
        }
        blocker.graphics.endFill();
        pageContainer_.addChild(blocker);
		
        // Draw the background fader
        if (Helper.validateBoolean(xmlData.@bggradient, true)) {
            var faderMatrix:Matrix = new Matrix();
            faderMatrix.createGradientBox(pageWidth * 2 + 200, pageHeight * 0.3,
                    Math.PI * 0.5, -100, pageHeight * 0.9);
            backgroundFader = new Shape();
            backgroundFader.graphics.beginGradientFill(GradientType.LINEAR,
                    [0xFFFFFF, 0xFFFFFF], [0.1, 0], [0, 255], faderMatrix);
            backgroundFader.graphics.drawRect(-100, pageHeight * 0.9,
                    pageWidth * 2 + 200, pageHeight * 0.3);
            backgroundFader.graphics.endFill();
			
            // Mask for the background fader
            var backgroundFaderMask:Shape = new Shape();
            var faderMaskMatrix:Matrix = new Matrix();
            faderMaskMatrix.createGradientBox(pageWidth * 2 + 200,
                    pageHeight * 0.3, 0, -100, pageHeight * 0.9);
            backgroundFaderMask.graphics.beginGradientFill(GradientType.LINEAR,
                    [0xFF00FF, 0xFF00FF, 0xFF00FF, 0xFF00FF], [0, 1, 1, 0],
                    [0, 40, 215, 255], faderMaskMatrix);
            backgroundFaderMask.graphics.drawRect(-100, pageHeight * 0.9,
                    pageWidth * 2 + 200, pageHeight * 0.3);
            backgroundFaderMask.graphics.endFill();
			
            addChildAt(backgroundFader, 0);
            addChild(backgroundFaderMask);
			
            backgroundFader.cacheAsBitmap = true;
            backgroundFaderMask.cacheAsBitmap = true;
            backgroundFader.mask = backgroundFaderMask;
        }
		
        // Reflection bitmapdata and bitmap
        if (settings.reflectionHeight > 0) {
            reflectionData = new BitmapData(pageWidth * 2,
                    settings.reflectionHeight, true, 0);
            reflectionImage = new Bitmap(reflectionData);
            // Position the reflection and add it to the container.
            reflectionImage.y = pageHeight;
            reflectionImage.alpha = 0.4;
            pageContainer_.addChildAt(reflectionImage, 0);
        }
		
		
        // Load an image left to the cover (page -1).
        var prePageURL:String = Helper.validateString(xmlData.@prepage, "");
        var prepage:Loader;
        if (prePageURL != "") {
            // Try to load it right now...
            prepage = new Loader();
            prePageURL = getAbsPath(prePageURL);
            cleanUpSupport.make(prepage.contentLoaderInfo,
                    IOErrorEvent.IO_ERROR,
                    function(e:IOErrorEvent):void {
                        Logger.log("MegaZine", "Could not load prepage: "
                                + e.text, Logger.TYPE_WARNING);
                    });
            cleanUpSupport.make(prepage.contentLoaderInfo, Event.COMPLETE,
                    function(e:Event):void {
                        if (prepage.getChildAt(0) is AVM1Movie
                                || prepage.getChildAt(0) is MovieClip)
                        {
                            // Try setting it up.
                            try {
                                // Try everything.
                                prepage.getChildAt(0)["megazineSetup"](this,
                                        library);
                            } catch (e:Error) {
                                try {
                                    // Only megazine.
                                    prepage.getChildAt(0)
                                            ["megazineSetup"](this);
                                } catch (e:Error) { 
                                }
                            }
                        }
                    });
            try {
                prepage.load(new URLRequest(prePageURL),
                        new LoaderContext(true));
            } catch (er:Error) {
                Logger.log("MegaZine", "Could not load prepage: "
                        + er.toString(), Logger.TYPE_WARNING);
            }
            var prepageMask:Shape = new Shape();
            prepageMask.graphics.beginFill(0xFF00FF);
            prepageMask.graphics.drawRect(0, 0, pageWidth, pageHeight);
            prepageMask.graphics.endFill();
            prepage.mask = prepageMask;
            pageContainer_.addChildAt(prepageMask, 0);
            pageContainer_.addChildAt(prepage, 0);
        }
		
        // Load an image right to the back cover (pagesTotal + 1).
        var postPageURL:String = Helper.validateString(xmlData.@postpage, "");
        if (postPageURL != "") {
            // Try to load it right now...
            var postpage:Loader = new Loader();
            postPageURL = getAbsPath(postPageURL);
            cleanUpSupport.make(postpage.contentLoaderInfo,
                    IOErrorEvent.IO_ERROR,
                    function(e:IOErrorEvent):void {
                        Logger.log("MegaZine", "Could not load postpage: "
                                + e.text, Logger.TYPE_WARNING);
                    });
            cleanUpSupport.make(postpage.contentLoaderInfo, Event.COMPLETE,
                    function(e:Event):void {
                        if (postpage.getChildAt(0) is AVM1Movie
                                || postpage.getChildAt(0) is MovieClip)
                        {
                            // Try setting it up.
                            try {
                                // Try everything.
                                postpage.getChildAt(0)
                                        ["megazineSetup"](this, library);
                            } catch (e:Error) {
                                try {
                                    // Only megazine.
                                    postpage.getChildAt(0)
                                            ["megazineSetup"](this);
                                } catch (e:Error) { 
                                }
                            }
                        }
                    });
            try {
                postpage.load(new URLRequest(postPageURL),
                        new LoaderContext(true));
            } catch (er:Error) {
                Logger.log("MegaZine", "Could not load postpage: "
                        + er.toString(), Logger.TYPE_WARNING);
            }
            var postpageMask:Shape = new Shape();
            postpageMask.graphics.beginFill(0xFF00FF);
            postpageMask.graphics.drawRect(pageWidth, 0, pageWidth, pageHeight);
            postpageMask.graphics.endFill();
            postpage.mask = postpageMask;
            postpage.x = pageWidth;
            pageContainer_.addChildAt(postpageMask, 0);
            pageContainer_.addChildAt(postpage, 0);
        }
    }


    // ---------------------------------------------------------------------- //
    // Dynamic page adding / removal
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new chapter, returning a reference to the chapter. The chapter
     * will be added at the end.
     * 
     * @param xml
     *          the xml describing the chapter.
     * @return a reference to the created chapter.
     */
    public function addChapter(xml:XML = null,
            updateGUI:Boolean = true):IChapter
    {
        return addChapterAt(xml, -1, updateGUI);
    }

    /**
     * Creates a new chapter, returning a reference to the chapter. Per default,
     * a chapter with settings copied from the book is created and added at the
     * end.
     * 
     * @param xml
     *          the xml describing the chapter.
     * @param index
     *          the position at which to insert the chapter. This is the number
     *          of the chapter in front of which the new chapter is added.
     * @param updateGUI
     *          refresh the GUI when the chapter was added.
     * @return a reference to the created chapter.
     */
    public function addChapterAt(xml:XML = null, index:int = -1,
            updateGUI:Boolean = true):IChapter
    {
        // Validate input
        xml ||= new XML("<chapter/>");
        if (index < 0 || index > chapters.length) {
            index = chapters.length;
        }
		
		var pageIndex:uint = (index < chapters.length)
		      ? chapters[index].firstPage
		      : l2r(pages.length);
		
        // Create the chapter
        var chapter:IChapter = new Chapter(this, xml, settings);
        chapters.splice(index, 0, chapter);
		
        // Check for an anchor.
        var anchor:String = Helper.validateString(xml.@anchor, null);
        if (anchor) {
            if (RESERVED_ANCHORS.indexOf(anchor) >= 0
                    || int(anchor) > 0 || anchor == "0")
            {
                Logger.log("MegaZine",
                        "Invalid anchor name (reserved name or numeric): "
                        + anchor, Logger.TYPE_WARNING);
            } else {
                anchors[anchor] = {isPage : false, c : chapter };
            }
        }
		
		// Create batch pages.
		appendBatchPages(xml);
		
        // Last created page half.
        var pageData:XML;
        
        // Insert pages defined in the xml
        for each (var pageXML:XML in xml.elements("page")) {
            // Every odd page create the page object.
            if (pageData != null) {
            	if (leftToRight) {
                    if (chapter.lastPage >= 0) {
                        addPageAt(pageData + pageXML, chapter.lastPage + 2,
                                true, false);
                    } else {
                        addPageAt(pageData + pageXML, pageIndex, true, false);
                    }
            	} else {
            		if (chapter.firstPage >= 0) {
            		    addPageAt(pageXML + pageData, chapter.firstPage,
            		          false, false);
            		} else {
            			addPageAt(pageXML + pageData, pageIndex, true, false);
            		}
            	}
                pageData = null;
            } else {
                pageData = pageXML;
            }
        }
		
		// If a half page is left...
        if (pageData != null) {
        	// Force insert one page to not lose a user defined page.
        	if (leftToRight) {
                addPageAt(pageData + new XML("<page/>"), chapter.lastPage + 2,
                        true, false);
        	} else {
        		addPageAt(new XML("<page/>") + pageData, chapter.firstPage,
        		        false, false);
        	}
        }
		
		if (updateGUI) {
            // Update fold effects
            for each (var p:Page in this.pages) {
                p.initFoldFX();
            }
    		
            // Update the navigation bar if possible.
            if (navigation != null) {
                updateButtonColors();
                navigation.layoutBar();
                navigation.updatePageNumbers();
            }
		}
        
        return chapter;
    }
    
    /**
     * Takes a chapter xml node and checks if the @pages attribute it set. If
     * so, it creates the so defined pages and appends the batch pages as
     * page-tag children.
     * 
     * <p>
     * The elements are appended to the same xml object that is passed as an
     * argument, meaning it's an in place modification.
     * </p>
     * 
     * @param xml
     *          the chapter xml to complete.
     */
    private function appendBatchPages(xml:XML):void {
        // Check if the chapter should be batch filled.
        var pageBatchRaw:Array = Helper.validateString(xml.@pages, "").
                split("?");
        var pageBatchSettings:String = "";
        if (pageBatchRaw.length > 1) {
            // More options...
            for (var charpos:int = 0;
                    charpos < pageBatchRaw[1].length;
                    ++charpos )
            {
                switch (pageBatchRaw[1].charAt(charpos)) {
                    case "a":
                        pageBatchSettings += " aa=\"true\"";
                        break;
                    case "b":
                        pageBatchSettings += " showbutton=\"false\"";
                        break;
                    case "n":
                        pageBatchSettings += " nocache=\"true\"";
                        break;
                    case "s":
                        pageBatchSettings += " static=\"true\"";
                        break;
                }
            }
        }
        
        // Build subpage XML based on the pages attribute.
        var pageBatch:Array = pageBatchRaw[0].split("|");
        if (pageBatch[0] != "") {
            // See if there is a numeric range given.
            var loopMatch:Function =
                    function(raw:String, repl:Array, list:Array):void {
                        repl = ArrayUtil.copyArray(repl);
                        var range:Array = repl.shift().replace("[", "").
                                replace("]", "").split("-");
                        if (range.length == 0) {
                            return;
                        } else if (range.length == 1) {
                            range.unshift(1);
                        }
                        for (var i:int = int(range[0]);i <= int(range[1]); i++)
                        {
                            if (repl.length == 0) {
                                list.push(
                                        [raw.replace(/\[\d+(\-\d+)?(|.?)?\]/,
                                                i),
                                        raw.replace(/\[\d+(\-\d+)?(|.?)?\]/,
                                                i + pageBatch[1])]);
                            } else {
                                loopMatch(raw.replace(/\[\d+(\-\d+)?(|.?)?\]/,
                                        i), repl, list);
                            }
                        }
                    };
            var urls:Array = new Array();
            loopMatch(pageBatch[0],
                    pageBatch[0].match(/\[\d+(\-\d+)?(|.?)?\]/g), urls);
            // Create the pages.
            var gallery:String = "__generated"
                    + (Math.random() * 1000000).toString()
                    + (new Date().getTime()).toString();
            for each (var imgURL:Array in urls) {
                var child:String = "<img";
                child += " src=\"" + imgURL[0] + "\"";
                child += " width=\"" + pageWidth + "\"";
                child += " height=\"" + pageHeight + "\"";
                if (pageBatch.length > 1 && imgURL[1] != "") {
                    child += " hires=\"" + imgURL[1] + "\"";
                    child += " iconpos=\"center\"";
                    child += " gallery=\"" + gallery + "\"";
                }
                child += pageBatchSettings;
                child += "/>";
                xml.appendChild(new XML("<page>" + child + "</page>"));
            }
        }
    }

    /**
     * Creates a new page and adds it to the end of the book.
     * 
     * <p>
     * By default the GUI is updated after adding a page, i.e. the number of
     * page buttons in the navigation bar is adjusted. When adding multiple
     * pages it might be a good idea only updating after the last insert.
     * </p>
     * 
     * @param xml
     *          the xml describing the page.
     * @param updateGUI
     *          update the gui after adding the page.
     * @return a reference to the created page.
     */
    public function addPage(xml:XMLList = null,
            updateGUI:Boolean = true):IPage {
        return addPageAt(xml, -1, false, updateGUI);
    }

    /**
     * Creates a new page in the given chapter. If no chapter is given, the
     * page is created in the last chapter. If the chapter is not part of
     * this book, an exception will be thrown.
     * 
     * <p>
     * By default the GUI is updated after adding a page, i.e. the number of
     * page buttons in the navigation bar is adjusted. When adding multiple
     * pages it might be a good idea only updating after the last insert.
     * </p>
     * 
     * @param xml
     *          the xml describing the page.
     * @param chapter
     *          the chapter into which to add the page.
     * @param updateGUI
     *          update the gui after adding the page.
     * @return a reference to the created page.
     */
    public function addPageIn(xml:XMLList = null,
            chapter:IChapter = null, updateGUI:Boolean = true):IPage {
        if (chapter == null) {
            return addPage(xml, updateGUI);
        } else if (chapters.indexOf(chapter) < 0) {
            // Chapter not part of this book
            throw new ArgumentError("Chapter not part of this book.");
        } else {
            return addPageAt(xml, chapter.lastPage + 2, true, updateGUI);
        }
    }

    /**
     * Create a new page. Per default, an empty page is created. Note that
     * this always creates "physical pages", i.e. pages consisting of a
     * back and a front. If an odd number of &lt;page&gt; elements is given,
     * one blank page is forcefully injected in the end.
     * 
     * <p>
     * The page will be inserted before the page with the given index, and
     * into the chapter in which the page at which the page is inserted is;
     * if the page is added to the back, the new page is added to the last
     * chapter.
     * </p>
     * 
     * <p>
     * To add a page at the end of a chapter, use the addPageIn function or set
     * the prevChapter parameter to true.
     * </p>
     * 
     * <p>
     * The prevChapter parameter is used to determine into which chapter to add
     * the new page. If set to false (the default) the page is added into the
     * same chapter as the page it "replaces", i.e. if you enter a page at
     * position 10, then it is added to the same chapter as the old page 10.
     * If set to true, it is added to the chapter of the previous page, or, if
     * one exists, a blank chapter before the one of the page being "replaced".
     * <br/>
     * If the page is added to the end of the book, the page is either added to
     * a blank chapter in the end, if one exists, or prevChapter is implicitly
     * true.<br/>
     * Equally, when adding at the beginning and prevPage is true, the page is
     * added to a blank chapter in the beginning, if it exists, or prevChapter
     * is implicitly false.
     * </p>
     * 
     * <p>
     * If no index is given the new page is created at the end of the book.
     * </p>
     * 
     * <p>
     * By default the GUI is updated after adding a page, i.e. the number of
     * page buttons in the navigation bar is adjusted. When adding multiple
     * pages it might be a good idea only updating after the last insert.
     * </p>
     * 
     * @param xml
     *          the xml describing the page.
     * @param index
     *          the position at which to insert the page.
     * @param prevChapter
     *          add the page to the chapter of the previous page instead.
     * @param updateGUI
     *          update the gui after adding the page.
     * @return a reference to the created page.
     */
    public function addPageAt(xml:XMLList = null, index:int = -1,
            prevChapter:Boolean = false, updateGUI:Boolean = true):IPage
    {
    	// Check if there are any chapters.
    	if (chapters.length == 0) {
    		throw new IllegalOperationError("Invalid state, no chapters" +
    		      " present. Add a chapter first.");
    	}
    	
        // Validate input
        if (index < 0 || index > pages.length) {
            index = pages.length;
        } else {
        	// Force an even page number.
        	index += index & 1;
        }
        
        // Find chapter to add in.
        var chapter:Chapter = null;
        // Get right chapter.
        if (index < pages.length) {
        	chapter = (pages[index] as Page).chapter;
        }
        // At this point rightChapter contain the chapter of the page being
        // moved back, or null, if no such chapter exits.
        // This null case happens if the page is in the last chapter of the
        // book. Therefore:
        // When adding to the previous chapter, check if the right chapter is
        // null. If it is, add to the last chapter. If it isn't, add to the
        // chapter one before of the right chapter.
        // When adding to the next chapter, check if the right chapter is null.
        // If it is, add to the last chapter. If it isn't, add to the right
        // chapter.
        if (prevChapter) {
        	// Left to current.
        	if (chapter != null) {
                // Right given, take the one left to it (if possible - if the
                // right chapter is the first chapter, add to it).
                chapter = chapters[Math.max(0,
                        chapters.indexOf(chapter) - 1)];
        	} else {
                // Right is null -> end of book, add to last chapter.
                chapter = chapters[chapters.length - 1];
        	} 
        } else {
        	// Right of current.
            if (chapter == null) {
                // No right chapter, add to last chapter in book
                chapter = chapters[chapters.length - 1];
            }
            // The != null case is chapter = chapter.
        }
        
        // Just a quick check. If both are null something is wrong, because the
        // some page is not part of any chapter...
        if (chapter == null) {
            throw IllegalOperationError("Invalid state, some pages are not " +
                    "part of a chapter. If you get this error message, " +
                    "please report it, because this should not be possible " +
                    "to happen.");
        }
        
        // Get xml data for the two pages.
        var pageData:Array = new Array(new XML("<page/>"), new XML("<page/>"));
        if (xml != null && xml.length() > 0 && xml[0].name() == "page") {
            pageData[0] = xml[0];
        }
        if (xml != null && xml.length() > 1 && xml[1].name() == "page") {
            pageData[1] = xml[1];
        }
		
        // Create page
        var pageContent:Array = new Array(new Sprite(), new Sprite());
        var pageShadow:Array = new Array(new Sprite(), new Sprite());
		
        var page:IPage = new Page(this, localizer_, library, chapter, index,
                pageData, pageContent, pageShadow, settings);
		
		// Add completion event listener.
        page.addEventListener(MegaZineEvent.PAGE_COMPLETE, handlePageLoaded);
        
        // Add the objects to the stage.
        var insertAt:uint = pages.length - index;
        pagesEven.addChildAt(pageContent[0], insertAt);
        pagesEven.addChildAt(pageShadow[0], insertAt);
        pagesOdd.addChildAt(pageContent[1], index);
        pagesOdd.addChildAt(pageShadow[1], index);
		
        // Make space at the given slot(s) and adjust values.
        pages.length += 2;
        for (var i:int = pages.length - 1; i >= index + 2; --i) {
            // Change page number in Page instance
            (pages[i - 2] as Page).setNumber(i);
            // Move page in page array
            pages[i] = pages[i - 2];
            // Change page number in gallery
            for each (var gallery : Dictionary in galleries) {
                if (gallery[i - 2] != null) {
                    gallery[i] = gallery[i - 2];
                    delete gallery[i - 2];
                }
            }
        }
        pages[index] = page;
        pages[index + 1] = page;
        
        // Adjust current page number if necessary.
		if (!leftToRight && page.getNumber(true) <= currentPage_) {
            currentPage_ += 2; 
        }
        
        // Building the gallery... check for img elements. Also build anchors.
        for (var id:int = 0; id < 2; ++id) {
			// Register elements with gallery if possible.
			addPageElementsToGallery(page.getNumber(id == 0), pageData[id]);
			
            // Check if there is an anchor, if so register it.
            var anchor:String = Helper.validateString(pageData[id].@anchor, "");
            if (anchor != "") {
                anchors[anchor] = { isPage : true, p : page, even : (id == 0) };
            }
        }
		
        // Add to chapter
        chapter.addPage(page);
        
        // Register with draghandler
        dragHandler.registerPage(page);
        
        // Update the navigation bar if possible.
        if (updateGUI) {
            // Update fold effects
            for each (var p:Page in pages) {
                p.initFoldFX();
            }
            // Update navbar
        	if (navigation != null) {
                updateButtonColors();
                navigation.layoutBar();
                navigation.updatePageNumbers();
        	}
        	// Page positions...
        	updatePagePosition();
        }
		
        return page;
    }

    /**
     * Helper function when adding pages. Checks every element in the page's
     * xml if it's an image with a hires version set, and if so registers it
     * with the gallery.
     * 
     * @param pageNumber
     *          the number of the page for which to register it.
     * @param pageXml
     *          the xml data of the (half) page.
     */
    private function addPageElementsToGallery(pageNumber:uint, pageXml:XML):void
    {
        var elementNumber:int = 0;
        for each (var element:XML in pageXml.elements("img")) {
            // Extract gallery data.
            
            // Check gallery name
            var galleryName:String =
                    Helper.validateString(element.@gallery, "");
            if (galleryName != "") {
                var defLang:String = localizer_.defaultLanguage;
                // Find localized src paths (for {src} template variable).
                // Also search in children to override attribute.
                var srcPaths:Dictionary = new Dictionary();
                // The one from the attribute
                srcPaths[defLang] = Helper.validateString(element.@src, "");
                // Localized ones
                for each (var src:XML in element.elements("src")) {
                    var currSrcLang:String =
                            Helper.validateString(src.@lang, "");
                    var currSrcPath:String = Helper.validateString(src, "");
                    if (currSrcLang == "" || currSrcPath == "") continue;
                    srcPaths[currSrcLang] = currSrcPath.substr(0,
                            currSrcPath.lastIndexOf("."));
                }
                // Now get the actual hires path(s)
                var hiresPaths:Dictionary = new Dictionary();
                // Check attribute first using it for the default language
                var attributeHires:String =
                        Helper.validateString(element.@hires, "");
                hiresPaths[defLang] = getAbsPath(attributeHires.
                        replace("{src}", srcPaths[defLang]));
                // Then check child tags
                for each (var locHires:XML in element.elements("hires")) {
                    var locLang:String =
                            Helper.validateString(locHires.@lang, "");
                    var locValue:String =
                            Helper.validateString(locHires, "");
                    if (locLang == "" || locValue == "") continue;
                    // Localized source or default one if none is found
                    var locSrc:String = srcPaths[locLang]
                            || srcPaths[defLang];
                    hiresPaths[locLang] =
                            getAbsPath(locValue.replace("{src}", locSrc));
                }
                // Now hiresPaths maps language ids to paths, using the
                // default base path where no localized variant is available
                // for the template {src}.
                
                // Register the image
                registerGalleryImage(galleryName, pageNumber, elementNumber,
                        hiresPaths);
            }
            elementNumber++;
        }
    }

    /**
     * Removes the given chapter and all its pages from the book.
     * 
     * @param chapter
     *          the chapter to remove.
     * @param updateGUI
     *          update the gui after removing the chapter or not.
     */
    public function removeChapter(chapter:IChapter,
            updateGUI:Boolean = true):void
    {
        throw IllegalOperationError("Not yet implemented.");
        // TODO call removePage for all pages in this chapter, remove chapter
//        if (updateGUI) {
//            // Update fold effects
//            for each (var p:Page in pages) {
//                p.initFoldFX();
//            }
//            // Update navbar
//            if (navigation != null) {
//                updateButtonColors();
//                navigation.layoutBar();
//                navigation.updatePageNumbers();
//            }
//            // Page positions...
//            updatePagePosition();
//        }
    }

    /**
     * Removes the given page from the book.
     * 
     * @param page
     *          the page to remove.
     * @param updateGUI
     *          update the gui after removing the page or not.
     */
    public function removePage(page:IPage, updateGUI:Boolean = true):void {
    	throw IllegalOperationError("Not yet implemented.");
    	// TODO cleanup, remove pages from array, kill listeners, call their
    	// respective cleanup etc
    	// (page as Page).destroy();
//        if (updateGUI) {
//            // Update fold effects
//            for each (var p:Page in pages) {
//                p.initFoldFX();
//            }
//            // Update navbar
//            if (navigation != null) {
//                updateButtonColors();
//                navigation.layoutBar();
//                navigation.updatePageNumbers();
//            }
//            // Page positions...
//            updatePagePosition();
//        }
    }

    // ---------------------------------------------------------------------- //
    // Page navigation functions
    // ---------------------------------------------------------------------- //
	
    /**
     * Turn to the first page of the book.
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * <p>
     * This function is aware of the reading order.
     * </p>
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function firstPage(instant:Boolean = false):void {
        gotoPage(0, instant);
    }
	
    /**
     * Go to the page with the specified anchor as specified in the xml. Chapter
     * anchors are handled via this method as well, because their anchors are
     * just mapped to their first page.
     * 
     * <p>
     * If there is no such anchor it is checked whether it is a predefined
     * anchor. Predefined anchors are: first, last, next, prev.
     * </p>
     * 
     * <p>
     * If it is no predefined anchor it is checked whether a number was passed,
     * and ich yes it is interpreted as a page number. Note that those numbers
     * are always interpreted as "indexes", i.e. starting at 0. They will be
     * appropriatly interpreted for right to left books, i.e. page 0 is at the
     * right end of the book.
     * </p>
     * 
     * <p>
     * If that fails too, nothing will happen.
     * </p>
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * @param id
     *          the anchor id, predefined anchorname or page number.
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function gotoAnchor(id:String, instant:Boolean = false):void {
        if (anchors[id] != undefined) {
            var anchor:Object = anchors[id];
            if (anchor.isPage) {
                gotoPage((anchor.p as Page).getNumber(anchor.even), instant);                	 
            } else {
                gotoPage(leftToRight
                        ? (anchor.c as Chapter).firstPage
                        : (anchor.c as Chapter).lastPage, instant);
            }
        } else if (id == "first") {
            firstPage(instant);
        } else if (id == "last") {
            lastPage(instant);
        } else if (id == "next") {
            nextPage(instant);
        } else if (id == "prev") {
            prevPage(instant);
        } else if (int(id) > 0 || id == "0") {
            gotoPage(int(id), instant);
        } else {
            Logger.log("MegaZine", "No such anchor: '" + id + "'.");
        }
    }

    /**
     * Go to the page with the specified number. Numeration begins with zero.
     * 
     * <p>
     * This function checks for the reading order, i.e. in right to left
     * ordered books page 0 is at the right end of the book.
     * </p>
     * 
     * <p>
     * If the number does not exist the method call is ignored.
     * </p>
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * @param page
     *          the number of the page to go to.
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function gotoPage(page:uint, instant:Boolean = false):void {
        if (!draggingEnabled_) {
        	return;
        }
        dragHandler.gotoPage(l2r(page), instant);
    }

    /**
     * Turn to the last page of the book.
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * <p>
     * This function is aware of the reading order.
     * </p>
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function lastPage(instant:Boolean = false):void {
        gotoPage(pages.length, instant);
    }

    /**
     * Turn to the next page in the book.
     * 
     * <p>
     * If there is no next page nothing happens.
     * </p>
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * <p>
     * This function is aware of the reading order.
     * </p>
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function nextPage(instant:Boolean = false):void {
        gotoPage(l2r(currentPage_) + 2, instant);
    }

    /**
     * Turn to the previous page in the book.
     * 
     * <p>
     * If there is no previous page nothing happens.
     * </p>
     * 
     * <p>
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * </p>
     * 
     * <p>
     * This function is aware of the reading order.
     * </p>
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public function prevPage(instant:Boolean = false):void {
        gotoPage(l2r(currentPage_) - 2, instant);
    }


    // ---------------------------------------------------------------------- //
    // Other public functions
    // ---------------------------------------------------------------------- //
	
    /**
     * Open the zoom mode for the image with the given path. The image is then
     * loaded by the zoom container and displayed in full resolution. Pages and
     * navigation / gui is hidden while the zoom is open.
     * 
     * <p>
     * Alternatively a gallery name can be passed. In that case it is also
     * necessary to pass a proper page number (of a page with images that are
     * contained in that gallery) and the number of the image on that page.
     * </p>
     * 
     * <p>
     * If set up accordingly this opens fullscreen mode. This only works if the
     * call was initially triggered by a user action, such as a mouse click or
     * key press.
     * </p>
     * 
     * @param galleryOrPath
     *          the url to the image to load into the zoom frame, or the name
     *          of a gallery.
     * @param page
     *          the page the image object referencing to the gallery image
     *          resides in.
     * @param number
     *          only needed when a gallery name was passed. The number of the
     *          element representing the image to be opened in its containing
     *          page.
     */
    public function openZoom(galleryOrPath:String, page:int = -1,
            number:int = -1):void
    {
        // Only if the zoom was loaded
        if (!zoomContainer || galleryOrPath == null) {
            return;
        }
        // Stop slideshow when entering zoom
        slideStop();
        // Open the zoom
        if (number < 0) {
            zoomContainer.display(galleryOrPath);
            zoomContainer.setCurrentPage(page);
        } else {
            zoomContainer.setGalleryData(galleries[galleryOrPath], page,
                    number);
            zoomContainer.display(galleries[galleryOrPath][page][number]
                            [localizer_.language]
                    || galleries[galleryOrPath][page][number]
                            [localizer_.defaultLanguage]);
        }
        // Hide pages and navigation while in zoom mode.
        pageContainer_.visible = false;
        draggingEnabled = false;
        if (navigation) {
            navigation.visible = false;
        }
        if (stage["displayState"] != undefined) {
            // Store previous fullscreen state.
            zoomPreviouslyFullscreen =
                (stage.displayState == StageDisplayState.FULL_SCREEN);
            // Go to fullscreen?
            if (settings != null && settings.zoomFullscreen) {
                try {
                    if (!zoomPreviouslyFullscreen) {
                        stage.displayState = StageDisplayState.FULL_SCREEN;
                    }
                } catch (e:Error) {
                }
            }
        }
        zoomState_ = Constants.MEGAZINE_ZOOM_STATUS_OPEN;
        page = l2r(page);
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_STATUS_CHANGE, page,
                Constants.MEGAZINE_ZOOM_STATUS_OPEN,
                Constants.MEGAZINE_ZOOM_STATUS_CLOSED));
    }

    /**
     * Start the slideshow mode.
     * 
     * <p>
     * If the current page has a delay of more than one second the first page
     * turn is immediate (otherwise the user might get the impression nothing
     * happened). Every next page turn will take place based on the delay stored
     * for the current page.
     * </p>
     * 
     * <p>
     * When the end of the book is reached the slideshow is automatically
     * stopped.
     * </p>
     * 
     * <p>
     * If slideshow is already active this method does nothing.
     * </p>
     * 
     * <p>
     * Fires a MegaZineEvent.SLIDE_START event for this megazine object.
     * </p>
     */
    public function slideStart():void {
        if (!slideTimer.running) {
            updateSlideDelay();
            // Start possible / needed?
            if (leftToRight ? currentPage_ > 0 : currentPage_ < pages.length) {
                // Start timer
                slideTimer.start();
                // Tell everyone interested
                dispatchEvent(new MegaZineEvent(MegaZineEvent.SLIDE_START));
                // Do first turn if wait time is long
                if (slideTimer.delay > 1000) {
                    handleSlideTimer();
                }
            }
        }
    }
    
    /**
     * Stop slideshow. If the slideshow is already stopped this method does
     * nothing.
     * 
     * <p>
     * Fires a MegaZineEvent.SLIDE_STOP event for this megazine object.
     * </p>
     */
    public function slideStop():void {
        if (slideTimer.running) {
            slideTimer.stop();
            dispatchEvent(new MegaZineEvent(MegaZineEvent.SLIDE_STOP));
        }
    }

    /**
     * Try to zoom in, if the zoom is open. If it cannot be zoomed in any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    public function zoomIn():Boolean {
        if (zoomState_ == Constants.MEGAZINE_ZOOM_STATUS_CLOSED) {
        	return false;
        }
        zoomContainer.zoomIn();
        return true;
    }

    /**
     * Try to zoom out, if the zoom is open. If it cannot be zoomed out any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    public function zoomOut():Boolean {
        if (zoomState_ == Constants.MEGAZINE_ZOOM_STATUS_CLOSED) {
        	return false;
        }
        zoomContainer.zoomOut();
        return true;
    }

    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Event handler for added to stage event.
     * 
     * @param e
     *          unused.
     */
    private function handleAddedToStage(e:Event):void {
        load();
    }
	
    /**
     * Patching through...
     * 
     * @param e
     *          unused.
     */
    private function handleDragAreaEnter(e:MegaZineEvent):void {
        dispatchEvent(new MegaZineEvent(MegaZineEvent.DRAGAREA_ENTER));
    }

    /**
     * Patching through...
     * 
     * @param e
     *          unused.
     */
    private function handleDragAreaLeave(e:MegaZineEvent):void {
        dispatchEvent(new MegaZineEvent(MegaZineEvent.DRAGAREA_LEAVE));
    }
	
    /**
     * Status of the drag handler changes. Check if we need to update our flip
     * state. If yes dispatch an event to let the world now what's going on...
     * 
     * @param e
     *          used to check the new state.
     */
    private function handleDragStateChange(e:MegaZineEvent):void {
        var oldState:String = flipState_;
        if (e.newState == DragHandler.NO_PAGES_TURNING) {
            if (flipState_ != Constants.MEGAZINE_FLIP_STATUS_READY) {
                flipState_ = Constants.MEGAZINE_FLIP_STATUS_READY;
                dispatchEvent(new MegaZineEvent(
                        MegaZineEvent.FLIP_STATUS_CHANGE, currentPage_,
                        flipState_, oldState));
            }
        } else if (flipState_ != Constants.MEGAZINE_FLIP_STATUS_BUSY) {
            flipState_ = Constants.MEGAZINE_FLIP_STATUS_BUSY;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.FLIP_STATUS_CHANGE,
                    currentPage_, flipState_, oldState));
        }
    }
	
    /**
     * All keypresses go here, triggering possible page navigation.
     * 
     * @param e
     *          used to see which key was pressed.
     */
    private function handleKeyPressed(e:KeyboardEvent):void {
        // Only if the pages are already visible.
        if (!pagesOdd.visible || !pagesEven.visible) {
            return;
        }
		
        // Check what to do
        switch(e.keyCode) {
            case Keyboard.LEFT:
                leftToRight ? prevPage() : nextPage();
                break;
            case Keyboard.RIGHT:
                leftToRight ? nextPage() : prevPage();
                break;
            case Keyboard.HOME:
                firstPage();
                break;
            case Keyboard.END:
                lastPage();
                break;
        }
    }

    /**
     * Done loading the library, begin initializing the gui.
     * @param e unused.
     */
    private function handleLibraryComplete(e:MegaZineEvent):void {
        
        // Get the cursor image references
        Cursor.init(library, stage || this, settings.handCursor);
        
        // Setup custom navigation
        if (library.factory.isCustom()) {
            // A custom gui was loaded. This means the navigation bar is the
            // loaded gui itself, and all scripting will be taken care of in it,
            // so we do not need to create a navigation bar.
            try {
                library.factory.init(this, currentPage_, library);
                var nav:DisplayObject = (library.factory as DisplayObject);
                nav.x = Math.round(pageWidth - nav.width * 0.5);
                nav.y = pageHeight;
                addChildAt(nav, 0);
            } catch (e:Error) {
                Logger.log("MegaZine",
                        "Failed setting up custom navigation bar.",
                        Logger.TYPE_WARNING);
            }
        }
        // Normal navigation?
        if (settings.showNavigation) {
            // Setup the navigation by telling how many pages there are, the
            // dimensions of the thumbnails etc.
            try {
                // Above or below pages?
                var above:Boolean = false;
                var offset:int = 25;
                if (settings.barPosition != "") {
                    var bposp:Array = settings.barPosition.split(" ");
                    if (bposp.length > 0) {
                        if (bposp.length == 2 && bposp[0] == "top") {
                            above = true;
                            offset = int(bposp[1]);
                        } else {
                            offset = int(bposp[0]);
                        }
                    }
                }
                
                
                // Create the navigation
                updateButtonColors();
                navigation = new Navigation(settings, above, this, localizer_,
                        library, buttonColors);
                // Determine actual height (of the VISIBLE area)...
                var bmpd:BitmapData = new BitmapData(pageWidth * 2, pageHeight,
                        true, 0);
                bmpd.draw(navigation);
                var h:int =
                        bmpd.getColorBoundsRect(0xFFFFFFFF, 0, false).height;
                // Then position
                var bpos:int;
                if (above) {
                    bpos = -(h + offset);
                } else {
                    bpos = pageHeight + offset;
                }
                navigation.y = bpos;
                // Add event listener
                cleanUpSupport.make(navigation, NavigationEvent.BUTTON_CLICK,
                        handleNavigationMenu);
                addChild(navigation);
            } catch (er:Error) {
                Logger.log("MegaZine", "Error setting up navigation: "
                        + er.toString(), Logger.TYPE_WARNING);
            }
        }
        
        // Settings dialog
        if (!settings.buttonHide["settings"]) {
            try {
                settingsDialog = new SettingsDialog(this, localizer_, library);
                settingsDialog.x = pageWidth - settingsDialog.width * 0.5;
                settingsDialog.y = pageHeight - settingsDialog.height
                        - pageHeight / 5 - 100;
                cleanUpSupport.make(settingsDialog, "closed",
                        handleModalWindowClose);
                addChild(settingsDialog);
            } catch (e:Error) {
                Logger.log("MegaZine", "Error setting up settings dialog: "
                        + e.toString(), Logger.TYPE_WARNING);
            }
        }
        
        // Setup the zoom frame
        try {
            // Create the zoom container
            zoomContainer = new ZoomContainer(pageWidth * 2, pageHeight,
                    localizer_, library, settings);
            // Add listener for closing
            cleanUpSupport.make(zoomContainer, MegaZineEvent.ZOOM_CLOSED,
                    handleZoomClose);
            // Add listener for gallery navigation events
            cleanUpSupport.make(zoomContainer, MegaZineEvent.ZOOM_CHANGED,
                    handleZoomChanged);
            // Do not add to stage now because we use the add event to show the
            // help the first time the zoom opens.
            addChild(zoomContainer);
        } catch (e:Error) {
            Logger.log("MegaZine", "Error setting up zoom frame: "
                    + e.toString(), Logger.TYPE_WARNING);
        }
        
        // Password check, if exists show pw form until right pw is entered.
        if (settings.password && settings.password.length > 0) {
            try {
                passwordForm = new PasswordForm(settings.password, localizer_,
                        library);
                cleanUpSupport.make(passwordForm,
                        MegaZineEvent.PASSWORD_CORRECT, handlePasswordCorrect);
                passwordForm.x = int(pageWidth - passwordForm.width * 0.5);
                passwordForm.y = int((pageHeight - passwordForm.height) * 0.5);
                addChild(passwordForm);
                if (navigation) {
                    navigation.visible = false;
                }
            } catch (e:Error) {
                Logger.log("MegaZine", "Failed setting up password form: "
                        + e.toString(), Logger.TYPE_WARNING);
                pageContainer_.visible = true;
                draggingEnabled = true;
            }
        } else {
            // No password, show pages.
            pageContainer_.visible = true;
            draggingEnabled = true;
        }
        
        // Help window
        helpWindow = new Help(localizer_, library, settings.buttonHide,
                settings.showNavigation);
        helpWindow.x = pageWidth - helpWindow.width * 0.5;
        helpWindow.y = (pageHeight - helpWindow.height) * 0.5;
        cleanUpSupport.make(helpWindow, "closed", handleModalWindowClose);
        addChild(helpWindow);
        
        var so:SharedObject = SharedObject.getLocal("megazine3");
        if (settings.openhelp) {
            so.data.helpShown = true;
            dragHandler.enabled = false;
        } else {
            helpWindow.visible = false;
            handleModalWindowClose();
        }
        
        if (settings.startSlide) slideStart();
        
        Logger.log("MegaZine", "Done loading interface graphics.");
        
        // Begin loading the pages
        loadPageContent();
    }

    /**
     * There was an error while loading the graphics for the interface...
     * show the pages and initialize page load.
     * 
     * @param e
     *          unused.
     */
    private function handleLibraryError(e:MegaZineEvent):void {
        // Failed loading gui graphics, show pages and begin loading pages.
        pageContainer_.visible = true;
        draggingEnabled = true;
        loadPageContent();
    }

    /**
     * Localization XML loaded completely. Parse it.
     * @param e to get the loaded data.
     */
    private function handleLocalizationComplete(e:Event):void {
        try {
            var _xmlData:XML = new XML(e.target.data);
            var _xmlSubdata:XMLList = _xmlData.elements("langstring");
            if (_xmlSubdata.length() > 0) {
                var langID:String = Helper.validateString(_xmlData.@id, "");
                if (langID == "") {
                    Logger.log("MegaZine", "Invalid language file found "
                            + "(missing language id).", Logger.TYPE_WARNING);
                } else {
                    Logger.log("MegaZine",
                            "Parsing localized strings for language '" + langID
                            + "'...");
                    for each (var node:XML in _xmlSubdata) {
                        localizer_.registerString(langID, node.@name.toString(),
                                node.toString());
                    }
                    // "Officially" register the language
                    localizer_.registerLanguage(langID);
                    // Pick that language if it is the system language.
                    if (langID == Capabilities.language
                            && !settings.ignoreSystemLanguage)
                    {
                        localizer_.language = langID;
                    }
                }
            } else {
                Logger.log("MegaZine", "No localized strings found.");
            }
        } catch (ex:Error) {
            Logger.log("MegaZine",
                    "Loaded XML data for localization is invalid: "
                    + ex.toString(), Logger.TYPE_WARNING);
        }
    }

    /**
     * Modal window (help or settings) was closed, reenable drag handler.
     * 
     * @param e
     *          unused.
     */
    private function handleModalWindowClose(e:Event = null):void {
        dragHandler.enabled = draggingEnabled_;
    }

    /**
     * Handles menu button clicks in the navigation.
     * 
     * @param e
     *          used to determine which button was pressed.
     */
    private function handleNavigationMenu(e:NavigationEvent):void {
		
        switch (e.subtype) {
            case NavigationEvent.FULLSCREEN:
                if (stage && stage["displayState"] != undefined) {
                    try {
                        stage.displayState = StageDisplayState.FULL_SCREEN;
                    } catch (er:Error) {
                        Logger.log("MegaZine",
                                "Failed going into fullscreen mode: "
                                + er.toString(), Logger.TYPE_WARNING);
                    }
                }
                break;
            case NavigationEvent.GOTO_PAGE:
                gotoPage(e.page);
                break;
            case NavigationEvent.GOTO_PAGE_DIALOG:
                navigation.showGotoPage();
                break;
            case NavigationEvent.HELP:
                if (helpWindow) {
                    if (settingsDialog) {
                        settingsDialog.visible = false;
                    }
                    helpWindow.visible = !helpWindow.visible;
                    dragHandler.enabled = 
                            (!helpWindow.visible && draggingEnabled_);
                }
                break;
            case NavigationEvent.MUTE:
                muted = true;
                break;
            case NavigationEvent.PAGE_FIRST:
                firstPage();
                break;
            case NavigationEvent.PAGE_LAST:
                lastPage();
                break;
            case NavigationEvent.PAGE_PREV:
                prevPage();
                break;
            case NavigationEvent.PAGE_NEXT:
                nextPage();
                break;
            case NavigationEvent.PAUSE:
                slideStop();
                break;
            case NavigationEvent.PLAY:
                slideStart();
                break;
            case NavigationEvent.RESTORE:
                if (stage && stage["displayState"] != undefined) {
                    try {
                        stage.displayState = StageDisplayState.NORMAL;
                    } catch (er:Error) {
                        Logger.log("MegaZine",
                                "Failed leaving fullscreen mode: "
                                + er.toString(), Logger.TYPE_WARNING);
                    }
                }
                break;
            case NavigationEvent.SETTINGS:
                if (settingsDialog) {
                    if (helpWindow) {
                        helpWindow.visible = false;
                    }
                    settingsDialog.visible = !settingsDialog.visible;
                    dragHandler.enabled = 
                            (!settingsDialog.visible && draggingEnabled_);
                }
                break;
            case NavigationEvent.UNMUTE:
                muted = false;
                break;
        }
    }

    /**
     * Triggered when the current page of the book changes. Redispatches the
     * event.
     * 
     * @param e
     *          used to get the new current page.
     */
    private function handlePageChange(e:MegaZineEvent):void {
        currentPage_ = e.page;
		
		updatePagePosition(false);
		
        dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE, e.page, "",
                "", false, e.wasInstantTurn));
    }

    /**
     * Called when a page is finished loaded completely. Only used when all
     * pages can be loaded at a time (in memory that is).
     * 
     * @param e
     *          used to tell which page was loaded.
     */
    private function handlePageLoaded(e:MegaZineEvent):void {
        dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, e.page));
    }

    /**
     * Called when the correct password was entered in the passwordform.
     * Make pages visible and remove the form.
     * 
     * @param e
     *          unused.
     */
    private function handlePasswordCorrect(e:MegaZineEvent):void {
        if (navigation) {
            navigation.visible = true;
        }
        pageContainer_.visible = true;
        draggingEnabled = true;
        if (passwordForm != null && contains(passwordForm)) {
        	removeChild(passwordForm);
        }
    }

    /**
     * Called when the page positioning timer ticks.
     * 
     * @param e
     *          unused.
     */
    private function handlePositionTimer(e:TimerEvent):void {
        if (Math.abs(pageContainer_.x - targetPagePosition) < 0.01) {
            // Done, finalize and stop.
            pageContainer_.x = targetPagePosition;
            positionTimer.stop();
        } else {
            pageContainer_.x = (pageContainer_.x + targetPagePosition) / 2;
        }
        // Update dragging.
        dragHandler.handleMouseMovement();
    }

    /**
     * When removed from stage cancel loading if currently in progess.
     * 
     * @param e
     *          unused.
     */
    private function handleRemoveFromStage(e:Event):void {
        // If loading, cancel.
        if (state == Constants.MEGAZINE_STATUS_LOADING) {
            setState(Constants.MEGAZINE_STATUS_CANCELLED);
        }
        if (destroyOnRemove_) {
            destroy();
        }
    }

    /**
     * Slide show page turning triggered by timer.
     * 
     * @param e
     *          unused.
     */
    private function handleSlideTimer(e:TimerEvent = null):void {
        nextPage();
        updateSlideDelay();
        // Check if done.
        if (leftToRight ? currentPage_ <= 0 : currentPage_ >= pages.length) {
            slideStop();
        }
    }

    /**
     * Error loading xml data.
     * 
     * @param e
     *          used to print the error message.
     */
    private function handleXmlLoadError(e:IOErrorEvent):void {
        Logger.log("MegaZine", "Could not load XML data: " + e.text,
                Logger.TYPE_ERROR);
        createErrorMessage("<b>Error</b><br/>Could not load XML data: "
                + e.text);
        setState(Constants.MEGAZINE_STATUS_ERROR);
    }

    /**
     * Called when the loading of the xml data is complete.
     * 
     * @param e
     *          unused.
     */
    private function handleXmlLoadComplete(e:Event):void {
        
        Logger.log("MegaZine", "XML loaded successfully.");
        
        if (state == Constants.MEGAZINE_STATUS_CANCELLED) {
            // Loading cancelled.
            Logger.log("MegaZine", "Loading cancelled!");
            setState(Constants.MEGAZINE_STATUS_PREINIT);
            return;
        }
        
        // Initialize the xml object with the loaded data.
        XML.ignoreComments = true;
        XML.ignoreWhitespace = true;
        XML.ignoreProcessingInstructions = false;
        
        try {
            xmlData = new XML((e.target as URLLoader).data);
        } catch (er:Error) {
            Logger.log("MegaZine", "Invalid XML data! " + er.toString(),
                    Logger.TYPE_ERROR);
            createErrorMessage("<b>Error</b><br/>Invalid XML data! "
                    + er.toString());
            setState(Constants.MEGAZINE_STATUS_ERROR);
            return;
        }
        
        parseXml();
    }

    /**
     * Called when the image in the gallery changes.
     * 
     * @param e
     *          used to retrieve the page containing the new image.
     */
    private function handleZoomChanged(e:MegaZineEvent):void {
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CHANGED,
                l2r(e.page)));
    }

    /**
     * Called when the zoom mode is closed. Restores other elements.
     * 
     * @param e
     *          used to check which page to go to.
     */
    private function handleZoomClose(e:MegaZineEvent):void {
        var page:int = e.page;
        draggingEnabled = true;
        if (page >= 0) {
        	page = l2r(page);
            gotoPage(page, true);
        } else {
            page = -1;
        }
        // Show pages again...
        pageContainer_.visible = true;
        // And navigation if it exists
        if (navigation) {
            navigation.visible = true;
        }
        // Return to normal?
        if (!zoomPreviouslyFullscreen) {
            try {
                stage.displayState = StageDisplayState.NORMAL;
            } catch (e:Error) {
            }
        }
        zoomState_ = Constants.MEGAZINE_ZOOM_STATUS_CLOSED;
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_STATUS_CHANGE, page,
                Constants.MEGAZINE_ZOOM_STATUS_CLOSED,
                Constants.MEGAZINE_ZOOM_STATUS_OPEN));
    }


    // ---------------------------------------------------------------------- //
    // Updating
    // ---------------------------------------------------------------------- //
	
    /**
     * Internal redraw function, redraws all pages. And the reflection if
     * active.
     * 
     * @param e
     *          unused.
     */
    private function redraw(e:Event = null):void {
		
        // Tell all pages to redraw
        for (var i:uint = 0;i < pages.length; i += 2) {
            if ((pages[i] as Page).pageEven.parent == pagesEven
                    || (pages[i] as Page).pageOdd.parent == pagesOdd)
            {
                (pages[i] as Page).redraw();
            }
        }
		
        // Update the reflection if they have been initialized.
        if (reflectionImage != null) {
            if (settings.useReflection && reflectionData != null) {
                reflectionData.fillRect(reflectionData.rect, 0);
                reflectionData.draw(pageContainer_,
                        new Matrix(1, 0, 0, -1, 0, pageHeight));
                reflectionImage.visible = true;
            } else {
                reflectionImage.visible = false;
            }
        }
    }

    /**
     * Update the button colors array for the navbar.
     */
    private function updateButtonColors():void {
        buttonColors.length = 0;
        for each (var chapter:Chapter in chapters) {
        	if (chapter != null) {
                buttonColors.push({ page : (leftToRight
                                ? chapter.firstPage
                                : chapter.lastPage + 1),
                        color : settings.buttonColors["chapter"] });
        	}
        }
        for each (var page:Page in pages) {
        	if (page != null) {
                buttonColors.push({ page : page.getNumber(true),
                        color : page.getButtonColor(true) });
                buttonColors.push({ page : page.getNumber(false),
                        color : page.getButtonColor(false) });
        	}
        }
        for each (var anchor : Object in anchors) {
            if (anchor != null) {
                if (anchor.isPage) {
                    buttonColors.push({ page : (anchor.p as Page).
                                    getNumber(anchor.even),
                            color : settings.buttonColors["anchor"] });
                } else {
                    buttonColors.push({ page : (anchor.c as Chapter).firstPage,
                            color : settings.buttonColors["anchor"] });
                }
            }
        }
    }
    
    /**
     * Update target position for page containers (and move instantly if
     * required).
     * 
     * @param instant
     *          move instantly or via timer?
     */
    private function updatePagePosition(instant:Boolean = false):void {
        if (settings.centerCovers) {
            if (currentPage_ == 0 && leftToRight
                    || currentPage_ == pages.length && !leftToRight)
            {
                targetPagePosition = -int(pageWidth / 2);
            } else if (currentPage_ == 0 && !leftToRight
                    || currentPage_  == pages.length && leftToRight)
            {
                targetPagePosition = int(pageWidth / 2);
            } else {
                targetPagePosition = 0;
            }
            if (instant) {
                pageContainer_.x = targetPagePosition;
                dragHandler.handleMouseMovement();
            } else {
                positionTimer.start();
            }
        }
    }

    /**
     * Used for updating the delay of the slideshow timer, based on which page
     * we're on and in which direction the book is read.
     */
    private function updateSlideDelay():void {
        // Update the delay
        var newDelayOdd:uint = currentPage_ > 0
                    ? pages[currentPage_ - 1].getSlideDelay(false)
                    : settings.slideDelay;
        var newDelayEven:uint = currentPage_ < pages.length
                    ? pages[currentPage_].getSlideDelay(true)
                    : settings.slideDelay;
        var defaultDelayOdd:uint = currentPage_ > 0
                    ? pages[currentPage_ - 1].slideDelayDefault
                    : settings.slideDelay;
        var defaultDelayEven:uint = currentPage_ < pages.length
                    ? pages[currentPage_].slideDelayDefault
                    : settings.slideDelay;
        var newDelay:uint;
        // First check if the one we're turning towards is not the default,
        // if so use it. Else, if the previous one is not default use that.
        // If that's default, too, though, use the one we're turning towards
        // as default.
        if (leftToRight) {
            if (newDelayEven == defaultDelayEven
                   && newDelayOdd != defaultDelayOdd)
            {
                newDelay = newDelayOdd;
            } else {
                newDelay = newDelayEven;
            }
        } else {
            if (newDelayOdd == defaultDelayOdd
                   && newDelayEven != defaultDelayEven)
            {
                newDelay = newDelayEven;
            } else {
                newDelay = newDelayOdd;
            }
        }
        slideTimer.delay = newDelay * 1000;
    }
	
	
    // ---------------------------------------------------------------------- //
    // Miscellaneous
    // ---------------------------------------------------------------------- //
	
	/**
	 * Converts a left to right page number to a right to left page number if
	 * the book is in right to left mode.
	 * 
	 * @param page
	 *         the page number to test, and, if necessary, convert.
	 */
	private function l2r(page:uint):uint {
		if (leftToRight) {
			return page;
		} else {
		  return (pages.length) - page;
		}
	}
	
    /**
     * Helper functions for creating context menu entries.
     * 
     * @param title
     *          the display title of the context menu entry.
     * @param handler
     *          handler function if the element is clicked.
     */
   /* private function createContextEntry(title:String,
            handler:Function = null):void
    {
        if (contextMenu.customItems == null) {
            contextMenu.customItems = new Array();
        }
        var cmi:ContextMenuItem = new ContextMenuItem(title);
        if (handler != null) {
            cleanUpSupport.make(cmi, ContextMenuEvent.MENU_ITEM_SELECT,
                    handler);
        }
        contextMenu.customItems.push(cmi);
    }*/
    
    /**
     * Create a new fading message above of the pages.
     * 
     * @param message
     *          the text message to display (language string ID).
     * @param delay
     *          time to wait before displaying. If a delay is given the
     *          dispatcher and event type are ignored.
     * @param color
     *          text color.
     * @param dispatcher
     *          dispatcher to observe.
     * @param eventType
     *          event type for which to wait before showing message.
     */
    private function createErrorMessage(message:String):void {
        var fm:FadingMessage = new FadingMessage(message, this, this,
                Event.ENTER_FRAME, true, 0xFF0000, 375);
        fm.y = -fm.height * 0.5;
    }

    /**
     * Check uid validity of this megazine build.
     * 
     * @param e
     *          unused.
     */
    private function validateLicenseUID(e:Event = null):void {
    	var url:String =
    	       "http://megazine.mightypirates.de/validate.php?uid="
    	       + LICENSE_UID;
        try {
            navigateToURL(new URLRequest(url), "_blank");
        } catch (er:Error) {
            Logger.log("MegaZine", "Could not navigate to validation page ("
                    + url + "): " + er.toString(),
                    Logger.TYPE_WARNING);
        }
    }

    /**
     * Visit project homepage.
     * 
     * @param e
     *          unused.
     */
    private function visitHomepage(e:Event = null):void {
        var url:String =
               "http://megazine.mightypirates.de/";
        try {
            navigateToURL(new URLRequest(url), "_blank");
        } catch (er:Error) {
            Logger.log("MegaZine", "Could not navigate to project homepage "
                    + "(" + url + "): " + er.toString(),
                    Logger.TYPE_WARNING);
        }
    }
}
}
