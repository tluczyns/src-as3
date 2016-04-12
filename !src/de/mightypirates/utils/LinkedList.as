/*
 * LinkedList - Basic implementation of a doubly linked list.
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

/**
 * A linked list into which new objects can be pushed or unshifted and current
 * ones can be popped or shifted. Handy for implementing queues.
 * 
 * @author fnuecke
 */
public class LinkedList {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** First element in the list */
    private var _head:Object;

    /** Last element in the list */
    private var _tail:Object;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new, empty linked list.
     */
    public function LinkedList() {
        clear();
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Tells if the list is empty or not.
     */
    public function get hasElements():Boolean {
        return _head != null;
    }

    /**
     * Clears the list removing all entries. O(1) complexity.
     */
    public function clear():void {
        _head = _tail = null;
    }

    /**
     * Tests if the queue contains the given element.
     * 
     * @param key
     *          the element to test for.
     * @return true if the list contains the element, else false.
     */
    public function contains(key:*):Boolean {
        var node:Object = _head;
        while (node != null) {
            if (node.data == key) return true;
            node = node.next;
        }
        return false;
    }

    /**
     * Remove a specific key from the list (if it is in the list).
     * O(n) complexity.
     * 
     * @param key
     *          the key to remove.
     */
    public function remove(key:*):void {
        var node:Object = _head;
        while (node != null) {
            if (node.data == key) {
                if (node.prev) {
                    node.prev.next = node.next;
                }
                if (node.next) {
                    node.next.prev = node.prev;
                }
                if (_head == node) {
                    _head = node.next;
                }
                if (_tail == node) {
                    _tail = node.prev;
                }
                return;
            }
            node = node.next;
        }
    }

    /**
     * Inserts a new key at the end of the list. O(1) complexity.
     * 
     * @param key
     *          the key to insert.
     */
    public function push(key:*):void {
        if (_tail) {
            _tail.next = { prev : _tail, next : null, data : key };
            _tail = _tail.next;
        } else {
            _head = _tail = { prev : null, next : null, data: key };
        }
    }

    /**
     * Inserts a new key at the first position where the given function returns
     * true for the argument pair of the currently checked element in the list
     * and the new element, walking fron to end. Will add _before_ the first
     * element where the condition is met. O(n) complexity.
     * 
     * @param key
     *          the key to insert.
     * @param condition
     *          function to use to determine where to insert.
     */
    public function insert(key:*, condition:Function):void {
        if (_head) {
            var curr:Object = _head;
            while (curr != null && !condition(curr.data, key)) curr = curr.next;
            if (curr == null) {
                // insert at the end
                _tail.next = { prev : _tail, next : null, data : key };
                _tail = _tail.next;
            } else if (curr == _head) {
                // insert as new head
                _head.prev = { prev : null, next : _head, data : key };
                _head = _head.prev;
            } else {
                // insert somewhere else
                curr.prev.next = { prev : curr.prev, next : curr, data : key };
                curr.prev = curr.prev.next;
            }
        } else {
            _head = _tail = { prev : null, next : null, data: key };
        }
    }

    /**
     * Removes and returns the key at the end of the list. O(1) complexity.
     * 
     * @return the last key in the list.
     */
    public function pop():* {
        if (_tail) {
            var ret:* = _tail.data;
            _tail = _tail.prev;
            if (_tail) {
                _tail.next = null;
            } else {
                _head = null;
            }
            return ret;
        } else {
            return null;
        }
    }

    /**
     * Inserts a new key at the beginning of the list. O(1) complexity.
     * 
     * @param key
     *          the key to insert.
     */
    public function unshift(key:*):void {
        if (_head) {
            _head.prev = { prev : null, next : _head, data : key };
            _head.prev.next = _head;
            _head = _head.prev;
        } else {
            _head = _tail = { prev : null, next : null, data: key };
        }
    }

    /**
     * Removes and returns the key at the beginning of the list.
     * O(1) complexity.
     * 
     * @return the first key in the list.
     */
    public function shift():* {
        if (_head) {
            var ret:* = _head.data;
            _head = _head.next;
            if (_head) {
                _head.prev = null;
            } else {
                _tail = null;
            }
            return ret;
        } else {
            return null;
        }
    }
}
} // end package
