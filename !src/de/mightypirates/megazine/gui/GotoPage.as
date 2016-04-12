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
import de.mightypirates.utils.CleanUpSupport;
import de.mightypirates.utils.Helper;
import de.mightypirates.utils.Localizer;
import de.mightypirates.utils.ToolTip;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.ui.Keyboard;

/**
 * Dialog box to jump to a page instantly.
 * 
 * @author fnuecke
 */
public class GotoPage extends Sprite {

    /** Book instance this belongs to */
    private var megazine:IMegaZine;

    /** Text field for user input */
    private var inputText:TextField;

    /** Tooltip */
    private var tooltip:ToolTip;
    
    /** Listener cleanup support. */
    private var cleanUpSupport:CleanUpSupport;

    /**
     * Creates a new goto page dialog box (basically just a text field).
     * 
     * @param megazine
     *          the book instance this element belongs to.
     * @param library
     *          the library used to get graphics.
     * @param localizer
     *          the localizer used to get localized strings.
     */
    public function GotoPage(megazine:IMegaZine, library:ILibrary,
            localizer:Localizer)
    {
        this.megazine = megazine;
        cleanUpSupport = new CleanUpSupport();
        var goto:DisplayObject = library.getInstanceOf(
                LibraryConstants.GOTO_PAGE);
        inputText = goto["pageInput"];
        inputText.restrict = "0-9";
        tooltip = new ToolTip("", this);
        localizer.registerObject(tooltip, "text", "LNG_GOTO_DIALOG_TIP");
        addChild(goto);
        cleanUpSupport.make(this, Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    /**
     * Show the dialog box.
     */
    public function show():void {
        if (!visible) {
            inputText.text = "";
            visible = true;
            stage.focus = inputText;
            tooltip.show();
        }
    }

    /**
     * Hide the dialog box.
     */
    public function hide():void {
        visible = false;
        stage.focus = stage;
        tooltip.hide();
    }

    private function handleAddedToStage(e:Event):void {
        cleanUpSupport.make(stage, KeyboardEvent.KEY_DOWN, handleKeyPressed,
                false, 1);
        cleanUpSupport.make(stage, MouseEvent.CLICK, handleMousePressed,
                false, 1);
        cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
                function(e:Event):void {
                    cleanUpSupport.cleanup();
                });
    }

    private function handleMousePressed(e:MouseEvent):void {
        if (visible && e.target != inputText) {
            hide();
            e.stopPropagation();
        }
    }

    private function handleKeyPressed(e:KeyboardEvent):void {
        if (!visible) {
            return;
        }
        e.stopPropagation();
		
        // Check what to do
        switch(e.keyCode) {
            case Keyboard.ESCAPE:
                hide();
                break;
            case Keyboard.ENTER:
                hide();
                megazine.gotoPage(Helper.validateInt(inputText.text, 1,
                         1 + megazine.pageOffset,
                        megazine.pageCount + megazine.pageOffset)
                        - (megazine.leftToRight ? 1 : 0)
                        - megazine.pageOffset);
                break;
        }
    }
}
} // end package
