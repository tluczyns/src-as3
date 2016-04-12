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

package de.mightypirates.megazine.interfaces {
import flash.display.DisplayObject;

/**
 * Interface for the library, to be used by (external) elements.
 * 
 * @author fnuecke
 */
public interface ILibrary {

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Returns a new instance of the graphics object of the given type.
     * 
     * @param id
     *          the type of the object.
     * @return a new instance of the type, or null if invalid.
     * @see LibraryConstants
     */
    function getInstanceOf(id:String):DisplayObject;
}
} // end package
