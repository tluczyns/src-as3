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

package de.mightypirates.megazine.elements {
import de.mightypirates.megazine.elements.overlay.AbstractOverlay;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;

/**
 * <code>Area (area)</code> elements can be used to genereate tooltips and links
 * anywhere on a page.
 * 
 * <p>
 * They represent a rectangular area somewhere on the page, and allow user
 * interaction via set urls or displaying tooltips. They are, however, totally
 * transparent (like loading a transparent png).
 * </p>
 * 
 * @author fnuecke
 */
public class Area extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The area */
    private var area:Sprite;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new area element.
     * 
     * @param megazine
     *          the <code>MegaZine</code> instance this element will belong to.
     * @param localizer
     *          the <code>Localizer</code> used for this book instance.
     * @param library
     *          the <code>Library</code> to use for generating graphics.
     * @param page
     *          the <code>Page</code> this element will go onto.
     * @param even
     *          whether this element will go onto the even or odd part of the
     *          page (pages always have two sides).
     * @param xml
     *          the <code>XML</code> element describing this element.
     * @param number
     *          the number of the element in it's containing page.
     */
    public function Area(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML, number:uint)
    {
        super(megazine, localizer, library, page, even, xml, number);
    }

    override public function init():void {
        var areaWidth:Number = Helper.validateNumber(xml.@width, 0);
        var areaHeight:Number = Helper.validateNumber(xml.@height, 0);
		
        if (areaWidth > 0 && areaHeight > 0) {
			
            area = new Sprite();
            area.graphics.beginFill(0xFF00FF);
            area.graphics.drawRect(0, 0, areaWidth, areaHeight);
            area.graphics.endFill();
            area.alpha = 0;
			
            addChild(area);
			
            // Use overlay?
            if (Helper.validateString(xml.@url, "") != "") {
                AbstractOverlay.createOverlays(this, xml.@overlay);
            }
        } else {
            Logger.log("MegaZine Area",
                    "    Invalid or no size for 'area' object in page "
                    + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
        }
			
        super.init();
    }
}
} // end package
