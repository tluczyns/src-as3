/*
 * LoggerEvent - The belonging event to the Logger class, for propagating messages
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
import flash.events.Event;

/**
 * Event used to propagate messages from the Logger class to listeners
 * 
 * @author fnuecke
 */
public class LoggerEvent extends Event {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /**
     * Event fired when a message is logged.
     * @eventType log_message
     */
    public static const MESSAGE:String = "log_message";

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The message that was logged */
    private var message_:String;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
    
    /**
     * Creates a new logger event.
     * 
     * @param type
     *          the type of the event.
     * @param message
     *          the message text.
     * @param bubbles
     *          determines whether the Event object participates in the bubbling
     *          stage of the event flow. The default value is false.
     * @param cancelable
     *          determines whether the Event object can be canceled. The default
     *          values is false.
     */
    public function LoggerEvent(type:String, message:String,
            bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        message_ = message;
    }

    // ---------------------------------------------------------------------- //
    // Getter / Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * The message that was logged.
     */
    public function get message():String {
        return message_;
    }
}
} // end package
