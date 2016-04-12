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
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.net.URLRequest;
import flash.display.*;
import flash.events.*;
import flash.filters.GlowFilter;
import flash.utils.*;

/**
 * The GUI element that allows selecting the gui language, i.e. the language of
 * elements part of MegaZine as well as title tooltip for elements.
 * 
 * @author fnuecke
 */
public class LangChooser extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The background graphics */
    private var background:DisplayObject;

    /** Container for flags, for masking */
    private var container:DisplayObjectContainer;

    /** The button of the current language */
    private var currentButton:DisplayObject;

    /** Displayed language buttons */
    private var displayedButtons:Dictionary; // SimpleButton
	
    /** Base path for flag images */
    private var flagPath:String;

    /** If above pages open downwards, else upwards */
    private var isAbovePages:Boolean;

    /** The localizer instance used */
    private var localizer:Localizer;

    /** The mask for the flags... */
    private var flagMask:Shape;

    /** MegaZine instance this belongs to (for resolving flag urls) */
    private var megazine:IMegaZine;

    /** When open this is the height of the list */
    private var targetHeight:int;

    /** Should the list be open or closed? */
    private var targetOpen:Boolean;

    /** Timer for opening or closing the list */
    private var expandTimer:Timer;
    
    /** Clean up support for listeners */
    private var cleanUpSupport:CleanUpSupport;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new language chooser control, displaying a flag button for each
     * language found in the passed localizer and calling the setLanguage()
     * method in the localizer for the appropriate language when a button is
     * clicked.
     * 
     * @param megazine
     *          the book this element belongs to.
     * @param localizer
     *          the localizer to use to get localized strings.
     * @param library
     *          the graphics library to get graphics from.
     * @param isAbovePages
     *          for expanding: above of below pages (grow down or up).
     * @param flagPath
     *          base path to the flag images.
     */
    public function LangChooser(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, isAbovePages:Boolean, flagPath:String = "")
    {
        // Initialize vars
        this.megazine = megazine;
        displayedButtons = new Dictionary();
        this.isAbovePages = isAbovePages;
        this.localizer = localizer;
        this.flagPath = flagPath;
        cleanUpSupport = new CleanUpSupport();
		
        cleanUpSupport.make(localizer, LocalizerEvent.LANGUAGE_ADDED,
                handleLangAdded);
        cleanUpSupport.make(localizer, LocalizerEvent.LANGUAGE_CHANGED,
                handleLangChanged);
		
        background = library.getInstanceOf(LibraryConstants.BACKGROUND);
        addChild(background);
		
        flagMask = new Shape();
        flagMask.graphics.beginFill(0xFF00FF);
        flagMask.graphics.drawRect(0, 0, 18, 16);
        flagMask.graphics.endFill();
		
        container = new Sprite();
        container.mask = flagMask;
        container.x = 1;
        container.y = 1;
		
        cleanUpSupport.make(container, MouseEvent.MOUSE_OVER, handleMouseOver);
        cleanUpSupport.make(container, MouseEvent.MOUSE_OUT, handleMouseOut);
		
        addChild(flagMask);
        addChild(container);
		
        expandTimer = new Timer(30);
        cleanUpSupport.addTimer(expandTimer);
        cleanUpSupport.make(expandTimer, TimerEvent.TIMER, handleTweenTimer);
		
		cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
		      function(e:Event):void {
		      	 cleanUpSupport.cleanup();
		      });
		
        // Do the first update.
        handleLangAdded();
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Handle a button click in terms of changing the language.
     * 
     * @param e
     *          used to get the clicked button, and thus the language.
     */
    private function handleButtonClick(e:MouseEvent):void {
        localizer.language = (e.target as SimpleButton).name;
    }

    /**
     * New language added to the localizer.
     * 
     * @param e
     *          unused.
     */
    private function handleLangAdded(e:LocalizerEvent = null):void {
        var langs:Array = localizer.getAvailableLanguages();
		
        if (langs == null || langs.length == 0) {
            background.visible = false;
            return;
        }
        background.visible = true;
        background.height = 16;
        background.width = 18;
        var offset:int = 0;
		
        targetHeight = 2 + langs.length * 14;
		
        for each (var langID:String in langs) {
            // Test if it exists, if yes reposition, else create new one.
            if (displayedButtons[langID]) {
                displayedButtons[langID].y = offset;
            } else {
                var flagBMD:BitmapData = new BitmapData(14, 12, false, 0xFF00FF);
				
                // Load flag graphics.
                var flag:Loader = new Loader();
                cleanUpSupport.make(flag.contentLoaderInfo,
                        IOErrorEvent.IO_ERROR, onFlagError(flagBMD));
                cleanUpSupport.make(flag.contentLoaderInfo, Event.COMPLETE,
                        handleFlagComplete(flagBMD));
                flag.load(new URLRequest(megazine.getAbsPath(
                        flagPath + "flag." + langID + ".gif")));
				
                // Create the button.
                var hitTestState:Shape = new Shape();
                hitTestState.graphics.beginFill(0xFF00FF);
                hitTestState.graphics.drawRect(0, 0, 16, 14);
                var upState:DisplayObject = new Bitmap(flagBMD);
                upState.x = 1;
                upState.y = 1;
                var overState:DisplayObject = new Bitmap(flagBMD);
                overState.x = 1;
                overState.y = 1;
                overState.filters =
                        [new GlowFilter(0xFFFFFF, 0.5, 10, 8, 2, 1, true)];
                var downState:DisplayObject = new Bitmap(flagBMD);
                downState.x = 2;
                downState.y = 2;
                downState.filters =
                        [new GlowFilter(0xFFFFFF, 0.5, 10, 8, 2, 1, true)];
                var btn:SimpleButton = new SimpleButton(upState, overState,
                        downState, hitTestState);
                btn.y = offset;
                // Use the instance name to pass the language id
                btn.name = langID;
                cleanUpSupport.make(btn, MouseEvent.CLICK, handleButtonClick);
                container.addChild(btn);
				
                displayedButtons[langID] = btn;
				
                // Create tooltip, add with listener (might be added due to
                // tooltip, in which case the actual language name will be added
                // later).
                var tt:ToolTip = new ToolTip(localizer.getLangString(langID,
                        "LNG_LANGUAGE_NAME"), btn);
                cleanUpSupport.make(localizer, LocalizerEvent.LANGUAGE_UPDATED,
                        updateCaptionForLanguage(tt, langID));
            }
			
            if (offset == 0) {
                currentButton = displayedButtons[langID];
            }
			
            offset += isAbovePages ? 14 : -14;
        }
		
        // If only one language is known do not display.
        visible = langs.length > 1;
		
        // Might be the newly added one is the current one...
        handleLangChanged();
    }

    /**
     * Update title of button if language changes.
     * (cannot directly bind this as it's independant of current language).
     * 
     * @param tt
     *          the tooltip for which to create the function.
     * @param langID
     *          the language for which the button stands.
     */
    private function updateCaptionForLanguage(tt:ToolTip,
            langID:String):Function
    {
        return function(e:LocalizerEvent):void {
            tt.text = localizer.getLangString(langID, "LNG_LANGUAGE_NAME");
        };
    }

    /**
     * Wrapper for handling failed flag loading.
     * 
     * @param bmd
     *          <code>BitmapData</code> object into which to paint the loaded
 *              image.
     * @return the actual event handling function.
     */
    private function onFlagError(bmd:BitmapData):Function {
        return function(e:IOErrorEvent):void {
            var def:String = megazine.getAbsPath("flag.gif");
            if ((e.target as LoaderInfo).loaderURL != def) {
                // try again
                var flag:Loader = new Loader();
                cleanUpSupport.make(flag.contentLoaderInfo,
                        IOErrorEvent.IO_ERROR, onFlagError(bmd));
                cleanUpSupport.make(flag.contentLoaderInfo,
                        Event.COMPLETE, handleFlagComplete(bmd));
                flag.load(new URLRequest(def));
            }
        };
    }

    /**
     * Wrapper for handling successful flag loading.
     * 
     * @param bmd
     *          <code>BitmapData</code> object into which to paint the loaded
     *          image.
     * @return the actual event handling function.
     */
    private function handleFlagComplete(bmd:BitmapData):Function {
        return function(e:Event):void {
            bmd.draw((e.target as LoaderInfo).loader);
        };
    }

    /**
     * Current language of localizer changed.
     * 
     * @param e
     *          unused.
     */
    private function handleLangChanged(e:LocalizerEvent = null):void {
        var newone:DisplayObject = displayedButtons[localizer.language];
        if (newone) {
            if (currentButton) {
                currentButton.y = newone.y;
            }
            newone.y = 0;
            currentButton = newone;
        }
    }

    /**
     * Mouse over, show all.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseOver(e:MouseEvent):void {
        targetOpen = true;
        expandTimer.start();
    }

    /**
     * Mouse out, collapse.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseOut(e:MouseEvent):void {
        targetOpen = false;
        expandTimer.start();
    }

    /**
     * Timer responsible for the smooth transitions when opening and collapsing.
     * 
     * @param e
     *          unused.
     */
    private function handleTweenTimer(e:TimerEvent):void {
        var target:int = targetOpen ? targetHeight : 16;
        // Interpolate new size
        background.height = (background.height + target) * 0.5;
        if (Math.abs(background.height - target) < 0.01) {
            background.height = target;
        }
        flagMask.height = background.height - 2;
        if (!isAbovePages) {
            background.y = 16 - background.height;
            flagMask.y = 16 - flagMask.height;
        }
    }
}
} // end package
