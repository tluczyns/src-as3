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
import de.mightypirates.megazine.gui.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import org.gif.player.GIFPlayer;

import flash.display.*;
import flash.events.*;
import flash.geom.Matrix;
import flash.net.*;
import flash.system.Capabilities;
import flash.system.LoaderContext;

/**
 * The <code>Image (img)</code> element provides a loader for images and flash
 * movies.
 * 
 * <p>
 * All formats supported by Flash's <code>Loader</code> class are possible. In
 * the GPL version it is additionally possible to load animated GIFs.
 * </p>
 * 
 * @author fnuecke
 */
public class Image extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** Container for the image (for interaction and overlays) */
    private var container:Sprite;

    /** The name of the gallery this image is in */
    private var galleryName:String;

    /** Not in a gallery, has one image for hires given */
    private var hiresPath:String;

    /** Remember if this is a gif or not. */
    private var isGif:Boolean;

    /**
     * The loader object. Must be a class variable, otherwise there is a (small)
     * chance that the garbage collector kills the loader before the image is
     * loaded completely.
     */
    private var loader:Loader;

    /** For loading gifs. */
    private var loaderGif:URLLoader;

    /** The loaded swf, if the file loaded was an swf and it's unbuffered */
    private var swfObject:DisplayObject;

    /** The zoom button */
    private var zoomButton:Sprite;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new image element.
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
    public function Image(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML, number:uint)
    {
        super(megazine, localizer, library, page, even, xml, number);
        container = new Sprite();
        if (loading != null && contains(loading)) {
            removeChild(loading);
            try {
                loading = new LoadingBar(library, localizer);
                loading.x = Helper.validateNumber(xml.@width, 0) * 0.5;
                loading.y = Helper.validateNumber(xml.@height, 0) * 0.5;
                if (loading.x > 0) {
                    loading.x -= (loading as LoadingBar).baseWidth * 0.5;
                }
                if (loading.y > 0) {
                    loading.y -= loading.height * 0.5;
                }
                addChild(loading);
            } catch (e:Error) { 
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Returns the actually loaded swf. Only works if the file loaded was an swf
     * file and the image is not buffered, i.e. the static attribute is not
     * set. Otherwise <code>null</code> is returned.
     * 
     * @return a reference to the loaded swf.
     */
    public function get swf():DisplayObject {
        return swfObject;
    }

    // ---------------------------------------------------------------------- //
    // Loading
    // ---------------------------------------------------------------------- //
	
    /**
     * Initialize loading.
     */
    override public function init():void {
    	// Get gallery name
        galleryName = Helper.validateString(xml.@gallery, "");
    	
        var src:String = Helper.validateString(xml.@src, "");
        if (src != "") {
            src = megazine.getAbsPath(src);
			
            if (Helper.validateBoolean(xml.@nocache, false)) {
                // Browser based? If yes, avoid cache.
                var delimiter:String = src.indexOf("?") >= 0 ? "&" : "?";
                switch (Capabilities.playerType.toLowerCase()) {
                    case "plugin":
                    case "activex":
                        // Browser, random.
                        src += delimiter + "r="
                                + Math.round(Math.random() * 1000000);
                        break;
                }
            }
			
            isGif = (src.substr(src.length - 4).toLowerCase() == ".gif");
            if (isGif) {
                loaderGif = new URLLoader();
                loaderGif.dataFormat = URLLoaderDataFormat.BINARY;
				
                cleanUpSupport.make(loaderGif, ProgressEvent.PROGRESS,
                        handleImageProgress);
                cleanUpSupport.make(loaderGif, Event.COMPLETE, handleImageLoad);
                cleanUpSupport.make(loaderGif, IOErrorEvent.IO_ERROR,
                        handleLoadError);
				
                try {
                    loaderGif.load(new URLRequest(src));
                } catch (e:Error) {
                    Logger.log("MegaZine Image",
                            "    Error loading file '"
                            + Helper.trimString(src, 40)
                            + "' via 'img' object in  page "
                            + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
                    super.init();
                }
            } else {
                loader = new Loader();
                cleanUpSupport.make(loader.contentLoaderInfo,
                        ProgressEvent.PROGRESS, handleImageProgress);
                cleanUpSupport.make(loader.contentLoaderInfo, Event.COMPLETE,
                        handleImageLoad);
                cleanUpSupport.make(loader.contentLoaderInfo,
                        IOErrorEvent.IO_ERROR, handleLoadError);
				
                try {
                    loader.load(new URLRequest(src), new LoaderContext(true));
                } catch (e:Error) {
                    Logger.log("MegaZine Image", "    Error loading file '"
                            + Helper.trimString(src, 40)
                            + "' via 'img' object in  page "
                            + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
                    super.init();
                }
            }
        } else {
            Logger.log("MegaZine Image",
                    "    No source defined for 'img' object in page "
                    + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
                    super.init();
        }
    }

    /** Image made progress while loading, update loading bar */
    private function handleImageProgress(e:ProgressEvent):void {
        try {
            (loading as LoadingBar).percent = e.bytesLoaded / e.bytesTotal;
        } catch (ex:Error) { 
        }
    }

    private function handleLoadError(e:IOErrorEvent):void {
        var src:String = megazine.getAbsPath(
                Helper.validateString(xml.@src, ""));
        Logger.log("MegaZine Image", "    Error loading file: "
                + Helper.trimString(src, 40) + " in page "
                + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
        super.init();
    }

    /**
     * Called when the image or swf was successfully loaded.
     * @param e The event object.
     */
    private function handleImageLoad(e:Event):void {
        // Width for this image (if smaller than 1 use sizes of loaded file)
        var sizex:Number = 0;
        // Height for this image (if smaller than 1 use sizes of loaded file)
        var sizey:Number = 0;
        // The image itself
        var img:DisplayObject;
		
        try {
			
            var rawWidth:Number = 0;
            var rawHeight:Number = 0;
			
            if (isGif) {
                img = new GIFPlayer();
                (img as GIFPlayer).loadBytes(loaderGif.data);
                rawWidth = (img as GIFPlayer).getFrame(1).bitmapData.width;
                rawHeight = (img as GIFPlayer).getFrame(1).bitmapData.height;
            } else {
                img = loader.getChildAt(0);
                rawWidth = loader.width;
                rawHeight = loader.height;
            }
			
            // Set scaling
            sizex = Helper.validateNumber(xml.@width, rawWidth);
            sizey = Helper.validateNumber(xml.@height, rawHeight);
            if (Math.abs(sizex) < 1) {
                sizex = Math.round(sizex * rawWidth);
            }
            if (Math.abs(sizey) < 1) {
                sizey = Math.round(sizey * rawHeight);
            }
			
            // Should the loaded be cached as a bitmap?
            var buffer:Boolean = Helper.validateBoolean(xml.@rasterize, false);
            if (img is AVM1Movie || img is MovieClip) {
                // Try setting it up.
                try {
                    // Try everything.
                    img["megazineSetup"](megazine, page, even, library);
                } catch (e:Error) {
                    try {
                        // Only megazine and page data?
                        img["megazineSetup"](megazine, page, even);
                    } catch (e:Error) {
                        try {
                            // Most basic variant?
                            img["megazineSetup"](megazine);
                        } catch (e:Error) { 
                        }
                    }
                }
                if (buffer) {
                    // Own method to copy the image that does not update when
                    // not animating or manipulating the display object
                    var cacheData:BitmapData = new BitmapData(sizex, sizey,
                            true, 0x00000000);
                    // If possible set stage quality to best, for best results..
                    if (megazine.stage) {
                        var oldQuality:String = megazine.stage.quality;
                        megazine.stage.quality = StageQuality.BEST;
                        cacheData.draw(img, new Matrix(sizex / rawWidth, 0, 0,
                                sizey / rawHeight), null, null, null, true);
                        megazine.stage.quality = oldQuality;
                    } else {
                        cacheData.draw(img, new Matrix(sizex / rawWidth, 0, 0,
                                sizey / rawHeight), null, null, null, true);
                    }
                    cacheData.lock();
                    img = new Bitmap(cacheData);
                } else {
                    swfObject = img;
                }
            }
            if (isGif) {
                img.scaleX = sizex / rawWidth;
                img.scaleY = sizey / rawHeight;
            } else {
                img.width = sizex;
                img.height = sizey;
            }
			
            // Should the image be antialiased?
            if ((img is Bitmap)) {
                (img as Bitmap).smoothing =
                        Helper.validateBoolean(xml.@aa, false);
            }
			
            // Move image from loader to self.
            container.addChild(img);
			
            var url:String = Helper.validateString(xml.@url, "");
			
            // Add container to stage
            addChild(container);
			
            // High resolution version given?
            hiresPath = Helper.validateString(xml.@hires, "");
            if (hiresPath != "") {
                if (!galleryName) {
                    var src:String = megazine.getAbsPath(
                            Helper.validateString(xml.@src, ""));
                    hiresPath = hiresPath.replace("{src}",
                            src.substr(0, src.lastIndexOf(".")));
                    hiresPath = megazine.getAbsPath(hiresPath);
                }
                if (url == "") {
                    // No url, make whole image clickable.
                    // Add event listener to trigger zoom.
                    if (galleryName) {
                        cleanUpSupport.make(container, MouseEvent.CLICK,
                                handleGalleryOpen);
                    } else {
                        cleanUpSupport.make(container, MouseEvent.CLICK,
                                handleSingleOpen);
                    }
                    // Cursor change.
                    cleanUpSupport.make(container, MouseEvent.MOUSE_OVER,
                            handleZoomCursorShow);
                    cleanUpSupport.make(container, MouseEvent.MOUSE_OUT,
                            handleZoomCursorHide);
                }
                if (url != ""
                        || Helper.validateBoolean(xml.@showbutton, true))
                {
                    try {
                        // Get new instance of a zoom button
                        zoomButton = library.getInstanceOf(
                                LibraryConstants.BUTTON_ZOOM) as Sprite;
                        // Default position.
                        zoomButton.x = container.width - zoomButton.width;
                        zoomButton.y = container.height - zoomButton.height;
                        // Then check for custom position.
                        var iconpos:String =
                                Helper.validateString(xml.@iconpos, "");
                        if (iconpos != "") {
                            // Split the string into its components, ignoring
                            // superfluous spaces.
                            var pos:Array = xml.@iconpos.toString().split(" ").
                                    filter(filterNonEmpty);
                            if (pos.length > 0) {
                                // x positioning
                                var px:String = pos[0] as String;
                                switch (px) {
                                    case "left":
                                        zoomButton.x = 0;
                                        break;
                                    case "right":
                                        zoomButton.x = container.width
                                                - zoomButton.width;
                                        break;
                                    case "center":
                                        zoomButton.x =
                                                Math.floor((container.width
                                                        - zoomButton.width)
                                                                 * 0.5);
                                        break;
                                    default:
                                        // Allow named positions to be for y if
                                        // it's the only entry
                                        if (pos.length == 1) {
                                            if (px == "top") {
                                                zoomButton.y = 0;
                                                break;
                                            } else if (px == "bottom") {
                                                zoomButton.y = container.height
                                                        - zoomButton.height;
                                                break;
                                            } else if (px == "middle") {
                                                zoomButton.y =
                                                        Math.floor(
                                                            (container.height
                                                            - zoomButton.height)
                                                                * 0.5);
                                                break;
                                            }
                                        }
                                        // Test for a number, if it is given
                                        // assume it's the x coordinate
                                        if (int(px) > 0) {
                                            // Must not leave image area.
                                            zoomButton.x = Math.min(int(px),
                                                    container.width
                                                    - zoomButton.width);
                                        }
                                        break;
                                }
                            }
                            if (pos.length > 1) {
                                // y positioning
                                var py:String = pos[1] as String;
                                switch (py) {
                                    case "top":
                                        zoomButton.y = 0;
                                        break;
                                    case "bottom":
                                        zoomButton.y = container.height
                                                - zoomButton.height;
                                        break;
                                    case "middle":
                                        zoomButton.y = Math.floor(
                                                (container.height
                                                - zoomButton.height) * 0.5);
                                        break;
                                    default:
                                        // Test for a number, if it is given
                                        // assume it's the y coordinate
                                        if (int(py) > 0) {
                                            // Must not leave image area.
                                            zoomButton.y = Math.min(int(py),
                                                    container.height
                                                    - zoomButton.height);
                                        }
                                        break;
                                }
                            }
                        }
                        // Add event listener to trigger zoom.
                        if (galleryName) {
                            cleanUpSupport.make(zoomButton["btn"],
                                    MouseEvent.CLICK, handleGalleryOpen);
                        } else {
                            cleanUpSupport.make(zoomButton["btn"],
                                    MouseEvent.CLICK, handleSingleOpen);
                        }
                        // Add tooltip.
                        var ttz:ToolTip = new ToolTip("", zoomButton);
                        localizer.registerObject(ttz, "text", "LNG_ZOOM_IN");
                        // Add the zoom (depth)
                        addChild(zoomButton);
                    } catch (e:Error) {
                        Logger.log("MegaZine Image",
                                "Failed setting up zoom button. "
                                + "Invalid library?", Logger.TYPE_WARNING);
                    }
                }
            }
			
            // Use overlay?
            if (url != "" || hiresPath != "") {
                AbstractOverlay.createOverlays(container, xml.@overlay);
            }
        } catch (ex:Error) {
            Logger.log("MegaZine Image", "Error loading image '"
                    + Helper.trimString(hiresPath, 40) + "': " + ex.toString(),
                    Logger.TYPE_WARNING);
        }
		
        //loader = null;
        loaderGif = null;
		
        super.init();
    }

    /**
     * Open a gallery.
     * 
     * @param e
     *          unused.
     */
    private function handleGalleryOpen(e:Event):void {
        megazine.openZoom(galleryName, page.getNumber(even), number);
    }

    /**
     * Open a single image in zoom mode.
     * 
     * @param e
     *          unused.
     */
    private function handleSingleOpen(e:Event):void {
        megazine.openZoom(hiresPath, page.getNumber(even));
    }

    /**
     * Hide the zoom cursor.
     * 
     * @param e
     *          unused.
     */
    private function handleZoomCursorHide(e:Event):void {
        if (Cursor.cursor == Cursor.ZOOM) {
            Cursor.cursor = Cursor.DEFAULT;
        }
    }

    /**
     * Show the zoom cursor.
     * 
     * @param e
     *          unused.
     */
    private function handleZoomCursorShow(e:Event):void {
        if (Cursor.cursor == Cursor.DEFAULT) {
            Cursor.cursor = Cursor.ZOOM;
        }
    }

    /**
     * Filter out empty entries.
     * 
     * @param value
     *          the value to test.
     * @param index
     *          the index of the current entry.
     * @param array
     *          the array the entry is in.
     */
    private function filterNonEmpty(value:*, index:int, array:Array):Boolean {
        return (value as String) != "";
    }

    /**
     * Clean up...
     */
    override protected function destroy(e:Event):void {
        super.destroy(e);
        if (loader != null) {
        	try {
        		loader["unloadAndStop"]();
        	} catch (er:Error) {
        		loader.unload();
        	} finally {
        		loader = null;
        	}
        }
        while (container.numChildren > 0) {
        	var child:DisplayObject = container.getChildAt(0);
        	if (child is Bitmap) {
        		(child as Bitmap).bitmapData.dispose();
        	}
        	container.removeChild(child);
        }
    }

    /**
     * Returns the element to use for interactions such as mouseclicks when the
     * element is linked (via url) or has a hires variant.
     * 
     * @return the <code>InteractiveObject</code> to use.
     */
    override public function getInteractiveObject():InteractiveObject {
        return container;
    }
}
} // end package
