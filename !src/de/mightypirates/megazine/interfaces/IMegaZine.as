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
import de.mightypirates.utils.Localizer;

import flash.display.Stage;
import flash.events.*;

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
 * Interface for the {@link MegaZine} class, to be used in (external) elements.
 * The reason the actual class is not used for external elements is to make the
 * files smaller. They do not need to instantiate a MegaZine class, so they only
 * need to know what methods they can call.
 * </p>
 * 
 * <p>
 * But it is also recommended to use this interface whenever working with a
 * <code>MegaZine</code> instance, because some of the functions are meant only
 * to be used by internal elements - lying in different packages, though, making
 * the use of the "internal" keyword impossible.
 * </p>
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
 * <p>
 * The actual <code>MegaZine</code> class extends <code>MovieClip</code>, so you
 * can cast this interface to <code>DisplayObject</code> whenever you need. As
 * there is no interface for display objects that's the only option, I'm afraid.
 * So basically, for adding to another container e.g. use:
 * <pre>
 * var megazine:IMegaZine = ...;
 * addChild(megazine as DisplayObject);
 * </pre>
 * </p>
 * 
 * @author fnuecke
 */
public interface IMegaZine extends IEventDispatcher {

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
    function get currentAnchor():String;

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
    function get currentLogicalPage():uint;
    
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
    function get currentPage():uint;

    /**
     * Determine whether to clean up when the book is removed from stage or not.
     * The default is true. Note that removing the book from the stage then
     * renders the book unfunctional for further use!
     */
    function get destroyOnRemove():Boolean;
    
    /**
     * Determine whether to clean up when the book is removed from stage or not.
     * The default is true. Note that removing the book from the stage then
     * renders the book unfunctional for further use!
     */
    function set destroyOnRemove(cleanup:Boolean):void;
    
    /**
     * Whether to currently allow mouse interaction with pages.
     */
    function get draggingEnabled():Boolean;

    /**
     * Whether to currently allow mouse interaction with pages.
     */
    function set draggingEnabled(enabled:Boolean):void;

    /**
     * Get the current page flipping state of this instance (turning or not).
     */
    function get flipState():String;

    /**
     * Tells whether the book is read from left to right (true) or right to left
     * (false).
     */
    function get leftToRight():Boolean;

    /**
     * The localizer instance used throughout the book to localize gui elements
     * / page elements.
     */
    function get localizer():Localizer;

    /**
     * The mute state for all elements that support it.
     */
    function get muted():Boolean;

    /**
     * Sets mute state for all elements that support it by firing a
     * MegaZineEvent.MUTE event.
     */
    function set muted(mute:Boolean):void;

    /**
     * Get the number of pages in the book.
     */
    function get pageCount():uint;

    /**
     * Get the default height for pages.
     */
    function get pageHeight():uint;

    /**
     * Get the pages offset for the book, i.e. the number added to the actual
     * page number before it is displayed below the book.
     */
    function get pageOffset():int;

    /**
     * Get the default width for pages.
     */
    function get pageWidth():uint;

    /**
     * Get the current setting for reflection useage.
     */
    function get reflection():Boolean;

    /**
     * Set the reflection useage
     */
    function set reflection(enabled:Boolean):void;

    /**
     * Get the state of shadow useage for pages.
     */
    function get shadows():Boolean;

    /**
     * Set the state of shadow useage for pages.
     */
    function set shadows(enabled:Boolean):void;

    /**
     * Get the stage the megazine object resides on. Used by elements for setup
     * when they themselves have not yet been added to the stage.
     */
    function get stage():Stage;

    /**
     * Get the current state of this instance.
     */
    function get state():String;

    /**
     * The underlying XML data used to describe the book, starting at the root
     * node (book). This is the raw form of the XML data as loaded from file.
     * This will return null if the XML data has not been loaded yet. The
     * xml will be completely interpreted after it was loaded, but changes to
     * this datastructure may have an effect, due to stored references
     * nontheless, so they are not recommended, to avoid inconsistencies with
     * other components accessing this variable later on.
     */
    function get xml():XML;

    /**
     * Get the current zoom state of this instance (open or closed).
     * 
     * @see de.mightypirates.megazine.interfaces.Constants
     */
    function get zoomState():String;

    /**
     * Cleans up all listeners and internal references used by the book and
     * makes it ready for garbage collection.
     */
    function destroy():void;

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
    function firstPage(instant:Boolean = false):void;

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
    function getAbsPath(url:String, protocols:Array = null):String;

    /**
     * Returns the element referred to by the given id. If no such element is
     * known the function returns null.
     * 
     * @param id
     *          the id of the element.
     * @return the element (the wrapper class, actually, so you'll have to check
     *          yourself if it's actually loaded.
     */
    function getElementById(id:String):IElement;

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
    function getPage(page:uint):IPage;

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
    function getPageAnchor(page:uint):String;

    /**
     * Gets the thumbnails for the left and right page for the given page.
     * 
     * @param page
     *          the page number for which to get the left and right page.
     * @return an array with the left page at 0 and the right at 1.
     */
    function getThumbnailsForPage(page:int):Array;

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
    function gotoAnchor(id:String, instant:Boolean = false):void;

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
    function gotoPage(page:uint, instant:Boolean = false):void;

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
    function lastPage(instant:Boolean = false):void;

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
     * automatically called as soon as the megazine object is added to the stage.
     * </p>
     * 
     * @param xml
     *          XML data may be given directly, in which case it won't try to
     *          load external data (which might have been specified in the
     *          constructor).
     */
    function load(xml:XML = null):void;

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
    function nextPage(instant:Boolean = false):void;

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
    function prevPage(instant:Boolean = false):void;

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
    function openZoom(galleryOrPath:String, page:int = -1,
            number:int = -1):void;

    /**
     * Start the slideshow mode. If the current page has a delay of more than
     * one second the first page turn is immediate (otherwise the user might get
     * the impression nothing happened). Every next page turn will take place
     * based on the delay stored for the current page.
     * 
     * <p>
     * When the end of the book is reached the slideshow is automatically
     * stopped. If slideshow is already active this method does nothing.
     * </p>
     * 
     * <p>
     * Fires a MegaZineEvent.SLIDE_START event for this megazine object.
     * </p>
     */
    function slideStart():void;

    /**
     * Stop slideshow. If the slideshow is already stopped this method does
     * nothing.
     * 
     * <p>
     * Fires a MegaZineEvent.SLIDE_STOP event for this megazine object.
     * </p>
     */
    function slideStop():void;

    /**
     * Try to zoom in, if the zoom is open. If it cannot be zoomed in any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    function zoomIn():Boolean;

    /**
     * Try to zoom out, if the zoom is open. If it cannot be zoomed out any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    function zoomOut():Boolean;
}
} // end package
