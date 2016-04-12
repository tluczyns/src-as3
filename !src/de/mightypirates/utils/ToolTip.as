/*
 * ToolTip - a class for easy creation of tooltips.
 * Copyright (C) 2007-2009 Florian Nuecke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package de.mightypirates.utils {
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.text.*;
import flash.utils.*;

/**
 * The ToolTop class allows for a simple creation of tooltips for any object
 * supporting the MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER and
 * MouseEvent.MOUSE_OUT events.
 * 
 * @version 1.0.6
 * @author fnuecke
 */
public class ToolTip extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /**
     * Use centered coordinate system, i.e. the stage spans equally in all
     * directions.
     */
    public static const COORDINATE_CENTERED:String = "coord_center";

    /**
     * Use a top left aligned coordinate system, i.e. the stage only spans
     * towards the bottom and right.
     */
    public static const COORDINATE_TOP_LEFT:String = "coord_topleft";

    /** Invert pointer direction on the x axis */
    private static const INVERT_X:uint = 1;

    /** Invert pointer direction on the y axis */
    private static const INVERT_Y:uint = 2;

    // ---------------------------------------------------------------------- //
    // Static Variables
    // ---------------------------------------------------------------------- //
	
    /** Maps display objects to their tooltips */
    private static var toolTipList:Dictionary = new Dictionary(true);

    /**
     * Current tooltip (used to hide old ones of new one is forced to be shown).
     */
    private static var currentToolTip:ToolTip;

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Use a centralized or top left aligned coordinate system */
    private var coordinateType:Boolean = false;

    /** The timer responsible for fading */
    private var fadeTimer:Timer;

    /** Current inversion states for x and y (used to only redraw background when needed) */
    private var invertState:uint;

    /** Maximum width of the tooltip */
    private var maximumWidth:Number;

    /** The object this tooltip belongs to */
    private var targetObject:DisplayObject;

    /** The textfield used to display the tooltip text */
    private var toolTipTextField:TextField;

    /** The timer used to delay the tooltip displaying */
    private var delayTimer:Timer;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new tooltip for the given object.
     * 
     * @param text
     *          the tooltip text to display.
     * @param object
     *          the object for which the tooltip should be shown.
     * @param delay
     *          After how many milliseconds to show the tooltip.
     * @param maxwidth
     *          the maximum width of the tooltip. If it exceeds that width,
     *          wordwrap and multiline get activated.
     * @param fadetime
     *          over how many milliseconds to fade the tooltip in and out.
     * @param coords
     *          the type of coordinates to use, see constants.
     * @param destroyOnRemove
     *          destroy the tooltip once the object it is registered for
     *          gets removed from the stage.
     */
    public function ToolTip(text:String, object:DisplayObject, delay:int = 400,
            maxWidth:Number = 275, fadeTime:int = 200,
            coords:String = COORDINATE_CENTERED,
            destroyOnRemove:Boolean = false)
    {
		
        // Remember the object to allow killing the tooltip later on
        this.targetObject = object;
		
        // Store coordinate type
        this.coordinateType = coords != COORDINATE_TOP_LEFT;
		
        // Remember maxwidth
        this.maximumWidth = maxWidth;
        
        // Setup self.
        mouseEnabled = false;
        // Add a dropshadow (eyecandy ftw)
        filters = [new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.5, BitmapFilterQuality.LOW)];
		
        // Create the textfield and set all the settings...
        toolTipTextField = new TextField();
        toolTipTextField.autoSize = TextFieldAutoSize.LEFT;
        toolTipTextField.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans", "11", null, null, null, null, null, null, TextFormatAlign.JUSTIFY);
        // mouseEnabled to false, else the tooltip blocks the cursor, causing a mouseout
        // everytime the tooltip becomes visible.
        toolTipTextField.mouseEnabled = false;
        toolTipTextField.selectable = false;
        toolTipTextField.textColor = 0xFFFFFF;
        // The "padding" left and right.
        toolTipTextField.x = 4;
        // Then add the actual text.
        addChild(toolTipTextField);
        this.text = text;
		
        // Create the timer, for delayed tooltip display.
        if (delay > 0) {
            delayTimer = new Timer(delay, 1);
            delayTimer.addEventListener(TimerEvent.TIMER, onDelayTimer);
        }
		
        // Create the timer for fading the tooltip.
        if (fadeTime > 0) {
            // Create the timer
            fadeTimer = new Timer(50);
            // The listener. Checks if we're as good as done, if yes set the
            // alpha to the target alpha instantly, stop the timer and if
            // the alpha is 0 remove from stage. Else just update the alpha.
            fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
        }
		
        // Destroy old one if it existed and store new one
        destroyForDisplayObject(targetObject);
        toolTipList[targetObject] = this;
		
        // Register event listeners.
        targetObject.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        targetObject.addEventListener(MouseEvent.ROLL_OUT, onOut);
        targetObject.addEventListener(MouseEvent.ROLL_OVER, onOver);
		
        // Cleanup
        if (destroyOnRemove) {
            targetObject.addEventListener(Event.REMOVED_FROM_STAGE, destroy_triggered);
        }
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /** The text displayed by the tooltip. */
    public function get text():String {
        return toolTipTextField.text;
    }

    /** The text displayed by the tooltip. */
    public function set text(message:String):void {
        // Disable multiline and wordwrap, then set the text.
        toolTipTextField.wordWrap = false;
        toolTipTextField.multiline = false;
        toolTipTextField.text = message;
		
        // Check if maxwidth is exceeded, if yes go to multiline mode.
        if (toolTipTextField.width > maximumWidth - 8) {
            toolTipTextField.multiline = true;
            toolTipTextField.width = maximumWidth - 8;
            toolTipTextField.wordWrap = true;
        }
		
        // Redraw stuff.
        redrawBackground();
    }

    /** Force the tooltip to close. */
    public function hide():void {
        onOut(null);
    }

    /** Force the tooltip to be displayed. */
    public function show():void {
        onOver(null);
    }

    // ---------------------------------------------------------------------- //
    // Event handlers
    // ---------------------------------------------------------------------- //
	
    /**
     * Fade in delay timer tick.
     * 
     * @param e
     *          unused.
     */
    private function onDelayTimer(e:TimerEvent):void {
        try {
            redrawBackground();
            targetObject.stage.addChild(this);
            if (fadeTimer != null) {
                alpha = 0;
                fadeTimer.start();
            }
        } catch (ex:Error) {
        }
    }

    /**
     * Fade in timer tick.
     * 
     * @param e
     *          unused.
     */
    private function onFadeTimer(e:TimerEvent):void {
        alpha += 10 / fadeTimer.delay;
        if (alpha > 0.9) {
            alpha = 1;
            fadeTimer.stop();
        }
    }

    /**
     * Mouse move event, used to reposition the tooltip next to the cursor.
     * 
     * @param e
     *          MouseEvent object. Used to get the new position for the
     *          textfield.
     */
    private function onMove(e:MouseEvent):void {
        var invertX:Boolean = false;
        if (coordinateType) {
            invertX = targetObject.stage.mouseX + width - targetObject.stage.stageWidth > 0;
        } else {
            invertX = targetObject.stage.mouseX + width - targetObject.stage.stageWidth / 2 > 0;
        }
        if (invertX) {
            x = targetObject.stage.mouseX - width;
        } else {
            x = targetObject.stage.mouseX;
        }
        var invertY:Boolean = false;
        if (coordinateType) {
            invertY = targetObject.stage.mouseY + 24 + height - targetObject.stage.stageHeight > 0;
        } else {
            invertY = targetObject.stage.mouseY + 24 + height - targetObject.stage.stageHeight / 2 > 0;
        }
        if (invertY) {
            y = targetObject.stage.mouseY - height;
        } else {
            y = targetObject.stage.mouseY + 24;
        }
        if ((invertState & INVERT_X) > 0 != invertX || (invertState & INVERT_Y) > 0 != invertY) {
            invertState = (invertX ? INVERT_X : 0) + (invertY ? INVERT_Y : 0);
            if (parent != null) {
                redrawBackground();
            }
        }
    }

    /**
     * When the parent gets removed from stage remove self, too.
     * 
     * @param e
     *          unused.
     */
    private function onRemoved(e:Event):void {
        onOut(null);
    }

    /**
     * Called when the mouse exits the object in question.
     * @param e MouseEvent object. Not used.
     */
    private function onOut(e:MouseEvent):void {
        if (currentToolTip == this) currentToolTip = null;
        try {
            var s:Stage = stage || targetObject.stage;
            if (s != null && s.contains(this)) {
                s.removeChild(this);
            }
            delayTimer.stop();
        } catch (ex:Error) {
        }
    }

    /**
     * Called when the mouse enters the object in question.
     * 
     * @param e
     *          unused.
     */
    private function onOver(e:MouseEvent):void {
        if (currentToolTip == this) return;
        if (currentToolTip != null) currentToolTip.hide();
        currentToolTip = this;
        onMove(e);
        if (delayTimer != null) {
            delayTimer.reset();
            delayTimer.start();
        } else {
            try {
                redrawBackground();
                targetObject.stage.addChild(this);
                if (fadeTimer != null) {
                    alpha = 0;
                    fadeTimer.start();
                }
            } catch (ex:Error) {
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Rendering
    // ---------------------------------------------------------------------- //
	
    /**
     * Redraw tooltip background.
     */
    private function redrawBackground():void {
        graphics.clear();
        graphics.beginFill(0x000000, 0.6);
        graphics.lineStyle(1, 0xFFFFFF, 0.6);
        graphics.drawRect(0, 0, toolTipTextField.width + toolTipTextField.x * 2, toolTipTextField.height);
        graphics.endFill();
		
        graphics.beginFill(0xFFFFFF, 0.5);
        graphics.lineStyle(NaN);
		
        if ((invertState & INVERT_X) > 0) {
            // right
            if ((invertState & INVERT_Y) > 0) {
                // bottom
                graphics.moveTo(width, height);
                graphics.lineTo(width - 5, height);
                graphics.lineTo(width, height - 5);
            } else {
                // top
                graphics.moveTo(width, 0);
                graphics.lineTo(width - 5, 0);
                graphics.lineTo(width, 5);
            }
        } else {
            // left
            if ((invertState & INVERT_Y) > 0) {
                // bottom
                graphics.moveTo(0, height);
                graphics.lineTo(5, height);
                graphics.lineTo(0, height - 5);
            } else {
                // top
                graphics.moveTo(0, 0);
                graphics.lineTo(5, 0);
                graphics.lineTo(0, 5);
            }
        }
		
        graphics.endFill();
    }

    // ---------------------------------------------------------------------- //
    // "Deconstructor"
    // ---------------------------------------------------------------------- //
    
    /**
     * Destroy self when belonging object gets removed from stage.
     * 
     * @param e
     *          unused.
     */
    private function destroy_triggered(e:Event):void {
        destroy();
    }

    /**
     * Destroys the tooltip by removing the event listeners for mouse events
     * from the object.
     */
    public function destroy():void {
        targetObject.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
        targetObject.removeEventListener(MouseEvent.ROLL_OUT, onOut);
        targetObject.removeEventListener(MouseEvent.ROLL_OVER, onOver);
        targetObject.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        hide();
        if (toolTipList[targetObject] != null) {
            delete toolTipList[targetObject];
        }
    }

    /**
     * Static one, based on given displayobject.
     * 
     * @param object
     *          the object for which to destroy the tooltip.
     */
    public static function destroyForDisplayObject(object:DisplayObject):void {
        if (toolTipList[object] != null) {
            (toolTipList[object] as ToolTip).destroy();
        }
    }
}
} // end package
