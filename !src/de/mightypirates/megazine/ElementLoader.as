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

package de.mightypirates.megazine {
import de.mightypirates.megazine.Element;
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.utils.LinkedList;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.setTimeout;

/**
 * This object represents a loader that is used to load any elements that are on
 * the pages. Elements are added to a queue, and a certain number is loaded in
 * parallel. Added elements can be removed again, either simply deleting the
 * queue entry or canceling the current loading process.
 * 
 * @author fnuecke
 */
internal class ElementLoader {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
    
    /** Number of elements currently loading. */
    private var currentlyLoading:uint;

    /** Maximum parallel loads allowed */
    private var maximumParallelLoading:uint;

    /** The loading queue */
    private var queue:LinkedList;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
    
    /**
     * Creates a new element loader, allowing it to load the given number of
     * elements at a time.
     * 
     * @param maxParallel
     *          the number of elements to load in parallel.
     */
    public function ElementLoader(maxParallel:uint = 4) {
        maximumParallelLoading = maxParallel;
        currentlyLoading = 0;
        queue = new LinkedList();
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Add an element to the loading queue.
     * The loading queue is a fifo queue.
     * 
     * @param element
     *          the element to add.
     */
    public function addElement(element:Element):void {
        queue.insert(element, priorityFilter);
        setTimeout(update, 100);
    }

    /**
     * Add a batch of element to add to the loading queue.
     * The loading queue is a fifo queue.
     * 
     * @param element
     *          the elements to add.
     */
    public function addElements(elements:Array):void {
        for each (var element:Element in elements) {
            queue.insert(element, priorityFilter);
        }
        setTimeout(update, 100);
    }

    /**
     * Tests if the element loader queue contains the given element.
     * 
     * @param element
     *          the element to test for.
     * @return true if the element is in the queue, else false.
     */
    public function containsElement(element:Element):Boolean {
        return queue.contains(element);
    }

    /**
     * Remove an element from the queue.
     * 
     * @param element
     *          the element to remove.
     */
    public function removeElement(element:Element):void {
        queue.remove(element);
    }

    /**
     * Filter for sorting the queue by elements' priority.
     * 
     * @param a
     *          the first element.
     * @param b
     *          the second element.
     * @return whether the first element is more important than the second.
     */
    private function priorityFilter(a:*, b:*):Boolean {
        return (a as Element).priority > (b as Element).priority;
    }

    /** Updater, tests if a slot is free and if yes tries to fill it */
    private function update():void {
        if (currentlyLoading < maximumParallelLoading && queue.hasElements) {
            // Find an element that is not loaded.
            var element:Element;
            do {
                element = queue.shift() as Element;
            }
			while (element && element.element);
            // If an unloaded element was found load it.
            if (element) {
                // Register listeners for failure / success
                element.addEventListener(
                        MegaZineEvent.ELEMENT_COMPLETE, handleElementEvent);
                element.addEventListener(IOErrorEvent.IO_ERROR,
                        handleElementEvent);
                // Occupy slot and begin loading.
                currentlyLoading++;
                element.elementLoader = this;
                element.load();
                // Wait until triggering the next element.
                setTimeout(update, 50);
            }
        }
    }

    private function handleElementEvent(e:Event):void {
        // Complete or error, don't care, free slot.
        currentlyLoading--;
        (e.target as Element).removeEventListener(
                MegaZineEvent.ELEMENT_COMPLETE, handleElementEvent);
        (e.target as Element).removeEventListener(
                IOErrorEvent.IO_ERROR, handleElementEvent);
        setTimeout(update, 100);
    }
}
} // end package
