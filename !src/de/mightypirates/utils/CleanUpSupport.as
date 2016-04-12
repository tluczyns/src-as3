/*
 * CleanUpSupport - Helper class for easier listener and other cleanup.
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
import flash.utils.Timer;
import flash.events.IEventDispatcher;

/**
 * This class allows the registration of known listener connections and
 * other functions that should be called.
 * 
 * <p>
 * This is an alternative to making all listeners using weak references or
 * manually removing listeners upon a certain point, as the first can sometimes
 * not fit all needs, and the second can be somewhat problematic if anonymous
 * handler functions are used, which cannot always be avoided.
 * </p>
 * 
 * <p>
 * When using an event to trigger cleanup, it is recommended to use this
 * pattern:
 * <pre>
 * cleanUpSupport.make(dispatcher, Event.TYPE, function(e:Event):void {
 *         cleanUpSupport.cleanup();
 *     });
 * </pre>
 * </p>
 * 
 * <p>
 * When the cleanup() function gets called, all connections are severed and all
 * registered functions called once. After that the lists are emptied.
 * </p>
 * 
 * @author fnuecke
 */
public class CleanUpSupport {

    /** List of known listener connections */
    private var listeners:Array;

    /** List of known clean up functions */
    private var cleaners:Array;

    /** List of known timers to stop on cleanup */
    private var timers:Array;
    
    /**
     * Create a new clean up support class.
     */
    public function CleanUpSupport() {
        listeners = new Array();
        cleaners = new Array();
        timers = new Array();
    }

    /**
     * Creates and adds a listener connection to severe later on. This is for
     * convenience, so one has not to always write the registration plus the
     * cleanup.
     * 
     * @param dispatcher
     *          the object dispatching the events.
     * @param eventType
     *          the type of event for which the function is registered.
     * @param listener
     *          the function listening.
     */
    public function make(dispatcher:IEventDispatcher, eventType:String,
            listener:Function, useCapture:Boolean = false,
            priority:int = 0):void
    {
        dispatcher.addEventListener(eventType, listener, useCapture, priority);
        listeners.push({ d : dispatcher,
        	             e : eventType,
        	             l : listener,
        	             c : useCapture });
    }

    /**
     * Add a listener connection to severe later on.
     * 
     * @param dispatcher
     *          the object dispatching the events.
     * @param eventType
     *          the type of event for which the function is registered.
     * @param listener
     *          the function listening.
     */
    public function add(dispatcher:IEventDispatcher, eventType:String,
            listener:Function, useCapture:Boolean = false):void
    {
        listeners.push({ d : dispatcher,
        	             e : eventType,
        	             l : listener,
        	             c : useCapture });
    }

    /**
     * Add a clean up function which gets called on clean up.
     * 
     * @param f
     *          the function to add.
     */
    public function addFunction(f:Function):void {
        cleaners.push(f);
    }

    /**
     * Add a timer to stop on clean up.
     * 
     * @param t
     *          the timer to add.
     */
    public function addTimer(t:Timer):void {
        timers.push(t);
    }

    /**
     * Clean up. Kills all registered listener connections and calls all
     * known clean up functions. After that clears both lists.
     */
    public function cleanup():void {
        for each (var o:Object in listeners) {
            try {
                (o.d as IEventDispatcher).removeEventListener(o.e, o.l, o.c);
            } catch (er:Error) { 
            }
        }
        listeners = new Array();
		
        for each (var f:Function in cleaners) {
            f();
        }
        cleaners = new Array();
        
        for each (var t:Timer in timers) {
            t.stop();
        }
        timers = new Array();
    }
}
} // end package
