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

import flash.display.*;
import flash.events.*;
import flash.geom.*;

/**
 * Dispatched when the position of the scrollbar changes.
 * 
 * @eventType de.mightypirates.megazine.events.ScrollBarEvent.POSITION_CHANGED
 */
[Event(name = 'position_changed',
        type = 'de.mightypirates.megazine.events.ScrollBarEvent')]

/**
 * A scroll bar object.
 * 
 * @author fnuecke
 */
public class VScrollBar extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The background graphics, also used for jumps on click */
    private var scrollBar:Sprite;

    /** The container for the button to make it draggable */
    private var scrollButtonContainer:Sprite;

    /** Currently dragging or not */
    private var isScrollDragging:Boolean;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new scrollbar with graphics from the given library, the given
     * width and the given height.
     * 
     * @param library
     *          graphics library to use to load graphics.
     * @param width
     *          width of the scrollbar.
     * @param height
     *          height of the scrollbar.
     */
    public function VScrollBar(library:ILibrary, width:uint = 15,
            height:uint = 100)
    {
		
        scrollBar = library.getInstanceOf(
                LibraryConstants.BAR_BACKGROUND) as Sprite;
        scrollBar.width = width;
        scrollBar.height = height;
        scrollBar.alpha = 0.5;
        scrollBar.buttonMode = true;
        scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, handleScrollClick);
		
        var scrollBtn:SimpleButton = library.getInstanceOf(
                LibraryConstants.BUTTON_SCROLL) as SimpleButton;
        scrollButtonContainer = new Sprite();
		
        scrollButtonContainer.addChild(scrollBtn);
        addChild(scrollBar);
        addChild(scrollButtonContainer);
		
        scrollButtonContainer.addEventListener(MouseEvent.MOUSE_DOWN,
                handleScrollDragStart);
		
        addEventListener(Event.ADDED_TO_STAGE, registerListeners);
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /** The percentual value / position of the scrollbar */
    public function set percent(p:Number):void {
        scrollButtonContainer.y = (scrollBar.height - 15) * p;
    }

    /** The percentual value / position of the scrollbar */
    public function get percent():Number {
        return scrollButtonContainer.y / (scrollBar.height - 15);
    }

    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /** Registers some stage reliant listeners when added to stage */
    private function registerListeners(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, registerListeners);
        stage.addEventListener(MouseEvent.MOUSE_UP, handleScrollDragStop);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMovement);
        addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
    }

    /** Remove stage reliant listeners when removed from stage */
    private function removeListeners(e:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
        stage.removeEventListener(MouseEvent.MOUSE_UP, handleScrollDragStop);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMovement);
    }

    /** Mouse movement handler for percent updating when dragging */
    private function handleMouseMovement(e:MouseEvent = null):void {
        if (isScrollDragging) {
            var p:Number = scrollButtonContainer.y / (scrollBar.height - 15);
            dispatchEvent(new ScrollBarEvent(
                    ScrollBarEvent.POSITION_CHANGED, p));
        }
    }

    /** Clicks on the scroll bar background, jump to that position */
    private function handleScrollClick(e:MouseEvent):void {
        scrollButtonContainer.y = globalToLocal(scrollBar.localToGlobal(
                new Point(e.localX, e.localY))).y - 7.5;
        // Update position of the knob
        handleScrollDragStart();
        handleMouseMovement();
    }

    /** Begin dragging the position knob */
    private function handleScrollDragStart(e:MouseEvent = null):void {
        isScrollDragging = true;
        scrollButtonContainer.startDrag(false, new Rectangle(
                scrollBar.x, scrollBar.y, 0, scrollBar.height - 15));
    }

    /** Stop dragging the position knob */
    private function handleScrollDragStop(e:MouseEvent):void {
        scrollButtonContainer.stopDrag();
        isScrollDragging = false;
    }
}
} // end package
