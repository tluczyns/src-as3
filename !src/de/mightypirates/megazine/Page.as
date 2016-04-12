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
import de.mightypirates.megazine.elements.*;
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;

/**
 * Dispatched when the page completes loading.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PAGE_COMPLETE
 */
[Event(name = 'page_complete',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the odd part of the page becomes visible (the one displayed
 * on the left).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.VISIBLE_ODD
 */
[Event(name = 'visible_odd',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the odd part of the page becomes invisible (the one displayed
 * on the left).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.INVISIBLE_OD
 */
[Event(name = 'invisible_odd',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the even part of the page becomes visible (the one displayed
 * on the right).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.VISIBLE_EVEN
 */
[Event(name = 'visible_even',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the even part of the page becomes invisible (the one
 * displayed on the right).
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.INVISIBLE_EVEN
 */
[Event(name = 'invisible_even',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Dispatched when the state of the page changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.STATUS_CHANGE
 */
[Event(name = 'status_change',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * Represents a page in the MegaZine.
 * 
 * Pages are made up from two single pages, to simulate a physical page.
 * The default top page is always an even page.
 * 
 * Pages are no display objects by themselves but instead handle the display
 * objects passed in the constructor method. This includes positioning and
 * visibility.
 * The passed objects therefore have to be handled appropriatetly and must
 * have the same container objects or at least the same offset.
 * 
 * @author fnuecke
 */
internal class Page extends EventDispatcher implements IPage {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The background color for this page */
    private var backgroundColor:Array; // uint
	
	/** The chapter this page resides in */
	private var chapter_:Chapter;
	
    /** Buffer pages while turning */
    private var doBuffer:Array; // Boolean
	
    /** Actual bitmap for buffering */
    private var bufferImage:Array; // Bitmap
	
    /** NitmapData for buffering */
    private var bufferImageData:Array; // BitmapData
	
    /** Color for the navigation button (if set) */
    private var buttonColor:Array; // uint
	
    /** Where the corner currently is */
    private var currentDragPosition:Vector2D;

    /** The function describing the path the drag target moves along */
    private var dragFunction:DragPath;

    /** Maximum distance the drag target may have from the bottom middle */
    private var dragMaxDistBottom:Number;

    /** Maximum distance the drag target may have from the top middle */
    private var dragMaxDistTop:Number;

    /**
     * The offset of the page drag (always based on the top corner, this is the
     * y offset of the dragpoint)
     */
    private var dragOffset:Number = 0;

    /**
     * Reference point while dragging for calculating the angles and stuff
     * (basically the upper corner of the edge the drag started from)
     */
    private var dragReference:Vector2D;

    /** Bottom middle */
    private var dragReferenceBottomMiddle:Vector2D;

    /** Top middle */
    private var dragReferenceTopMiddle:Vector2D;

    /** Dragging speed for page position interpolation */
    private var dragSpeed:Number;

    /** Where to drag the corner to */
    private var dragTarget:Vector2D;

    /** The Element objects representing the elements of the pages */
    private var elements:Array; // Array // Element ([even or odd][number])
	
    /** Number of elements that have been loaded */
    private var elementsLoaded:Array; // [even or odd], Number
	
	/** Actual fold effect graphics */
	private var foldEffect:Array; // Shape
	
    /** The alpha value for the folding effects for this page */
    private var foldEffectAlpha:Array;

    /** Tells whether a thumbnail has been generated for the page */
    private var hasCachedThumb_:Array;

    /** Distance to keep from originating border when dragging */
    private var keepDistance:Number;

    /**
     * The direction the pageturn goes - left to right or right to left.
     * Also used to tell which way the pages currently lie when not moving.
     */
    private var isLeftToRight:Boolean = false;

    /** The main masks for the pages, for hiding them when turning */
    private var maskMain:Array; // Shape
	
    /** The MegaZine this page belongs to */

    private var megazine:MegaZine;

    /** This will contain the page containers */
    private var pageContainer:Array;

    /** The page diagonale */
    private var pageDiagonale:Number = 0;

    /** The height of this page (height is also already taken) */
    private var pageHeight:Number = 0;

    /** The number of this page (even one, so it will be 0, 2, 4 etc) */
    private var pageNumber:uint = 0;

    /**
     * Visibility state of the pages, used to check for changes in visibility
     * for events
     */
    private var pageVisibility:Array;

    /**
     * The width of one page (width is already taken by the Sprite class this
     * class extends)
     */
    private var pageWidth:Number = 0;
    
	private var thumbScale: Number;
	
	/** Max alpha of shadows */
    private var shadowAlpha:Number;

    /** The masks for the shadows */
    private var shadowMasks:Array;

    /**
     * The shadow effects. 0|1 for the shadow being dropped on the background,
     * 2|3 for the shadow on top of the page - each for the odd and even page
     * (although only one each would be needed, we need 4 in total because of
     * how depths are handled).
     */
    private var shadowAndLight:Array;

    /** Slideshow delay for this page */
    private var slideDelay:Array;
    
    /** Default slide delay (from chapter) */
    private var slideDelayDefault_:uint;

    /** Current state of the page */
    private var state_:String = Constants.PAGE_READY;

    /** Current loading state of the page */
    private var stateLoading:Array; // String
	
    /** Determines whether to render this as a stiff page or a normal one. */
    private var isStiff_:Boolean = false;

    /** The _thumbnail images for this page */
    private var thumbnail:Array; // Bitmap
	
    /** The _thumbnail image data for this page */
    private var thumbnailData:Array; // BitmapData
	
    /** Anchor names of the contained pages */
    private var pageAnchors:Array;
    
    /** For cleaning up */
    private var cleanUpSupport:CleanUpSupport;
    
    /** Redrawing of folding effects was requested at this time */
    private var foldEffectsRequested:Number = 0;
	

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * The page constructor.
     * Loads the settings from either the defaults or the overriding XML
     * attributes and fills the background appropriately.
     * 
     * @param megazine
     *          the MegaZine instance this page belongs to.
     * @param localizer
     *          Localizer used for localizing displayed text.
     * @param library
     *          graphics library used to get gui elements from.
     * @param chapter
     *          the chapter this page belongs to (for attribute defaults).
     * @param pageNumber
     *          the number of this page.
     * @param pageData
     *          an array with the xml data for the two pages.
     * @param pageContent
     *          the containers to be used for the pages (0 even, 1 odd).
     * @param pageShadow
     *          the container to be used for the page shadows (0 even, 1 odd).
     * @param settings
     *          settings object with common settings.
     */
    public function Page(megazine:MegaZine, localizer:Localizer,
            library:ILibrary, chapter:Chapter, pageNumber:uint, pageData:Array,
		    pageContent:Array, pageShadow:Array, settings:Settings) {
		
        // Initialize objects and fill them with default values
        dragTarget = new Vector2D();
        currentDragPosition = new Vector2D();
        dragReference = new Vector2D();
        
        cleanUpSupport = new CleanUpSupport();
		
        maskMain = new Array(new Shape(), new Shape());
        backgroundColor = new Array(0, 0);
        foldEffectAlpha = new Array(0, 0);
        this.pageContainer = pageContent;
        pageVisibility = new Array(false, false);
        pageAnchors = new Array(null, null);
        shadowAlpha = settings.shadowIntensity;
        dragSpeed = settings.dragSpeed;
        keepDistance = settings.dragKeepDistance;
        stateLoading = new Array(Constants.PAGE_UNLOADED,
                Constants.PAGE_UNLOADED);
        elementsLoaded = new Array(0, 0);
        doBuffer = new Array(false, false);
        bufferImage = new Array(2);
        bufferImageData = new Array(2);
        buttonColor = new Array(-1, -1);
        hasCachedThumb_ = new Array(false, false);
        foldEffect = new Array(new Shape(), new Shape());
        
        isLeftToRight = pageNumber < megazine.currentLogicalPage;
		
        // Remember the MegaZine this page belongs to
        this.megazine = megazine;
        // Store chapter.
        this.chapter_ = chapter;
		
        // Create the element wrappers
        elements = new Array(new Array(), new Array());
        var elementXML:XML;
        var element:Element;
        var elementNumber:uint = 0;
        for each (elementXML in (pageData[0] as XML).children()) {
            element = new Element(megazine, localizer, library, elementXML,
                    this, true, elementNumber++);
            cleanUpSupport.make(element, MegaZineEvent.ELEMENT_COMPLETE,
                    handleElementLoaded);
            cleanUpSupport.make(element, MegaZineEvent.ELEMENT_INIT,
                    handleElementInit);
            cleanUpSupport.make(element, IOErrorEvent.IO_ERROR,
                    handleElementError);
            elements[0].push(element);
        }
        elementNumber = 0;
        for each (elementXML in (pageData[1] as XML).children()) {
            element = new Element(megazine, localizer, library, elementXML,
                    this, false, elementNumber++);
            cleanUpSupport.make(element, MegaZineEvent.ELEMENT_COMPLETE,
                    handleElementLoaded);
            cleanUpSupport.make(element, MegaZineEvent.ELEMENT_INIT,
                    handleElementInit);
            cleanUpSupport.make(element, IOErrorEvent.IO_ERROR,
                    handleElementError);
            elements[1].push(element);
        }
		
        // Add the containers as children for the display
        megazine.pageContainer.addChild(maskMain[0]);
        megazine.pageContainer.addChild(maskMain[1]);
		
        // And page number
        this.pageNumber = pageNumber;
        //this.pageWidth = Helper.validateUInt(pageData[1].@width,
        //        Helper.validateUInt(pageData[0].@width, megazine.pageWidth));
        //this.pageHeight = Helper.validateUInt(pageData[1].@height,
        //        Helper.validateUInt(pageData[0].@height, megazine.pageHeight));
        pageWidth = megazine.pageWidth;
        pageHeight = megazine.pageHeight;
		thumbScale = settings.thumbScale
        pageDiagonale = Math.sqrt(pageWidth * pageWidth
                + pageHeight * pageHeight);
        dragReferenceTopMiddle = new Vector2D(pageWidth, 0);
        dragReferenceBottomMiddle = new Vector2D(pageWidth, pageHeight);
		
        // Generate thumbnail data objects
		
        thumbnailData = [new BitmapData(pageWidth * settings.thumbScale, pageHeight * settings.thumbScale,
                true, 0), new BitmapData(pageWidth * settings.thumbScale, pageHeight * settings.thumbScale,
                true, 0)];
        thumbnail = [new Bitmap(thumbnailData[0], "auto", true),
                new Bitmap(thumbnailData[1], "auto", true)];
        
        // Cleanup when done.
        cleanUpSupport.addFunction(
                function():void {
                    (thumbnailData[0] as BitmapData).dispose();
                    (thumbnailData[1] as BitmapData).dispose();
                });
		
        // Stiff page or not? Must be checked beforehand, because it counts for
        // both.
        isStiff_ = Helper.validateBoolean(pageData[1].@stiff,
                Helper.validateBoolean(pageData[0].@stiff, false));
		
		
		slideDelayDefault_ = chapter.slideDelay;
		 
        // Time in ms to show a page before turning to the next one in seconds.
        this.slideDelay = [Helper.validateUInt(pageData[0].@slidedelay,
                        slideDelayDefault_),
                Helper.validateUInt(pageData[1].@slidedelay,
                        slideDelayDefault_)];
		
        // Get data for the pages.
        for (var i:int = 0;i < 2; i++) {
			
            // Get anchors
            pageAnchors[i] = Helper.validateString(pageData[i].@anchor, null);
			
            // Get some per page settings stored in attributes
            // Background color overwriting the default one.
            backgroundColor[i] = Helper.validateUInt(pageData[i].@bgcolor,
                    chapter.backgroundColor);
			
            // Folding effects alpha value.
            foldEffectAlpha[i] = Helper.validateNumber(pageData[i].@foldfx,
                    chapter.foldEffectAlpha, 0, 1);
			
            // Buffering (bitmap caching) - cleanup see below
            doBuffer[i] =
                    Helper.validateBoolean(pageData[i].@buffer, doBuffer[i]);
            if (doBuffer[i]) {
                bufferImageData[i] = new BitmapData(pageWidth, pageHeight,
                        false);
                bufferImage[i] = new Bitmap(bufferImageData[i]);
            }
			
            // Button color
            buttonColor[i] = Helper.validateInt(pageData[i].@buttoncolor,
                    buttonColor[i]);
			
            // Build the basic page layout
			
            // Check if alpha is zero but color is given, if so assume it's a
            // 24 bit rgb value, not a 32bit argb value.
            if (backgroundColor[i] > 0
                    && (backgroundColor[i] & 0xFF000000) == 0)
            {
                backgroundColor[i] += 0xFF000000;
            }
			
            // Fill thumbnail with "loading" text per default
            var bmd:BitmapData = thumbnailData[i] as BitmapData;
            var ldt:TextField = new TextField();
            ldt.defaultTextFormat = new TextFormat("_sans", pageWidth / 40,
                    0xEEEEEE, true, null, null, null, null,
                    TextFormatAlign.CENTER);
            ldt.width = pageWidth * settings.thumbScale;
            ldt.text = "Loading...";
            bmd.fillRect(bmd.rect, 0x333333);
            bmd.draw(ldt, new Matrix(1, 0, 0, 1, 0,
                    (8 * pageHeight - pageWidth) / 80));
			
            // Background fill (extracting the alpha channel)
            pageContainer[i].graphics.beginFill(backgroundColor[i] & 0xFFFFFF,
                    (backgroundColor[i] >>> 24) / 255);
            pageContainer[i].graphics.drawRect(0, 0, pageWidth, pageHeight);
            pageContainer[i].graphics.endFill();
			
            // Create the masks and elementcontainer
            maskMain[i].graphics.beginFill(0xFF00FF);
            if (isStiff_) {
                maskMain[i].graphics.drawRect(0, pageHeight - pageDiagonale,
                        pageWidth, pageDiagonale);
            } else {
                maskMain[i].graphics.drawRect(0, 0, pageDiagonale * 2,
                        pageDiagonale * 3);
            }
            maskMain[i].graphics.endFill();
			
            pageContainer[i].mask = maskMain[i];
			
            // Highlight / shadow overrides
            shadowAlpha = Helper.validateNumber(pageData[i].@shadows,
                    shadowAlpha, 0);
        }
        
        // Clear buffer bitmapdata
        cleanUpSupport.addFunction(
                function():void {
                	if (doBuffer[0]) {
                        (bufferImageData[0] as BitmapData).dispose();
                	}
                    if (doBuffer[1]) {
                        (bufferImageData[1] as BitmapData).dispose();
                    }
                });
		
        // Shadows / Highlights
        if (!Helper.fpEquals(shadowAlpha, 0.0)) {
            // Initialize the array
            shadowAndLight = new Array(4);
			
            // Masks
            shadowMasks = new Array(4);
			
            // Matrix for the shadow
            var shadowMatrix:Matrix = new Matrix();
            shadowMatrix.createGradientBox(pageWidth * 2, pageHeight * 2, 0,
                    -pageWidth, -pageHeight);
            var shadowMatrix2:Matrix = new Matrix();
            shadowMatrix2.createGradientBox(pageWidth, pageHeight * 2, 0,
                    -pageWidth * 0.5, -pageHeight);
			
            for (i = 0;i < (isStiff_ ? 2 : 4); i++) {
				
                shadowAndLight[i] = i > 1
                        ? new Shape()
                        : pageShadow[i == 0 ? 0 : 1];
				
                shadowMasks[i] = new Shape();
				
                if (i < 2) {
					
                    // The shadow
                    shadowAndLight[i].graphics.beginGradientFill(
                            GradientType.LINEAR, [0x000000, 0x000000, 0x000000],
                                    [0, 1, 0], [112, 128, 255], shadowMatrix);
                    shadowAndLight[i].graphics.drawRect(-pageDiagonale,
                            -pageDiagonale, pageDiagonale * 2,
                            pageDiagonale * 2);
                    shadowAndLight[i].graphics.endFill();
					
                    // The mask
                    shadowMasks[i].graphics.beginFill(0xFF00FF);
                    shadowMasks[i].graphics.drawRect(0, 0, pageWidth * 2,
                            pageHeight);
                    shadowMasks[i].graphics.endFill();
                } else {
					
                    // The highlight
                    shadowAndLight[i].graphics.beginGradientFill(
                            GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF, 0xFFFFFF],
                                    [0, 1, 0], [120, 160, 200], shadowMatrix2);
					
                    shadowAndLight[i].graphics.drawRect(-pageDiagonale * 0.5,
                            -pageDiagonale, pageDiagonale, pageDiagonale * 2);
                    shadowAndLight[i].graphics.endFill();
					
                    // The mask
                    shadowMasks[i].graphics.beginFill(0xFF00FF);
                    shadowMasks[i].graphics.drawRect(0, 0, pageWidth,
                            pageHeight);
                    shadowMasks[i].graphics.endFill();
                }
				
                shadowAndLight[i].mask = shadowMasks[i];
				
                shadowAndLight[i].visible = megazine.shadows;
            }
			
            megazine.pageContainer.addChild(shadowMasks[0]);
            megazine.pageContainer.addChild(shadowMasks[1]);
			
            // Move the masks of the shadows to the right positions if this is
            // a stiff page.
            if (isStiff_) {
                shadowMasks[0].x = pageWidth;
                shadowMasks[1].x = -pageWidth;
            }
        } else {
            shadowAlpha = 0;
        }
		
        // Starting position
        resetPage();
    }
    
    /**
     * Cleans up all listeners and internal references used by the page and
     * makes it ready for garbage collection.
     */
    public function destroy():void {
        cleanUpSupport.cleanup();
    }
    
    /**
     * Initialize / update folding effects.
     */
    internal function initFoldFX(instant:Boolean = false):void {
    	if (instant) {
    		drawFoldEffects();
    	} else {
    		foldEffectsRequested = new Date().time;
    	}
    }
    
    /**
     * Actually draw the folding effects.
     */
    private function drawFoldEffects():void {
        for (var i:int = 0; i < 2; ++i) {
            // Folding effects
            if (!isStiff_ && foldEffectAlpha[i] > 0) {
                // The maximum and minimum percentual widths for the shadows
                var maxWidth:Number = 0.16;
                var minWidth:Number = 0.02;
                // The max and min alpha values
                var maxAlpha:Number = Math.max(0.1,
                        Math.min(0.9, megazine.pageCount / 50.0));
                var minAlpha:Number = Math.max(0.1, maxAlpha / 4.0);
                // Decrease alpha based on how far we are away from the cover.
                // Otherwise the shadow would appear to be too intensive in the
                // middle.
                var coverDistFactor:Number = 0.5 + Math.abs(
                        Number(pageNumber + i) / megazine.pageCount - 0.5);
                maxAlpha *= coverDistFactor;
                minAlpha *= coverDistFactor;
                // Modify based on the settings.
                maxAlpha *= foldEffectAlpha[i];
                minAlpha *= foldEffectAlpha[i];
                
                // Calculate intensity for the current page
                var intensityRight:Number = Number(pageNumber + i)
                        / megazine.pageCount;
                var intensityLeft:Number = 1.0 - intensityRight;
                
                // Prepare variables for the actual gradient fill.
                var foldEffectColors:Array = [0x000000, 0x000000];
                var foldEffectRatios:Array = [0, 255];
                var foldEffectMatrix:Matrix = new Matrix();
                var foldEffectAlphas:Array;
                
                // Which side to paint. The scaling done by actually scaling the
                // whole gradient, not by changing the ratios. This is because
                // otherwise small gradients look rather choppy.
                var width:Number;
                var alpha:Number;
                if (i == 1) {
                    // Odd - left page
                    alpha = minAlpha + (maxAlpha - minAlpha) * intensityLeft;
                    foldEffectAlphas = [0, alpha];
                    width = minWidth + (maxWidth - minWidth) * intensityRight;
                    foldEffectMatrix.createGradientBox(pageWidth * width,
                            pageHeight, 0, pageWidth - pageWidth * width);
                } else {
                    // Even - right page
                    alpha = minAlpha + (maxAlpha - minAlpha) * intensityRight;
                    foldEffectAlphas = [alpha, 0];
                    width = minWidth + (maxWidth - minWidth) * intensityLeft;
                    foldEffectMatrix.createGradientBox(pageWidth * width,
                            pageHeight);
                }
                
                // Preform the gradient fill, drawing the folding effect.
                (foldEffect[i] as Shape).graphics.clear();
                (foldEffect[i] as Shape).graphics.beginGradientFill(
                        GradientType.LINEAR, foldEffectColors, foldEffectAlphas,
                        foldEffectRatios, foldEffectMatrix);
                (foldEffect[i] as Shape).graphics.drawRect(0, 0, pageWidth,
                        pageHeight);
                (foldEffect[i] as Shape).graphics.endFill();
                
                // Make it visible on the page
                if (pageContainer[i].contains(foldEffect[i])) {
                    pageContainer[i].removeChild(foldEffect[i]);
                }
                pageContainer[i].addChild(foldEffect[i]);
            }
        }
        
        // Add highlights
        if (!isStiff_ && shadowAndLight) {
            pageContainer[0].addChild(shadowMasks[2]);
            pageContainer[0].addChild(shadowAndLight[2]);
            pageContainer[1].addChild(shadowMasks[3]);
            pageContainer[1].addChild(shadowAndLight[3]);
        }
    }

    /**
     * Page number correction for right to left books.
     */
    internal function correctPageNumber():void {
        pageNumber = megazine.pageCount - pageNumber - 1;
    }

    // ---------------------------------------------------------------------- //
    // Accessors
    // ---------------------------------------------------------------------- //
	
    /**
     * Tells whether the page is a stiff or a normal page.
     */
    public function get isStiff():Boolean {
        return isStiff_;
    }

    /**
     * Get the <code>DisplayObjectContainer</code> for the even part of this
     * page. This container may be used to manually add elements so the page.
     * Note that it will also contain all actual elements as defined in the
     * book, which may also be unloaded / reloaded as required.
     */
    public function get pageEven():DisplayObjectContainer {
        return pageContainer[0];
    }

    /**
     * Get the <code>DisplayObjectContainer</code> for the odd part of this
     * page. This container may be used to manually add elements so the page.
     * Note that it will also contain all actual elements as defined in the
     * book, which may also be unloaded / reloaded as required.
     */
    public function get pageOdd():DisplayObjectContainer {
        return pageContainer[1];
    }

    /**
     * Gets the page's state.
     */
    public function get state():String {
        return state_;
    }

    /**
     * The default slide delay for this page, from the chapter.
     */
    public function get slideDelayDefault():uint {
        return slideDelayDefault_;
    }

    /**
     * Get the chapter this page resides in.
     */
    internal function get chapter():Chapter {
        return chapter_;
    }

    /**
     * Determine whether to buffer or not.
     * 
     * <p>
     * If set to true all elements on stage will be made invisible and the
     * buffer will be shown after rendering the current page state (with
     * elements) into it.
     * </p>
     * 
     * <p>
     * If set to false visibility of elements will be restored, buffer image
     * will be hidden.
     * </p>
     * 
     * @param enable
     *          buffer or restore to normal?
     */
    private function set buffer(enable:Boolean):void {
        for (var pageIdx:int = 0;pageIdx < 2; ++pageIdx) {
            if (!doBuffer[pageIdx]) return;
            
            var cont:DisplayObjectContainer = pageContainer[pageIdx];
            var bmd:BitmapData = bufferImageData[pageIdx];
            var bmp:Bitmap = bufferImage[pageIdx];
            var i:int;
            
            if (enable) {
                // Buffered state
                
                // Pretty much the same procedure as for thumbnails...
                
                // Remove mask for rendering
                cont.mask = null;
                // Hide page shadows if active
                if (shadowAndLight) {
                    shadowAndLight[0].visible =
                            shadowAndLight[1].visible = false;
                    if (!isStiff_) {
                        shadowAndLight[2].visible =
                                shadowAndLight[3].visible = false;
                    }
                }
                
                // Background color
                bmd.fillRect(bmd.rect, backgroundColor[pageIdx]);
                // Draw page data
                bmd.draw(cont);
                
                // Hide all elements and show buffer
                for (i = 0;i < cont.numChildren; ++i) {
                    cont.getChildAt(i).visible = false;
                }
                
                // Restore shadow visibility
                updateShadowVisibility();
                // Restore mask
                cont.mask = maskMain[pageIdx];
                
                cont.addChildAt(bmp, 0);
            } else {
                // Normal state
                
                // Show all elements and hide buffer
                if (bmp != null && cont.contains(bmp)) cont.removeChild(bmp);
                for (i = 0;i < cont.numChildren; ++i) {
                    cont.getChildAt(i).visible = true;
                }
            }
        }
    }
    
    // ---------------------------- End Properties -------------------------- //
	
    /**
     * Get the anchor of this page, if it has one. If it has no anchor, an empty
     * string is returned.
     * 
     * @param even
     *          for the even or for the odd part of this page.
     * @return the anchor for the page.
     */
    public function getAnchor(even:Boolean):String {
        return pageAnchors[int(!even)];
    }

    /**
     * Get this page's background color.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return this page's background color.
     */
    public function getBackgroundColor(even:Boolean):uint {
        return backgroundColor[int(!even)];
    }

    /**
     * Get the button color for this page (used in the navigation bar).
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return the color for this page's button in the navigation bar.
     */
    internal function getButtonColor(even:Boolean):int {
        return buttonColor[int(!even)];
    }

    /**
     * Get the loading state for one of the pages sides.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return the current loading state.
     */
    internal function getLoadState(even:Boolean):String {
        return stateLoading[int(!even)];
    }

    /**
     * Get the page's number. Not that this returns the indexed page number,
     * i.e. the count starts at 0.
     * Please note that this ignores right to left reading order. This will
     * always be counted left to right.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return the page number.
     */
    public function getNumber(even:Boolean):uint {
        return pageNumber + int(!even);
    }

    /**
     * Sets the page number for this page, in case it changes its position in
     * the book.
     * 
     * @param pageNumber
     *          the new pagenumber of this page.
     */
    internal function setNumber(number:uint):void {
        this.pageNumber = number;
    }

    /**
     * Get the BitMap object that is used for rendering the thumbnail.
     * This BitMap is updated automatically.
     * Please note that this will always return a reference to the same BitMap
     * object. If you need another one, use it's bitmap data to create one.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return the BitMap with the thumbnail.
     */
    public function getPageThumbnail(even:Boolean):Bitmap {
        return thumbnail[int(!even)];
    }

    /**
     * Get whether the even or odd page is visible or not.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return visible or not.
     */
    public function getPageVisible(even:Boolean):Boolean {
        return pageVisibility[int(!even)];
    }

    /**
     * Gets the slide delay for this page, or this pages odd part.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return the slide delay of this page or its odd part.
     */
    internal function getSlideDelay(even:Boolean):int {
        return slideDelay[int(!even)];
    }

    /**
     * Checks if the page has a thumbnail cached, i.e. if it has been rendered
     * once.
     * 
     * @param even
     *          for the even page, or for the odd one.
     * @return true if a thumbnail has once been rendered for that page.
     */
    public function hasCachedThumb(even:Boolean):Boolean {
        return hasCachedThumb_[int(!even)];
    }

    /**
     * Sets the dragging target.
     * 
     * @param target
     *          the new position to drag to.
     */
    internal function setDragTarget(target:Vector2D):void {
		
        dragTarget.copy(target);
		
        // Check if dragging in corner inverts, if yes set to that corner.
        // Only works when dragging corners.
        if (dragReference.y == 0 && dragTarget.y < 0) {
			
            // Top corner
            if (isLeftToRight && dragTarget.x > pageWidth * 2) {
                // Left to right and far enough to the right
                dragTarget.setTo(pageWidth * 2, 0);
            } else if (!isLeftToRight && dragTarget.x < 0) {
                // Right to left and far enough to the left
                dragTarget.setTo(0, 0);
            }
        } else if (dragReference.y == pageHeight && dragTarget.y > pageHeight) {
			
            // Bottom corner
            if (isLeftToRight && dragTarget.x > pageWidth * 2) {
                // Left to right and far enough to the right
                dragTarget.setTo(pageWidth * 2, pageHeight);
            } else if (!isLeftToRight && dragTarget.x < 0) {
                // Right to left and far enough to the left
                dragTarget.setTo(0, pageHeight);
            }
        }
		
        validatePosition(dragTarget);
    }

    /**
     * Sets the page's state, fires an event.
     * 
     * @param state 
     *          new page state
     */
    private function setState(state:String):void {
        // Create first to store the old page number.
        // Note on leftToRight: when turning the leftToRight is inverted before
        // calling resetPage(), thus it has to be "reinverted" here, to return
        // the actual leftToRight value from the page turn.
        var e:MegaZineEvent = new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
                pageNumber, state, this.state_,
                this.state_ == Constants.PAGE_TURNING
                        ? !isLeftToRight
                        : isLeftToRight);
        this.state_ = state;
        dispatchEvent(e);
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    // ---------------------------------------------------------------------- //
    // Loading
    // ---------------------------------------------------------------------- //
	
    /**
     * Increase the number of loaded elements for one of the pages, check if
     * we're done.
     * 
     * @param even
     *          even or for the odd page.
     */
    private function increaseElementCounter(even:Boolean):void {
		
        var i:uint = uint(!even);
        if (elementsLoaded[i] >= (elements[i] as Array).length) {
            // Already done, element was probably exchanged.
            return;
        } else if (++elementsLoaded[i] >= (elements[i] as Array).length) {
            // Done, fire event.
            loadingComplete(even);
        }
    }

    /**
     * Load a page's elements.
     * 
     * @param even
     *          the even or the odd page?
     * @param loader
     *          the element loader to use.
     * @param thumb
     *          only load the page to generate a thumbnail.
     */
    internal function load(even:Boolean, loader:ElementLoader,
            thumb:Boolean = false):void
    {
        // For which page...
        var i:uint = uint(!even);
        var s:String = getLoadState(even);
		
        if (s != Constants.PAGE_UNLOADED
                && (s != Constants.PAGE_LOADING_THUMB || thumb))
        {
            throw new Error("Already loading or loaded.");
        } else if (s == Constants.PAGE_LOADING_THUMB && !thumb) {
            stateLoading[i] = Constants.PAGE_LOADING;
            return;
        }
		
        // Set loading state
        stateLoading[i] = thumb ? Constants.PAGE_LOADING_THUMB
                : Constants.PAGE_LOADING;
		
        // Load the elements
        if ((elements[i] as Array).length == 0) {
			
            Logger.log("MegaZine Page", "  No elements for page "
                    + (getNumber(even) + 1) + ".");
			
            loadingComplete(even);
        } else {
			
            Logger.log("MegaZine Page", "  Begin loading elements for page "
                    + (getNumber(even) + 1) + ".");
			
            // Load all the elements. Inverse order, because we need to add at
            // the bottom to not overwrite folding effects and shadows.
            elementsLoaded[i] = 0;
            loader.addElements(elements[i]);
        }
    }

    /**
     * Done loading...
     * 
     * @param even
     *          even or odd page.
     */
    private function loadingComplete(even:Boolean):void {
		
        var e:MegaZineEvent;
        if (getLoadState(even) == Constants.PAGE_LOADING) {
            e = new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, getNumber(even),
                    Constants.PAGE_LOADED, getLoadState(even));
            // Set state to loaded
            stateLoading[int(!even)] = Constants.PAGE_LOADED;
            // Generate thumbnail
            redraw(true);
        } else { 
            // Only the thumb, afterwards unload again
            e = new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, getNumber(even),
                    Constants.PAGE_UNLOADED, getLoadState(even));
            // Set state to loaded
            stateLoading[int(!even)] = Constants.PAGE_LOADED;
            // Generate thumbnail
            redraw(true);
            // Only the thumb
            unload(even);
        }
        // Dispatch event to let the world know we're done
        dispatchEvent(e);
    }

    /** Failed loading an element */
    private function handleElementError(e:IOErrorEvent):void {
        var ele:Element = e.target as Element;
        Logger.log("MegaZine Page", "    Page " + (pageNumber + int(!ele.even))
                + ": " + e.text, Logger.TYPE_WARNING);
        increaseElementCounter(ele.even);
    }

    /** Called when an element is ready to be added to stage. */
    private function handleElementInit(e:MegaZineEvent):void {
        // Check which of the pages.
        var i:uint = (e.page & 1);
		
        // Create the mask (do not allow visible area to exceed that of the
        // page)
        var mask:Shape = new Shape();
        mask.graphics.beginFill(0xFF00FF);
        mask.graphics.drawRect(0, 0, pageWidth, pageHeight);
        mask.graphics.endFill();
        var ele:Element = e.target as Element;
        ele.element.mask = mask;
		
        // If buffering hide for now.
        if (doBuffer[i] && (bufferImage[i] as Bitmap).parent != null) {
            ele.element.visible = false;
        }
		
        // Add at lowest level, so we do not override foldeffects and shadows.
        var index:int = (elements[i] as Array).indexOf(ele);
        var cont:DisplayObjectContainer = pageContainer[i];
        cont.addChildAt(ele.element, 0);
        // Sort elements. Due to the loader elements might finish in another
        // order than they should display in, so fix that possibly jumbled order
        // here. Keep track of how many elements are missing so as not to step
        // out of the valid range.
        var bias:uint = 0;
        // Parse all possible elements.
        for (var elementIndex:int = 0;elementIndex <= index; elementIndex++) {
            // Get the actual element.
            var element:AbstractElement =
                    (elements[i][elementIndex] as Element).element;
            // If it is loaded and on the display container swap it with the
            // element at the position it should be at.
            if (element != null && cont.contains(element)) {
                cont.swapChildrenAt(elementIndex - bias,
                        cont.getChildIndex(element));
            } else {
                // Else we have a not loaded element; increase bias.
                bias++;
            }
        }
        // Add the mask for the element.
        cont.addChild(mask);
    }

    /** Called when an element finishes loading. */
    private function handleElementLoaded(e:MegaZineEvent):void {
        increaseElementCounter((e.page & 1) == 0);
    }

    /**
     * Unloads page elements, removing all elements form that page. The page has
     * to be reloaded with the load method when it should be displayed again.
     * 
     * @param even
     *          even or odd page.
     * @param loader
     *          the element loader used.
     */
    internal function unload(even:Boolean, loader:ElementLoader = null):void {
		
        // The id...
        var i:uint = uint(!even);
		
        // Check if the page is loaded. If it is not cancel.
        if (getLoadState(even) != Constants.PAGE_LOADED) {
            // If loading mark it for unloading after load.
            if (getLoadState(even) == Constants.PAGE_LOADING) {
                stateLoading[i] = Constants.PAGE_LOADING_THUMB;
            }
            return;
        }
		
		// Remove all children, thus making them ready for the garbage
		// collector.
        for each (var e:Element in elements[i]) {
            if (loader) loader.removeElement(e);
            e.unload();
        }
		
        // Set state
        stateLoading[i] = Constants.PAGE_UNLOADED;
    }

    // ---------------------------------------------------------------------- //
    // Dragging
    // ---------------------------------------------------------------------- //
	
    /**
     * Begin dragging this page to the specified position. The point on the edge
     * of the page is defined by the offset and the direction (i.e. if the left
     * or right edge is used).
     * 
     * @param dragTarget
     *          where to drag the reference point on the edge to.
     * @param offset
     *          the y offset of the reference point on the edge.
     * @param leftToRight
     *          turn the page left to right or right to left?
     */
    internal function beginDrag(dragTarget:Vector2D, offset:Number,
            leftToRight:Boolean):void
    {
		
        // Check if the page is ready for dragging
        if (state == Constants.PAGE_READY) {
			
            // Start buffering (setter checks if allowed)
            buffer = true;
			
            setState(Constants.PAGE_DRAGGING);
			
            // Copy the basics
            this.isLeftToRight = leftToRight;
			
            if (isStiff_) {
                // If it's a stiff page always set the offset to 0, because only
                // the x coordinate matters. Also we can skip the calculations
                // of the max distances.
                dragOffset = 0;
            } else {
                // Copy the offset.
                dragOffset = offset;
                // Allowed distances from the top and bottom middle points
                dragMaxDistTop = Math.sqrt(pageWidth * pageWidth
                        + dragOffset * dragOffset);
                dragMaxDistBottom = Math.sqrt(pageWidth * pageWidth
                        + (pageHeight - dragOffset)
                        * (pageHeight - dragOffset));
            }
			
            // Check if we are dragging left to right or right to left and set
            // the starting point.
            dragReference.setTo(leftToRight ? 0 : pageWidth * 2, dragOffset);
			
            // Set the current drag point to the starting location
            currentDragPosition.copy(dragReference);
			
            setDragTarget(dragTarget);
			
            // Force the first update (to avoid flickers)
            redraw();
        } else {
            Logger.log("MegaZine Page", "The page (" + pageNumber
                    + ") is not yet ready for dragging.");
        }
    }

    /**
     * Begin dragging so that we won't restore, even if we get out of range of
     * the corners.
     * Triggered when the lmb is held down.
     */
    internal function beginUserDrag():void {
        setState(Constants.PAGE_DRAGGING_USER);
    }

    /**
     * Cancel dragging and restore the page to its previous position.
     * 
     * @param instant
     *          immediately reset the page.
     */
    internal function cancelDrag(instant:Boolean = false):void {
		
        if (state == Constants.PAGE_DRAGGING
                || state == Constants.PAGE_DRAGGING_USER)
        {
			
            setState(Constants.PAGE_RESTORING);
			
            if (instant) {
                resetPage();
            } else {
				
                // Get the function describing the path to the starting point.
                // Make the arch steep, to get the page horizontal quickly.
                var height:Number = currentDragPosition.y - dragOffset;
                var above:Boolean = false;
                var mult:Number = height;
                if (height < 0 ) {
                    above = true;
                    mult = -height;
                }
				
                mult /= currentDragPosition.distance(dragReference) * 2;
				
                dragFunction = new DragPath(currentDragPosition, dragReference,
                        (int(above) ^ int(isLeftToRight))
                                ? DragPath.ARCH_RIGHT
                                : DragPath.ARCH_LEFT,
                        mult, pageWidth * dragSpeed * 0.25);
            }
        } else {
			
            Logger.log("MegaZine Page", "The page (" + pageNumber
                    + ") is not being dragged, therefore the drag cannot be "
                    + "canceled.");
        }
    }

    /**
     * Handles redrawing of the page (i.e. repositioning).
     * 
     * @param forceThumbs
     *          forces a thumbnail update, even if the thumbnails are not
     *          visible. Will skip everything else, such as updating the drag
     *          position.
     */
    internal function redraw(forceThumbs:Boolean = false):void {
		
        // Update thumbnails if they have a parent, i.e. if they are visible.
        for (var i:int = 0;i < 2; i++) {
            if ((forceThumbs || thumbnail[i].parent != null)
                    && stateLoading[i] == Constants.PAGE_LOADED
                    && (forceThumbs || pageContainer[i].numChildren > 0))
            {
                // First remove the mask, so that nothing gets in the way.
                pageContainer[i].mask = null;
                if (shadowAndLight) {
                    shadowAndLight[0].visible = shadowAndLight[1].visible =
                            false;
                    if (!isStiff_) {
                        shadowAndLight[2].visible = shadowAndLight[3].visible =
                                false;
                    }
                }
                // First overpaint it with the page's background color or the
                // default page color. 
                (thumbnailData[i] as BitmapData).fillRect(
                        (thumbnailData[i] as BitmapData).rect,
                        backgroundColor[i]);
                // Then draw the elements on the page (scaled down to 20
                // percent).
				
				MegaZine.stage.quality = StageQuality.BEST;
                BitmapData(thumbnailData[i]).draw(pageContainer[i],
                        new Matrix(thumbScale, 0, 0, thumbScale), null, null, null, true);
				MegaZine.stage.quality = StageQuality.HIGH;
                // Then set the mask again.
                pageContainer[i].mask = maskMain[i];
                updateShadowVisibility();
                hasCachedThumb_[i] = true;
            }
        }
		
        // When only updating thumbnails go no further
        if (forceThumbs) {
            return;
        }
        
        // Check if we want to draw the fold effects now.
        if (foldEffectsRequested > 0) {
        	// Depending on how long it's passed by, the more likely it becomes
        	// we'll repaint it. This approach allows the engine to distribute
        	// the actual work over some renderpasses (and depending on how
        	// good the randomizer is, it should be evenly distributed).
        	// Rendering it all at once would lead to small lags on bigger books
        	// After n seconds enforce repainting (because the random number
        	// cannot get bigger than that). This n depends on the number of
        	// pages in the book.
        	var timeDelta:Number = new Date().time - foldEffectsRequested;
        	if (timeDelta > Math.random() * 100 * megazine.pageCount) {
        		drawFoldEffects();
                foldEffectsRequested = 0;
            }
        }
		
        // Check what to do (animating or not)
        if (state == Constants.PAGE_DRAGGING
                || state == Constants.PAGE_DRAGGING_USER)
        {
			
            // If close to the traget then do nothing (do not waste cpu time
            // while actually idling).
            if (currentDragPosition.distance(dragTarget) == 0) {
                return;
            }
			
            // Dragging, get the new _dragTarget via interpolation
            currentDragPosition.interpolate(dragTarget, dragSpeed);
            if (isStiff_) {
                validatePosition(currentDragPosition, true);
            }
        } else if (state == Constants.PAGE_TURNING
                || state == Constants.PAGE_RESTORING)
        {
			
            currentDragPosition.copy(dragFunction.getPosition());
            validatePosition(currentDragPosition);
			
            // Turning or restoring, meaning we move along a path described by
            // the dragpath function. Get the new _dragTarget via the defined
            // function.
            if (dragFunction.step()) {
                //(_dragSpeed * _pageWidth * 0.5)) {
				
                // We're done
                if (state_ == Constants.PAGE_TURNING) {
                    isLeftToRight = !isLeftToRight;
                }
                resetPage();
            }
        }
		
        // Update the matrices if not ready, i.e. the page is most likely
        // moving. If the page is ready, the _dragCurrent is probably wrong, so
        // we don't want to do an update.
        if (state != Constants.PAGE_READY) {
            updateMatrices();
        }
		
        // Check if visibility changed, if yes fire an event.
        try {
            if (pageContainer[0].visible != pageVisibility[0]) {
                pageVisibility[0] = pageContainer[0].visible;
                dispatchEvent(new MegaZineEvent(pageVisibility[0]
                        ? MegaZineEvent.VISIBLE_EVEN
                        : MegaZineEvent.INVISIBLE_EVEN, getNumber(true)));
            }
        } catch (e:Error) { /* _pageContainer[0] == null */ 
        }
        try {
            if (pageContainer[1].visible != pageVisibility[1]) {
                pageVisibility[1] = pageContainer[1].visible;
                dispatchEvent(new MegaZineEvent(pageVisibility[1]
                        ? MegaZineEvent.VISIBLE_ODD
                        : MegaZineEvent.INVISIBLE_ODD, getNumber(false)));
            }
        } catch (e:Error) { /* _pageContainer[1] == null */ 
        }
    }

    /**
     * Set position back to the default
     */
    internal function resetPage():void {
		
        // Cease buffering (setter checks if allowed)
        buffer = false;
		
        // Matrix used for resetting transformations set for the pages.
        var matrix:Matrix = new Matrix();
		
        // Reset positions to the defaults, remove rotations, skews.
        if (isLeftToRight) {
			
            pageContainer[1].transform.matrix = matrix;
            maskMain[1].transform.matrix = matrix;
            if (isStiff_) {
                matrix.tx = pageWidth;
            }
            maskMain[0].transform.matrix = matrix;
            matrix.tx = pageWidth;
            pageContainer[0].transform.matrix = matrix;
        } else {
			
            matrix.tx = pageWidth;
            pageContainer[0].transform.matrix = matrix;
            maskMain[0].transform.matrix = matrix;
            matrix.tx = 0;
            pageContainer[1].transform.matrix = matrix;
            maskMain[1].transform.matrix = matrix;
        }
		
        setState(Constants.PAGE_READY);
		
        updateShadowVisibility();
    }

    /**
     * Finish the pagedrag and turn the page over. If not dragging, do
     * a complete page turn.
     * 
     * @param instant
     *          perform the turn without animation.
     * @param ltr
     *          turn left to right or right to left.
     */
    internal function turnPage(instant:Boolean, ltr:Boolean):void
    {
        var target:Vector2D;
        var archDir:String;
        
        isLeftToRight = ltr;
		
        if (instant) {
            resetPage();
            return;
        } else if (state == Constants.PAGE_DRAGGING
                || state == Constants.PAGE_DRAGGING_USER)
        {
            // Page is being dragged, finish the drag
            var above:Boolean = currentDragPosition.y - dragOffset < 0;
            archDir = (int(isLeftToRight) ^ int(above)) == 0
                    ? DragPath.ARCH_LEFT
                    : DragPath.ARCH_RIGHT;
        } else if (state == Constants.PAGE_READY) {
            // Start buffering (setter checks if allowed)
            buffer = true;
			
            // At bottom, because we always arc up, and in that case dragging
            // the top would cause overly fast movement in the first frames.
            dragOffset = pageHeight;
            dragMaxDistTop = pageDiagonale;
            dragMaxDistBottom = pageWidth;
			
            // Check if we are dragging left to right or right to left and set
            // the starting point.
            dragReference.setTo(isLeftToRight ? 0 : pageWidth * 2, dragOffset);
			
            // Set the current drag point to the starting location
            currentDragPosition.copy(dragReference);
			
            // Not yet turning, do a complete page turn
            archDir = isLeftToRight ? DragPath.ARCH_LEFT : DragPath.ARCH_RIGHT;
        } else {
            Logger.log("MegaZine Page", "The page (" + pageNumber
                    + ") is not yet ready for turning.");
        }
		
        setState(Constants.PAGE_TURNING);
		
        target = new Vector2D(isLeftToRight ? pageWidth * 2 : 0, dragOffset);
		
        dragFunction = new DragPath(currentDragPosition, target, archDir, 0.05
                + Math.random() * 0.05, pageWidth * dragSpeed * 0.5);
		
        // Force first update (to avoid flickers)
        dragFunction.step();
        redraw();
    }

    /**
     * Updates the matrices for the page and its mask to fit the new drag point.
     */
    private function updateMatrices():void {
		
        var matrix:Matrix = new Matrix();
        var obj:DisplayObject;
		
        if (isStiff_) {
            // Current percentual distance to the middle, used frequently in the
            // following.
            var distMid:Number = currentDragPosition.x / pageWidth - 1;
			
            // Right page (even)
            matrix.a = distMid < 0 ? 0 : distMid;
            matrix.b = currentDragPosition.y / pageHeight;
            matrix.tx = pageWidth;
            pageContainer[0].transform.matrix = matrix;
			
            // Left page (odd)
            matrix.a = distMid > 0 ? 0 : distMid;
            matrix.a = matrix.a < 0 ? -matrix.a : matrix.a;
            matrix.b *= -1;
            matrix.tx = currentDragPosition.x;
            matrix.ty = currentDragPosition.y * pageWidth / pageHeight;
            pageContainer[1].transform.matrix = matrix;
			
            if (shadowAndLight) {
                // Shadows (no highlights for stiff pages)
                if (megazine.shadows) {
                    shadowAndLight[0].visible = false;
                    shadowAndLight[1].visible = false;
					
                    // Matrix for the dropped shadow
                    matrix.identity();
                    matrix.scale(distMid, 1);
                    matrix.tx = pageWidth;
					
                    //id = distMid > 0 ? 0 : 1;
                    obj = shadowAndLight[distMid > 0 ? 0 : 1];
                    obj.transform.matrix = matrix;
                    obj.visible = true;
                    obj.alpha = (distMid < 0 ? -distMid : distMid)
                            * shadowAlpha;
                } else {
                    // Don't use shadows
                    shadowAndLight[0].visible = false;
                    shadowAndLight[1].visible = false;
                }
            }
        } else {
            // First get the vector between the reference point and the current
            // point.
            var v:Vector2D = currentDragPosition.minus(dragReference);
			
            // Make sure the vector has a minimal length
            // Actually we'd only need to do this if y is 0 as well, but as this
            // can actually only happen in the very beginning (because
            // afterwards the keepDistance kicks in) it doesn't really matter.
            // And even if keepdist was set to 0, the jump is less than tiny.
            // It's unrecognizable.
            if (isLeftToRight) {
                v.x ||= 0.1;
            } else {
                v.x ||= -0.1;
            }
			
            // Base corners off of the middle of the reference and the current
            // point.
            var corner:Vector2D =
                    dragReference.clone().interpolate(currentDragPosition);
			
            // The angle to rotate the matrix
            var angle:Number = Math.atan2(v.y, v.x);
			
            // For the moving page
			
            // !!! The order matters, because of the rotation around the origin!
            // Move it up by the offset to rotate it, then move it to the actual
            // position. If it's the even page we need to move it a tad to the
            // left.
            matrix.translate(isLeftToRight ? -pageWidth : 0, -dragOffset);
            // Rotate it.
            matrix.rotate(angle * 2);
            // Move it back down and then to the drag point
            matrix.translate(currentDragPosition.x, currentDragPosition.y);
			
            // For the page's mask
			
            // Check which way we turn (we could also use isEven, because left
            // to right always means we drag an even page, right to left always
            // an odd one).
            if (isLeftToRight) {
                // Add the masks height / 2, in the proper direction.
                corner.plusEquals(v.lhn().normalize(maskMain[0].height * 0.5));
            } else {
                // Add the masks height / 2, in the proper direction.
                corner.minusEquals(v.rhn().normalize(maskMain[0].height * 0.5));
            }
			
            // Apply the new matrix
            if (isLeftToRight) {
                pageContainer[0].transform.matrix = matrix;
            } else {
                pageContainer[1].transform.matrix = matrix;
            }
			
            // !!! Again, order matters!
            // Reset the matrix
            matrix.identity();
            // Rotate the matrix
            matrix.rotate(angle);
            // And move it to the corner
            matrix.translate(corner.x, corner.y);
			
            maskMain[0].transform.matrix = matrix;
            maskMain[1].transform.matrix = matrix;
			
            // Shadow / Highlight
            if (shadowAndLight) {
                if (megazine.shadows) {
					
                    var middle:Point = new Point(
                            currentDragPosition.x - v.x * 0.5,
                            currentDragPosition.y - v.y * 0.5);
					
                    // Calculate the final position (where the drag would end)
                    v.setTo(isLeftToRight ? pageWidth * 2 : 0, dragOffset);
					
                    // The scaling factor for the shadow / highlight, depends on
                    // how far the dragpoint is away from the beginning. Begins
                    // with 0 (dragCurrent == start) and ends with 1
                    // (dragCurrent is two times the pageWidth away from the
                    // start).
                    var scale:Number = 1 - v.distance(currentDragPosition)
                            / (pageWidth * 2);
					
                    // Minimum scale
                    scale = scale < 0.1 ? 0.1 : scale;
					
                    // Calculate alpha values (quickly become visible, then be
                    // 100% for a time, and in the end quickly fade out again)
                    var alpha:Number = (scale < 0.90
                            ? (scale * 20)
                            : 1 - (20 * (scale - 0.90)));
                    alpha = alpha > 1 ? 1 : alpha;
					
                    // Begin fading after 50%
                    var alpha2:Number = (scale < 0.5
                            ? alpha
                            : 1 - (2 * (scale - 0.5)));
                    alpha2 = alpha2 > 1 ? 1 : alpha2;
					
                    // Apply maxima
                    alpha *= shadowAlpha;
                    alpha2 *= shadowAlpha;
					
                    // Matrix for the dropped shadow
                    matrix.identity();
                    matrix.scale(scale, 2);
                    matrix.rotate(angle);
                    matrix.translate(middle.x, middle.y);
					
                    obj = shadowAndLight[isLeftToRight ? 0 : 1];
                    obj.transform.matrix = matrix;
                    obj.alpha = alpha;
                    obj.visible = true;
					
                    // Matrix for the highlight
                    matrix.identity();
                    matrix.scale(scale, 2);
                    matrix.rotate(-angle);
                    middle = pageContainer[isLeftToRight ? 0 : 1].
							globalToLocal(megazine.pageContainer.
							        localToGlobal(middle));
                    matrix.translate(middle.x, middle.y);
					
                    obj = shadowAndLight[isLeftToRight ? 2 : 3];
                    obj.transform.matrix = matrix;
                    obj.alpha = alpha2;
                    obj.visible = true;
                } else {
                    // Don't use shadows
                    shadowAndLight[0].visible = false;
                    shadowAndLight[1].visible = false;
                    shadowAndLight[2].visible = false;
                    shadowAndLight[3].visible = false;
                }
            }
        }
    }

    /**
     * Check which shadows / highlights to enable and which to disable
     */
    private function updateShadowVisibility():void {
        // Don't do anything if shadows are disabled or there are no
        // shadows / highlights.
        if (shadowAndLight) {
            if (megazine.shadows && state != Constants.PAGE_READY) {
                // Page is dragged, show shadows
                if (isLeftToRight) {
                    shadowAndLight[0].visible = true;
                    if (!isStiff_) {
                        shadowAndLight[2].visible = true;
                    }
                } else {
                    shadowAndLight[1].visible = true;
                    if (!isStiff_) {
                        shadowAndLight[3].visible = true;
                    }
                }
            } else {
                // Page is static, hide all shadows / highlights
                shadowAndLight[0].visible = false;
                shadowAndLight[1].visible = false;
                if (!isStiff_) {
                    shadowAndLight[2].visible = false;
                    shadowAndLight[3].visible = false;
                }
            }
        }
    }

    /**
     * Validate a Vector's location (for dragTarget, so no impossible page
     * positions happen).
     * 
     * @param v
     *      the vector to check.
     * @param yOnly
     *      only validates the y position based on the x position (for stiff
     *      pages).
     */
    private function validatePosition(v:Vector2D, yOnly:Boolean = false):void {
		
        var tmp:Number;
		
        // Add the distance to keep from the border if manually dragging.
        if (!yOnly && (state == Constants.PAGE_DRAGGING
                || state == Constants.PAGE_DRAGGING_USER))
        {
            if (isLeftToRight) {
                v.x = keepDistance < v.x ? v.x : keepDistance;
            } else {
                tmp = pageWidth * 2 - keepDistance;
                v.x = tmp > v.x ? v.x : tmp;
            }
        }
		
        if (isStiff_) {
            // Check for stiff pages. This is pretty easy, because the pages can
            // only move on a fixed arc. We just calculate the y value, so we
            // only need to validate the x value.
            tmp = pageWidth * 2;
            v.x = tmp > v.x ? v.x : tmp;
            v.x = v.x < 0 ? 0 : v.x;
            // Calculate y.
            // Let a = Angle between v.x and _dragReferenceTopMiddle
            // x = Math.cos(a) * _pageWidth + _pageWidth
            // y = - Math.sin(a) * (_pageDiagonale - _pageHeight)
            // With x as the variable this gives us:
            // a = Math.acos(x / _pageWidth - 1)
            // y = - Math.sin(Math.acos(x / _pageWidth - 1))
            //         * (_pageDiagonale - _pageHeight)
            // As for the final correction factor... I don't know where that
            // comes from, and am too lazy to find out. After all, it works.
            v.y = -Math.sin(Math.acos(v.x / pageWidth - 1))
                    * (pageDiagonale - pageHeight) * pageHeight / pageWidth;
        } else {
            // A normal page. Check the distance from the top reference point,
            // being in the top middle. The allowed distance is determined when
            // starting to drag the page and is either the page width if the
            // corner is a top corner, or the page diagonale if it is a bottom
            // corner.
            var d:Number = v.distance(dragReferenceTopMiddle);
            if (d > dragMaxDistTop) {
                v.interpolate(dragReferenceTopMiddle, 1 - dragMaxDistTop / d);
            }
            // Same as for the top middle reference point, just for the bottom
            // (vice versa).
            d = v.distance(dragReferenceBottomMiddle);
            if (d > dragMaxDistBottom) {
                v.interpolate(dragReferenceBottomMiddle,
                        1 - dragMaxDistBottom / d);
            }
        }
    }
}
} // end package
