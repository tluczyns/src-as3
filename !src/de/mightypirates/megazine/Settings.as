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
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.Helper;
import de.mightypirates.utils.Logger;

import flash.net.SharedObject;
import flash.utils.Dictionary;

/**
 * Setting manager (for settings set in the book element, used by
 * other elements, e.g. zoom and so on).
 * 
 * @author fnuecke
 */
public class Settings {

    /** The MegaZine instance these settings belong to */
    public var megazine:IMegaZine;

    /** The vertical position of the navigation bar */
    public var barPosition:String = "";

    public var buttonColors:Dictionary;

    /** Boolean array telling which buttons to hide in the gui. */
    public var buttonHide:Dictionary; // Boolean
    
    /** Center the book when on cover pages */
    public var centerCovers:Boolean = true;

    /** Hint that the corners can be pulled */
    public var cornerHint:Boolean = true;

    /**
     * Distance to keep from originating border while dragging.
     * Can be any value between 1 and pagewidth.
     */
    public var dragKeepDistance:uint;

    /**
     * Distance in which to start autodragging / make borders clickable.
     * Can be any value between 1 and pagewidth.
     */
    public var dragRange:uint;

    /** Page move speed. Can be any value between 0 and 1. */
    public var dragSpeed:Number = 0.25;

    /** Use hand cursor instead of arrows */
    public var handCursor:Boolean = false;

    /** Show navigation */
    public var showNavigation:Boolean = true;

    /** Show pagenumbers left and right to navigation */
    public var showPagenumbers:Boolean = true;

    /** Ignore book edges for clicks, only use corners */
    public var ignoreSides:Boolean = false;

    /** Ignore the system language when determining the default language */
    public var ignoreSystemLanguage:Boolean = false;

    /**
     * Number of pages that can be turned before instantly jumping to the
     * target. Can be any positive number (incl. 0, which means only instant
     * jumps)
     */
    public var instantJumpCount:uint = 5;

    /** Base path for languages (flags and images) */
    public var langPath:String = "";

    /** Show warning messages if a language string cannot be found? */
    public var langWarn:Boolean = false;

    /** How many pages to load in parallel */
    public var loadParallel:uint = 4;

    /** How many pages may be kept in memory */
    public var maxLoaded:uint = 22;

    /** Show help initially */
    public var openhelp:Boolean = false;

    /** Default page background color. */
    public var pageBackgroundColor:uint = 0xFFCCCCCC;

    /** Folding effects alpha value. Must be a number between 0 and 1. */
    public var pageFoldEffectAlpha:Number = 0.5;

    /** The height of the MegaZine's pages */
    public var pageHeight:uint = 400;

    /** Counting offset for page number display */
    public var pageOffset:int = 0;
	
	
    /**
     * Number of each sound type
     * drag, restore, turn, dragstiff, endstiff
     */
    public var pageSoundCount:Array;

    /**
     * Number of pages that can be turned before going to low quality.
     * Can be any positive number (incl. 0, which means quality is reduced
     * always).
     */
    public var pagesToLowQuality:uint = 20;

    /** Use page shadows (when turning) */
    public var pageUseShadows:Boolean = true;

    /** The width of the MegaZine's pages (one page) */
    public var pageWidth:uint = 275;

    /** Password for the MegaZine */
    public var password:String = "";

    /**
     * Reading order (left to right or right to left, e.g. for arabic or asian
     * languages).
     * true: left to right, false: right to left
     */
    public var readingOrderLTR:Boolean = true;
    
    /** Height of the reflection */
    public var reflectionHeight:uint = 0; // -> auto(pageHeight / 2)
    
    /** Use page shadows and highlights per default when turning or not. */
    public var shadowIntensity:Number = 0.25;

    /** Time delay before going to the next page in slideshow */
    public var slideDelay:uint = 5;

    /** Automatically start slideshow */
    public var startSlide:Boolean = false;

    /**
     * Automatically generate thumbnails for books with a max amount of pages in
     * memory.
     */
    public var thumbAuto:Boolean = false;

	/**
     * TŁ height of thumbnail
     */
	public var thumbScale: Number = 0.05;
	
    /** Use page sounds (dragging, restoring, turning) or not. */
    public var usePageTurnSounds:Boolean = true;

    /** Use the reflection effect */
    public var useReflection:Boolean = false;

    /**
     * Wait for all pages to continue turning before beginning to unload/load
     * pages.
     */
    public var waitForNoTurning:Boolean = true;

    /** Zoom alignment when changing zoom steps */
    public var zoomAlign:String = "center middle";

    /** Alpha of the thumbnail area when not hovered */
    public var zoomFadeOutAlpha:Number = 0.25;

    /** Automatically go to fullscreen mode when clicking a zoom button */
    public var zoomFullscreen:Boolean = true;

    /** Initial zoom step. */
    public var zoomInitial:Number = 0.0;

    /** Maximal zoom step. */
    public var zoomMaximal:Number = 1.0;

    /** Move in zoom via mouse movement, not dragging */
    public var zoomMouseMove:Boolean = true;

    /** Show the rotation buttons in zoom. */
    public var zoomRotationButtons:Boolean = true;

    /** Show thumbnail in zoom mode when image is larger than display area */
    public var zoomThumb:Boolean = true;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
    
    /**
     * Initializes a new settings instance, based on the given xml data for the
     * given MegaZine instance.
     * 
     * @param megazine
     *          the MegaZine instance.
     * @param xml
     *          the xml data with the settings.
     */
    public function Settings(megazine:IMegaZine, xml:XML) {
        this.megazine = megazine;
        
        buttonColors = new Dictionary();
        buttonHide   = new Dictionary();
        
        // Defaults
        buttonColors["chapter"] = 0;// 0x666699; //0xCC6600;
        buttonColors["anchor"] = 0;// 0x9999AA; // 0xFFCC00;
        
        // Get shared object with locally stored user settings
        var so:SharedObject = SharedObject.getLocal("megazine3");
        
        // Special treatment attributes
        // (need to be done in advance / fixed order).
        initAttribute("pageheight", xml.@pageheight);
        initAttribute("pagewidth", xml.@pagewidth);
        
        initAttribute("zoommax", xml.@zoommax);
        initAttribute("zoominit", xml.@zoominit);
        
        // Calculated / instantiated default settings...
        dragKeepDistance =  pageWidth >> 4;
        dragRange = pageWidth >> 2;
        pageSoundCount = [3, 2, 5, 1, 1];
        reflectionHeight = pageHeight >> 1;
        
        // Loglevel defaults.
        Logger.level = Logger.TYPE_WARNING | Logger.TYPE_ERROR;
        
        // Rest of the attributes given.
        for each (var attrib:XML in xml.attributes()) {
            var attribName:String = String(attrib.name());
            // Don't initialize attributes twice.
            if (["pageheight", "pagewidth", "zoommax", "zoominit"].
                    indexOf(attribName) > -1) continue;
            initAttribute(attribName, attrib, so);
        }
        
        if ((Logger.level & Logger.TYPE_NOTICE) == 0) {
            Logger.log("MegaZine Settings", "    Disabling notices.",
                    Logger.TYPE_SYSTEM_NOTICE);
        }
        
        // Factor the frame rate into the drag speed (constant speeds
        // regardless of fps)
        if (megazine.stage) dragSpeed *= 25 / megazine.stage.frameRate;
        
        // Restore from so if not given in xml.
        if (so.data.useShadows != undefined
            && (xml.@shadows == undefined || xml.@shadows == null))
        {
            pageUseShadows = so.data.useShadows;
        }
        
        // Restore mute state
        megazine.muted = so.data.isMuted;
    }
    
    
    // ---------------------------------------------------------------------- //
    // Initializer
    // ---------------------------------------------------------------------- //
    
    /**
     * Initializes an attribute.
     * 
     * Initialize page width and height first as they are used by other
     * attributes when initializing!
     * 
     * zoommax has to be set before zoominit.
     * 
     * @param attribute
     *             the name of the attribute (equivalent to the one in the xml).
     * @param val
     *             the value to set the attribute to.
     * @param so
     *             sharedobject to store attributes locally.
     * 
     */
    private function initAttribute(attribute:String, val:*,
           so:SharedObject = null):void
    {
        switch(attribute) {
            case "barpos": barPosition =
                    Helper.validateString(val, barPosition);
            break;
            case "bgcolor": pageBackgroundColor =
                    Helper.validateUInt(val, pageBackgroundColor);
            break;
            case "buttoncolors":
                for each (var colRaw:String in
                        (Helper.validateString(val, "").
                                replace(/ /g, "")).split(","))
                {
                    var colSplit:Array = colRaw.split(":");
                    buttonColors[colSplit[0]] = uint(colSplit[1]);
                }
            break;
            case "centercovers": centerCovers =
                    Helper.validateBoolean(val, centerCovers);
            break;
            case "cornerhint": cornerHint =
                    Helper.validateBoolean(val, cornerHint);
            break;
            case "dragkeepdist": dragKeepDistance =
                    Helper.validateUInt(val, dragKeepDistance, 1, pageWidth);
            break;
            case "dragrange": dragRange =
                    Helper.validateUInt(val, dragRange, 1, pageWidth);
            break;
            case "dragspeed": dragSpeed =
                    Helper.validateNumber(val, dragSpeed, 0.001, 1);
            break;
            case "errorlevel":
                var errorReporting:uint = Logger.TYPE_NONE;
                for each (var errid:String in Helper.validateString(val, "").
                        replace(/ /g, "").split("|"))
                {
                    switch (errid) {
                        case "ALL":
                            errorReporting |= Logger.TYPE_ALL;
                            break;
                        case "ERROR":
                            errorReporting |= Logger.TYPE_ERROR;
                            break;
                        case "WARNING":
                            errorReporting |= Logger.TYPE_WARNING;
                            break;
                        case "NOTICE":
                            errorReporting |= Logger.TYPE_NOTICE;
                            break;
                        default:
                            Logger.log("MegaZine Settings",
                                    "    Unknown error reporting level named '" 
                                    + errid + "'.", Logger.TYPE_WARNING);
                            break;
                    }
                }
                Logger.level = errorReporting;
            break;
            case "foldfx": pageFoldEffectAlpha =
                    Helper.validateNumber(val, pageFoldEffectAlpha, 0, 1);
            break;
            case "handcursor": handCursor =
                    Helper.validateBoolean(val, handCursor);
            break;
            case "hidebuttons":
                var buttonsRaw:String = Helper.validateString(val, "");
                if (buttonsRaw != "") {
                    for each (var bname:String in buttonsRaw.split(" ")) {
                        buttonHide[bname] = true;
                    }
                    // Hide fullscreen button regardless if player does not
                    // support fullscreen
                    if (megazine.stage["displayState"] == undefined) {
                        buttonHide["fullscreen"] = true;
                    }
                }
            break;
            case "ignoresides": ignoreSides =
                    Helper.validateBoolean(val, ignoreSides);
            break;
            case "ignoresyslang": ignoreSystemLanguage =
                    Helper.validateBoolean(val, ignoreSystemLanguage);
            break;
            case "instantjumpcount": instantJumpCount =
                    Helper.validateUInt(val, instantJumpCount);
            break;
            case "langpath":
                langPath = Helper.validateString(val, langPath);
                if (langPath != ""
                        && langPath.charAt(langPath.length - 1) != "/")
                {
                    langPath += "/";
                }
            break;
            case "langwarn":
                langWarn = Helper.validateBoolean(val, langWarn);
            break;
            case "loadparallel": loadParallel =
                    Helper.validateUInt(val, loadParallel, 1);
            break;
            case "lowqualitycount": pagesToLowQuality =
                    Helper.validateUInt(val, pagesToLowQuality);
            break;
            case "ltr": readingOrderLTR =
                    Helper.validateBoolean(val, readingOrderLTR);
            break;
            case "maxloaded": maxLoaded =
                    Helper.validateUInt(val, maxLoaded);
            break;
            case "navigation": showNavigation =
                    Helper.validateBoolean(val, showNavigation);
            break;
            case "openhelp":
                 openhelp = (Helper.validateString(val, "").
                        toLowerCase() == "always")
                        || ((Helper.validateBoolean(val, openhelp)
                                || Helper.validateString(val, "") == "once")
                        && !(so.data.helpShown != undefined
                                && Boolean(so.data.helpShown)));
            break;
            case "pageheight": pageHeight =
                    Helper.validateUInt(val, pageHeight);
            break;
            case "pagenumbers": showPagenumbers =
                    Helper.validateBoolean(val, showPagenumbers);
            break;
            case "pageoffset": pageOffset =
                    Helper.validateInt(val, pageOffset);
            break;
            case "pagesounds": usePageTurnSounds =
                    Helper.validateBoolean(val, usePageTurnSounds);
            break;
            case "pagewidth": pageWidth =
                    Helper.validateUInt(val, pageWidth);
            break;
            case "password": password =
                    Helper.validateString(val, password);
            break;
            case "reflection":
                if (so.data.useReflection != undefined) {
                    useReflection = so.data.useReflection;
                } else {
                    useReflection = Helper.validateBoolean(val, useReflection);
                }
            break;
            case "reflectionheight":
                var tmp:uint = Helper.validateUInt(val, reflectionHeight);
                reflectionHeight = tmp > 0 ? tmp : pageHeight / 2;
            break;
            case "shadows":
                shadowIntensity = Helper.validateNumber(val, shadowIntensity);
                pageUseShadows = !Helper.fpEquals(shadowIntensity, 0)
                        && shadowIntensity > 0;
                shadowIntensity = Math.abs(shadowIntensity);
            break;
            case "slidedelay": slideDelay =
                    Helper.validateUInt(val, slideDelay, 1);
            break;
            case "startslide": startSlide =
                    Helper.validateBoolean(val, startSlide);
            break;
            case "thumbauto": thumbAuto =
                    Helper.validateBoolean(val, thumbAuto);
            break;
			case "thumbscale": thumbScale =
                    Helper.validateNumber(val, thumbScale, 0.0001, 1);
            break;
            case "waitfornoturning": waitForNoTurning =
                    Helper.validateBoolean(val, waitForNoTurning);
            break;
            case "zoomalign": zoomAlign = Helper.validateString(val, zoomAlign);
            break;
            case "zoomcontrolalpha": zoomFadeOutAlpha =
                    Helper.validateNumber(val, zoomFadeOutAlpha, 0, 1);
            break;
            case "zoomfs": zoomFullscreen =
                    Helper.validateBoolean(val, zoomFullscreen);
            break;
            case "zoominit": zoomInitial =
                    Helper.validateNumber(val, zoomInitial, 0, zoomMaximal);
            break;
            case "zoommax": zoomMaximal =
                    Helper.validateNumber(val, zoomMaximal, 1.0);
            break;
            case "zoommousemove": zoomMouseMove =
                    Helper.validateBoolean(val, zoomMouseMove);
            break;
            case "zoomrotate": zoomRotationButtons =
                    Helper.validateBoolean(val, zoomRotationButtons);
            break;
            case "zoomthumb": zoomThumb =
                    Helper.validateBoolean(val, zoomThumb);
            break;
            case "soundcount":
                var pageSoundCountRaw:String = Helper.validateString(val, "");
                if (pageSoundCountRaw != "") {
                    var pageSoundCountRawAr:Array =
                            pageSoundCountRaw.replace(/ /g, "").split(",");
                    for (var soundID:int = 0;
                         soundID < Math.min(pageSoundCount.length,
                                pageSoundCountRawAr.length);
                         ++soundID)
                    {
                        pageSoundCount[soundID] =
                                Helper.validateUInt(
                                        pageSoundCountRawAr[soundID],
                                        pageSoundCount[soundID]);
                    }
                }
            break;
        }
        
    }
}
} // end package
