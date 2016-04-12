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

/**
 * Interface for the chapter class, representing chapters in the book.
 * 
 * @author fnuecke
 */
public interface IChapter {

    /**
     * Check if this chapter contains the given page.
     * 
     * @param page
     *          the page to test for.
     * @return <code>true</code> if the page is contained within the chapter.
     */
    function containsPage(page:IPage):Boolean;

    /**
     * The number of the first page in this chapter. Returns -1 if there are no
     * pages in this chapter.
     */
    function get firstPage():int;

    /**
     * The number of the last page in this chapter. Returns -1 if there are no
     * pages in this chapter.
     */
    function get lastPage():int;

    /**
     * Get the default page background color for this chapter.
     */
    function get backgroundColor():uint;

    /**
     * Get the default page folding effects alpha value for this chapter.
     */
    function get foldEffectAlpha():Number;

    /**
     * Gets the slide delay for pages in this chapter.
     */
    function get slideDelay():uint;
}
} // end package
