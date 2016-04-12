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
import de.mightypirates.megazine.ElementLoader;
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.LinkedList;

import flash.events.*;
import flash.utils.*;

/**
 * The pageloader class loads an unloads pages on request. Basically it just
 * determines which pages should be in memory and which should not, and
 * accordingly loads or unloads pages.
 * Also handles loading of pages to generate a thumbnail for them, either all
 * at once or at request.
 * 
 * @author fnuecke
 */
internal class PageLoader {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /**
     * When all thumbnails have been loaded once remember that, to avoid
     * unnecessary ifs.
     */
    private var areAllThumbsDone:Boolean = false;

    /** The current page, start loading this one first */
    private var currentPage:uint = 0;

    private var delayTimer:Timer;

    /** The loader used for loading the page's elements. */
    private var elementLoader:ElementLoader;

    /**
     * Remember which pages have already been loaded once (thus already have a
     * thumbnail).
     */
    private var loadedOnce:Array; // Boolean
	
    /**
     * Prioritize loading of pages in this array, worked lifo
     * (i.e. via Array.pop).
     */
    private var loadPreferred:Array;

    /** Only load thumbnails when asked to */
    private var loadSpecifiedOnly:Boolean = false;

    /** Currently loading thumbnails */
    private var isThumbnailLoadingActive:Boolean = false;

    /** Maximim of pages to be kept in memory */
    private var maximumLoaded:uint = 0;

    /** The megazine instance this loader is associated to */
    private var megazine:IMegaZine;

    /**
     * Array containing all pages in the book, references same array as in
     * MegaZine instance.
     */
    private var pages:Array; // Page
	
    /** Instance settings */
    private var settings:Settings;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new pageloader for an array of pages.
     * 
     * @param megazine
     *          the megazine this loader belongs to.
     * @param currentPage
     *          the current page.
     * @param pages
     *          an array with all loadable pages.
     * @param dragHandler
     *          the used draghandler.
     * @param settings
     *          used settings.
     */
    public function PageLoader(megazine:IMegaZine, currentPage:uint,
            pages:Array, dragHandler:DragHandler, settings:Settings)
    {
		
        this.megazine = megazine;
        this.settings = settings;
        this.pages = pages;
        this.currentPage = currentPage;
        this.maximumLoaded = settings.maxLoaded;
        this.loadSpecifiedOnly = !settings.thumbAuto;
        this.loadedOnce = new Array(pages.length);
        this.loadPreferred = new Array();
        this.elementLoader = new ElementLoader(settings.loadParallel);
        this.delayTimer = new Timer(500, 1);
		
        // Delay timer setup
        delayTimer.addEventListener(TimerEvent.TIMER, delayedRebuild);
		
        // Register for page change / no more turning events if there is a
        // chance that pages need to be reloaded / unloaded.
        if (settings.waitForNoTurning) {
            dragHandler.addEventListener(MegaZineEvent.STATUS_CHANGE,
                    handlePageChange);
        } else {
            megazine.addEventListener(MegaZineEvent.PAGE_CHANGE,
                    handlePageChange);
        }
		
        // 0 means load all pages at once, also increase number if it is greater
        // or equal to the page count, so that all pages stay loaded when at a
        // cover of the book.
        if (maximumLoaded == 0 || maximumLoaded >= pages.length) {
            // Just take an absurdly high number to keep all pages loaded. Times
            // two should be enough, but rounding errors might occur, so to be
            // on the safe side...
            maximumLoaded = pages.length * 4;
            // All will be loaded anyway, so only load the ones currently
            // requested thumbnails.
            loadSpecifiedOnly = true;
        }
		
        // Rebuild the complete queue.
        rebuildQueue();
		
        // Initialize the production of thumbnails. This will load one page at
        // a time, until all pages have been loaded once.
        if (maximumLoaded < pages.length && !loadSpecifiedOnly) {
            makeThumbs();
        }
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * Sets the page for which to generate the thumbnails next - this does not
     * mean that the thumbnail is generated instantly, just that the next
     * thumbnail that will be generated will be that of the given page.
     * 
     * @param page
     *          the page for which to generate the thumbnail.
     */
    internal function prioritizeThumbForPage(page:uint):void {
        // If everything is done already ignore the command.
        if (areAllThumbsDone) {
            return;
        }
        // Clear the request queue if only loading specified.
        if (loadSpecifiedOnly) {
            loadPreferred = new Array();
        }
        // Make sure it's even.
        page += page & 1;
        // Add the page and its left neighbour to the request queue if they have
        // not been loaded once before.
        if (pages.length > page && page >= 0
                && !(pages[page] as Page).hasCachedThumb(true))
        {
            loadPreferred.push(page);
        }
        if (pages.length > page - 1 && page - 1 >= 0
                && !(pages[page - 1] as Page).hasCachedThumb(false))
        {
            loadPreferred.push(page - 1);
        }
        // Start loading if not active and there is something to load.
        if (loadPreferred.length > 0 && !isThumbnailLoadingActive) {
            makeThumbs();
        }
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * When the page changes in the megazine update the loaded pages.
     * 
     * @param e
     *          used to retrieve the new current page.
     */
    private function handlePageChange(e:MegaZineEvent):void {
        if (!settings.waitForNoTurning
                || e.newState != DragHandler.PAGES_TURNING)
        {
            // Shift the queue to continue loading in the right place
            currentPage = e.page;
            // Instead of completely rebuilding the queue it might be faster to
            // rearrange it, but as the queue will never be overly large (books
            // only have that much of a sensible size) I don't think it matters
            // much. Also, removing from the queue responsible for the element
            // loading will be a little inefficient, so...
            delayTimer.reset();
            delayTimer.start();
        } else {
            // Cancel pending rebuilds...
            delayTimer.stop();
        }
    }

    /**
     * Trigger a delayed queue rebuild...
     * 
     * @param e
     *          unused.
     */
    private function delayedRebuild(e:TimerEvent):void {
        rebuildQueue();
    }

    /**
     * Rebuild the complete loading queue, discarding the old one.
     */
    private function rebuildQueue():void {
        var queue:LinkedList = new LinkedList();
        var i:int;
        // Load pages, left right, left right, ...
        // This was originally meant to make pages closer to the current page
        // load first, which is unimportant since now elements have priorities,
        // and those priorities also take into account the distance of the
        // containing page to the current page. It is still ok this way, I
        // think, as the loop only need half the normal iterations.
        for (i = 0; i < (maximumLoaded >> 1); i++) {
            queue.push(currentPage - i);
            queue.push(currentPage + 1 + i);
        }
        for (i = 0; i < pages.length; i++) {
            if (Math.abs(currentPage - i) >= (maximumLoaded >> 1)) {
                (pages[i] as Page).unload((i & 1) == 0, elementLoader);
            }
        }
        // Process pages
        while (queue.hasElements) {
            var page:uint = queue.pop();
            if (page < 0 || page >= pages.length) continue;
            var even:Boolean = (page & 1) == 0;
            var s:String = (pages[page] as Page).getLoadState(even);
            if (s == Constants.PAGE_UNLOADED
                    || s == Constants.PAGE_LOADING_THUMB)
            {
                (pages[page] as Page).load(even, elementLoader);
            }
        }
    }

    /**
     * Generate all thumbnails by once loading all pages in background and then
     * unloading them again.
     * 
     * @param page
     *          the number of the page to generate the thumbnail for.
     */
    private function makeThumbs(page:uint = 0):void {
        // Producing thumbnails...
        isThumbnailLoadingActive = true;
        // Check if there are preferred pages, if there are none and only
        // specified pages are to be loaded stop loading.
        if (loadPreferred.length > 0) {
            page = loadPreferred.pop();
        } else if (loadSpecifiedOnly) {
            isThumbnailLoadingActive = false;
            return;
        }
        while (page < pages.length) {
            var even:Boolean = (page & 1) == 0;
            // Check if the page was already loaded, if yes try the next one...
            if (!loadedOnce[page] && (pages[page] as Page).
                    getLoadState(even) == Constants.PAGE_UNLOADED)
            {
                (pages[page] as Page).addEventListener(
                        MegaZineEvent.PAGE_COMPLETE, thumbDone);
                (pages[page] as Page).load(even, elementLoader, true);
                // Started one, and we only load one thumb at a time, so exit
                // here.
                return;
            }
            // Don't try to generate more when only loading specified, but try
            // the next one form the preferred pages array.
            if (loadSpecifiedOnly) {
                setTimeout(makeThumbs, 100);
                return;
            }
            page++;
        }
        // Walked the whole array, check again just to make sure... this is
        // necessary, because we might have skipped one page because it was
        // loading but the loading progress was cancelled due to a page turn
        // before it could generate a thumbnail.
        for (var i:uint = 0;i < loadedOnce.length; i++) {
            if (!loadedOnce[i]) {
                // One unloaded entry, try it (with a certain delay so that the
                // display does not get choppy)
                setTimeout(makeThumbs, 1000, i);
                return;
            }
        }
        isThumbnailLoadingActive = false;
        areAllThumbsDone = true;
    }

    /**
     * A page we generated a thumbnail for finished loading...
     * @param e the event telling which page finished loading.
     */
    private function thumbDone(e:MegaZineEvent):void {
        // Remove listener
        (pages[e.page] as Page).removeEventListener(
                MegaZineEvent.PAGE_COMPLETE, thumbDone);
        // Continue with the next thumb
        setTimeout(makeThumbs, 100, e.page + 1);
    }
}
} // end package
