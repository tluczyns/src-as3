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
import de.mightypirates.utils.Localizer;
import de.mightypirates.utils.ToolTip;

import flash.display.*;
import flash.events.*;
import flash.net.SharedObject;

/**
 * Settings dialog for changing shadow and reflection useage.
 * 
 * @author fnuecke
 */
public class SettingsDialog extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Create new settings dialog for the given megazine.
     * 
     * @param megazine
     *          the MegaZine object the settings dialog controls.
     * @param library
     *          the library from which to get the base graphics.
     */
    public function SettingsDialog(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary)
    {
        //Initially hide
        visible = false;
		
        // Load base graphics
        var gui:DisplayObjectContainer = library.getInstanceOf(
                LibraryConstants.SETTINGS) as DisplayObjectContainer;
		
        // Initialize "checkboxes"
        gui["chkShadowOn"].visible = megazine.shadows;
        gui["chkShadowOff"].visible = !megazine.shadows;
        gui["chkReflectOn"].visible = megazine.reflection;
        gui["chkReflectOff"].visible = !megazine.reflection;
		
        // String localization
        localizer.registerObject(gui["lblShadows"], "text", "LNG_SHADOWS");
        localizer.registerObject(gui["lblReflection"], "text", "LNG_REFLECTION");
        var tt:ToolTip;
        tt = new ToolTip("", gui["chkShadowOn"] as SimpleButton);
        localizer.registerObject(tt, "text", "LNG_SHADOWS_LONG");
        tt = new ToolTip("", gui["chkShadowOff"] as SimpleButton);
        localizer.registerObject(tt, "text", "LNG_SHADOWS_LONG");
        tt = new ToolTip("", gui["chkReflectOn"] as SimpleButton);
        localizer.registerObject(tt, "text", "LNG_REFLECTION_LONG");
        tt = new ToolTip("", gui["chkReflectOff"] as SimpleButton);
        localizer.registerObject(tt, "text", "LNG_REFLECTION_LONG");
        tt = new ToolTip("", gui["btnOK"] as SimpleButton);
        localizer.registerObject(tt, "text", "LNG_SETTINGS_ACCEPT");
		
        // Settings toggling
        (gui["chkShadowOff"] as SimpleButton).addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            (gui["chkShadowOn"] as SimpleButton).visible = true;
            (gui["chkShadowOff"] as SimpleButton).visible = false;
            var so:SharedObject = SharedObject.getLocal("megazine3");
            so.data.useShadows = true;
            megazine.shadows = true;
        });
        (gui["chkShadowOn"] as SimpleButton).addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            (gui["chkShadowOff"] as SimpleButton).visible = true;
            (gui["chkShadowOn"] as SimpleButton).visible = false;
            var so:SharedObject = SharedObject.getLocal("megazine3");
            so.data.useShadows = false;
            megazine.shadows = false;
        });
        (gui["chkReflectOff"] as SimpleButton).addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            (gui["chkReflectOn"] as SimpleButton).visible = true;
            (gui["chkReflectOff"] as SimpleButton).visible = false;
            var so:SharedObject = SharedObject.getLocal("megazine3");
            so.data.useReflection = true;
            megazine.reflection = true;
        });
        (gui["chkReflectOn"] as SimpleButton).addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            (gui["chkReflectOff"] as SimpleButton).visible = true;
            (gui["chkReflectOn"] as SimpleButton).visible = false;
            var so:SharedObject = SharedObject.getLocal("megazine3");
            so.data.useReflection = false;
            megazine.reflection = false;
        });
		
        // Dragging of the window
        (gui["dragBar"] as Sprite).buttonMode = true;
        (gui["dragBar"] as Sprite).addEventListener(MouseEvent.MOUSE_DOWN, handleStartDrag);
		
        // Hide self on ok button click
        (gui["btnOK"] as SimpleButton).addEventListener(MouseEvent.CLICK, handleClose);
		
        addChild(gui);
		
        // Stage reliant events
        addEventListener(Event.ADDED_TO_STAGE, registerEventListeners);
    }

    // ---------------------------------------------------------------------- //
    // Eventhandlers
    // ---------------------------------------------------------------------- //
	
    /**
     * Add stage listeners when added to stage.
     * 
     * @param e
     *          unused.
     */
    private function registerEventListeners(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, registerEventListeners);
        addEventListener(Event.REMOVED_FROM_STAGE, removeEventListeners);
        stage.addEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
    }

    /**
     * Remove stage listeners when removed from stage.
     * 
     * @param e
     *          unused.
     */
    private function removeEventListeners(e:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, removeEventListeners);
        stage.removeEventListener(MouseEvent.MOUSE_UP, handleStopDrag);
    }

    /**
     * Start dragging the window.
     * 
     * @param e
     *          unused.
     */
    private function handleStartDrag(e:MouseEvent):void {
        startDrag(false);
    }

    /**
     * Stop dragging the window.
     * 
     * @param e
     *          unused.
     */
    private function handleStopDrag(e:MouseEvent):void {
        stopDrag();
    }

    /**
     * Hide self.
     * 
     * @param e
     *          unused.
     */
    private function handleClose(e:MouseEvent):void {
        visible = false;
        dispatchEvent(new Event("closed"));
    }
}
} // end package
