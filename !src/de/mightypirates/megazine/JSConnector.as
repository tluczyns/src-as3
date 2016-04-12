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
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;

import flash.errors.IllegalOperationError;
import flash.external.ExternalInterface;

/**
 * Can be used to connect a megazine instance to the "outside", so that some
 * functions may be called using JavaScript. Obviously, only one MegaZine
 * can be addressed like this at a time, so this class cannot be instantiated.
 * 
 * @author fnuecke
 */
public class JSConnector {

    /** Current instance of the MegaZine engine to use. */
    private static var megazine:IMegaZine = null;

    /** Was the connector instantiated, i.e. have the callbacks been set? */
    private static var isInitialized:Boolean = false;

    
    /**
     * Not allowed to instantiate this class, will always throw an
     * IllegalOperationError.
     */
    public function JSConnector() {
        throw new IllegalOperationError("JSConnector cannot be instantiated.");
    }

    /** Initialize callbacks */
    private static function init():Boolean {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("getCurrentAnchor", getCurrentAnchor);
            ExternalInterface.addCallback("getCurrentPage", getCurrentPage);
            ExternalInterface.addCallback("isDraggingEnabled",
                    isDraggingEnabled);
            ExternalInterface.addCallback("setDraggingEnabled",
                    setDraggingEnabled);
            ExternalInterface.addCallback("isMuted", isMuted);
            ExternalInterface.addCallback("setMuted", setMuted);
            ExternalInterface.addCallback("getPageAnchor", getPageAnchor);
            ExternalInterface.addCallback("getPageCount", getPageCount);
            ExternalInterface.addCallback("getPageHeight", getPageHeight);
            ExternalInterface.addCallback("getPageWidth", getPageWidth);
            ExternalInterface.addCallback("hasReflection", hasReflection);
            ExternalInterface.addCallback("setReflection", setReflection);
            ExternalInterface.addCallback("hasShadows", hasShadows);
            ExternalInterface.addCallback("setShadows", setShadows);
            ExternalInterface.addCallback("getFlipState", getFlipState);
            ExternalInterface.addCallback("getState", getState);
            ExternalInterface.addCallback("getZoomState", getZoomState);
            ExternalInterface.addCallback("gotoAnchor", gotoAnchor);
            ExternalInterface.addCallback("gotoPage", gotoPage);
            ExternalInterface.addCallback("firstPage", firstPage);
            ExternalInterface.addCallback("lastPage", lastPage);
            ExternalInterface.addCallback("nextPage", nextPage);
            ExternalInterface.addCallback("prevPage", prevPage);
            ExternalInterface.addCallback("slideStart", slideStart);
            ExternalInterface.addCallback("slideStop", slideStop);
            ExternalInterface.addCallback("zoomIn", zoomIn);
            ExternalInterface.addCallback("zoomOut", zoomOut);
            ExternalInterface.addCallback("openZoom", openZoom);
            
            isInitialized = true;
            return true;
        } else {
        	return false;
        }
    }

    /** Event handling */
    private static function registerListeners():void {
        if (megazine != null) {
            megazine.addEventListener(MegaZineEvent.SLIDE_START,
                    handleSlideStart);
            megazine.addEventListener(MegaZineEvent.SLIDE_STOP,
                    handleSlideStop);
            megazine.addEventListener(MegaZineEvent.PAGE_CHANGE,
                    handlePageChange);
            megazine.addEventListener(MegaZineEvent.MUTE, handleMute);
            megazine.addEventListener(MegaZineEvent.UNMUTE, handleUnmute);
            megazine.addEventListener(MegaZineEvent.STATUS_CHANGE,
                    handleStatusChange);
            megazine.addEventListener(MegaZineEvent.FLIP_STATUS_CHANGE,
                    handleFlipStatusChange);
            megazine.addEventListener(MegaZineEvent.ZOOM_CHANGED,
                    handleZoomChanged);
            megazine.addEventListener(MegaZineEvent.ZOOM_STATUS_CHANGE,
                    handleZoomStatusChange);
        }
    }

    private static function removeListeners():void {
        if (megazine != null) {
            megazine.removeEventListener(MegaZineEvent.SLIDE_START,
                    handleSlideStart);
            megazine.removeEventListener(MegaZineEvent.SLIDE_STOP,
                    handleSlideStop);
            megazine.removeEventListener(MegaZineEvent.PAGE_CHANGE,
                    handlePageChange);
            megazine.removeEventListener(MegaZineEvent.MUTE, handleMute);
            megazine.removeEventListener(MegaZineEvent.UNMUTE, handleUnmute);
            megazine.removeEventListener(MegaZineEvent.STATUS_CHANGE,
                    handleStatusChange);
            megazine.removeEventListener(MegaZineEvent.FLIP_STATUS_CHANGE,
                    handleFlipStatusChange);
            megazine.removeEventListener(MegaZineEvent.ZOOM_CHANGED,
                    handleZoomChanged);
            megazine.removeEventListener(MegaZineEvent.ZOOM_STATUS_CHANGE,
                    handleZoomStatusChange);
        }
    }

    private static function handleSlideStart(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onSlideStart");
        } catch (ex:Error) {
        }
    }

    private static function handleSlideStop(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onSlideStop");
        } catch (ex:Error) {
        }
    }

    private static function handlePageChange(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onPageChange", e.page);
        } catch (ex:Error) {
        }
    }

    private static function handleMute(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onMute");
        } catch (ex:Error) {
        }
    }

    private static function handleUnmute(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onUnmute");
        } catch (ex:Error) {
        }
    }

    private static function handleStatusChange(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onStatusChange",
                    e.newState, e.previousState);
        } catch (ex:Error) {
        }
    }

    private static function handleFlipStatusChange(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onFlipStatusChange",
                    e.newState, e.previousState);
        } catch (ex:Error) {
        }
    }

    private static function handleZoomChanged(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onZoomChanged", e.page);
        } catch (ex:Error) {
        }
    }

    private static function handleZoomStatusChange(e:MegaZineEvent):void {
        try {
            ExternalInterface.call("MegaZine.onZoomStatusChange",
                    e.newState, e.previousState, e.page);
        } catch (ex:Error) {
        }
    }

    /**
     * Returns the anchor name of the page currently being displayed. If the
     * page has no anchor defined, the anchor of the chapter is returned. If the
     * chapter has no anchor defined, null is returned.
     * This first checks for an anchor in the left page, then in the right page.
     * I.e. if an anchor is set in both pages, the left one is returned.
     * 
     * @return the current anchor.
     */
    public static function getCurrentAnchor():String {
        if (megazine != null) return megazine.currentAnchor;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Returns the number of the currently 'focused' page, i.e. the page the
     * book is opened on when there is no page turn active. If a page is turned
     * this will hold the future main page. If multiple pages are turned it will
     * be updated rapidly and always return <i>current</i> main page.
     * This will always be an even number, i.e. the number of the page on the
     * right, starting the count at 0.
     * 
     * @return the number of the current main page.
     */
    public static function getCurrentPage():uint {
        if (megazine != null) return megazine.currentLogicalPage;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Whether to currently allow mouse interaction with pages.
     */
    public static function isDraggingEnabled():Boolean {
        if (megazine != null) return megazine.draggingEnabled;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Whether to currently allow mouse interaction with pages.
     */
    public static function setDraggingEnabled(enabled:Boolean):void {
        if (megazine != null) megazine.draggingEnabled = enabled;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * The mute state for all elements that support it.
     */
    public static function isMuted():Boolean {
        if (megazine != null) return megazine.muted;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Sets mute state for all elements that support it by firing a
     * MegaZineEvent.MUTE event.
     */
    public static function setMuted(mute:Boolean):void {
        if (megazine != null) megazine.muted = mute;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Looks up the anchor associated with this page. If it exists, returns
     * that, if not returns null.
     * 
     * @param page
     *          the page for which to look up the anchor.
     * @return the anchor associated with the given page.
     */
    public static function getPageAnchor(page:uint):String {
        if (megazine != null) return megazine.getPageAnchor(page);
        else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the number of pages in the book.
     * 
     * @return the number of pages in the book.
     */
    public static function getPageCount():uint {
        if (megazine != null) return megazine.pageCount;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the default height for pages.
     * 
     * @return the default height for pages.
     */
    public static function getPageHeight():uint {
        if (megazine != null) return megazine.pageHeight;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the default width for pages.
     * 
     * @return the defaut width for pages.
     */
    public static function getPageWidth():uint {
        if (megazine != null) return megazine.pageWidth;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the current state of this instance.
     * 
     * @return the current state of this instance.
     */
    public static function getState():String {
        if (megazine != null) return megazine.state;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the current page flipping state of this instance (turning or not).
     * 
     * @return the current flip state of this instance.
     */
    public static function getFlipState():String {
        if (megazine != null) return megazine.flipState;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the current zoom state of this instance (open or closed).
     * 
     * @return the current zoom state of this instance.
     * @see de.mightypirates.megazine.interfaces.Constants.ZOOM_STATUS_OPEN
     * @see de.mightypirates.megazine.interfaces.Constants.ZOOM_STATUS_CLOSED
     */
    public static function getZoomState():String {
        if (megazine != null) return megazine.zoomState;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the current setting for reflection useage.
     * 
     * @return the current setting for reflection useage.
     */
    public static function hasReflection():Boolean {
        if (megazine != null) return megazine.reflection;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Set the reflection useage.
     * 
     * @param enabled
     *          enable the reflection or disable it.
     */
    public static function setReflection(enabled:Boolean):void {
        if (megazine != null) megazine.reflection = enabled;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Get the state of shadow useage for pages.
     * 
     * @return the state of shadow useage for pages.
     */
    public static function hasShadows():Boolean {
        if (megazine != null) return megazine.shadows;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Set the state of shadow useage for pages.
     * 
     * @param enabled
     *          the new state of shadow useage for pages.
     */
    public static function setShadows(enabled:Boolean):void {
        if (megazine != null) megazine.shadows = enabled;
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Go to the page with the specified anchor as specified in the xml. Chapter
     * anchors are handled via this method as well, because their anchors are
     * just mapped to their first page.
     * If there is no such anchor it is checked whether it is a predefined
     * anchor. Predefined anchors are: first, last, next, prev.
     * If it is no predefined anchor it is checked whether a number was passed,
     * and ich yes it is interpreted as a page number.
     * If that fails too, nothing will happen.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param id
     *          the anchor id, predefined anchorname or page number.
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function gotoAnchor(id:String, instant:Boolean = false):void {
        if (megazine != null) megazine.gotoAnchor(id, instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Go to the page with the specified number. Numeration begins with zero.
     * If the number does not exist the method call is ignored.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param page
     *          the number of the page to go to.
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function gotoPage(page:uint, instant:Boolean = false):void {
        if (megazine != null) megazine.gotoPage(page, instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Turn to the first page of the book.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function firstPage(instant:Boolean = false):void {
        if (megazine != null) megazine.firstPage(instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Turn to the last page of the book.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function lastPage(instant:Boolean = false):void {
        if (megazine != null) megazine.lastPage(instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Turn to the next page in the book. If there is no next page nothing
     * happens.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function nextPage(instant:Boolean = false):void {
        if (megazine != null) megazine.nextPage(instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Open the zoom mode for the image with the given path. The image is then
     * loaded by the zoom container and displayed in full resolution. Pages and
     * navigation / gui is hidden while the zoom is open.
     * Alternatively a gallery name can be passed. In that case it is also
     * necessary to pass a proper page number (of a page with images that are
     * contained in that gallery) and the number of the image on that page.
     * If set up accordingly this opens fullscreen mode. This only works if the
     * call was initially triggered by a user action, such as a mouse click or
     * key press. This means especially that fullscreen mode will not be
     * triggered when opening zoom via JavaScript (which is impossible due to
     * Flash's security restrictions).
     * 
     * @param galleryOrPath
     *          the url to the image to load into the zoom frame, or the name
     *          of a gallery.
     * @param page
     *          only needed when a gallery name was passed. The number of the
     *          page the image object referencing to the gallery image resides
     *          in.
     * @param number
     *          only needed when a gallery name was passed. The number of the
     *          image in its containing page (only images in the same gallery
     *          count).
     */
    public static function openZoom(galleryOrPath:String, page:int = -1,
            number:int = -1):void
    {
        if (megazine != null) megazine.openZoom(galleryOrPath, page, number);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Turn to the previous page in the book. If there is no previous page
     * nothing happens. If there is currently a page turn animation in progress
     * this method does nothing.
     * 
     * @param instant
     *          no animation, but instantly going to the page.
     */
    public static function prevPage(instant:Boolean = false):void {
        if (megazine != null) megazine.prevPage(instant);
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Start the slideshow mode. If the current page has a delay of more than
     * one second the first page turn is immediate (otherwise the user might get
     * the impression nothing happened). Every next page turn will take place
     * based on the delay stored for the current page.
     * When the end of the book is reached the slideshow is automatically
     * stopped.
     * If slideshow is already active this method does nothing.
     * Triggers a call to the onSlideStart function.
     */
    public static function slideStart():void {
        if (megazine != null) megazine.slideStart();
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Stop slideshow. If the slideshow is already stopped this method does
     * nothing.
     * Triggers a call to the onSlideStop function.
     */
    public static function slideStop():void {
        if (megazine != null) megazine.slideStop();
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Try to zoom in, if the zoom is open. If it cannot be zoomed in any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    public static function zoomIn():Boolean {
        if (megazine != null) return megazine.zoomIn();
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Try to zoom out, if the zoom is open. If it cannot be zoomed out any
     * further, nothing happens.
     * 
     * @return true if zoom is open, else false.
     */
    public static function zoomOut():Boolean {
        if (megazine != null) return megazine.zoomOut();
		else throw new IllegalOperationError("No MegaZine instance set!");
    }

    /**
     * Connect the ExternalInterface to a MegaZine instance. If another instance
     * was previously used it will be disconnected. If the callbacks for the
     * ExternalInterface have not been set up yet they will be.
     * 
     * @param megazine
     *          the MegaZine instance to use.
     * @return true if the connection succeeds, else false.
     */
    public static function connect(megazine:IMegaZine):Boolean {
        if (!isInitialized && !init()) return false;
		
        removeListeners();
		
        JSConnector.megazine = megazine;
		
        try {
            ExternalInterface.call("onInstanceChange");
        } catch (ex:Error) {
        }
		
        registerListeners();
		
        return true;
    }
}
} // end package
