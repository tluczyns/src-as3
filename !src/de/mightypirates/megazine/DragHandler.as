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
import de.mightypirates.megazine.gui.Cursor;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.utils.*;

/**
 * Dispatched when the cursor enters the draggable area.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.DRAGAREA_ENTER
 */
[Event(name = 'dragarea_enter',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the cursor leaves the draggable area.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.DRAGAREA_LEAVE
 */
[Event(name = 'dragarea_leave',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the current main page changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_CHANGE
 */
[Event(name = 'page_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when pages start turning or all pages finished turning.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.STATUS_CHANGE
 */
[Event(name = 'status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * The DragHandler class is responsible for handling user mouse input triggering
 * page dragging or turning, and for making pages turn.
 * 
 * <p>
 * It also handles api calls triggering page turns. This class makes sure only a
 * certain number of pages can be turned at a time, that the direction cannot be
 * reversed while turning, plays back the page sounds (e.g. when starting to
 * drag manually) and sets the displayed cursor when dragging.
 * </p>
 * 
 * <p>
 * It updates the position where a currently dragged page should be dragged to
 * (the cursor position).
 * </p>
 * 
 * <p>
 * Actual page turn animation is handled by the Page objects.
 * </p>
 * 
 * @author fnuecke
 */
internal class DragHandler extends EventDispatcher {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** State when no pages are currently turning */
    internal static const NO_PAGES_TURNING:String = "no_pages_turning";

    /** State when a page is passively dragged by a user */
    internal static const PAGE_DRAGGED:String = "page_dragged";

    /** State when some pages are turning */
    internal static const PAGES_TURNING:String = "pages_turning";

    /** Cursor near any edge */
    private static const CURSOR_NOWHERE:int = 0; // 0000
	
    /** Cursor is near the left edge */
    private static const CURSOR_LEFT:int = 1; // 0001
	
    /** Cursor is near the right edge */
    private static const CURSOR_RIGHT:int = 2; // 0010
	
    /** Cursor is near the top edge */
    private static const CURSOR_TOP:int = 4; // 0100
	
    /** Cursor is near the bottom edge */
    private static const CURSOR_BOTTOM:int = 8; // 1000
	
	
    /** Sound when starting to drag manually */
    private static const SOUND_DRAG:uint = 0;

    /** Sound when restoring a page after dragging */
    private static const SOUND_RESTORE:uint = 1;

    /** Sound when completing a page turn */
    private static const SOUND_TURN:uint = 2;

    /** Sound when starting to drag a stiff page */
    private static const SOUND_DRAGSTIFF:uint = 3;

    /** Sound when finishing the pageturn of a stiff page */
    private static const SOUND_ENDSTIFF:uint = 4;

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Settings used by megazine instance */
    private var settings:Settings;

    /**
     * Set to true while flipping over multiple pages, disabling interactivity
     * with the pages during that time.
     */
    private var isAutoTurning:Boolean = false;

    /** Currently hinting corners are draggable */
    private var isCornerHintActive:Boolean = false;

    /** Current angle for the hint animation */
    private var cornerHintAngle:Number = 0;

    /** Base position for the hinting drag */
    private var cornerHintBase:Vector2D;

    /** Radius to use for the hinting animation */
    private var cornerHintRadius:Number;

    /** Timer used for the hinting animation */
    private var cornerHintTimer:Timer;

    /** Cursor not on stage */
    private var cursorOut:int = 0;

    /** Current main page */
    private var currentPage:uint;

    /** Cursor currently in draggable area? */
    private var isCursorInDragArea:Boolean = false;

    /**
     * Temporarily disable userinteraction, e.g. when settings or help is open.
     */
    private var isDisabled:Boolean;

    /** The page currently being dragged */
    private var draggedPage:Page;

    /**
     * The point where the current drag started (to check if it was a click).
     */
    private var dragStart:Vector2D;

    /**
     * Tells if the last drag or page turn was left to right or right to left.
     */
    private var isLeftToRight:Boolean = false;

    /** The MegaZine object this handler belongs to */
    private var megazine:MegaZine;

    /**
     * Array with all pages in the megazine, references to the same array as the
     * one in the MegaZine instance.
     */
    private var pages:Array; // Page
	
    /**
     * Holds all even pages, needed for fast depth changes when the
     * page turn direction changes.
     */
    private var pagesEven:DisplayObjectContainer;

    /**
     * Holds all odd pages, needed for fast depth changes when the
     * page turn direction changes.
     */
    private var pagesOdd:DisplayObjectContainer;

    /** Page turning/dragging/restoring sounds */
    private var pageSounds:Array; // Array // Sound
	
    /** Pages currently animated - for quality control */
    private var pagesTurning:int = 0;

    /** The page currently being restored */
    private var pageBeingRestored:Page;

    /**
     * Number of different sound types currently being loaded.
     * Used to determine when loading is completed.
     */
    private var soundsLoading:uint;

    /** The last stage object the owning megazine was on (for listeners) */
    private var stage:Stage;

    /** Current state (turning / non turning) */
    private var state_:String = NO_PAGES_TURNING;

    /**
     * Indicates if we can do the next pageturn already, and if not how many
     * more calculations (redrawTimed) we have to wait.
     */
    private var waitNextTurn:uint = 0;
    
    /** Clean up helper */
    private var cleanUpSupport:CleanUpSupport;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new drag handler for a megazine, handling user mouse
     * interaction and page turning triggered via the gotoPage method.
     * 
     * @param megazine
     *          the MegaZine the handler should belong to.
     * @param pages
     *          list of all pages in the book. Will be kept as a reference.
     * @param pagesOdd
     *          container of odd pages.
     * @param pagesEven
     *          container of even pages.
     */
    public function DragHandler(megazine:MegaZine, pages:Array,
            pagesOdd:DisplayObjectContainer, pagesEven:DisplayObjectContainer)
    {
		
        this.megazine = megazine;
        this.pages = pages;
        this.pagesEven = pagesEven;
        this.pagesOdd = pagesOdd;
		
		cleanUpSupport = new CleanUpSupport();
		
        dragStart = new Vector2D();
		
        // Only use the listeners while megazine is on the stage
        cleanUpSupport.make(megazine, Event.ADDED_TO_STAGE, registerListeners);
        cleanUpSupport.make(megazine, Event.REMOVED_FROM_STAGE,
            function(e:Event):void {
            	cleanUpSupport.cleanup();
            });
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * Tells whether any pages are currently turning or if all pages are still.
     */
    internal function get arePagesTurning():Boolean {
        return pagesTurning > 0;
    }

    /** User interaction via mouse disabled or not */
    internal function get enabled():Boolean {
        return !isDisabled;
    }

    /** User interaction via mouse disabled or not */
    internal function set enabled(setTo:Boolean):void {
        isDisabled = !setTo;
    }

    // ---------------------------------------------------------------------- //
    // Secondary initialization
    // ---------------------------------------------------------------------- //
	
    /**
     * Page turn complete handler and other updating.
     * 
     * @param page the page to register.
     */
    internal function registerPage(page:IPage):void {
        cleanUpSupport.make(page, MegaZineEvent.STATUS_CHANGE, turnComplete);
		
		// Cancel current drags.
        cancelDrag(true);
        
        // Stop all page turning animations
        for each (var p:Page in pages) {
            p.resetPage();
        }
        
        // Update the depths
        updateDepths();
        // And visibility
        updateVisibility();
    }

    /**
     * Sets variables read from the xml configuration.
     * 
     * @param settings
     *          settings object containing book specific options.
     * @param currentPage
     *          current main page in book.
     */
    internal function setup(settings:Settings, currentPage:uint):void {
        this.settings = settings;
		
        // Begin loading the sounds in the background.
        if (settings.usePageTurnSounds) {
        	// [drag, restore, turn, dragstiff, endstiff]
            pageSounds = new Array(new Array(settings.pageSoundCount[0]),
                          new Array(settings.pageSoundCount[1]),
                          new Array(settings.pageSoundCount[2]),
                          new Array(settings.pageSoundCount[3]),
                          new Array(settings.pageSoundCount[4]));
            soundsLoading = 5;
            loadSound(SOUND_DRAGSTIFF);
            loadSound(SOUND_ENDSTIFF);
            loadSound(SOUND_DRAG);
            loadSound(SOUND_RESTORE);
            loadSound(SOUND_TURN);
        }
		
        // Go to initial page (without sound, though)
        handleMute();
        gotoPage(currentPage, true);
        if (!megazine.muted) handleUnmute();
		
        if (settings.cornerHint) {
            setTimeout(beginCornerHint, 1000);
        }
    }

    // ---------------------------------------------------------------------- //
    // Listener handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Register listeners for mouse events.
     * 
     * @param e
     *          unused.
     */
    private function registerListeners(e:Event = null):void {
		
        stage = megazine.stage;
		
        // Mouse event listener
        // Note: using the stage here, because otherwise it would not fire as
        // soon as the cursor leaves the pages - causing the pages not to be
        // dragged any longer. Which obviously sucks.
        cleanUpSupport.make(stage, MouseEvent.MOUSE_MOVE, handleMouseMovement);
        cleanUpSupport.make(stage, MouseEvent.MOUSE_DOWN, handleMouseDown);
        cleanUpSupport.make(stage, MouseEvent.MOUSE_UP, handleMouseUp);
		
        // Mouse leaves the stage
        cleanUpSupport.make(stage, Event.MOUSE_LEAVE, handleMouseLeave);
        cleanUpSupport.make(stage, Event.ENTER_FRAME, handleUpdate);
		
        // Muting / unmuting
        cleanUpSupport.make(megazine, MegaZineEvent.MUTE, handleMute);
        cleanUpSupport.make(megazine, MegaZineEvent.UNMUTE, handleUnmute);
    }

    // ---------------------------------------------------------------------- //
    // Input event handlers for mouse
    // ---------------------------------------------------------------------- //
	
    /**
     * Handle mouse downs.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseDown(e:MouseEvent):void {
		
        // Disable hinting on clicks...
        if (isCornerHintActive) {
            return;
        }
		
        // Disable all interactivity with the pages during autoturning
        if (isAutoTurning || !pagesOdd.visible
                || !pagesEven.visible || isDisabled)
        {
            return;
        }
		
        if (!draggedPage) {
			
            // No dragging yet, try to begin edge dragging
            beginDrag(getCursorPosition());
        } else if (draggedPage.state != Constants.PAGE_READY
                 && draggedPage.state != Constants.PAGE_DRAGGING)
         {
            return;
        }
		
        if (draggedPage) {
            draggedPage.beginUserDrag();
			
            // Play sound
            playSoundOfType(draggedPage.isStiff ? SOUND_DRAGSTIFF : SOUND_DRAG);
        }
        dragStart.setTo(megazine.pageContainer.mouseX,
                megazine.pageContainer.mouseY);
    }

    /**
     * Handle the mouse leaving the stage. If autodragging cancel the drag.
     * Note that a mousemove event is fired after the mouse leave event, so we
     * have to remember that we left, to avoid the autodrag being reinitiated.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseLeave(e:Event):void {
        // Continue hinting when leaving stage.
        if (isCornerHintActive) {
            return;
        }
		
        // Remember that the cursor left the stage
        cursorOut = 1;
		
        if (draggedPage == null
                || draggedPage.state != Constants.PAGE_DRAGGING_USER)
        {
            Cursor.cursor = Cursor.DEFAULT;
            Cursor.visible = true;
            cancelDrag();
        }
    }

    /**
     * Handle mousemovements, these can trigger an automatic drag if near
     * corners and update the position of the drag target if a page is dragged.
     * 
     * @param e
     *          unused.
     */
    internal function handleMouseMovement(e:Event = null):void {
        // This is to fix the problem with the mouse move event being fired once
        // even after the mouse leave event was fired.
        if (cursorOut > 0) {
            cursorOut--;
            return;
        }
		
        // Disable all interactivity with the pages during autoturning
        if (isAutoTurning || !pagesOdd.visible
                || !pagesEven.visible || isDisabled)
        {
            return;
        }
		
        var curPos:int = getCursorPosition();
        var inDragArea:Boolean = (curPos & CURSOR_LEFT) > 0
                || (curPos & CURSOR_RIGHT) > 0;
		
        if (inDragArea && !isCursorInDragArea) {
            // Disable hinting when entering a dragarea...
            if (isCornerHintActive) {
                stopCursorHint();
            }
            isCursorInDragArea = true;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.DRAGAREA_ENTER));
        } else if (!inDragArea && isCursorInDragArea) {
            isCursorInDragArea = false;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.DRAGAREA_LEAVE));
        }
		
        // Ignore mouse moves when hinting...
        if (isCornerHintActive) {
            return;
        }
		
        var inCorner:Boolean = (curPos & (CURSOR_LEFT | CURSOR_RIGHT)) > 0
                && (curPos & (CURSOR_TOP | CURSOR_BOTTOM)) > 0;
		
        // Check if the page is being dragged. If not, check if cursor
        // is in a corner.
        if (draggedPage != null && (draggedPage.state == Constants.PAGE_DRAGGING
                || draggedPage.state == Constants.PAGE_DRAGGING_USER))
        {
            if (inCorner || draggedPage.state == Constants.PAGE_DRAGGING_USER) {
                // Manually dragging or in range, update target
                draggedPage.setDragTarget(
                        new Vector2D(megazine.pageContainer.mouseX,
                                megazine.pageContainer.mouseY));
            } else {
                // Dragging automatically but not near a corner: cancel the drag
                cancelDrag();
            }
        } else if (inCorner) {
            // OK, it's a corner, begin dragging
            // (only for non stiff pages, though).
            var p:Page = pages[(curPos & CURSOR_LEFT)
                    ? currentPage - 1
                    : currentPage];
            if (p != null && !p.isStiff) {
                beginDrag(curPos);
            }
        }
		
        // Update cursor visibility / type
        if (pagesOdd.visible && pagesEven.visible) {
            if (pages[currentPage - 1] && (curPos & CURSOR_LEFT)) {
                if (settings.handCursor) {
                    megazine.pageContainer.buttonMode = true;
                }
                if (Cursor.cursor != Cursor.TURN_LEFT
                        && Cursor.cursor != Cursor.TURN_RIGHT)
                {
                    Cursor.cursor = Cursor.TURN_LEFT;
                }
            } else if (pages[currentPage] && (curPos & CURSOR_RIGHT)) {
                if (settings.handCursor) {
                    megazine.pageContainer.buttonMode = true;
                }
                if (Cursor.cursor != Cursor.TURN_LEFT
                        && Cursor.cursor != Cursor.TURN_RIGHT)
                {
                    Cursor.cursor = Cursor.TURN_RIGHT;
                }
            } else if (!draggedPage) {
                if (settings.handCursor) {
                    megazine.pageContainer.buttonMode = false;
                }
                if (Cursor.cursor == Cursor.TURN_LEFT
                        || Cursor.cursor == Cursor.TURN_RIGHT)
                {
                    Cursor.cursor = Cursor.DEFAULT;
                }
            }
        }
    }

    /**
     * Handle mouse releases.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseUp(e:MouseEvent):void {
		
        // Disable hinting on clicks...
        if (isCornerHintActive) {
            stopCursorHint();
        }
		
        // Update cursor image visibility
        Cursor.cursor = Cursor.DEFAULT;
		
        // Disable all interactivity with the pages during autoturning
        if (isAutoTurning || !pagesOdd.visible
                || !pagesEven.visible || isDisabled)
        {
            return;
        }
		
        if (draggedPage && (draggedPage.state == Constants.PAGE_DRAGGING
                || draggedPage.state == Constants.PAGE_DRAGGING_USER))
        {
			
            // Conditions for a completed pageturn are the cursor being in range
            // of the point where it started (click), or far enough away
            // (_mz.getPageWidth()).
            var dist:Number = dragStart.distance(
                    new Vector2D(megazine.pageContainer.mouseX,
                            megazine.pageContainer.mouseY));
            if (dist < settings.dragRange || dist > megazine.pageWidth) {
				
                // Complete the turn
                if (turnPage(isLeftToRight) && !pages[isLeftToRight
                        ? currentPage
                        : currentPage - 1].isStiff)
                {
                    playSoundOfType(SOUND_TURN);
                }
            } else {
				
                // Cancel the drag and return to the old position
                cancelDrag();
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Dragging and turning pages
    // ---------------------------------------------------------------------- //
	
    /**
     * Start dragging a page.
     * 
     * @param fromPosition
     *          the area from where to start defined via the CURSOR_ constants.
     */
    private function beginDrag(fromPosition:int):void {
		
        // If _waitNextTurn > 0 we don't do anything
        if (waitNextTurn) {
            return;
        }
		
        // Check which way to turn
        var leftToRight:Boolean = Boolean(fromPosition & CURSOR_LEFT);
		
        // Check if the rightToLeft is valid, else cancel
        if (!leftToRight && !(fromPosition & CURSOR_RIGHT)) {
            return;
        }
		
        // Get the page we need to drag
        draggedPage = pages[leftToRight ? currentPage - 2 : currentPage];
		
        // If the _draggedPage is null cancel (the page does not exist)
        if (!draggedPage) {
            return;
        }
		
        // Check if the page can be dragged
        if (draggedPage.state == Constants.PAGE_READY) {
			
            // OK, get the dragging offset
            var dragOffset:Number = 0;
            if (fromPosition & (CURSOR_BOTTOM | CURSOR_TOP)) {
				
                // It's close to the top or bottom, so make it a corner drag
                dragOffset = fromPosition & CURSOR_BOTTOM
                        ? megazine.pageHeight
                        : 0;
            } else {
				
                // Somewhere inbetween, make it an edge drag
                dragOffset = megazine.pageContainer.mouseY;
            }
			
            isLeftToRight = leftToRight;
			
            // And begin the drag
            if (isCornerHintActive) {
                draggedPage.beginDrag(getCornerHintPos(), dragOffset,
                        isLeftToRight);
            } else {
                draggedPage.beginDrag(
                        new Vector2D(megazine.pageContainer.mouseX,
                                megazine.pageContainer.mouseY),
                        dragOffset, isLeftToRight);
            }
			
            // And update the page order
            updateDepths();
			
            // Update page visibility (make pages dragging towards visible)
            try {
                var current:uint = currentPage;
                if (isLeftToRight) {
                    current -= 2;
                    (pages[current] as Page).pageEven.visible = true;
                    (pages[current - 2] as Page).pageOdd.visible = true;
                    while (((pages[current - 2] as Page).
                            getBackgroundColor(false) >>> 24) < 255)
                    {
                        current -= 2;
                        (pages[current - 2] as Page).pageOdd.visible = true;
                    }
                } else {
                    current += 2;
                    (pages[current - 2] as Page).pageOdd.visible = true;
                    (pages[current] as Page).pageEven.visible = true;
                    while (((pages[current] as Page).
                            getBackgroundColor(true) >>> 24) < 255)
                    {
                        current += 2;
                        (pages[current] as Page).pageEven.visible = true;
                    }
                }
            } catch (e:Error) { /* _pages[X] invalid */ 
            }
        } else {
			
            // Page cannot be dragged... so forget about it
            draggedPage = null;
        }
		
        // No event when hinting.
        if (isCornerHintActive) {
            return;
        }
		
        var oldState:String = state_;
        if (draggedPage == null && state_ == PAGE_DRAGGED) {
            // Page cannot be dragged.
            state_ = NO_PAGES_TURNING;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                    currentPage, state_, oldState));
        } else if (draggedPage != null && state_ != PAGE_DRAGGED) {
            // Page gets dragged.
            state_ = PAGE_DRAGGED;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                    currentPage, state_, oldState));
        }
    }

    /**
     * Cancel the current page turning returning it to its previous state.
     * 
     * @param instant Instantly reset the dragged page.
     */
    private function cancelDrag(instant:Boolean = false):void {
		
        // Check if we're actually dragging a page
        if (draggedPage && (draggedPage.state == Constants.PAGE_DRAGGING
                || draggedPage.state == Constants.PAGE_DRAGGING_USER))
        {
			
            // Play sound if user drag.
            if (draggedPage.state == Constants.PAGE_DRAGGING_USER
                    && !draggedPage.isStiff)
            {
                playSoundOfType(SOUND_RESTORE);
            }
            // Cancel the drag, then forget about the page
            if (!instant) {
                pageBeingRestored = draggedPage;
            }
            draggedPage.cancelDrag(instant);
            draggedPage = null;
			
            if (state_ != NO_PAGES_TURNING) {
                var oldState:String = state_;
                state_ = pagesTurning > 0 ? PAGES_TURNING : NO_PAGES_TURNING;
                dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                        currentPage, state_, oldState));
            }
        }
    }

    /**
     * Check if the cursor is near any edges, and if yes which.
     * 
     * @return a combination of the cursor position constants.
     */
    private function getCursorPosition():int {
        var ret:int = CURSOR_NOWHERE;
		
        // Check if the cursor is over the pages at all
        if (megazine.pageContainer.mouseX > 0
                && megazine.pageContainer.mouseX < megazine.pageWidth * 2
                && megazine.pageContainer.mouseY > 0
                && megazine.pageContainer.mouseY < megazine.pageHeight)
        {
			
            // Top of bottom
            if (megazine.pageContainer.mouseY < settings.dragRange) {
                // Top
                ret |= CURSOR_TOP;
            } else if (megazine.pageContainer.mouseY > megazine.pageHeight
                    - settings.dragRange)
            {
                // Bottom
                ret |= CURSOR_BOTTOM;
            } else if (settings.ignoreSides) {
                return CURSOR_NOWHERE;
            }
			
            // Left or right
            if (megazine.pageContainer.mouseX < settings.dragRange) {
                // Left
                ret |= CURSOR_LEFT;
            } else if (megazine.pageContainer.mouseX > megazine.pageWidth * 2
                    - settings.dragRange)
            {
                // Right
                ret |= CURSOR_RIGHT;
            }
        }
		
        return ret;
    }

    /**
     * Go to the page with the specified number. If the number does not exist
     * the method call is ignored. Numeration begins with zero.
     * If there is currently a page turn animation in progress this method does
     * nothing.
     * 
     * @param page
     *          the number of the page to go to.
     * @param instant
     *          no animation, but instant setting.
     */
    public function gotoPage(page:int, instant:Boolean = false):void {
    	// Ignore impossible gotos
        if (page < 0 || page > pages.length) {
        	return;
        }
        
        // Restoring a page? If so, hurry it up.
        if (pageBeingRestored != null
                && pageBeingRestored.state == Constants.PAGE_RESTORING)
        {
        	pageBeingRestored.resetPage();
        }
        
        // Make it an even page number
        page += page & 1;
		
        // Disable all interactivity with the pages during autoturning, also
        // don't turn if dragging manually.
         // Check if the page is valid, i.e. if it exists, and if we're not
         // already there.
        if (isAutoTurning || (draggedPage
                && (draggedPage.state == Constants.PAGE_DRAGGING_USER))
                || (pagesTurning > 0 && (page < currentPage) != isLeftToRight)
			    || page == currentPage)
	    {
            return;
        }
		
        // How many pages have to be turned?
        var count:int = currentPage - page;
        count = (count < 0 ? -count : count) >>> 1;
		
        // Check if we're currently dragging a page, and if yes, if it's in the
        // same direction. If not, cancel the drag first.
        if (count > settings.instantJumpCount || (draggedPage
                && int(page < currentPage) ^ int(draggedPage.getNumber(true)
                        < currentPage)))
        {
            // Instantly (depths cant be right when dragging in both directions
            // at once).
            cancelDrag(true);
        }
		
        // Trigger the page turn in the proper direction, with the necessary
        // amount of turns, and a delay that is directly inversely proportional
        // to the number of pages turned, so that the total time needed stays
        // constant.
        if (turnPage(page < currentPage
                ? true
                : false, count, instant ? 0 : 500 / count))
        {
            // Play sound
            try {
                playSoundOfType(pages[isLeftToRight
                        ? currentPage
                        : currentPage - 2].isStiff
                                ? SOUND_DRAGSTIFF
                                : SOUND_TURN);
            } catch (e:Error) { 
            }
        }
    }

    /**
     * Updates visibility after a page movement is complete by hiding the old
     * pages.
     * If one of it (which on depends on the turning direction of course) is
     * still visible due to the new page's invisibility do not hide it, though.
     * Also reduce count of pages currently turning and adjust movie quality
     * accordingly.
     * 
     * @param e
     *          used to get which page finished.
     */
    private function turnComplete(e:MegaZineEvent):void {
        if (e.newState != Constants.PAGE_READY) {
            return;
        }
		
        try {
            var current:uint = e.page;
            // Depending on where we were turning, and whether we were restoring
            // or completed a turn update visibility.
            if (int(e.leftToRightTurn)
                    ^ int(e.previousState == Constants.PAGE_RESTORING))
            {
                (pages[e.page] as Page).pageOdd.visible = false;
                if (((pages[e.page] as Page).
                        getBackgroundColor(true) >>> 24) == 255)
                {
                    // Opaque, make all following visible pages invisible
                    while ((pages[current + 2] as Page).pageEven.visible) {
                        current += 2;
                        (pages[current] as Page).pageEven.visible = false;
                    }
                }
            } else {
                (pages[e.page] as Page).pageEven.visible = false;
                if (((pages[e.page] as Page).
                        getBackgroundColor(false) >>> 24) == 255)
                {
                    // Opaque, make all following visible pages invisible
                    while ((pages[current - 2] as Page).pageOdd.visible) {
                        current -= 2;
                        (pages[current] as Page).pageOdd.visible = false;
                    }
                }
            }
        } catch (ex:Error) { /* invalid page */ 
        }
		
        // Only when a turn was complete
        if (e.previousState == Constants.PAGE_TURNING) {
            // Reduce count of pages currently moving, and update the quality
            // if needed.
            pagesTurning = pagesTurning < 2 ? 0 : pagesTurning - 1;
            if (pagesTurning > settings.pagesToLowQuality) {
                stage.quality = StageQuality.LOW;
            } else if (pagesTurning > 0) {
                stage.quality = StageQuality.HIGH; //TŁ: StageQuality.MEDIUM;
            } else {
                stage.quality = StageQuality.HIGH;
            }
			
            if (pagesTurning < 1 && state_ != NO_PAGES_TURNING) {
                var oldState:String = state_;
                state_ = NO_PAGES_TURNING;
                dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                        currentPage, state_, oldState));
            }
			
            // Play sound if it was a stiff page.
            if ((e.target as Page).isStiff) {
                playSoundOfType(SOUND_ENDSTIFF);
            }
			
            if (draggedPage == null) {
                // Needs delayed execution to avoid graphical glitches
                // (highlights not getting cleared, which is actually pretty
                // weird)
                setTimeout(handleMouseMovement, 100);
            }
        }
    }

    /**
     * Turn the currently dragged page around completely, or turn the current
     * pages in the direction specified. If a page is currently dragged it is
     * assumed that that page sould be turned and all arguments are ignored.
     * 
     * @param leftToRight
     *          only used if not currently dragging a page. When used specifies
     *          in which direction to turn.
     * @param count
     *          how many pages to turn.
     * @param delay
     *          the delay in milliseconds between the pages start turning (only
     *          used if count > 1).
     * @return true if a page turn was triggered.
     */
    private function turnPage(leftToRight:Boolean, count:int = 1,
            delay:uint = 0):Boolean
    {
		
        var pageTurned:Page, pageOpposite:Page;
		
        // If waitNextTurn > 0 we cannot turn yet - but cancel any drag, just
        // to make sure. Overidden by automatic turning...
        if (waitNextTurn && !isAutoTurning) {
            if (draggedPage) {
                cancelDrag();
            }
            return false;
        }
		
        // Wait until we may do the next pageturn
        waitNextTurn = 1 / settings.dragSpeed;
        // Increase the wait time if the current page was a normal one and the
        // next is a stiff page, otherwise graphical glitches occur (well, it
        // looks kinda unrealistic).
        if (leftToRight && (!(pages[currentPage - 2] as Page).isStiff
                        && currentPage - 4 > 0
                        && (pages[currentPage - 4] as Page).isStiff)
                || !leftToRight && (!(pages[currentPage] as Page).isStiff
                        && currentPage + 2 < pages.length
                        && (pages[currentPage + 2] as Page).isStiff))
        {
            waitNextTurn *= 4;
        }
		
        // Currently dragging/moving?
        if (draggedPage) {
            // OK, turn the page and then forget about it
            pagesTurning++;
            draggedPage.turnPage(false, isLeftToRight);
            draggedPage = null;
        } else if (delay < 1 || count > settings.instantJumpCount) {
            // "Instant" turning (no parallel flipping)
            // No need to wait in that case
            waitNextTurn = 0;
            // Not dragging, check which way to turn, and if the turn is valid
            if (leftToRight && currentPage - count * 2 >= 0) {
                // Valid left to right turn
                currentPage = currentPage - count * 2;
            } else if (!leftToRight && currentPage
                    + count * 2 <= pages.length)
            {
                // Valid right to left turn
                currentPage = currentPage + count * 2;
            } else {
                // Invalid turn, cancel
                return false;
            }

            var i:int;
            for (i = currentPage;i < pages.length; i += 2) {
                (pages[i] as Page).turnPage(true, false);
            }
            for (i = currentPage - 1;i > 0; i -= 2) {
                (pages[i] as Page).turnPage(true, true);
            }
			
            // Update depths
            updateDepths();
			
            // Update page visibility
            updateVisibility();
			
            // Quality control reset (needed if pages are skipped while some
            // page turning is still in progress).
            stage.quality = StageQuality.HIGH;
            pagesTurning = 0;
			
            // Always force this event, otherwise loading of pages won't trigger
            // if an instant turn takes place.
            var oldState:String = state_;
            if (state_ == PAGES_TURNING) {
                state_ = NO_PAGES_TURNING;
            }
			
            // Fire an event, telling possible listeners of the new current page
            dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE,
                    currentPage, "", "", false, true));
			
            dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                    currentPage, state_, oldState));
			
            // First update after turn...
            setTimeout(handleMouseMovement, 100);
			
            return true;
        } else {
			
            // Not dragging, check which way to turn, and if the turn is valid
            if (leftToRight && pages[currentPage - 1]) {
                // Valid left to right turn
                pageTurned = pages[currentPage - 1];
                pageOpposite = pages[currentPage + 1];
            } else if (!leftToRight && pages[currentPage + 1]) {
                // Valid right to left turn
                pageTurned = pages[currentPage + 1];
                pageOpposite = pages[currentPage - 1];
            } else {
                // Invalid turn, cancel
                return false;
            }
			
            // Check if page is already being turned, an if the opposite page is
            // in the ready state when changing directions (otherwise graphical
            // errors arise).
            if (pageTurned.state != Constants.PAGE_READY
                    || (leftToRight != isLeftToRight && pageOpposite
                            && pageOpposite.state != Constants.PAGE_READY))
            {
                return false;
            }
			
            isLeftToRight = leftToRight;
			
            // Turn the page
            pagesTurning++;
            pageTurned.turnPage(false, isLeftToRight);
        }
		
        // Modify the current page counter appropriately
        if (isLeftToRight) {
            currentPage -= 2;
        } else {
            currentPage += 2;
        }
		
        // Fire an event, telling possible listeners of the new current page
        dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE,
                currentPage));
		
        if (pagesTurning > 0 && state_ == NO_PAGES_TURNING) {
            state_ = PAGES_TURNING;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                    currentPage, state_, NO_PAGES_TURNING));
        }
		
        // Update depths
        updateDepths();
		
        // Update page visibility (make target ones visible)
        try {
            var current:uint = currentPage;
            if (isLeftToRight) {
                (pages[currentPage] as Page).pageEven.visible = true;
                (pages[currentPage - 2] as Page).pageOdd.visible = true;
                while (((pages[current - 2] as Page).
                        getBackgroundColor(false) >>> 24) < 255)
                {
                    current -= 2;
                    (pages[current - 2] as Page).pageOdd.visible = true;
                }
            } else {
                (pages[currentPage - 2] as Page).pageOdd.visible = true;
                (pages[currentPage] as Page).pageEven.visible = true;
                while (((pages[current] as Page).
                        getBackgroundColor(true) >>> 24) < 255)
                {
                    current += 2;
                    (pages[current] as Page).pageEven.visible = true;
                }
            }
        } catch (e:Error) { /* _pages[X] invalid */ 
        }
		
        // Reduce stage quality if turning many _pages
        if (pagesTurning > settings.pagesToLowQuality) {
            stage.quality = StageQuality.LOW;
        } else if (pagesTurning > 0) {
            stage.quality = StageQuality.HIGH; //TŁ: StageQuality.MEDIUM;
        }
		
        // Call a delayed recursive call of this function, until the remaining
        // count is zero.
        if (count > 1) {
			
            isAutoTurning = true;
            var t:Timer;
            // Increase the wait time if the current page was a normal one and
            // the next is a stiff page, otherwise graphical glitches occur
            // (well, it looks kinda unrealistic).
            if (isLeftToRight && (!(pages[currentPage] as Page).isStiff
                    && (pages[currentPage - 1] as Page).isStiff)
                    || !isLeftToRight
                    && (!(pages[currentPage - 1] as Page).isStiff
                            && (pages[currentPage] as Page).isStiff))
            {
                t = new Timer(Math.max(stage.frameRate * 4 / settings.dragSpeed,
                        delay), 1);
            } else {
                t = new Timer(delay, 1);
            }
			
            cleanUpSupport.addTimer(t);
            cleanUpSupport.make(t, TimerEvent.TIMER,
                    function(e:TimerEvent):void {
                        if (turnPage(isLeftToRight, count - 1, delay)) {
                            // Play sound
                            playSoundOfType((pages[isLeftToRight
                                    ? currentPage
                                    : currentPage - 1] as Page).isStiff
                                            ? SOUND_DRAGSTIFF
                                            : SOUND_TURN);
                        }
                    });
            t.start();
        } else {
            isAutoTurning = false;
        }
		
        return true;
    }

    // ---------------------------------------------------------------------- //
    // Updating
    // ---------------------------------------------------------------------- //
	
    /**
     * Reduce wait count for next possible page turn each frame.
     * 
     * @param e
     *          unused.
     */
    private function handleUpdate(e:Event = null):void {
		
        // Reduce the wait count if greater than zero.
        if (waitNextTurn) {
            waitNextTurn--;
            if (!waitNextTurn) {
                handleMouseMovement();
            }
        }
    }

    /**
     * Updates the depths of pages. Depends on the direction we're turning.
     * When turning left to right the even pages must be on top of the odd ones,
     * else it's vice versa.
     */
    private function updateDepths():void {
		
        // Depends on where we currently turn. If we turn left, the even pages
        // need to be on to, else the odd ones have to be.
        if (int(!isLeftToRight) ^ int(megazine.pageContainer.
                getChildIndex(pagesEven) > megazine.pageContainer.
                        getChildIndex(pagesOdd)))
        {
            megazine.pageContainer.swapChildren(pagesEven, pagesOdd);
        }
    }

    /**
     * Updates page visibility for all _pages in the book. This means a complete
     * update, first hiding all _pages, then starting from the current one and
     * making all relevant one visible again (can be more due to invisible
     * pages).
     */
    private function updateVisibility():void {
		
		// First hide all _pages.
        for each (var p:Page in pages) {
            p.pageEven.visible = false;
            p.pageOdd.visible = false;
        }
		
        // Then make the required ones visible again, starting at the current
        // page. This is two times nearly the exact same procedure... once
        // forwards, once backwards.
		
        // Even pages - forwards.
        for (var i:int = currentPage; i < pages.length; i += 2) {
            // Test if the current page exists.
            if (pages[i] != undefined && (pages[i] as Page).pageEven) {
                // Make it visible.
                (pages[i] as Page).pageEven.visible = true;
                // Check if it is opaque / covers all _pages behind it.
                if ((((pages[i] as Page).
                        getBackgroundColor(true) >>> 24) == 255)
                        && (pages[i] as Page).state == Constants.PAGE_READY)
                {
                    // Jup, no more need for making _pages visible.
                    break;
                } else if ((pages[i] as Page).state != Constants.PAGE_READY
                        && (pages[i] as Page).pageOdd)
                {
                    // Page is being dragged, make the backside visible as well.
                    (pages[i] as Page).pageOdd.visible = true;
                }
            }
        }
		
        // Odd _pages - backwards.
        for (var j:int = currentPage - 1; j > 0; j -= 2) {
            // Test if the current page exists.
            if (pages[j] != undefined && (pages[j] as Page).pageOdd) {
                // Make it visible.
                (pages[j] as Page).pageOdd.visible = true;
                // Check if it is opaque / covers all _pages behind it.
                if ((((pages[j] as Page).
                        getBackgroundColor(false) >>> 24) >= 255)
                        && (pages[j] as Page).state == Constants.PAGE_READY)
                {
                    // Jup, no more need for making _pages visible.
                    break;
                } else if ((pages[j] as Page).state != Constants.PAGE_READY
                        && (pages[j] as Page).pageEven)
                {
                    // Page is being dragged, make the backside visible as well.
                    (pages[j] as Page).pageEven.visible = true;
                }
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Sounds
    // ---------------------------------------------------------------------- //
	
    /**
     * Try loading a sound of the given type.
     * 
     * @param type
     *          the sound type (name of the files).
     * @param num
     *          the running number of the sound.
     */
    private function loadSound(type:uint, num:int = 0):void {
        if (num >= pageSounds[type].length) {
            if (--soundsLoading < 1) {
                Logger.log("DragHandler", "All page sounds loaded.",
                        Logger.TYPE_NOTICE);
            }
            return;
        }
		
        var name:String;
        switch (type) {
            case 0:
                name = "drag";
                break;
            case 1:
                name = "restore";
                break;
            case 2:
                name = "turn";
                break;
            case 3:
                name = "dragstiff";
                break;
            case 4:
                name = "endstiff";
                break;
            default:
                // Invalid type, cancel.
                return;
        }
		
        var s:Sound = new Sound();
        cleanUpSupport.make(s, Event.COMPLETE,
                function(e:Event):void {
                    pageSounds[type][num] = e.target;
                    loadSound(type, num + 1);
                });
        cleanUpSupport.make(s, IOErrorEvent.IO_ERROR,
                function(e:IOErrorEvent):void {
    				// Not found, previous one was the last one.
                });
        try {
            s.load(new URLRequest(
                    megazine.getAbsPath("data/snd/" + name + num + ".mp3")), //TŁ
                    new SoundLoaderContext(1000, true));
        } catch (ex:SecurityError) {
            Logger.log("DragHandler",
                    "Could not load sound because of a security error.",
                    Logger.TYPE_WARNING);
        }
    }

    /**
     * Mute command from the owning megazine, disable page turn sounds.
     * @param e unused.
     */
    private function handleMute(e:MegaZineEvent = null):void {
        // First set page turn sounds
        if (settings != null) {
            settings.usePageTurnSounds = false;
        }
    }

    /**
     * Plays a random sound of the given type.
     * 
     * @param type
     *      the type of the required sound, can be "drag", "restore" or "turn".
     */
    private function playSoundOfType(type:uint):void {
        // Check if sounds are activated.
        if (!settings.usePageTurnSounds) {
            return;
        }
		
        // OK, check which sound type to play, pick a random one and play it.
        try {
            // Check if there are any sounds of that type...
            if (pageSounds[type].length > 0) {
                // Get a random id, cast to int and -0.5 to equalize chances
                // (due to the 0<n<1 thingy).
                pageSounds[type][uint(pageSounds[type].length * Math.random()
                        - 0.5)].play();
            }
        } catch (ex:Error) {
        }
    }

    /**
     * Unmute command from the owning megazine, enable page turn sounds.
     * @param e unused.
     */
    private function handleUnmute(e:MegaZineEvent = null):void {
        if (settings != null) {
            settings.usePageTurnSounds = pageSounds != null;
        }
    }

    // ---------------------------------------------------------------------- //
    // Corner hinting
    // ---------------------------------------------------------------------- //
	
    /**
     * Start hinting that corners are draggable.
     */
    private function beginCornerHint():void {
        if (draggedPage != null) {
            // User already dragged, no need for hinting.
            return;
        }
        isCornerHintActive = true;
        cornerHintTimer = new Timer(25);
        cleanUpSupport.addTimer(cornerHintTimer);
        cleanUpSupport.make(cornerHintTimer, TimerEvent.TIMER,
                handleCornerTimer);
        cornerHintRadius = settings.dragRange / 4;
		
        if (settings.readingOrderLTR) {
            cornerHintBase = new Vector2D(
                    megazine.pageWidth * 2 - settings.dragRange / 2,
                    megazine.pageHeight - settings.dragRange / 2);
            beginDrag(CURSOR_RIGHT | CURSOR_BOTTOM);
        } else {
            cornerHintBase = new Vector2D(
                    settings.dragRange / 2,
                    megazine.pageHeight - settings.dragRange / 2);
            beginDrag(CURSOR_LEFT | CURSOR_BOTTOM);
        }
		
        cornerHintTimer.start();
    }

    /**
     * Cancel hinting that corners are draggable.
     * 
     * @param instant
     *          instantly stop dragging hint.
     */
    private function stopCursorHint(instant:Boolean = false):void {
        isCornerHintActive = false;
        cornerHintTimer.stop();
        cancelDrag(instant);
    }

    /**
     * Get current position for hinting based on angle and radius.
     * 
     * @return current position.
     */
    private function getCornerHintPos():Vector2D {
        return cornerHintBase.plus(new Vector2D(
                Math.sin(cornerHintAngle) * cornerHintRadius,
                Math.cos(cornerHintAngle) * cornerHintRadius / 2));
    }

    /**
     * Update hinting animation.
     * 
     * @param e
     *          unused.
     */
    private function handleCornerTimer(e:TimerEvent):void {
        if (draggedPage == null) {
            cornerHintTimer.stop();
            return;
        }
        cornerHintAngle += 0.05;
        draggedPage.setDragTarget(getCornerHintPos());
    }
}
} // end package
