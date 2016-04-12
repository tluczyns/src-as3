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
import de.mightypirates.megazine.*;
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.geom.ColorTransform;
import flash.system.Capabilities;
import flash.utils.Dictionary;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.utils.Timer;

/**
 * Dispatched when a button in the navigation is clicked. See the subtypes of
 * the NavigationEvent for possible subtypes (telling which button was clicked).
 * 
 * @eventType de.mightypirates.megazine.events.NavigationEvent.BUTTON_CLICK
 */
[Event(name = 'button_click',
        type = 'de.mightypirates.megazine.events.NavigationEvent')]

/**
 * The navigation bar.
 * 
 * @author fnuecke
 */
public class Navigation extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** Spacing between the page numbers and the navigation (minimum) */
    private static const SPACING:Number = 25.0;

    /** Border of the thumbnail window */
    private static const THUMB_BORDER:Number = 10.0;

    /** Buttons definitions for the navigation bar. */
    private static const BUTTONS:Object = {
		// Button descriptor:
		// name = the name of the button, as used in the buttonHide Array.
		// states = button states, for toggleable buttons.
		// in states:
		// btn = the button to use from the library.
		// tooltip = the tooltip to show.
		// event = the event type of the NavigationEvent that is fired when the
	    //         button is clicked.
		// 
		// For technical reasons (too many necessary parameters not available
		// here) listener functions that toggle the button state must be set
		// manually. Use the registerEventListeners and removeEventListeners
		// functions for setup.
		// 
		// Special entries (such as the language chooser) must be defined in the
		// actual initializing code in the constructor. The place is marked
		// rather clearly with two commented lines.
		
		// Buttons left and right to the pagination
		left : [{
				name : "fullscreen",
				    states : [{
						btn     : LibraryConstants.BUTTON_FULLSCREEN,
						tooltip : "LNG_FULLSCREEN",
						event   : NavigationEvent.FULLSCREEN
					},
					{
						btn     : LibraryConstants.BUTTON_RESTORE,
						tooltip : "LNG_RESTORE",
						event   : NavigationEvent.RESTORE
					}]
			},
			{
				name : "slideshow",
				    states : [{
						btn     : LibraryConstants.BUTTON_PLAY,
						tooltip : "LNG_SLIDESHOW_START",
						event   : NavigationEvent.PLAY
					},
					{
						btn     : LibraryConstants.BUTTON_PAUSE,
						tooltip : "LNG_SLIDESHOW_STOP",
						event   : NavigationEvent.PAUSE
					}]
			},
			{
				name : "goto",
				    states : [{
						btn     : LibraryConstants.BUTTON_GOTO,
						tooltip : "LNG_GOTO_PAGE_DIALOG",
						event   : NavigationEvent.GOTO_PAGE_DIALOG
					}]
			},
			{
				name : "first",
				    states : [{
						btn     : LibraryConstants.BUTTON_PAGE_FIRST,
						tooltip : "LNG_FIRST_PAGE",
						event   : NavigationEvent.PAGE_FIRST
					}]
			},
			{
				name : "prev",
				    states : [{
						btn     : LibraryConstants.BUTTON_PAGE_PREV,
						tooltip : "LNG_PREV_PAGE",
						event   : NavigationEvent.PAGE_PREV
					}]
			}], right : [{
				name : "next",
				    states : [{
						btn     : LibraryConstants.BUTTON_PAGE_NEXT,
						tooltip : "LNG_NEXT_PAGE",
						event   : NavigationEvent.PAGE_NEXT
					}]
			},
			{
				name : "last",
				    states : [{
						btn     : LibraryConstants.BUTTON_PAGE_LAST,
						tooltip : "LNG_LAST_PAGE",
						event   : NavigationEvent.PAGE_LAST
					}]
			},
			{
				name : "mute",
				    states : [{
						btn     : LibraryConstants.BUTTON_MUTE,
						tooltip : "LNG_MUTE",
						event   : NavigationEvent.MUTE
					},
					{
						btn     : LibraryConstants.BUTTON_UNMUTE,
						tooltip : "LNG_UNMUTE",
						event   : NavigationEvent.UNMUTE
					}]
			},
			{
				name : "settings",
				    states : [{
						btn     : LibraryConstants.BUTTON_SETTINGS,
						tooltip : "LNG_SETTINGS",
						event   : NavigationEvent.SETTINGS
					}]
			},
			{
				name : "help",
				    states : [{
						btn     : LibraryConstants.BUTTON_HELP,
						tooltip : "LNG_HELP",
						event   : NavigationEvent.HELP
					}]
			},
			{
				// This one receives special treatment internally, because it
				// need to use a special class, not an object from the library.
				name : "language"
			}]
	};

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Background image - needed here for resizing */
    private var background:DisplayObject;

    /** Container for all buttons (for masking) */
    private var buttonContainer:DisplayObjectContainer;

    /** Glowfilter for page button of the active page */
    private var buttonGlow:GlowFilter;

    /** Gotopage dialog */
    private var gotoPageDialog:GotoPage;

    /** Mask for hiding additional button rows */
    private var buttonMask:Shape;

    /** Maximum mask height */
    private var maskHeightMax:Number;

    /** Minimum mask height */
    private var maskHeightMin:Number;

    /** Currently targeted mask height */
    private var maskHeightTarget:Number;

    /** Timer for updating mask size */
    private var maskTimer:Timer;

    /** Adjusted list of buttons for this instance */
    private var instanceButtons:Object;

    /** Remember megazine for page navigation calls */
    private var megazine:IMegaZine;

    /** Currently highlighted button */
    private var pageButtonActive:SimpleButton;

    /** The pagination buttons - used for updating the highlight */
    private var pageButtons:Array; // SimpleButton
	
    /** The page number display for the left page */

    private var pageNumberLeft:PageNumber;

    /** The page number display for the right page */
    private var pageNumberRight:PageNumber;

    /** Thumbnail container */
    private var pageThumbnailContainer:DisplayObjectContainer;

    private var cleanUpSupport:CleanUpSupport;

    // ---------------------------------------------------------------------- //
    // Needed for layouting
    // ---------------------------------------------------------------------- //
    
    /** Global settings */
    private var settings:Settings;

    /** Library for graphics */
    private var library:Library;

    /** Localizer for localized strings */
    private var localizer:Localizer;

    /** Above or below pages */
    private var isAbovePages:Boolean;

    /** Array holding information on how to color the page buttons */
    private var buttonColors:Array;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Create a new navigation element to display below the pages.
     * 
     * @param settings
     *          settings object with various settings.
     * @param isAbovePages
     *          navigation above or below book? (Changes some behaviours)
     * @param mz
     *          megazine instance this belongs to.
     * @param localizer
     *          localizer to use.
     * @param library
     *          library from which to get graphics.
     * @param buttonColors
     *          array with colors for page buttons (holds objects with page
     *          number and color). The reference will be stored and used when
     *          relayouting takes place.
     */
    public function Navigation(settings:Settings, isAbovePages:Boolean,
            megazine:IMegaZine, localizer:Localizer, library:Library,
            buttonColors:Array = null)
    {
		
        // Remember the owning MegaZine object
        this.megazine = megazine;
        this.settings = settings;
        this.library = library;
        this.localizer = localizer;
        this.isAbovePages = isAbovePages;
        this.buttonColors = buttonColors;
        cleanUpSupport = new CleanUpSupport();
		
        // Easy things first: set up the page number display
        if (settings.showPagenumbers) {
            try {
                pageNumberLeft = new PageNumber(megazine, library, settings);
                pageNumberLeft.x = SPACING;
                pageNumberRight = new PageNumber(megazine, library, settings);
                pageNumberRight.x = megazine.pageWidth * 2
                        - pageNumberRight.width - SPACING;
                addChild(pageNumberLeft);
                addChild(pageNumberRight);
            } catch (e:Error) {
                Logger.log("Navigation", "Failed setting up page numbers: "
                        + e.toString(), Logger.TYPE_WARNING);
            }
        }
		
        buildBar();
        layoutBar();
		
        updatePageNumbers();
        
        cleanUpSupport.make(this, Event.ADDED_TO_STAGE, registerEventListeners);
        // When removed from stage remove listeners
        cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
                function(e:Event):void {
                   cleanUpSupport.cleanup();
                });
    }

    private function buildBar():void {
		
        // Now the more complex stuff, setting up the actual navigational part
        if (settings.showNavigation) {
            // This should _definitely_ not happen
            if (settings.buttonHide == null) {
                throw new Error("Invalid buttonHide variable given.");
            }
			
            // Iterators... stupid actionscript needs to learn stupid scoping.
            var i:int, entry:Object;
			
            // Create glow filter for active page button
            buttonGlow = new GlowFilter(0xFFFFFF, 1.0, 5.0, 5.0, 3,
                    BitmapFilterQuality.MEDIUM);
			
            // Create a clone of the buttons listing.
            instanceButtons = Helper.deepObjectCopy(BUTTONS);
            // Actual button instances, for toggling. Filled during creation of
            // buttons.
            // Array // SimpleButton
            instanceButtons.instances = new Dictionary();
            if (!settings.readingOrderLTR) {
                // Right to left, swap next/prev and last/first.
                var btn:Object;
                var prev:Object;
                var next:Object;
                var first:Object;
                var last:Object;
				// find the entries, get the references to the actual state
                for each (btn in instanceButtons.left) {
                    switch (btn.name) {
                        case "prev": 
                            prev = btn.states[0]; 
                            break;
                        case "next": 
                            next = btn.states[0]; 
                            break;
                        case "first": 
                            first = btn.states[0]; 
                            break;
                        case "last": 
                            last = btn.states[0]; 
                            break;
                    }
                }
                for each (btn in instanceButtons.right) {
                    switch (btn.name) {
                        case "prev": 
                            prev = btn.states[0]; 
                            break;
                        case "next": 
                            next = btn.states[0]; 
                            break;
                        case "first": 
                            first = btn.states[0]; 
                            break;
                        case "last": 
                            last = btn.states[0]; 
                            break;
                    }
                }
                // check if we found both so we can swap
                var tmpTT:String;
                var tmpEvent:String;
                if (prev != null && next != null) {
                    tmpTT = prev.tooltip;
                    tmpEvent = prev.event;
                    prev.tooltip = next.tooltip;
                    prev.event = next.event;
                    next.tooltip = tmpTT;
                    next.event = tmpEvent;
                }
                if (first != null && last != null) {
                    tmpTT = first.tooltip;
                    tmpEvent = first.event;
                    first.tooltip = last.tooltip;
                    first.event = last.event;
                    last.tooltip = tmpTT;
                    last.event = tmpEvent;
                }
            }
			
            // Create and size the background
            background = library.getInstanceOf(
                    LibraryConstants.BACKGROUND) as DisplayObject;
			
            // Button container
            buttonContainer = new Sprite();
			
            // Create the buttons, first the menu buttons. Prepare the info
            // array (interwoven, left on even slots, right on odd ones)
            var buttonsInterwoven:Array = new Array();
            for (i = 0;
                    i < Math.max(instanceButtons.left.length,
                            instanceButtons.right.length);
                    ++i)
            {
                if (i < instanceButtons.left.length
                        && !settings.buttonHide[instanceButtons.left[i].name])
                {
                    buttonsInterwoven.push(instanceButtons.left[i]);
                } else {
                    buttonsInterwoven.push(null);
                }
                if (i < instanceButtons.right.length
                        && !settings.buttonHide[instanceButtons.right[i].name])
                {
                    buttonsInterwoven.push(instanceButtons.right[i]);
                } else {
                    buttonsInterwoven.push(null);
                }
            }
			
			// Now create the actual buttons and initialize them.
            for each (entry in buttonsInterwoven) {
                var d:DisplayObject;
                if (entry != null) {
                    if (entry.states && entry.states.length > 0) {
                        var statesTmp:Array =  instanceButtons.
                                instances[entry.name] = new Array();
                        for each (var state:Object in entry.states) {
                            d = library.getInstanceOf(state.btn)
                                    as SimpleButton;
                            d["eventType"] = state.event;
                            cleanUpSupport.make(d, MouseEvent.CLICK,
                                    handleNavButtonClicked);
                            var tt:ToolTip = new ToolTip("", d);
                            localizer.registerObject(tt, "text", state.tooltip);
                            // Hide secondary buttons
                            if (statesTmp.length > 0) d.visible = false;
                            statesTmp.push(d);
                            buttonContainer.addChild(d);
                        }
                    } else {
						
                        // Special treatment of buttons that cannot be described
                        // using library buttons.
                        // Place your element instance into the "d" variable
                        // (see below, used for adding to instances list).
                        switch(entry.name) {
// --------- HERE ;-) ------------------------------------------------------- //
                            case "language":
                                // Center language chooser (it does not scale,
                                // even if the buttons do)
                                d = new LangChooser(megazine, localizer,
                                        library, isAbovePages,
                                        settings.langPath);
                                buttonContainer.addChild(d);
                                break;
// -------------------------------------------------------------------------- //
                            default:
                                Logger.log("Navigation",
                                        "Unhandled special button type: '"
                                        + entry.name + "'",
                                        Logger.TYPE_WARNING);
                        }
                        instanceButtons.instances[entry.name] = d;
                    }
                }
            }
			
            // Restore mute state if necessary
            if (megazine.muted) {
                handleSoundsMute(null);
            }
			
            // Then the page buttons
            if (!settings.buttonHide["pages"]) {
                // Actual pagination buttons are recreated each time in layout,
                // because it's a lot easier that way (don't have to care about
                // added / remove buttons, just can do a complete remake).
				
                // Thumbnail box setup - not needed if there are no page buttons
                // (no way to display it then)
                pageThumbnailContainer = new Sprite();
                var thumbBackground:DisplayObject = library.getInstanceOf(
                        LibraryConstants.BACKGROUND) as DisplayObject;
                thumbBackground.width = megazine.pageWidth / 5 * 2
                        + THUMB_BORDER * 2;
                thumbBackground.height = megazine.pageHeight / 5
                        + THUMB_BORDER * 2;
                pageThumbnailContainer.x = megazine.pageWidth * 2 * 0.5
                        - megazine.pageWidth / 5 - THUMB_BORDER;
                if (isAbovePages) {
                    pageThumbnailContainer.y = library.factory.getButtonSize()
                            + SPACING * 2;// + offset + 25;
                } else {
                    pageThumbnailContainer.y = -megazine.pageHeight / 5
                            - THUMB_BORDER * 2 - SPACING * 2; // - offset - 25;
                }
                pageThumbnailContainer.addChild(thumbBackground);
                pageThumbnailContainer.visible = false;
				
                addChild(pageThumbnailContainer);
            }
			
            // Add stuff to display tree
            addChild(background);
            addChild(buttonContainer);
			
            // The min and max heights
            maskHeightTarget = maskHeightMax = maskHeightMin =
                    library.factory.getButtonSize();
			
            // Create the mask
            buttonMask = new Shape();
            buttonMask.graphics.beginFill(0xFF00FF);
            buttonMask.graphics.drawRect(0, 0, 10, 10);
            buttonMask.graphics.endFill();
            buttonContainer.mask = buttonMask;
			
            // Initialize the timer
            maskTimer = new Timer(40);
            cleanUpSupport.addTimer(maskTimer);
            cleanUpSupport.make(maskTimer, TimerEvent.TIMER, updateMask);
			
            // Add event listeners for mouse over and out
            cleanUpSupport.make(background, MouseEvent.ROLL_OVER, fadeIn);
            cleanUpSupport.make(background, MouseEvent.ROLL_OUT, fadeOut);
            cleanUpSupport.make(buttonContainer, MouseEvent.ROLL_OVER, fadeIn);
            cleanUpSupport.make(buttonContainer, MouseEvent.ROLL_OUT, fadeOut);
			
            // Centering and adding
            addChild(buttonMask);
			
            if (!settings.buttonHide["goto"]) {
                gotoPageDialog = new GotoPage(megazine, library, localizer);
                gotoPageDialog.visible = false;
                addChild(gotoPageDialog);
            }
        }
    }

    /**
     * Rebuild the navigation bar, in case page count changes, e.g.
     */
    public function layoutBar():void {
        var entry:Object;
        var i:int;
        var d:DisplayObject;
		
        // Perfom layouting on the buttons...
        if (settings.showNavigation) {
			
            var wasOpen:Boolean = background.height > maskHeightMin;
			
            // Halve the page count (because we only one button for every
            // second page)
            var pages:uint = (megazine.pageCount >> 1) + 1;
			
            // Maximum width
            var maxWidth:uint = megazine.pageWidth * 2 - SPACING * 2;
            if (pageNumberLeft != null) {
                maxWidth -= pageNumberLeft.width + SPACING;
            }
            if (pageNumberRight != null) {
                maxWidth -= pageNumberRight.width + SPACING;
            }
			
            // How many buttons we will have to fit into the pagination and
            // determine how many buttons are to the left and right of the page
            // buttons
            var btnsVisLeft:int = 0;
            var btnsVisRight:int = 0;
            for each (entry in instanceButtons.left) {
            	if (!settings.buttonHide[entry.name]) {
            		btnsVisLeft++;
            	}
            }
            for each (entry in instanceButtons.right) {
            	if (!settings.buttonHide[entry.name]) {
            		btnsVisRight++;
            	}
            }
            var btnsVisTotal:int = btnsVisLeft + btnsVisRight;
			
            // Calculate some more stuff
            // Width taken by normal buttons
            var buttonLeftWidth:Number = library.factory.getButtonSize()
                    * btnsVisLeft;
            // Number of page buttons that would fit into a row
            var buttonPagePerRow:int = Math.floor((maxWidth
                    - library.factory.getButtonSize() * btnsVisTotal)
                    / library.factory.getPageButtonWidth());
            // Width taken by page buttons per row
            var buttonPageWidthTotal:Number = settings.buttonHide["pages"]
                    ? 0
                    : Math.min(pages, buttonPagePerRow)
                            * library.factory.getPageButtonWidth();
            // Total width of the bar
            var finalWidth:Number = library.factory.getButtonSize()
                    * btnsVisTotal + buttonPageWidthTotal;
            // Number of rows necessary
            var numRows:int = settings.buttonHide["pages"]
                    ? 1
                    : Math.ceil(pages / buttonPagePerRow);
			
            // Background size
            background.width = finalWidth;
			
            // Center it all
            var offsetX:uint = (megazine.pageWidth * 2 - finalWidth) * 0.5;
            background.x = offsetX;
            buttonContainer.x = offsetX;
			
            // Base positioning
            var btnsLeft:int = 0, btnsRight:int = 0;
            var instances:*;
            var sb:SimpleButton;
            for (i = 0;
                    i < Math.max(instanceButtons.left.length,
                            instanceButtons.right.length);
                    ++i)
            {
                if (i < instanceButtons.left.length
                        && !settings.buttonHide[instanceButtons.left[i].name])
                {
                    entry = instanceButtons.left[i];
                    instanceButtons.left[i].x = btnsLeft++
                            * library.factory.getButtonSize();
                    instances = instanceButtons.instances[entry.name];
                    if (instances is Array) {
                        for each (sb in instances) {
                            sb.x = entry.x;
                        }
                    } else {
                        d = instances;
                        // Special treatment of buttons that cannot be described
                        // using library buttons.
                        // Place your element instance into the "d" variable
                        // (see below, used for adding to instances list).
                        switch(entry.name) {
// --------- HERE  2 -------------------------------------------------------- //
                            case "language":
                                // Center language chooser (it does not scale,
                                // even if the buttons do)
                                d.x = entry.x
                                        + (library.factory.getButtonSize() - 18)
                                        * 0.5;
                                d.y = (library.factory.getButtonSize() - 16)
                                        * 0.5;
                                break;
// -------------------------------------------------------------------------- //
                        }
                    }
                }
                if (i < instanceButtons.right.length
                        && !settings.buttonHide[instanceButtons.right[i].name])
                {
                    instanceButtons.right[i].x = btnsRight++
                            * library.factory.getButtonSize()
                            + buttonLeftWidth + buttonPageWidthTotal;
                    entry = instanceButtons.right[i];
                    instances = instanceButtons.instances[entry.name];
                    if (instances is Array) {
                        for each (sb in instances) {
                            sb.x = entry.x;
                        }
                    } else {
                        d = instances;
                        // Special treatment of buttons that cannot be described
                        // using library buttons.
                        // Place your element instance into the "d" variable
                        // (see below, used for adding to instances list).
                        switch(entry.name) {
// --------- HERE  2 -------------------------------------------------------- //
                            case "language":
                                // Center language chooser (it does not scale,
                                // even if the buttons do)
                                d.x = entry.x
                                        + (library.factory.getButtonSize() - 18)
                                        * 0.5;
                                d.y = (library.factory.getButtonSize() - 16)
                                        * 0.5;
                                break;
// -------------------------------------------------------------------------- //
                        }
                    }
                }
            }
			
            // Then the page buttons
            if (!settings.buttonHide["pages"]) {
                // Cleanup old buttons
                if (pageButtons != null) {
                    for each (var oldButton:SimpleButton in pageButtons) {
                        oldButton.removeEventListener(MouseEvent.CLICK,
                                handleGotoPage);
                        oldButton.removeEventListener(MouseEvent.ROLL_OVER,
                                handleThumbsShow);
                        oldButton.removeEventListener(MouseEvent.ROLL_OUT,
                                handleThumbsHide);
                        buttonContainer.removeChild(oldButton);
                    }
                }
				
                pageButtons = new Array();
                for (i = 0;i < pages; i++) {
                    pageButtons.push(library.getInstanceOf(
                            LibraryConstants.BUTTON_PAGE) as SimpleButton);
                }
				
                // Add and position the pagination buttons
                for (i = 0;i < pageButtons.length; i++) {
					
                    var button:SimpleButton = pageButtons[i];
					
                    // Create and position
                    button.x = buttonLeftWidth + (i % buttonPagePerRow)
                            * library.factory.getPageButtonWidth();
                    button.y = Math.floor(Number(i) / Number(buttonPagePerRow))
                            * library.factory.getButtonSize();
                    button["page"] = i * 2;
					
                    // Add function linkage
                    button.addEventListener(MouseEvent.CLICK, handleGotoPage);
                    button.addEventListener(MouseEvent.ROLL_OVER, handleThumbsShow);
                    button.addEventListener(MouseEvent.ROLL_OUT, handleThumbsHide);
					
                    // Tooltip
                    var left:int = i * 2;
                    var right:int = i * 2 + 1;
					
                    // Left to right or not?
                    if (!megazine.leftToRight) {
                        button["page"] = pages * 2 - 2 - button["page"];
                    }
					
                    // Page offset
                    if (!settings.readingOrderLTR) {
                        left = megazine.pageCount - left + 1;
                        right = megazine.pageCount - right + 1;
                    }
                    var leftValid:Boolean = left > 0
                            && left < pages * 2 - 1;
                    var rightValid:Boolean = right > 0
                            && right < pages * 2 - 1;
                    left += settings.pageOffset;
                    right += settings.pageOffset;
                    var tt:ToolTip = new ToolTip("", button);
                    localizer.registerObject(tt, "text", "LNG_GOTO_PAGE", [
										(leftValid ? left : "")
										+ (leftValid && rightValid ? "/" : "")
										+ (rightValid ? right : "")]);
					
                    // Add to display
                    buttonContainer.addChild(button);
                }
				
                // Colorize if colors are given
                if (buttonColors != null) {
                    for each (var colorInfo:Object in buttonColors) {
                        var color:int = colorInfo.color;
                        var pageNumber:int = (colorInfo.page >> 1)
                                + (colorInfo.page & 1);
                        if (color > 0 && pageNumber >= 0
                                && pageNumber < pageButtons.length)
                        {
                            var colorTrans:ColorTransform =
                                    new ColorTransform(
                                        ((color & 0xFF0000) >> 16) / 255,
                                        ((color & 0x00FF00) >> 8) / 255,
                                        ((color & 0x0000FF)      ) / 255);
                            (pageButtons[pageNumber] as SimpleButton).
                                    transform.colorTransform = colorTrans;
                        }
                    }
                }
				
                // Set effect for active page
                pageButtonActive = pageButtons[(megazine.currentLogicalPage >> 1)];
                pageButtonActive.downState.filters = [buttonGlow];
                pageButtonActive.overState.filters = [buttonGlow];
                pageButtonActive.upState.filters = [buttonGlow];
            }
			
            // Check if there are multiple rows. If there are, build the
            // extender.
            maskHeightMax = numRows * library.factory.getButtonSize();
            buttonMask.width = background.width;
            buttonMask.x = background.x;
            buttonMask.height = background.height = maskHeightMin;
			
            // Additional masking on top, for language popup.
            buttonMask.height += 280;
            buttonMask.y = -280;
			
            updateMask(null);
			
            if (!settings.buttonHide["goto"]) {
                gotoPageDialog.x = instanceButtons.instances["goto"][0].x
                        + (library.factory.getButtonSize() - 80) / 2
                        + buttonContainer.x;
                gotoPageDialog.y = instanceButtons.instances["goto"][0].y
                        + (library.factory.getButtonSize() - 32) / 2;
            }

            if (wasOpen) {				
                fadeIn(null);
            }
        }
    }

    private function registerEventListeners(e:Event):void {
        // Toggling buttons
        cleanUpSupport.make(stage, FullScreenEvent.FULL_SCREEN,
                handleFullscreen);
        cleanUpSupport.make(megazine, MegaZineEvent.PAGE_CHANGE,
                handlePageChange);
        cleanUpSupport.make(megazine, MegaZineEvent.SLIDE_START,
                handleSlideStart);
        cleanUpSupport.make(megazine, MegaZineEvent.SLIDE_STOP,
                handleSlideStop);
        cleanUpSupport.make(megazine, MegaZineEvent.MUTE, handleSoundsMute);
        cleanUpSupport.make(megazine, MegaZineEvent.UNMUTE, handleSoundsUnmute);
    }
    

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    // ---------------------------------------------------------------------- //
    // Button toggling
    // ---------------------------------------------------------------------- //
	
    /**
     * Toggle fullscreen button.
     * @param e used to determine which button to show.
     */
    private function handleFullscreen(e:FullScreenEvent):void {
        try {
            instanceButtons.instances["fullscreen"][0].visible = !e.fullScreen;
            instanceButtons.instances["fullscreen"][1].visible = e.fullScreen;
        } catch (ex:Error) {
        }
        try {
            switch (Capabilities.playerType.toLowerCase()) {
                case "plugin":
                case "activex":
                    if (e.fullScreen) {
                        instanceButtons.instances["goto"][0].alpha = 0.25;
                    } else {
                        instanceButtons.instances["goto"][0].alpha = 1;
                    }
                    instanceButtons.instances["goto"][0].enabled =
                            !e.fullScreen;
                    break;
            }
        } catch (ex:Error) {
        }
    }

    /**
     * Toggle slideshow controls.
     * @param e unused.
     */
    private function handleSlideStart(e:MegaZineEvent):void {
        instanceButtons.instances["slideshow"][0].visible = false;
        instanceButtons.instances["slideshow"][1].visible = true;
    }

    /**
     * Toggle slideshow controls.
     * @param e unused.
     */
    private function handleSlideStop(e:MegaZineEvent):void {
        instanceButtons.instances["slideshow"][0].visible = true;
        instanceButtons.instances["slideshow"][1].visible = false;
    }

    /**
     * Toggle mute controls.
     * @param e unused.
     */
    private function handleSoundsMute(e:MegaZineEvent):void {
        instanceButtons.instances["mute"][0].visible = false;
        instanceButtons.instances["mute"][1].visible = true;
    }

    /**
     * Toggle mute controls.
     * @param e unused.
     */
    private function handleSoundsUnmute(e:MegaZineEvent):void {
        instanceButtons.instances["mute"][0].visible = true;
        instanceButtons.instances["mute"][1].visible = false;
    }

    /**
     * Hide currently displayed thumbnail and the container.
     * @param e unused.
     */
    private function handleThumbsHide(e:MouseEvent):void {
        pageThumbnailContainer.visible = false;
        // The removal is important!
        // a) So that there are not all thumbnails of all pages
        // in there in the end
        // b) If the thumbs have no parent they are not rerendered,
        // saving a lot cpu time
        while (pageThumbnailContainer.numChildren > 1) {
            pageThumbnailContainer.removeChildAt(1);
        }
    }

    /**
     * Show thumbnails, based on the page number stored in the button firing the
     * event.
     * 
     * @param e
     *          used to get the page number.
     */
    private function handleThumbsShow(e:MouseEvent):void {
        var page:uint = e.target["page"];
        if (!megazine.leftToRight) {
            page = megazine.pageCount - page;
        }
        var thumbs:Array = megazine.getThumbnailsForPage(page);
        // Test for left thumbnail
        if (thumbs[0] != null) {
            thumbs[0].x = 10;
            thumbs[0].y = 10;
            pageThumbnailContainer.addChild(thumbs[0]);
        }
        // Test for right thumbnail
        if (thumbs[1] != null) {
            thumbs[1].x = thumbs[1].width + 10;
            thumbs[1].y = 10;
            pageThumbnailContainer.addChild(thumbs[1]);
        }
        pageThumbnailContainer.visible = true;
    }

    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Trigger navigating to a page. Which page is read from the button firing
     * the event.
     * 
     * @param e
     *          used to get the page number.
     */
    private function handleGotoPage(e:MouseEvent):void {
        var page:uint = e.target["page"];
        dispatchEvent(new NavigationEvent(NavigationEvent.GOTO_PAGE, page));
    }

    /**
     * Fire event when button in the menu was clicked.
     * 
     * @param e
     *          used to determine which button was clicked.
     */
    private function handleNavButtonClicked(e:MouseEvent):void {
        if (!(e.target as SimpleButton).enabled) return;
        var type:String = e.target["eventType"];
        dispatchEvent(new NavigationEvent(type));
        // Necessary to avoid goto page input from immediately being
        // hidden again
        e.stopPropagation();
    }

    private function handlePageChange(e:MegaZineEvent):void {
    	updatePageNumbers();
    }

    /**
     * Update page nubmer display.
     * 
     * @param e
     *          unused.
     */
    public function updatePageNumbers():void {
        // Update page numbers if existant
        var page:uint = megazine.currentLogicalPage;
        if (pageNumberLeft) {
            pageNumberLeft.setNumber(megazine.currentPage + 
                    (settings.readingOrderLTR ? 0 : 1));
        }
        if (pageNumberRight) {
            pageNumberRight.setNumber(megazine.currentPage + 
                    (settings.readingOrderLTR ? 1 : 0));
        }
		
        // Update highlight of page navigation
        if (pageButtons != null) {
            page = page >> 1;
            if (pageButtonActive) {
                pageButtonActive.downState.filters = null;
                pageButtonActive.overState.filters = null;
                pageButtonActive.upState.filters = null;
            }
            pageButtonActive = pageButtons[megazine.currentLogicalPage >> 1];
            pageButtonActive.downState.filters = [buttonGlow];
            pageButtonActive.overState.filters = [buttonGlow];
            pageButtonActive.upState.filters = [buttonGlow];
        }
    }

    // ---------------------------------------------------------------------- //
    // Stuff
    // ---------------------------------------------------------------------- //
	
    /**
     * Display the goto page dialog box.
     */
    public function showGotoPage():void {
        gotoPageDialog.show();
        fadeOut(null);
    }

    // ---------------------------------------------------------------------- //
    // Fader
    // ---------------------------------------------------------------------- //
	
    /**
     * Begin fading in additional button rows
     * @param e unused.
     */
    private function fadeIn(e:MouseEvent):void {
        if (maskTimer != null) {
            maskHeightTarget = maskHeightMax;
            maskTimer.start();
        }
    }

    /**
     * Begin fading out additional button rows
     * @param e unused.
     */
    private function fadeOut(e:MouseEvent):void {
        if (maskTimer != null) {
            maskHeightTarget = maskHeightMin;
            maskTimer.start();
        }
    }

    /**
     * Update the mask size (and background size)
     * @param e unused.
     */
    private function updateMask(e:TimerEvent):void {
        // Buffer height to top, for language buttons
        buttonMask.height = Math.max(0, buttonMask.height - 280);
        buttonMask.y = 0;
		
        // Interpolate closer to the target height.
        buttonMask.height += (maskHeightTarget - buttonMask.height) * 0.5;
		
        // Stop running when the target is almost reached.
        if (Math.abs(buttonMask.height - maskHeightTarget) < 1) {
            buttonMask.height = maskHeightTarget;
            maskTimer.stop();
        }
		
        background.height = buttonMask.height;
		
        // Buffer height to top, for language buttons
        buttonMask.height += 280;
        buttonMask.y = -280;
    }
}
} // end package
