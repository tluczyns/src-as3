/*
 * FadingMessage - a class for simplified creation of self fading text boxes.
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
 * Class for simple creation of text boxes that fade out automatically.
 * 
 * <p>
 * The element's center (the location set by the x and y properties) is at the
 * top middle of the visible text box.
 * </p>
 * 
 * @author fnuecke
 * @version 1.02
 */
public class FadingMessage extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /**
     * Currently visible message (to allow only one visible message at a time).
     */
    private static var currentMessage:FadingMessage;

    /** The display object containing the fader message. */
    private var container:DisplayObjectContainer;

    /** The display duration */
    private var duration_:Number;

    /** The maximum width of the message container */
    private var maximumWidth:Number;

    /** One shot or multishot timer? */
    private var isOneshot:Boolean;

    /** Time display started */
    private var timeStarted:Number;

    /** The textfield used for displaying the text */
    private var messageTextField:TextField;

    /** Timer used for fading */
    private var fadeTimer:Timer;

    /**
     * Unique message? Two unique messages cannot be displayed at a time,
     * the old one will be hidden first
     */
    private var isUnique:Boolean;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new fading message that first fades in, stays for the given
     * duration, then fades out again.
     * 
     * @param message
     *          the message to display. May be HTML formatted.
     * @param container
     *          the container object in which to display the message.
     * @param dispatcher
     *          the event dispatcher to observe. If left blank the message must
     *          manually be displayed by calling the "show" method.
     * @param eventType
     *          the event for which to wait to show this message.
     * @param duration
     *          how long to show the message in seconds (does not include time
     *          taken for fading). Negative value means auto (based on text
     *          length).
     * @param oneshot
     *          oneshot or multishot message.
     * @param color
     *          text color.
     * @param maxWidth
     *          maximum width of the message window. Height is determined
     *          automatically via wordwrap.
     * @param unique
     *          unique messages cannot be displayed simultaneously. If another
     *          unique message is visible when this one should be shown the old
     *          one gets hidden first.
     */
    public function FadingMessage(message:String,
            container:DisplayObjectContainer, dispatcher:IEventDispatcher,
            eventType:String, oneshot:Boolean = true, color:uint = 0xFFFFFF,
            maxWidth:uint = 300, unique:Boolean = true)
    {
        container = container;
        isOneshot = oneshot;
        isUnique = unique;
        maximumWidth = maxWidth;
        alpha = 0;
		
        // Create the textfield and set all the settings...
        messageTextField = new TextField();
        messageTextField.autoSize = TextFieldAutoSize.LEFT;
        messageTextField.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans", "11", null, null, null, null, null, null, TextFormatAlign.JUSTIFY);
        messageTextField.selectable = false;
        messageTextField.textColor = color;
        addChild(messageTextField);
		
        this.text = message;
		
        // Add a dropshadow (eyecandy ftw)
        filters = [new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.5, BitmapFilterQuality.LOW)];
		
        // Setup timer
        fadeTimer = new Timer(20);
        fadeTimer.addEventListener(TimerEvent.TIMER, onTimer);
		
        // Add event listener if given
        if (dispatcher != null && eventType != null) {
            dispatcher.addEventListener(eventType, eventFired);
        }
		
        // Click listener (click instantly hides)
        addEventListener(MouseEvent.CLICK, onClick);
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * The total duration (including fading) this message is displayed. Note
     * that this might change whenever the text does.
     */
    public function get duration():uint {
        return (1900 + duration_) / 1000;
    }

    /** The (HTML formatted) text displayed by the tooltip. */
    public function get text():String {
        return messageTextField.text;
    }

    /** The (HTML formatted) text displayed by the tooltip. */
    public function set text(message:String):void {
        // Disable multiline and wordwrap, then set the text.
        messageTextField.wordWrap = false;
        messageTextField.multiline = false;
        messageTextField.htmlText = message.replace(/<br\/>/g, "\n");
		
        // Check if maxwidth is exceeded, if yes go to multiline mode.
        if (messageTextField.width > maximumWidth - 8) {
            messageTextField.multiline = true;
            messageTextField.width = maximumWidth - 8;
            messageTextField.wordWrap = true;
        }
		
        // Center position.
        messageTextField.x = -messageTextField.width * 0.5;
        messageTextField.y = 2;
		
        // Redraw stuff.
        redrawBackground();
		
        // Set display duration
        duration_ = Math.sqrt(messageTextField.text.length) * 750;
    }

    // ---------------------------------------------------------------------- //
    // Public
    // ---------------------------------------------------------------------- //
	
    /**
     * Manually show the message.
     */
    public function show():void {
        // If another message is visible remove it first
        if (isUnique) {
            if (currentMessage != null) {
                currentMessage.hide();
            }
            currentMessage = this;
        }
        // Show message
        container.addChild(this);
        // Remember the current time and start the timer.
        timeStarted = new Date().getTime();
        fadeTimer.start();
    }

    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Event fired that triggers the display of this message.
     * 
     * @param e
     *          unused.
     */
    private function eventFired(e:Event):void {
        // If it's a oneshot message, kill the listener
        if (isOneshot) {
            (e.target as IEventDispatcher).removeEventListener(e.type, eventFired);
        }
        show();
    }

    /**
     * Clicked, hide self.
     * 
     * @param e
     *          unused.
     */
    private function onClick(e:MouseEvent):void {
        if (isOneshot) {
            removeEventListener(MouseEvent.CLICK, onClick);
        }
        hide();
    }

    /**
     * Timer for fading.
     * 
     * @param e
     *          unused.
     */
    private function onTimer(e:TimerEvent):void {
        // Check if fading should begin.
        var diff:Number = new Date().getTime() - timeStarted;
        if (diff <= 400) {
            // Fade in.
            alpha = Math.min(1, 1 + (diff - 400) / 400);
            // Check how far we are.
            if (alpha > 0.99) {
                alpha = 1;
            }
        } else if (diff >= duration_ + 400) {
            // Fade out.
            alpha = Math.max(0, (1 - (diff - duration_) / 1500));
            // Check how far we are. When done hide and stop the timer.
            if (alpha < 0.01) {
                hide();
            }
        } else {
            // Main visibility time.
            alpha = 1;
        }
    }

    /**
     * Hide self by removing self from container.
     */
    private function hide():void {
        fadeTimer.stop();
        if (isUnique && currentMessage == this) {
            currentMessage = null;
        }
        alpha = 0;
        container.removeChild(this);
    }

    // ---------------------------------------------------------------------- //
    // Rendering
    // ---------------------------------------------------------------------- //
	
    /**
     * Redraw fade message background.
     */
    private function redrawBackground():void {
        // Draw background
        graphics.clear();
        graphics.beginFill(0x000000, 0.6);
        graphics.lineStyle(1, 0xFFFFFF, 0.6);
        graphics.drawRect(-messageTextField.width * 0.5 - 2, 0, messageTextField.width + 4,
                messageTextField.height + 4);
        graphics.endFill();
    }
}
} // end package
