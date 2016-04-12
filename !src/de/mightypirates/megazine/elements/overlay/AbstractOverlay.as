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

package de.mightypirates.megazine.elements.overlay {
import de.mightypirates.utils.*;

import flash.display.*;
import flash.errors.IllegalOperationError;
import flash.events.*;
import flash.utils.Timer;

/**
 * Base class to element overlays, as well as home to the factory functions
 * createOverlay and createOverlays (for creating multiple overlays at once).
 * Must not be instantiated directly, neither must its subclasses. Use said
 * factory functions for creating new overlays.
 * 
 * <p>
 * When creating a subclass, make sure to call super(target, args) first, for
 * general setup of fading and the width and height variables. Also make sure
 * to add your class to the switch inside the createOverlay function, to make it
 * available.
 * </p>
 * 
 * <p>
 * Per default overlays will be created inside the given target container. They
 * will not update their sizes if the container changes, though. This can be
 * neglected in this context, though, as elements should not change their size.
 * </p>
 * 
 * @author fnuecke
 */
public class AbstractOverlay extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** Not currently fading */
    private static const FADE_NONE:int = 0;

    /** Currently fading towards hover */
    private static const FADE_HOVER:int = 1;

    /** Currently fading towards normal */
    private static const FADE_NORMAL:int = 2;

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Alpha value for normal state. */
    private var alphaNormal:Number = 0;

    /** Alpha value for hover state */
    private var alphaHover:Number = 0.5;

    /** Current fade state (see constants) */
    private var fadeState:int = FADE_NONE;

    /** Step size when fading */
    private var fadeStep:Number;

    /** Timer used for the alpha-"tween" */
    private var fadeTimer:Timer;

    /** The width of the overlay, copied from the target on instantiation */
    protected var overlayWidth:Number;

    /** The height of the overlay, copied from the target on instantiation */
    protected var overlayHeight:Number;
    
    /** Listener cleanup support */
    protected var cleanUpSupport:CleanUpSupport;
    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * This class must not be instantiated directly. Use the createOverlay or
     * createOverlays functions to create new overlays.
     * 
     * @param target
     *          The target object (for which to create the overlay).
     * @param args
     *          Arguments for the overlay.
     */
    public function AbstractOverlay(target:DisplayObjectContainer, args:Array) {
        if (!(super is AbstractOverlay)) {
            throw new IllegalOperationError(
                    "Cannot directly instantiate abstract class.");
        }
        if (target == null) {
            throw new IllegalOperationError("Given target is null.");
        }
		
        // Get params (min and max alpha)
        if (args.length > 0) {
            alpha = alphaNormal = Helper.validateNumber(args[0], 0, 0, 1);
        } else {
            alpha = alphaNormal;
        }
        if (args.length > 1) {
            alphaHover = Helper.validateNumber(args[1], 1, 0, 1);
        }
		
		cleanUpSupport = new CleanUpSupport();
        // Only add listeners and stuff if needed.
        if (alphaHover != alphaNormal) {
            fadeStep = (alphaHover - alphaNormal) / 10;
			
            fadeTimer = new Timer(25);
            cleanUpSupport.addTimer(fadeTimer);
            cleanUpSupport.make(fadeTimer, TimerEvent.TIMER, tick);
			
            cleanUpSupport.make(target, MouseEvent.MOUSE_OVER, fadeIn);
            cleanUpSupport.make(target, MouseEvent.MOUSE_OUT, fadeOut);
        }
		
        // Disable mouse interaction - we're just eyecandy.
        mouseEnabled = false;
		
        // Add self and position / store sizes.
        target.addChild(this);
        cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
                function(e:Event):void {
            cleanUpSupport.cleanup();
        });
        overlayWidth = target.width;
        overlayHeight = target.height;
    }

    // ---------------------------------------------------------------------- //
    // Factories
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates multiple overlays from a semicolon (;) separated list. The single
     * overlays are created using the createOverlay function. The returned array
     * will never be null, but may contain no elements. It will also never
     * contain null elements - when an overlay cannot be created it will be
     * skipped.
     * 
     * @param target
     *          The object for which to create the overlays.
     * @param definition
     *          The overlay definition. Will be converted to a string.
     * @param defaultTo
     *          Default overlay to use if definition is non existant.
     * @return An array with the generated overlays (AbstractOverlay subclass
     *         instances).
     */
    public static function createOverlays(target:DisplayObjectContainer,
            definition:*, defaultTo:String = "border"):Array
    {
        if (definition == undefined || definition == null) {
            definition = defaultTo;
        }
        var base:String = Helper.validateString(definition, "").replace(/ /g, "");
        if (base == "none" || base == "") return [];
        var overlays:Array = base.split(";");
        var ret:Array = [];
        for each (var o:String in overlays) {
            var overlay:AbstractOverlay = createOverlay(target, o);
            if (overlay != null) ret.push(overlay);
        }
        return ret;
    }

    /**
     * Creates a single overlay from the string definition. A string definition
     * is of the form "name[arg1, arg2, ...]", where the argument list ([...])
     * is optional.
     * 
     * <p>
     * Argument one and two are always the normal and hovered alpha values.
     * Remaining parameters vary based on the overlay type. Arguments cannot be
     * "skipped", so if you want to give the third argument you will always also
     * need to provide the first two.
     * </p>
     * 
     * <p>
     * Examples for definition are:
     * "color[0.25, 0.75, 0xFF00FF]", "color", "border[0.5]"
     * </p>
     * 
     * @param target
     *          The object for which to create the overlay.
     * @param definition
     *          The overlay definition. Will be converted to a string.
     * @param defaultTo
     *          Default overlay to use if definition is non existant.
     * @return An AbstractOverlay subclass if successful, else null.
     */
    public static function createOverlay(target:DisplayObjectContainer,
            definition:*, defaultTo:String = "border"):AbstractOverlay
    {
        if (definition == undefined || definition == null) {
            definition = defaultTo;
        }
        // Parse the definition.
        var base:String = Helper.validateString(definition, "").
                replace(/ /g, "");
        if (base == "none" || base == "") return null;
        var parsed:Array = base.match(/^(.+)\[(.*)\]$/);
        if (parsed == null || parsed.length == 0) {
            // no arguments
            parsed = [base];
        } else {
            // remove first entry (original input)
            parsed.shift();
        }
        // Nothing left? Then stop.
        if (parsed.length == 0) return null;
        // Clean up the arguments.
        var args:Array = [];
        if (parsed.length > 1) {
            args = (parsed[1] as String).split(",");
        }
        try {
            // Create the actual overlay.
            switch (parsed[0]) {
                case "color":
                    return new ColorOverlay(target, args);
                case "border":
                    return new BorderOverlay(target, args);
            }
        } catch (er:Error) {
            Logger.log("Overlay", "Error creating overlay: " + er.toString(),
                    Logger.TYPE_WARNING);
            if (er.getStackTrace() != null) {
                Logger.log("Warning", er.getStackTrace(), Logger.TYPE_WARNING);
            }
        }
        return null;
    }

    // ---------------------------------------------------------------------- //
    // General stuff...
    // ---------------------------------------------------------------------- //
	
    /**
     * Begin fading in.
     * 
     * @param e
     *          unused.
     */
    private function fadeIn(e:MouseEvent):void {
        fadeState = FADE_HOVER;
        visible = true;
        if (!fadeTimer.running) {
        	fadeTimer.start();
        }
    }

    /**
     * Begin fading out.
     * 
     * @param e
     *          unused.
     */
    private function fadeOut(e:MouseEvent):void {
        fadeState = FADE_NORMAL;
        visible = true;
        if (!fadeTimer.running) {
        	fadeTimer.start();
        }
    }

    /**
     * Update alpha.
     * 
     * @param e
     *          unused.
     */
    private function tick(e:TimerEvent):void {
        switch (fadeState) {
            case FADE_HOVER:
                if (fadeStep == 0
                        || Math.abs(alpha - alphaHover) < fadeStep)
                {
                    alpha = alphaHover;
                    fadeState = FADE_NONE;
                } else {
                    alpha += fadeStep;
                }
                break;
            case FADE_NORMAL:
                if (fadeStep == 0
                        || Math.abs(alpha - alphaNormal) < fadeStep)
                {
                    alpha = alphaNormal;
                    fadeState = FADE_NONE;
                } else {
                    alpha -= fadeStep;
                }
                break;
            default:
                fadeTimer.stop();
                if (alpha == 0) { 
                    visible = false;
                }
                break;
        }
    }

}
} // end package
