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
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.Helper;
import de.mightypirates.utils.Localizer;

import flash.display.*;
import flash.text.*;

/**
 * The text element can be used to display blocks of text.
 * 
 * <p>
 * Note that it is normally not recommended to use this element, as it's
 * visual representation depends on which fonts are installed on the end user's
 * machine. Also, formatting is very limited. In most cases it is advisable to
 * render your text to an image beforehand, and load that image.
 * </p>
 * 
 * @author fnuecke
 */
public class Text extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new text element.
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
    public function Text(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML, number:uint)
    {
        super(megazine, localizer, library, page, even, xml, number);
    }

    /**
     * Initialize the text field.
     */
    override public function init():void {
			
        var t:TextField = new TextField();
        t.autoSize = TextFieldAutoSize.LEFT;
        t.multiline = true;
        t.selectable = false;
        t.wordWrap = true;
        t.width = megazine.pageWidth - x;
        t.height = megazine.pageHeight - y;
			
        // Text color
        t.textColor = Helper.validateInt(xml.@color, 0, 0);
		
        // Text alignment.
        var align:String = TextFormatAlign.LEFT;
        if (xml.@align != undefined) {
            switch(xml.@align.toString()) {
                case "right":
                    align = TextFormatAlign.RIGHT;
                    break;
                case "center":
                    align = TextFormatAlign.CENTER;
                    break;
                case "justify":
                    align = TextFormatAlign.JUSTIFY;
                    break;
            }
        }
        t.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans",
                    "12", null, null, null, null, null, null, align);
        // Get custom width and height if given and smaller than the max value.
        var xmlWidth:uint = Helper.validateUInt(xml.@width, 0);
        if (xmlWidth > 0) {
            t.width = Math.min(t.width, xmlWidth);
        }
        var xmlHeight:uint = Helper.validateUInt(xml.@height, 0);
        if (xmlHeight > 0) {
            t.height = Math.min(t.height, xmlHeight);
        }
		
        t.htmlText = Helper.validateString(xml.@content, "");
        var bd:BitmapData = new BitmapData(t.width, t.height, true, 0);
        var oldQuality:String = megazine.stage.quality;
        megazine.stage.quality = StageQuality.BEST;
        bd.draw(t);
        megazine.stage.quality = oldQuality;
        bd.lock();
        addChild(new Bitmap(bd, PixelSnapping.NEVER, true));
		
        super.init();
    }
}
} // end package
