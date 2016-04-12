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
import de.mightypirates.megazine.events.ScrollBarEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.utils.Dictionary;
import flash.display.*;
import flash.events.*;
import flash.geom.Rectangle;
import flash.text.*;

/**
 * The help box.
 * 
 * @author fnuecke
 */
public class Help extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Number of the currently displayed message */
    private var currentMessage:uint;

    /** Rectangle used to constrain the text when dragging it */
    private var draggingConstraints:Rectangle;

    /** The localizer used for localizing tooltips and texts */
    private var localizer:Localizer;

    /** Ids of messages that may be displayed */
    private var messages:Array; // String
	
    /** The scrollbar for scrolling messages that are too long */

    private var scrollBar:VScrollBar;

    /** The text container to enable dragging */
    private var textContainer:Sprite;

    /** Currently dragging the text or not */
    private var isTextDragging:Boolean;

    /** The actual text field, for updating the text */
    private var helpTextField:TextField;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new help window.
     * 
     * @param localizer
     *          the localizer to use for the tooltips and messages.
     * @param library
     *          the library to use to get graphics from.
     * @param buttonHide
     *          buttons to show in the navigation (influences which topics get
     *          shown, and which don't as to not confuse the used).
     * @param navbar
     *          navigation bar visible or not, also determines which topics are
     *          shown.
     */
    public function Help(localizer:Localizer, library:ILibrary,
            buttonHide:Dictionary, navbar:Boolean)
    {
		
        this.localizer = localizer;
		
        var bg:DisplayObject = library.getInstanceOf(
                LibraryConstants.BACKGROUND);
        bg.width = 300;
        bg.height = 200;
		
        addChild(bg);
		
        var txtBG:DisplayObject = library.getInstanceOf(
                LibraryConstants.BACKGROUND);
        txtBG.width = bg.width - 50;
        txtBG.height = bg.height - 50;
        txtBG.x = 25;
        txtBG.y = 25;
        addChild(txtBG);
		
        var btnClose:SimpleButton = library.getInstanceOf(
                LibraryConstants.BUTTON_CLOSE) as SimpleButton;
        btnClose.x = bg.width - btnClose.hitTestState.width;
        btnClose.addEventListener(MouseEvent.CLICK, handleClose);
		
        var btnPrev:SimpleButton = library.getInstanceOf(
                LibraryConstants.BUTTON_ARROW_LEFT) as SimpleButton;
        btnPrev.y = bg.height - btnPrev.hitTestState.height;
        btnPrev.addEventListener(MouseEvent.CLICK, handlePrevMessage);
		
        var btnNext:SimpleButton = library.getInstanceOf(
                LibraryConstants.BUTTON_ARROW_RIGHT) as SimpleButton;
        btnNext.x = bg.width - btnPrev.hitTestState.width;
        btnNext.y = bg.height - btnPrev.hitTestState.height;
        btnNext.addEventListener(MouseEvent.CLICK, handleNextMessage);
		
        addChild(btnClose);
        addChild(btnPrev);
        addChild(btnNext);
		
        var tt:ToolTip = new ToolTip("", btnClose);
        localizer.registerObject(tt, "text", "LNG_HELP_CLOSE");
        tt = new ToolTip("", btnPrev);
        localizer.registerObject(tt, "text", "LNG_HELP_PREV");
        tt = new ToolTip("", btnNext);
        localizer.registerObject(tt, "text", "LNG_HELP_NEXT");
		
        // Drag bar
        var dragBar:Sprite = library.getInstanceOf(
                LibraryConstants.BAR_BACKGROUND) as Sprite;
        dragBar.x = 50;
        dragBar.y = 10;
        dragBar.width = bg.width - 100;
        dragBar.height = 5;
        dragBar.buttonMode = true;
        dragBar.addEventListener(MouseEvent.MOUSE_DOWN, handleWindowDragStart);
        addChild(dragBar);
		
        helpTextField = new TextField();
        helpTextField.defaultTextFormat = new TextFormat(
                "Verdana, Helvetica, Arial, _sans", "11", null, null, null,
                null, null, null, TextFormatAlign.LEFT);
        helpTextField.selectable = false;
        helpTextField.textColor = 0xFFFFFF;
        helpTextField.x = 25;
        helpTextField.y = 25;
        helpTextField.width = bg.width - 65;
        helpTextField.autoSize = TextFieldAutoSize.CENTER;
        helpTextField.wordWrap = true;
        helpTextField.mouseEnabled = false;
		
        textContainer = new Sprite();
        textContainer.addChild(helpTextField);
		
        textContainer.addEventListener(MouseEvent.MOUSE_DOWN, handleTextDragStart);
		
        addChild(textContainer);
		
        var mask:Shape = new Shape();
        mask.graphics.beginFill(0xFF00FF);
        mask.graphics.drawRect(25, 25, bg.width - 65, bg.height - 50);
        mask.graphics.endFill();
		
        addChild(mask);
		
        textContainer.mask = mask;
		
        scrollBar = new VScrollBar(library, 15, bg.height - 50);
        scrollBar.y = 25;
        scrollBar.x = bg.width - 40;
        scrollBar.addEventListener(ScrollBarEvent.POSITION_CHANGED,
                handleScrollBar);
        addChild(scrollBar);
		
        messages = new Array();
        if (!buttonHide["help"] && navbar) {
            messages.push("LNG_HELP1");
        } else {
            messages.push("LNG_HELP1B");
        }
        if (navbar) {
            messages.push("LNG_HELP2");
        }
        messages.push("LNG_HELP3");
        if (navbar) {
            if (!buttonHide["fullscreen"]) {
                messages.push("LNG_HELP4");
            }
            if (!buttonHide["slideshow"]) {
                messages.push("LNG_HELP5");
            }
        }
		
        setMessage(0);
		
        addEventListener(Event.ADDED_TO_STAGE, registerListeners);
    }

    // ---------------------------------------------------------------------- //
    // Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * The displayed text, may be html formatted. This property is registered
     * with the localizer, because it handles some post formatting and updating
     * of the scrollbar visibility.
     */
    public function set text(message:String):void {
        helpTextField.htmlText = message.replace(/<br\/>/g, "\n");
        textContainer.y = 0;
        draggingConstraints = new Rectangle(0, 0, 0, Math.min(0, textContainer.mask.height - textContainer.height));
        var scrollable:Boolean = textContainer.mask.height < textContainer.height;
        textContainer.buttonMode = scrollable;
        scrollBar.visible = scrollable;
        textContainer.y = 0;
        scrollBar.percent = 0;
    }

    /**
     * Method used internally to set the current message. Updates linkage with
     * the localizer. Handles "circular" switching, i.e. if a number too small
     * is given the last message is shown, if a number too big is shown the
     * first message is shown.
     * 
     * @param messageNumber
     *      the number of the new message.
     */
    private function setMessage(messageNumber:int):void {
        if (messages.length < 1) return;
        if (messageNumber < 0) {
            currentMessage = messages.length - 1;
        } else if (messageNumber >= messages.length) {
            currentMessage = 0;
        } else {
            currentMessage = messageNumber;
        }
        localizer.registerObject(this, "text", messages[currentMessage]);
    }

    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Register stage reliant listeners.
     * 
     * @param e
     *          unused.
     */
    private function registerListeners(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, registerListeners);
        stage.addEventListener(MouseEvent.MOUSE_UP, handleTextDragStop);
        stage.addEventListener(MouseEvent.MOUSE_UP, handleWindowDragStop);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleTextScroll);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMovement);
        addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
    }

    /**
     * Kill stage reliant listeners.
     * 
     * @param e
     *          unused.
     */
    private function removeListeners(e:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
        stage.removeEventListener(MouseEvent.MOUSE_UP, handleTextDragStop);
        stage.removeEventListener(MouseEvent.MOUSE_UP, handleWindowDragStop);
        stage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleTextScroll);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMovement);
    }

    /**
     * Next button, show next message.
     * 
     * @param e
     *          unused.
     */
    private function handleNextMessage(e:Event = null):void {
        setMessage(currentMessage + 1);
    }

    /**
     * Prev button, show previous message.
     * 
     * @param e
     *          unused.
     */
    private function handlePrevMessage(e:Event = null):void {
        setMessage(currentMessage - 1);
    }

    /**
     * Mouse moved, update scrollbar if dragging the text.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseMovement(e:MouseEvent = null):void {
        if (isTextDragging) {
            scrollBar.percent = textContainer.y / (textContainer.mask.height - textContainer.height);
        }
    }

    /**
     * Scrollbar changed, update text position.
     * 
     * @param e
     *          used to retrieve scrollbar percentage.
     */
    private function handleScrollBar(e:ScrollBarEvent):void {
        textContainer.y = e.percent * (textContainer.mask.height - textContainer.height);
    }

    /**
     * Start dragging the text.
     * 
     * @param e
     *          unused.
     */
    private function handleTextDragStart(e:MouseEvent):void {
        isTextDragging = true;
        textContainer.startDrag(false, draggingConstraints);
    }

    /**
     * Stop dragging the text.
     * 
     * @param e
     *          unused.
     */
    private function handleTextDragStop(e:MouseEvent):void {
        textContainer.stopDrag();
        isTextDragging = false;
    }

    /**
     * Start dragging the window.
     * 
     * @param e
     *          unused.
     */
    private function handleWindowDragStart(e:MouseEvent):void {
        startDrag(false);
    }

    /**
     * Stop dragging the window.
     * 
     * @param e
     *          unused.
     */
    private function handleWindowDragStop(e:MouseEvent):void {
        stopDrag();
    }

    /**
     * Text scroll via mousewheel. Update scrollbar if necessary.
     * 
     * @param e
     *          used to get the scroll direction.
     */
    private function handleTextScroll(e:MouseEvent):void {
        if (!visible || !scrollBar.visible) return;
        if (e.delta > 0) {
            textContainer.y += 15;
        } else {
            textContainer.y -= 15;
        }
        textContainer.y = Math.min(draggingConstraints.top,
                Math.max(draggingConstraints.bottom, textContainer.y));
        scrollBar.percent = textContainer.y / (textContainer.mask.height
                - textContainer.height);
    }

    /** Close this window */
    private function handleClose(e:MouseEvent):void {
        visible = false;
        dispatchEvent(new Event("closed"));
    }
}
} // end package
