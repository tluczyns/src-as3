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
import de.mightypirates.utils.Logger;
import de.mightypirates.megazine.interfaces.*;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.utils.Dictionary;

/**
 * Handles cursor display (allows for different cursor images in a centralized
 * fashion).
 * 
 * @author fnuecke
 */
public class Cursor {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** Default mouse cursor */
    public static const DEFAULT:String = "";

    /** Cursor hinting for the possibility to turn left */
    public static const TURN_LEFT:String = "turn_left";

    /** Cursor hinting for the possibility to turn right */
    public static const TURN_RIGHT:String = "turn_right";

    /** Cursor hinting for zoom possibility */
    public static const ZOOM:String = "zoom";

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** ID of the currently used cursor */
    private static var currentCursor:String = "";

    /** List of cursor images */
    private static var cursors:Dictionary = new Dictionary(); // DisplayObject
	
    /** Current position of the cursor */

    private static var position:Point = new Point();

    /** Current cursor visibility */
    private static var visible_:Boolean = true;
    
    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Initialize with graphics from the given library, in the given container.
     * 
     * @param library
     *          the library to get the graphics from.
     * @param container
     *          the container into which to render the cursors.
     * @param handCursor
     *          use hand cursor for left and right turning instead.
     */
    public static function init(library:ILibrary,
                container:DisplayObjectContainer, handCursor:Boolean):void
    {
        try {
            cursors[ZOOM] = library.getInstanceOf(LibraryConstants.CURSOR_ZOOM);
            cursors[ZOOM].visible = false;
            cursors[ZOOM].mouseEnabled = false;
            container.addChild(cursors[ZOOM]);
			
            if (!handCursor) {
                cursors[TURN_LEFT] = library.getInstanceOf(
                        LibraryConstants.CURSOR_TURN_LEFT);
                cursors[TURN_LEFT].visible = false;
                cursors[TURN_LEFT].mouseEnabled = false;
                container.addChild(cursors[TURN_LEFT]);
				
                cursors[TURN_RIGHT] = library.getInstanceOf(
                        LibraryConstants.CURSOR_TURN_RIGHT);
                cursors[TURN_RIGHT].visible = false;
                cursors[TURN_RIGHT].mouseEnabled = false;
                container.addChild(cursors[TURN_RIGHT]);
            }
        } catch (e:Error) {
            Logger.log("MegaZine", "Error getting cursor images: "
                    + e.toString(), Logger.TYPE_WARNING);
        }
		
        container.addEventListener(MouseEvent.MOUSE_MOVE, updatePosition);
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * Gets the current type of the cursor.
     */
    public static function get cursor():String {
        return currentCursor;
    }

    /**
     * Sets the type of the cursor.
     */
    public static function set cursor(id:String):void {
        if (id != currentCursor) {
            if (currentCursor && cursors[currentCursor]) {
                cursors[currentCursor].visible = false;
            }
            currentCursor = id;
            if (cursors[currentCursor]) {
                cursors[currentCursor].x = position.x;
                cursors[currentCursor].y = position.y;
            }
            if (currentCursor && cursors[currentCursor]) {
            	Mouse.hide();
            } else {
            	Mouse.show();
            }
            visible = true;
        }
    }

    /**
     * Gets visibility of the cursor.
     */
    public static function get visible():Boolean {
        return visible_;
    }

    /**
     * Sets visibility of the cursor.
     */
    public static function set visible(visible:Boolean):void {
        visible_ = visible;
        if (currentCursor) {
            if (cursors[currentCursor]) {
                cursors[currentCursor].visible = visible_;
            } else {
                if (visible_) {
                	Mouse.show();
                } else {
                	Mouse.hide();
                }
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Event handler
    // ---------------------------------------------------------------------- //
	
    /**
     * Handles mouse movement and repositions image of the current cursor image.
     * 
     * @param e
     *          used to set the new position.
     */
    private static function updatePosition(e:MouseEvent):void {
        position.x = e.stageX;
        position.y = e.stageY;
        if (currentCursor && cursors[currentCursor]) {
            cursors[currentCursor].x = e.stageX;
            cursors[currentCursor].y = e.stageY;
        }
    }
}
} // end package
