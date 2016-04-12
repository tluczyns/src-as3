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
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import flash.utils.Dictionary;

/**
 * The navigation element is meant to be used to create table of contents in an
 * easy to use fashion.
 * 
 * <p>
 * It is, however, rather limited in it's graphical adjustability. I.e. if you
 * would rather a nice looking link list, it is recommended to use multiple
 * images and position them manually.
 * </p>
 * 
 * @author fnuecke
 */
public class Navigation extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** A dictionary mapping language ids to arrays with nav entries */
    private var links:Dictionary; // Array
	
    /** Normal color */
    private var normalColor:int;

    /** The array of the currently visible nav elements */
    private var current:Array; // Sprite
	
    /** The dropshadow filter for the text */
    private var dropShadow:DropShadowFilter;

    /** Hover color */
    private var hoverColor:int;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new navigation/index element.
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
    public function Navigation(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML, number:uint)
    {
        super(megazine, localizer, library, page, even, xml, number);
    }

    /**
     * Perform actual initialization, positioning the links etc.
     */
    override public function init():void {
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
            }
        }
		
        // Get the width and height.
        var sizex:int = -1;
        if (xml.@width != undefined) {
            sizex = int(xml.@width.toString());
            sizex = sizex > 0 ? sizex : -1;
        }
        var sizey:int = -1;
        if (xml.@height != undefined) {
            sizey = int(xml.@height.toString());
            sizey = sizey > -1 ? sizey : -1;
        }
        sizey /= xml.children().length();
		
        // Normal and hover colors
        normalColor = Helper.validateUInt(xml.@color, 0x000000, 0, 0xFFFFFF);
        hoverColor = Helper.validateUInt(xml.@color, 0x333333, 0, 0xFFFFFF);
		
        // Parse all lnk elements and build the navigation.
        links = new Dictionary();
        current = new Array();
        var t:TextField = new TextField();
        t.autoSize = TextFieldAutoSize.LEFT;
        t.multiline = true;
        t.selectable = false;
        t.textColor = normalColor;
        t.width = sizex;
        t.wordWrap = true;
		
        dropShadow = new DropShadowFilter(2, 45, 0x000000, 0.5, 3, 3, 1,
                BitmapFilterQuality.MEDIUM);
		
        for each (var lnk:XML in xml.elements("lnk")) {
            t.defaultTextFormat = new TextFormat(
                    "Verdana, Helvetica, Arial, _sans", "14", null, null, null,
                    null, null, null, align);
            t.htmlText = lnk.toString();
            megazine.stage.quality = StageQuality.BEST;
            var bd:BitmapData = new BitmapData(t.width,
                    Math.max(t.height, sizey), true, 0);
            bd.draw(t, new Matrix(1, 0, 0, 1, 0,
                    sizey > t.height ? (sizey - t.height) / 2 : 0));
            var b:Bitmap = new Bitmap(bd, PixelSnapping.NEVER, true);
            // Must be put into a sprite for interaction (mouse events)
            var s:Sprite = new Sprite();
            s.addChild(b);
			
            var lang:String = Helper.validateString(lnk.@lang,
                    localizer.defaultLanguage);
			
            if (links[lang]) {
                var last:Sprite = links[lang][links[lang].length - 1];
                s.y = last.y + last.height;
            } else {
                links[lang] = new Array();
            }
			
            var url:String = Helper.validateString(lnk.@url, "");
            if (url != "") {
                s.buttonMode = true;
                cleanUpSupport.make(s, MouseEvent.MOUSE_OUT, handleMouseOut);
                cleanUpSupport.make(s, MouseEvent.MOUSE_OVER, handleMouseOver);
                var h:Function = getLinkHandler(lnk.@url.toString(),
                        Helper.validateString(lnk.@target, "_blank"));
                cleanUpSupport.make(s, MouseEvent.CLICK, h);
            }
            links[lang].push(s);
        }
		
        onLanguageChange();
        cleanUpSupport.make(localizer, LocalizerEvent.LANGUAGE_CHANGED,
                onLanguageChange);
		
        super.init();
    }

    /**
     * Mouse out - return to normal.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseOut(e:Event):void {
        var ct:ColorTransform = new ColorTransform();
        ct.color = normalColor;
        e.target.transform.colorTransform = ct;
        e.target.filters = null;
    }

    /**
     * Mouse over - hover mode.
     * 
     * @param e
     *          unused.
     */
    private function handleMouseOver(e:Event):void {
        var ct:ColorTransform = new ColorTransform();
        ct.color = hoverColor;
        e.target.transform.colorTransform = ct;
        e.target.filters = [dropShadow];
    }

    /**
     * Change displayed text based on to which language we change.
     * 
     * @param e
     *          used to determine what happened.
     */
    private function onLanguageChange(e:LocalizerEvent = null):void {
        // Only if the language was changed.
        if (e && e.type != LocalizerEvent.LANGUAGE_CHANGED) {
        	return;
        }
		
        // Check if we have text for that language. If not fallback to default.
        var lang:String = localizer.language;
        if (!links[lang]) {
        	lang = localizer.defaultLanguage;
        }
        // If we have no default either do not change anything.
        if (!links[lang]) {
        	return;
        }
		
		// Remove current ones...
        for each (var remove:Sprite in current) {
            if (remove != null && contains(remove)) {
            	removeChild(remove);
            }
        }
        // Add new ones...
        current = links[lang];
        for each (var add:Sprite in current) {
            addChild(add);
        }
    }

    /**
     * Get a link handler for a given url. Used to work around scoping.
     * 
     * @param url
     *          the url the link refers to.
     * @param target
     *          the target property for the link (_top, _blank, ...).
     */
    private function getLinkHandler(url:String, target:String):Function {
        if (url.search("anchor:") == 0) {
            // Internal link
            return function(e:MouseEvent):void {
                megazine.gotoAnchor(url.slice(7));
            };
        } else {
            // External link
            url = megazine.getAbsPath(url, ["http://", "https://", "file://",
									   "ftp://", "mailto:"]);
            return function(e:MouseEvent):void {
                try {
                    navigateToURL(new URLRequest(url), target);
                } catch (ex:Error) {
                    Logger.log("MegaZine Nav", "Error navigating to url '" + url
                            + "': " + ex.toString(), Logger.TYPE_WARNING);
                }
            };
        }
    }
}
} // end package
