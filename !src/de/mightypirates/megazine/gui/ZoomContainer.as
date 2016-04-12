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

package de.mightypirates.megazine.gui {
import de.mightypirates.megazine.*;
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.ui.Keyboard;
import flash.utils.*;

/**
 * Dispatched when the gallery image changes.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.ZOOM_CHANGE
 */
[Event(name = 'zoom_changed',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * This is the zoom overlay that can be opened for any image.
 * 
 * @author fnuecke
 */
public class ZoomContainer extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** Bottom aligned zooming (keep the bottom edge in place) */
    private static const ALIGN_BOTTOM:String = "align_bottom";

    /** Centered zooming (keep the horizontal center in place) */
    private static const ALIGN_CENTER:String = "align_center";

    /** Left aligned zooming (keep the left edge in place) */
    private static const ALIGN_LEFT:String = "align_left";

    /** Centered zooming (keep the vertical center in place) */
    private static const ALIGN_MIDDLE:String = "align_middle";

    /** Right aligned zooming (keep the right edge in place) */
    private static const ALIGN_RIGHT:String = "align_right";

    /** Top aligned zooming (keep the top edge in place) */
    private static const ALIGN_TOP:String = "align_top";

    /** Currently not dragging */
    private static const DRAG_NONE:String = "drag_none";

    /** Currently dragging the image */
    private static const DRAG_IMAGE:String = "drag_image";

    /** Currently dragging the rectangle across the thumbnail */
    private static const DRAG_THUMB:String = "drag_thumb";

    /** Number of zoom steps (when using the mouse wheel) */
    private static const ZOOM_STEPS:uint = 5;

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The main background */
    private var background:DisplayObject;

    /** The button for closing the zoom mode */
    private var buttonClose:SimpleButton;

    /** Container for next image in the gallery button */
    private var buttonGalleryNext:SimpleButton;

    /** Container for previous image in the gallery button */
    private var buttonGalleryPrev:SimpleButton;

    /** Rotate image counter clock wise button. */
    private var buttonRotateLeft:SimpleButton;

    /** Rotate image clock wise button */
    private var buttonRotateRight:SimpleButton;

    /**
     * The container for the image (makes dragging and positioning the image a
     * lot easier)
     */
    private var container:Sprite;

    /** Currently loaded and displayed image */
    private var currentImage:DisplayObject;

    /** The rectangle for dragging the view across the thumbnail */
    private var dragRectangle:Sprite;

    /** Current drag state */
    private var dragState:String = DRAG_NONE;

    /** Thumbnail fading timer */
    private var fadeTimer:Timer;

    /** Target alpha of the fader */
    private var fadeTarget:Number;

    /** Currently opened gallery */
    private var gallery:Dictionary; // Dictionary
	
    /** Number of the image in the page array */
    private var galleryImage:int;

    /** Number of the page with the current image */
    private var galleryPage:int;

    /** The original and unscaled height of the loaded image */
    private var imageHeight:Number;

    /** Loader used to load the image */
    private var imageLoader:Loader;

    /** The original and unscaled width of the loaded image */
    private var imageWidth:Number;

    /** The loading bar */
    private var loadingBar:LoadingBar;

    /** Localizer for localized galleries... */
    private var localizer:Localizer;

    /** The mask for the container */
    private var containerMask:Shape;

    /** Mask for the dragrect (so it does not overflow the thumbnail area) */
    private var dragRectangleMask:Shape;

    /** Normal height for non fullscreen mode */
    private var normalHeight:Number;

    /** Normal width for non fullscreen mode */
    private var normalWidth:Number;

    /** Stage align before entering fullscreen */
    private var originalAlign:String;

    /** Stage scale mode before entering fullscreen */
    private var originalScaleMode:String;

    /** Constraint rectangle for dragging the container. */
    private var containerConstraints:Rectangle;

    /** Constraint rectangle for the dragging the dragrect. */
    private var draggingConstraints:Rectangle;

    /** Current scaling factor of the thumbnail */
    private var thumbnailScale:Number;

    /** Actual base height of the scaled image (thumbnail) */
    private var scaledHeight:Number;

    /** Actual base width of the scaled image (thumbnail) */
    private var scaledWidth:Number;

    /** Global settings */
    private var settings:Settings;

    /** The background for the thumbnail view */
    private var thumbnailBackground:Sprite;

    /** The bitmap to display the thumbnail */
    private var thumbnailBitmap:Bitmap;

    /** Thumbnail bitmapdata */
    private var thumbnailData:BitmapData;

    /** Container for the thumbnail view */
    private var thumbnailContainer:DisplayObjectContainer;

    /** Current zoom level. */
    private var zoomLevel:Number = 1.0;

    /** Z alignment for zooming */
    private var zoomAlignX:String = ALIGN_CENTER;

    /** Y alignment for zooming */
    private var zoomAlignY:String = ALIGN_MIDDLE;

    /** 
     * Relative zoom level, i.e. a value between 0 and 1, meaning min to max.
     */
    private var zoomLevelRelative:Number = 0;

    /**
     * Minimum zoom level - this gets set so that when zoomed out completely
     * the whole image fits onto the available area.
     */
    private var zoomLevelMinimum:Number = 0.5;
    
    /** Clean up support for listeners and so on */
    private var cleanUpSupport:CleanUpSupport;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new zoom container.
     * 
     * @param width
     *          the normal width, when not in fullscreen.
     * @param height
     *          the normal height, when not in fullscreen.
     * @param localizer
     *          the localizer to use for gui strings.
     * @param library
     *          the graphics library to use for getting images.
     * @param settings
     *          settings object with various common settings.
     */
    public function ZoomContainer(width:uint, height:uint, localizer:Localizer,
            library:ILibrary, settings:Settings) {
        // Hide initially
        visible = false;
		
        // Copy setting
        this.settings = settings;
		
        this.localizer = localizer;
        
        cleanUpSupport = new CleanUpSupport();
		
        // Parse zoomalign.
        var zoomAlignParts:Array = settings.zoomAlign.split(" ");
        for each (var zoomAlignEntry:String in zoomAlignParts) {
            switch (zoomAlignEntry) {
                case "bottom":
                    zoomAlignY = ALIGN_BOTTOM;
                    break;
                case "center":
                    zoomAlignX = ALIGN_CENTER;
                    break;
                case "left":
                    zoomAlignX = ALIGN_LEFT;
                    break;
                case "middle":
                    zoomAlignY = ALIGN_MIDDLE;
                    break;
                case "right":
                    zoomAlignX = ALIGN_RIGHT;
                    break;
                case "top":
                    zoomAlignY = ALIGN_TOP;
                    break;
            }
        }
		
        // Thumbnail fader
        fadeTimer = new Timer(30);
        cleanUpSupport.addTimer(fadeTimer);
		
        // Base background
        background = library.getInstanceOf(
                    LibraryConstants.BACKGROUND) as DisplayObject;
        addChild(background);
		
        // Loading bar
        loadingBar = new LoadingBar(library, localizer);
        addChild(loadingBar);
		
        // Main container
        containerMask = new Shape();
        addChild(containerMask);
        container = new Sprite();
        container.mask = containerMask;
        if (settings.zoomMouseMove) {
            container.mouseEnabled = false;
        }
        addChild(container);
		
        // Thumbnail view setup
        thumbnailContainer = new Sprite();
        thumbnailBackground = library.getInstanceOf(
                    LibraryConstants.BACKGROUND) as Sprite;
        thumbnailBackground.y = 10;
        thumbnailBackground.mouseEnabled = false;
        thumbnailContainer.addChild(thumbnailBackground);
        dragRectangleMask = new Shape();
        dragRectangleMask.y = thumbnailBackground.y;
        thumbnailContainer.addChild(dragRectangleMask);
        dragRectangle = new Sprite();
        dragRectangle.mask = dragRectangleMask;
        dragRectangle.buttonMode = !settings.zoomMouseMove;
        thumbnailContainer.addChild(dragRectangle);
        buttonClose = library.getInstanceOf(
                    LibraryConstants.BUTTON_CLOSE) as SimpleButton;
        buttonClose.y = 10;
        thumbnailContainer.addChild(buttonClose);
        thumbnailContainer.alpha = settings.zoomFadeOutAlpha;
        thumbnailContainer.mouseEnabled = false;
        addChild(thumbnailContainer);
		
        // Gallery navigation buttons
        var tt:ToolTip;
        buttonGalleryNext = library.getInstanceOf(
                LibraryConstants.BUTTON_ARROW_RIGHT) as SimpleButton;
        cleanUpSupport.make(buttonGalleryNext, MouseEvent.CLICK,
                handleGalleryNext);
        tt = new ToolTip("", buttonGalleryNext);
        if (settings.readingOrderLTR) {
            localizer.registerObject(tt, "text", "LNG_ZOOM_NEXT");
        } else {
            localizer.registerObject(tt, "text", "LNG_ZOOM_PREV");
        }
		
        buttonGalleryPrev = library.getInstanceOf(
                LibraryConstants.BUTTON_ARROW_LEFT) as SimpleButton;
        cleanUpSupport.make(buttonGalleryPrev, MouseEvent.CLICK,
                handleGalleryPrev);
        tt = new ToolTip("", buttonGalleryPrev);
        if (settings.readingOrderLTR) {
            localizer.registerObject(tt, "text", "LNG_ZOOM_PREV");
        } else {
            localizer.registerObject(tt, "text", "LNG_ZOOM_NEXT");
        }
		
        // Hide initially
        buttonGalleryNext.visible = false;
        buttonGalleryPrev.visible = false;
		
        thumbnailContainer.addChild(buttonGalleryNext);
        thumbnailContainer.addChild(buttonGalleryPrev);
		
        // Image rotation buttons
        if (settings.zoomRotationButtons) {
            buttonRotateRight = library.getInstanceOf(
                    LibraryConstants.BUTTON_ROTATE_RIGHT) as SimpleButton;
            cleanUpSupport.make(buttonRotateRight, MouseEvent.CLICK,
                    function(e:MouseEvent):void { 
                        rotateRight(); 
                    });
            tt = new ToolTip("", buttonRotateRight);
            localizer.registerObject(tt, "text", "LNG_ZOOM_ROTATE_RIGHT");
			
            buttonRotateLeft = library.getInstanceOf(
                    LibraryConstants.BUTTON_ROTATE_LEFT) as SimpleButton;
            cleanUpSupport.make(buttonRotateLeft, MouseEvent.CLICK,
                    function(e:MouseEvent):void { 
                        rotateLeft(); 
                    });
            tt = new ToolTip("", buttonRotateLeft);
            localizer.registerObject(tt, "text", "LNG_ZOOM_ROTATE_LEFT");
            thumbnailContainer.addChild(buttonRotateRight);
            thumbnailContainer.addChild(buttonRotateLeft);
        }
		
        // Event listeners
        cleanUpSupport.make(this, Event.ADDED_TO_STAGE, registerListeners);
		
        // Set base width and height
        normalWidth = width;
        normalHeight = height;
		
        // Set tooltip for close button
        tt = new ToolTip("", buttonClose);
        localizer.registerObject(tt, "text", "LNG_ZOOM_EXIT");
    }

    // ---------------------------------------------------------------------- //
    // Event listeners
    // ---------------------------------------------------------------------- //
	
    /**
     * Set up listeners as soon as this object is added to the stage.
     * @param e unused.
     */
    private function registerListeners(e:Event):void {
        cleanUpSupport.make(this, Event.REMOVED_FROM_STAGE,
                function(e:Event):void { cleanUpSupport.cleanup(); });
        if (settings.zoomMouseMove) {
            // Move on mousemove
            cleanUpSupport.make(stage, MouseEvent.MOUSE_MOVE,
                    handleMouseMovement);
        } else {
            // Dragging of the big image / container
            cleanUpSupport.make(container, MouseEvent.MOUSE_DOWN,
                    handleDragStart);
            cleanUpSupport.make(dragRectangle, MouseEvent.MOUSE_DOWN,
                    handleDragStart);
            cleanUpSupport.make(stage, MouseEvent.MOUSE_MOVE, handleDragMove);
            cleanUpSupport.make(stage, MouseEvent.MOUSE_UP, handleDragStop);
        }
        // Keyboard controls for gallery navigation
        cleanUpSupport.make(stage, KeyboardEvent.KEY_DOWN, handleKeyPressed);
        // Exit
        cleanUpSupport.make(buttonClose, MouseEvent.CLICK, handleCloseZoom);
        cleanUpSupport.make(stage, KeyboardEvent.KEY_DOWN, handleCloseZoom);
        // Zoom
        cleanUpSupport.make(stage, MouseEvent.MOUSE_WHEEL, handleUserZoom);
        // Fullscreen entering/leaving handling
        cleanUpSupport.make(stage, FullScreenEvent.FULL_SCREEN,
                handleFullscreenChange);
        // Fader of the thumbnail view
        cleanUpSupport.make(thumbnailContainer, MouseEvent.MOUSE_OVER,
                handleFadeIn);
        cleanUpSupport.make(thumbnailContainer, MouseEvent.MOUSE_OUT,
                handleFadeOut);
        // Actual fade timer
        cleanUpSupport.make(fadeTimer, TimerEvent.TIMER, handleFadeTimer);
		
        // Reset sizes if in fullscreen.
        if (stage["displayState"] != undefined
                && stage.displayState == StageDisplayState.FULL_SCREEN)
        {
            setSizes(stage["fullScreenWidth"], stage["fullScreenHeight"], true);
        } else {
            setSizes(normalWidth, normalHeight);
        }
    }

    /**
     * Update the drag position.
     * @param e unused.
     */
    private function handleDragMove(e:MouseEvent):void {
        if (!visible || parent == null || currentImage == null) {
        	return;
        }
        if (dragState == DRAG_IMAGE) {
            updateDragRectPos();
        } else if (dragState == DRAG_THUMB) {
            updateImagePos();
        }
    }

    /**
     * Start dragging.
     * @param e unused.
     */
    private function handleDragStart(e:MouseEvent):void {
        if (!visible || parent == null || currentImage == null) {
        	return;
        }
        if (dragState == DRAG_NONE) {
            if (e.target == container) {
                container.startDrag(false, containerConstraints);
                dragState = DRAG_IMAGE;
            } else if (e.target == dragRectangle) {
                dragRectangle.startDrag(false, draggingConstraints);
                dragState = DRAG_THUMB;
            }
        }
    }

    /**
     * Stop dragging.
     * @param e unused.
     */
    private function handleDragStop(e:MouseEvent):void {
        if (!visible || parent == null || currentImage == null) {
        	return;
        }
        container.stopDrag();
        dragRectangle.stopDrag();
        dragState = DRAG_NONE;
    }

    /**
     * Mousemove event, used when adjusting image not via dragging but moving.
     * @param e for new position.
     */
    private function handleMouseMovement(e:MouseEvent):void {
    	if (!visible || parent == null || currentImage == null) {
            return;
        }
        var mousePos:Point = globalToLocal(background.localToGlobal(
                new Point(background.mouseX, background.mouseY))).
                        subtract(new Point(background.x, background.y));
        var percentualX:Number = Math.min(1,
                Math.max(0, mousePos.x / background.width));
        var percentualY:Number = Math.min(1,
                Math.max(0, mousePos.y / background.height));
        container.x = containerConstraints.width / 2 - percentualX
                * containerConstraints.width;
        container.y = containerConstraints.height / 2 - percentualY
                * containerConstraints.height;
        updateDragRectPos();
    }

    /**
     * Update the zoom ratio.
     * @param e used to determine whether to increase or to decrease the ratio.
     */
    private function handleUserZoom(e:MouseEvent):void {
        if (!visible || parent == null || currentImage == null) {
        	return;
        }
        e.delta < 0 ? zoomOut() : zoomIn();
        // Workaround for FF3 bug causing mousewheel event to fire multiple
        // times
        stage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleUserZoom);
        setTimeout(function():void {
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleUserZoom);
        }, 10);
    }

    /**
     * Leave zoom mode.
     * 
     * @param e
     *          if KeyboardEvent used to determined whether it was the escape
     *          key.
     */
    private function handleCloseZoom(e:Event = null):void {
        if (!(e is KeyboardEvent)
                || (e as KeyboardEvent).keyCode == Keyboard.ESCAPE)
        {
            hide();
        }
    }

    /**
     * Start fading the thumbnail in.
     * 
     * @param e
     *          unused.
     */
    private function handleFadeIn(e:Event):void {
        fadeTarget = 1.0;
        fadeTimer.start();
    }

    /**
     * Start fading the thumbnail out.
     * 
     * @param e
     *          unused.
     */
    private function handleFadeOut(e:Event):void {
        fadeTarget = settings.zoomFadeOutAlpha;
        fadeTimer.start();
    }

    /**
     * Handle timer event for thumbnail fading.
     * 
     * @param e
     *          unused.
     */
    private function handleFadeTimer(e:TimerEvent):void {
        if (Math.abs(fadeTarget - thumbnailContainer.alpha) < 0.1) {
            thumbnailContainer.alpha = fadeTarget;
            fadeTimer.stop();
        } else if (fadeTarget > thumbnailContainer.alpha) {
            thumbnailContainer.alpha += 0.1;
        } else if (fadeTarget < thumbnailContainer.alpha) {
            thumbnailContainer.alpha -= 0.1;
        }
    }

    /**
     * Fired when the right arrow is pressed, show next image in the gallery.
     * 
     * @param e
     *          unused.
     */
    private function handleGalleryNext(e:MouseEvent):void {
        if (gallery == null) {
            return;
        }
        var oldPage:int = galleryPage, oldImage:uint = galleryImage;
        if (galleryImage == Helper.dictFirstKey(gallery[galleryPage])) {
        	// Next page.
        	galleryPage = Helper.dictNextKey(gallery, galleryPage);
        	galleryImage = Helper.dictLastKey(gallery[galleryPage]);
        } else {
        	// There is a next image on this page, or only one page.
        	galleryImage = Helper.dictPrevKey(gallery[galleryPage],
        	       galleryImage);
        }
        if (galleryPage == oldPage && galleryImage == oldImage) {
            // No change...
            return;
        }
        if (settings.zoomMaximal == zoomLevelMinimum) {
            zoomLevelRelative = 0;
        } else {
            zoomLevelRelative = 1 - (settings.zoomMaximal - zoomLevel)
                    / (settings.zoomMaximal - zoomLevelMinimum);
        }
        var actualPath:String =
                gallery[galleryPage][galleryImage][localizer.language];
        if (actualPath == null || actualPath == "") {
            actualPath = gallery[galleryPage][galleryImage]
                    [localizer.defaultLanguage];
        }
        display(actualPath, true);
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CHANGED,
                galleryPage));
    }

    /**
     * Fired when the left arrow is pressed, show previous image in the gallery.
     * 
     * @param e
     *          unused.
     */
    private function handleGalleryPrev(e:MouseEvent):void {
        if (gallery == null) {
            return;
        }
        var oldPage:int = galleryPage, oldImage:uint = galleryImage;
        if (galleryImage == Helper.dictLastKey(gallery[galleryPage])) {
            // Next page.
            galleryPage = Helper.dictPrevKey(gallery, galleryPage);
            galleryImage = Helper.dictFirstKey(gallery[galleryPage]);
        } else {
            // There is a next image on this page, or only one page.
            galleryImage = Helper.dictNextKey(gallery[galleryPage],
                   galleryImage);
        }
        if (galleryPage == oldPage && galleryImage == oldImage) {
            // No change...
            return;
        }
        if (settings.zoomMaximal == zoomLevelMinimum) {
            zoomLevelRelative = 0;
        } else {
            zoomLevelRelative = 1 - (settings.zoomMaximal - zoomLevel)
                    / (settings.zoomMaximal - zoomLevelMinimum);
        }
        var actualPath:String =
                gallery[galleryPage][galleryImage][localizer.language];
        if (actualPath == null || actualPath == "") {
            actualPath = gallery[galleryPage][galleryImage]
                    [localizer.defaultLanguage];
        }
        display(actualPath, true);
        dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CHANGED,
                galleryPage));
    }

    /**
     * All keypresses go here, triggering possible gallery navigation.
     * 
     * @param e
     *          used to check which key was pressed.
     */
    private function handleKeyPressed(e:KeyboardEvent):void {
		
        // Only if the pages are already visible.
        if (!visible) {
            return;
        }
		
        // Check what to do
        switch(e.keyCode) {
            case Keyboard.LEFT:
                handleGalleryPrev(null);
                break;
            case Keyboard.RIGHT:
                handleGalleryNext(null);
                break;
            case Keyboard.PAGE_DOWN:
                zoomOut();
                break;
            case Keyboard.PAGE_UP:
                zoomIn();
                break;
            case Keyboard.ESCAPE:
                hide();
                break;
        }
    }

    /**
     * Fullscreen mode changed. Update sizes.
     * 
     * @param e
     *          used to test which mode we are in now.
     */
    private function handleFullscreenChange(e:FullScreenEvent):void {
        //try {
        
            // Set new sizes
            if (e.fullScreen) {
                setSizes(stage["fullScreenWidth"],
                        stage["fullScreenHeight"], true);
                // If zoom mode is active redraw the thumbnail
                if (visible) {
                    updateThumb();
                    updateZoom();
                }
            } else {
                setSizes(normalWidth, normalHeight);
                hide();
            }
        //} catch (er:Error) {
        //    Logger.log("MegaZine Zoom", "Error handling fullscreen change: "
        //            + er.toString(), Logger.TYPE_WARNING);
        //}
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Set size of thumbnail and main container based on allowed limits.
     * 
     * @param width
     *          allowed width.
     * @param height
     *          allowed height.
     */
    private function setSizes(width:int, height:int,
            fullscreen:Boolean = false):void
    {
        // Position background and self
        background.width = width;
        background.height = height;
		
        if (fullscreen) {
            var position:Point = parent.globalToLocal(new Point(0, 0));
            x = position.x;
            y = position.y;
        } else {
            x = 0;
            y = 0;
        }
		
        // Position loading bar
        loadingBar.x = (background.width - loadingBar.baseWidth) * 0.5;
        loadingBar.y = (background.height - loadingBar.height) * 0.5;
		
        // Position close button and assign function
        buttonClose.x = width - 10 - buttonClose.hitTestState.width;
		
        // Scale and position thumbnail background
        thumbnailBackground.width = buttonClose.hitTestState.width;
        thumbnailBackground.height = buttonClose.hitTestState.height;
        thumbnailBackground.x = buttonClose.x + (buttonClose.width
                - buttonClose.hitTestState.width);
		
        // Masking to the visible area.
        containerMask.graphics.clear();
        containerMask.graphics.beginFill(0xFF00FF);
        containerMask.graphics.lineStyle();
        containerMask.graphics.drawRect(0, 0, width, height);
        containerMask.graphics.endFill();
		
        // Drawing of the dragrect
        dragRectangle.graphics.clear();
        dragRectangle.graphics.beginFill(0xFFFFFF, 0.5);
        dragRectangle.graphics.lineStyle(1, 0x000000, 0.6, true,
                LineScaleMode.NONE);
        dragRectangle.graphics.lineTo(width, 0);
        dragRectangle.graphics.lineTo(width, height);
        dragRectangle.graphics.lineTo(0, height);
        dragRectangle.graphics.lineTo(0, 0);
        dragRectangle.graphics.endFill();
    }

    /**
     * Update the dragging rectangle's position, e.g. when dragging the actual
     * image.
     */
    private function updateDragRectPos():void {
        if (thumbnailBitmap == null || dragRectangle == null
                || draggingConstraints == null)
        {
        	return;
        }
        dragRectangle.x = Math.round(thumbnailBitmap.x
                + (thumbnailBitmap.width - dragRectangle.width) * 0.5
                - container.x * dragRectangle.scaleX);
        dragRectangle.y = Math.round(thumbnailBitmap.y
                + (thumbnailBitmap.height - dragRectangle.height) * 0.5
                - container.y * dragRectangle.scaleX);
        // Enforce constraints
        dragRectangle.x = Math.min(Math.max(dragRectangle.x,
                draggingConstraints.x), draggingConstraints.right);
        dragRectangle.y = Math.min(Math.max(dragRectangle.y,
                draggingConstraints.y), draggingConstraints.bottom);
    }

    /**
     * Update the image's position, e.g. when dragging the rectangle on top of
     * the thumbnail.
     */
    private function updateImagePos():void {
    	if (currentImage == null || containerConstraints == null) {
    		return;
        }
        // Inverse of updateDragRectPos...
        container.x = Math.round((thumbnailBitmap.x
                + (thumbnailBitmap.width - dragRectangle.width) * 0.5
                - dragRectangle.x)
                / dragRectangle.scaleX);
        container.y = Math.round((thumbnailBitmap.y
                + (thumbnailBitmap.height - dragRectangle.height) * 0.5
                - dragRectangle.y)
                / dragRectangle.scaleX);
        // Enforce constraints
        container.x = Math.min(Math.max(container.x, containerConstraints.x),
                containerConstraints.right);
        container.y = Math.min(Math.max(container.y, containerConstraints.y),
                containerConstraints.bottom);
    }

    /**
     * Update image preview and limits based on loaded image.
     * Also updates zoom, because the zoom is dependant on the scaling factor
     * calculated here.
     */
    private function updateThumb():void {
        // Create and position thumbnail
        if (thumbnailData != null) {
            thumbnailData.dispose();
            thumbnailData = null;
        }
        if (thumbnailBitmap != null) {
            thumbnailContainer.removeChild(thumbnailBitmap);
            thumbnailBitmap = null;
        }
        // If we have no image, cancel...
        if (currentImage == null) {
            return;
        }
        thumbnailData = new BitmapData(Math.round(
                Math.max(background.width / 5, background.height / 5)) - 20,
                        Math.round(Math.max(background.width / 5,
                                background.height / 5)) - 20, true, 0x00000000);
        thumbnailBitmap = new Bitmap(thumbnailData);
        thumbnailBitmap.x = background.width - thumbnailData.width - 20;
        thumbnailBitmap.y = thumbnailBackground.y + 10;
		
        thumbnailContainer.addChildAt(thumbnailBitmap, 1);
		
        // Paint thumbnail
        thumbnailScale = Math.min(1, Math.min(thumbnailData.width / imageWidth,
                thumbnailData.height / imageHeight));
        scaledWidth = int(thumbnailScale * imageWidth);
        scaledHeight = int(thumbnailScale * imageHeight);
        var matrix:Matrix = new Matrix();
        matrix.rotate(currentImage.rotation * Math.PI / 180);
        matrix.scale(thumbnailScale, thumbnailScale);
        var tx:int, ty:int;
        tx = int((thumbnailData.width - scaledWidth) * 0.5);
        ty = int((thumbnailData.height - scaledHeight) * 0.5);
        switch (currentImage.rotation) {
            case 90:
            case -270:
                tx += scaledWidth;
                break;
            case 180:
            case -180:
                tx += scaledWidth;
                ty += scaledHeight;
                break;
            case 270:
            case -90:
                ty += scaledHeight;
                break;
        }
        matrix.translate(tx, ty);
        thumbnailData.draw(currentImage, matrix, null, null,
                new Rectangle(int((thumbnailData.width - scaledWidth) * 0.5),
                        int((thumbnailData.height - scaledHeight) * 0.5),
                        scaledWidth, scaledHeight), true);
        // Reset container positioning
        container.x = 0;
        container.y = 0;
		
        // Calculate zoom level required.
        zoomLevelMinimum = Math.min(settings.zoomMaximal,
                background.width / imageWidth,
                background.height / imageHeight);
        if (Math.abs(zoomLevelMinimum - settings.zoomMaximal) < 0.01) {
            zoomLevelMinimum = settings.zoomMaximal;
        }
        // Don't let the zoom be smaller than the min zoom
        zoomLevel = Math.max(zoomLevel, zoomLevelMinimum);
        // Snap to full or min zoom
        if (Math.abs(zoomLevel - zoomLevelMinimum) < 0.01) {
            zoomLevel = zoomLevelMinimum;
        } else if (Math.abs(zoomLevel - settings.zoomMaximal) < 0.01) {
            zoomLevel = settings.zoomMaximal;
        }
    }

    private function updateZoom():void {
		if (currentImage != null) {
            // Old dragrect position
            var oldDragRect:Rectangle =
                    dragRectangle.getRect(dragRectangle.parent);
            
            // Scale and position acutal image
            currentImage.scaleX = zoomLevel;
            currentImage.scaleY = zoomLevel;
            currentImage.width = Math.round(currentImage.width);
            currentImage.height = Math.round(currentImage.height);
            currentImage.x =
                    Math.round((background.width - currentImage.width) * 0.5);
            currentImage.y =
                    Math.round((background.height - currentImage.height) * 0.5);
            switch (currentImage.rotation) {
                case 90:
                case -270:
                    currentImage.x += currentImage.width;
                    break;
                case 180:
                case -180:
                    currentImage.x += currentImage.width;
                    currentImage.y += currentImage.height;
                    break;
                case 270:
                case -90:
                    currentImage.y += currentImage.height;
                    break;
            }
		
            // Update the dragrect size
            var dragScale:Number = thumbnailScale / zoomLevel;
            dragRectangle.scaleX = dragScale;
            dragRectangle.scaleY = dragScale;
            dragRectangle.width = Math.round(dragRectangle.width);
            dragRectangle.height = Math.round(dragRectangle.height);
    		
            // Show hand cursor when the image can be dragged / scrolled.
            // If not hide thumbnail.
            var showHand:Boolean = imageWidth * zoomLevel > background.width
                    || imageHeight * zoomLevel > background.height;
            if (!settings.zoomMouseMove) {
                container.buttonMode = showHand;
            }
            thumbnailBitmap.visible = settings.zoomThumb && showHand;
            dragRectangle.visible = showHand;
    		
            // Update the constraint rectangle for dragging.
            containerConstraints = new Rectangle(
                    Math.min(0, (background.width - imageWidth * zoomLevel)
                            * 0.5),
                    Math.min(0, (background.height - imageHeight * zoomLevel)
                            *0.5),
                    Math.max(0, (imageWidth * zoomLevel - background.width)),
                    Math.max(0, (imageHeight * zoomLevel - background.height)));
            draggingConstraints = new Rectangle(
                    Math.min((thumbnailBitmap.x
                        + (thumbnailBitmap.width - scaledWidth) * 0.5),
                        (thumbnailBitmap.x
                        + (thumbnailBitmap.width - dragRectangle.width) * 0.5)),
                    Math.min((thumbnailBitmap.y
                            + (thumbnailBitmap.height - scaledHeight)
                            * 0.5),
                            (thumbnailBitmap.y
                            + (thumbnailBitmap.height - dragRectangle.height)
                            * 0.5)),
                    Math.max(0, scaledWidth - dragRectangle.width),
                    Math.max(0, scaledHeight - dragRectangle.height));
    		
            // Positioning with alignment...
            switch (zoomAlignX) {
                case ALIGN_CENTER:
                    dragRectangle.x -= (dragRectangle.width
                            - Math.round(oldDragRect.width)) / 2;
                    break;
                case ALIGN_RIGHT:
                    dragRectangle.x -= (dragRectangle.width
                            - Math.round(oldDragRect.width));
                    break;
            }
            switch (zoomAlignY) {
                case ALIGN_MIDDLE:
                    dragRectangle.y -= (dragRectangle.height
                            - Math.round(oldDragRect.height)) / 2;
                    break;
                case ALIGN_BOTTOM:
                    dragRectangle.y -= (dragRectangle.height
                            - Math.round(oldDragRect.height));
                    break;
            }
    		
            // Enforce constraints
            dragRectangle.x = Math.min(
                    Math.max(draggingConstraints.x, dragRectangle.x),
                    draggingConstraints.right);
            dragRectangle.y = Math.min(
                    Math.max(draggingConstraints.y, dragRectangle.y),
                    draggingConstraints.bottom);
    		
        }
        // Position the image
        updateImagePos();
		
        updateThumbBox();
		
        dragRectangleMask.graphics.clear();
        dragRectangleMask.graphics.beginFill(0xFF00FF);
        dragRectangleMask.graphics.lineStyle();
        dragRectangleMask.graphics.drawRect(0, 0, thumbnailBackground.width,
                thumbnailBackground.height);
        dragRectangleMask.graphics.endFill();
        dragRectangleMask.x = thumbnailBackground.x;
    }

    private function updateThumbBox():void {
        // Test if the thumbnail needs showing
        var needThumb:Boolean = settings.zoomThumb && currentImage != null
                && (imageWidth * zoomLevel > background.width
                        || imageHeight * zoomLevel > background.height);
		
        // Base size of the box.
        thumbnailBackground.width = buttonClose.hitTestState.width;
        thumbnailBackground.height = buttonClose.hitTestState.height;
        
        if (buttonRotateLeft != null && buttonRotateRight != null) {
            thumbnailBackground.width += buttonRotateRight.hitTestState.width
                    + buttonRotateLeft.hitTestState.width;
            thumbnailBackground.height = Math.max(thumbnailBackground.height,
                    buttonRotateRight.hitTestState.height,
                    buttonRotateLeft.hitTestState.height);
        }
		
        if (buttonGalleryNext.visible && buttonGalleryPrev.visible) {
            thumbnailBackground.width += buttonGalleryNext.hitTestState.width
                    + buttonGalleryPrev.hitTestState.width;
            thumbnailBackground.height = Math.max(thumbnailBackground.height,
                    buttonGalleryPrev.hitTestState.height,
                    buttonGalleryNext.hitTestState.height);
        }
		
        if (needThumb) {
            // Thumbnail needed
            thumbnailBackground.width = Math.max(thumbnailBackground.width,
                    Math.round(Math.max(background.width / 5,
                            background.height / 5)));
            thumbnailBackground.height = thumbnailBackground.width;
        }
        
        // Position box
        thumbnailBackground.x = background.width - 10
                - thumbnailBackground.width;
		
        // Position buttons
        if (buttonRotateLeft != null && buttonRotateRight != null) {
            buttonRotateLeft.y = thumbnailBackground.y
                    + thumbnailBackground.height
                    - buttonRotateLeft.hitTestState.height;
            buttonRotateRight.y = thumbnailBackground.y
                    + thumbnailBackground.height
                    - buttonRotateRight.hitTestState.height;
        }
        buttonGalleryNext.y = thumbnailBackground.y + thumbnailBackground.height
                - buttonGalleryNext.hitTestState.height;
        buttonGalleryPrev.y = thumbnailBackground.y + thumbnailBackground.height
                - buttonGalleryPrev.hitTestState.height;
                
        // x depends on visibility of gallery navigation
        if (buttonGalleryNext.visible) {
            buttonGalleryPrev.x = thumbnailBackground.x;
            if (needThumb) {
                buttonGalleryNext.x = thumbnailBackground.x
                        + thumbnailBackground.width
                        - buttonGalleryNext.hitTestState.width;
            } else {
                buttonGalleryNext.x = thumbnailBackground.x
                        + thumbnailBackground.width
                        - buttonClose.hitTestState.width
                        - buttonGalleryNext.hitTestState.width;
            }
            if (buttonRotateLeft != null && buttonRotateRight != null) {
                buttonRotateRight.x = buttonGalleryPrev.x
                        + buttonGalleryPrev.hitTestState.width;
                buttonRotateLeft.x = buttonGalleryNext.x
                        - buttonRotateLeft.hitTestState.width;
            }
        } else {
            if (buttonRotateLeft != null && buttonRotateRight != null) {
                buttonRotateRight.x = thumbnailBackground.x;
                if (needThumb) {
                    buttonRotateLeft.x = thumbnailBackground.x
                            + thumbnailBackground.width
                            - buttonRotateLeft.hitTestState.width;
                } else {
                    buttonRotateLeft.x = thumbnailBackground.x
                            + buttonRotateLeft.hitTestState.width;
                }
            }
        }
    }

    /**
     * Rotate counter clock wise by 90 degrees.
     */
    private function rotateLeft():void {
        rotateImage(false);
    }

    /**
     * Rotate clock wise by 90 degrees.
     */
    private function rotateRight():void {
        rotateImage(true);
    }

    private function rotateImage(clockwise:Boolean):void {
        currentImage.rotation += clockwise ? 90 : -90;
        var tmp:Number = imageHeight;
        imageHeight = imageWidth;
        imageWidth = tmp;
        updateThumb();
        updateZoom();
        handleMouseMovement(null);
        updateDragRectPos();
    }

    // ---------------------------------------------------------------------- //
    // Setter
    // ---------------------------------------------------------------------- //
	
    /**
     * Might be set if the image that should be displayed is part of a gallery.
     * 
     * @param gallery
     *          array with all pages and all images in this gallery.
     * @param currPage
     *          the page containing the currently displayed image.
     * @param currNum
     *          the number of the currently displayed image in the array for
     *          the images of its page.
     */
    public function setGalleryData(gallery:Dictionary, currPage:int,
            currNum:uint):void
    {
        this.gallery = gallery;
        galleryPage = currPage;
        galleryImage = currNum;
        buttonGalleryNext.visible = true;
        buttonGalleryPrev.visible = true;
    }

    /**
     * Set the pagenumber of the image that references to the displayed image.
     * This is the page which will be set in the event which is fired when the
     * zoom is closed.
     * 
     * @param page
     *          the page containing the image referencing to the hires one.
     */
    public function setCurrentPage(page:int):void {
        galleryPage = page;
    }

    /**
     * Increase zoomstep, zooming in.
     */
    public function zoomIn():void {
        zoomChange(false);
    }

    /**
     * Decrease zoomstep, zooming out.
     */
    public function zoomOut():void {
        zoomChange(true);
    }

    private function zoomChange(out:Boolean = false):void {
        if (!visible || currentImage == null) return;
        var stepSize:Number = (settings.zoomMaximal - zoomLevelMinimum)
                / ZOOM_STEPS;
        if (out) {
            zoomLevel = Math.max(zoomLevelMinimum, zoomLevel - stepSize);
        } else {
            zoomLevel = Math.min(settings.zoomMaximal, zoomLevel + stepSize);
        }
        if (Math.abs(zoomLevel - zoomLevelMinimum) < 0.01) {
            zoomLevel = zoomLevelMinimum;
        } else if (Math.abs(zoomLevel - settings.zoomMaximal) < 0.01) {
            zoomLevel = settings.zoomMaximal;
        }
        updateZoom();
    }

    // ---------------------------------------------------------------------- //
    // Display / Hide
    // ---------------------------------------------------------------------- //
	
    /**
     * Display the given image.
     * 
     * @param path
     *          the path to the image to display.
     * @param keepZoom
     *          keep the zoom ration.
     */
    public function display(path:String, keepZoom:Boolean = false):void {
        // Avoid nullpointers... and don't try to load empty strings.
        if (path == null || path == "") {
            hide(true);
            return;
        }
		
        // Reset zoom
        if (!keepZoom) {
            zoomLevelRelative = -1;
            zoomLevel = settings.zoomInitial;
        }
		
        // Kill previous images, to allow consecutive execution of this method.
        unloadImage();
		
        // Initially don't show the dragging rectangle
        dragRectangle.visible = false;
        updateThumbBox();
		
        // Show loading bar
        loadingBar.visible = true;
		
        // If not previously visible, remember and adjust stage scaling and
        // alignment
        if (!visible) {
            originalAlign = stage.align;
            originalScaleMode = stage.scaleMode;
            if (stage["displayState"] != undefined
                    && stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                stage.align = StageAlign.TOP_LEFT;
                stage.scaleMode = StageScaleMode.NO_SCALE;
            }
        }
		
        // Show self
        visible = true;
		
        // Try loading the image, on failure hide self
        try {
            imageLoader = new Loader();
            imageLoader.contentLoaderInfo.addEventListener(
                    ProgressEvent.PROGRESS, handleLoadProgress);
            imageLoader.contentLoaderInfo.addEventListener(
                    Event.COMPLETE, handleLoadComplete);
            imageLoader.contentLoaderInfo.addEventListener(
                    IOErrorEvent.IO_ERROR, handleLoadError);
            imageLoader.load(new URLRequest(path), new LoaderContext(true));
        } catch (ex:SecurityError) {
            Logger.log("MegaZine Zoom",
                    "Could not load highres image from path '"
                    + Helper.trimString(path, 40)
                    + "' due to a security error.", Logger.TYPE_WARNING);
            loadingBar.visible = false;
            try {
                imageLoader.close();
            } catch (ex:Error) { 
            } finally {
                imageLoader = null;
            }
        }
    }

    /**
     * Error loading the image...
     * 
     * @param e
     *          used to print the error message.
     */
    private function handleLoadError(e:IOErrorEvent):void {
        Logger.log("MegaZine Zoom",
                "Error loading highres image, probably the filename/url is "
                + "wrong. Error was: " + e.toString(), Logger.TYPE_WARNING);
        imageLoader.contentLoaderInfo.removeEventListener(
                ProgressEvent.PROGRESS, handleLoadProgress);
        imageLoader.contentLoaderInfo.removeEventListener(
                Event.COMPLETE, handleLoadComplete);
        imageLoader.contentLoaderInfo.removeEventListener(
                IOErrorEvent.IO_ERROR, handleLoadError);
        loadingBar.visible = false;
        try {
            imageLoader.close();
        } catch (ex:Error) { 
        } finally {
            imageLoader = null;
        }
    }

    /**
     * Making progress while loading the image.
     * 
     * @param e
     *          used to get the percentual progress.
     */
    private function handleLoadProgress(e:ProgressEvent):void {
        var p:Number = e.bytesLoaded / e.bytesTotal;
        try {
            loadingBar.percent = p;
        } catch (e:Error) {
        }
    }

    /**
     * Image loaded completely!
     * 
     * @param e
     *          used to get the loaded image from the loader.
     */
    private function handleLoadComplete(e:Event):void {
        imageLoader.contentLoaderInfo.removeEventListener(
                ProgressEvent.PROGRESS, handleLoadProgress);
        imageLoader.contentLoaderInfo.removeEventListener(
                Event.COMPLETE, handleLoadComplete);
        imageLoader.contentLoaderInfo.removeEventListener(
                IOErrorEvent.IO_ERROR, handleLoadError);
        loadingBar.visible = false;
        // OK, save in variable, position and add
        imageWidth = imageLoader.width;
        imageHeight = imageLoader.height;
        // The lazy way, sprites will be collected by the gc :P
        currentImage = imageLoader.getChildAt(0);
		
        container.addChild(currentImage);
		
        if (currentImage is Bitmap) {
        	// For smoother scaling when zooming
            (currentImage as Bitmap).smoothing = true;
            // Helps when scaling very large images
            (currentImage as Bitmap).cacheAsBitmap = true;
        }
		
        updateThumb();
        // Restore relative zoom if given.
        if (zoomLevelRelative >= 0) {
            zoomLevel = zoomLevelMinimum + zoomLevelRelative
                    * (settings.zoomMaximal - zoomLevelMinimum);
        }
        // Validate zoom.
        zoomLevel = Math.max(zoomLevelMinimum,
                Math.min(settings.zoomMaximal, zoomLevel));
        updateZoom();
        
        // Position, based on zoom align.
        switch (zoomAlignX) {
            case ALIGN_LEFT:
                container.x = containerConstraints.right;
                break;
            case ALIGN_RIGHT:
                container.x = containerConstraints.left;
                break;
            case ALIGN_CENTER:
            default:
                container.x = 0;
                break;
        }
        switch (zoomAlignY) {
            case ALIGN_TOP:
                container.y = containerConstraints.bottom;
                break;
            case ALIGN_BOTTOM:
                container.y = containerConstraints.top;
                break;
            case ALIGN_MIDDLE:
            default:
                container.y = 0;
                break;
        }
        
        // Fake mousemovent to position image and dragrects, with a small delay
        // to avoid rendering glitches. It might still flicker for a millisecond
        // or so, but that's not so bad.
        setTimeout(function():void { handleMouseMovement(null); }, 10);
    }

    /**
     * Hide the zoom.
     * 
     * @param forced
     *          also perform hide actions if already invisible.
     */
    private function hide(forced:Boolean = false):void {
        if (visible) {
            unloadImage();
            stage.align = originalAlign;
            stage.scaleMode = originalScaleMode;
            // Hide self
            visible = false;
            buttonGalleryNext.visible = false;
            buttonGalleryPrev.visible = false;
            galleryImage = 0;
            gallery = null;
            dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CLOSED,
                    galleryPage));
            galleryPage = -1;
        }
        if (forced) {
            dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CLOSED,
                    galleryPage));
        }
    }

    /**
     * Unload the current image, consequently clearing the display.
     * Resets thumbnail areas size to min.
     */
    private function unloadImage():void {
    	// If loader is still there it's either still loading, or we can use it
    	// to unload it.
        if (imageLoader != null) {
            imageLoader.contentLoaderInfo.removeEventListener(
                    ProgressEvent.PROGRESS, handleLoadProgress);
            imageLoader.contentLoaderInfo.removeEventListener(
                    Event.COMPLETE, handleLoadComplete);
            imageLoader.contentLoaderInfo.removeEventListener(
                    IOErrorEvent.IO_ERROR, handleLoadError);
            try {
            	imageLoader.close();
                imageLoader["unloadAndStop"]();
            } catch (er:Error) {
                imageLoader.unload();
            } finally {
                imageLoader = null;
            }
        }
        // Remove image
        if (currentImage != null) {
        	if (container.contains(currentImage)) {
                container.removeChild(currentImage);
        	}
            if (currentImage is Bitmap) {
                (currentImage as Bitmap).bitmapData.dispose();
            }
        }
        // Clear thumbnail
        if (thumbnailBitmap != null) {
            thumbnailContainer.removeChild(thumbnailBitmap);
        }
        // And thumbnail data
        if (thumbnailData != null) {
            thumbnailData.dispose();
        }
        currentImage = null;
        thumbnailBitmap = null;
        thumbnailData = null;
        try {
            loadingBar.percent = 0;
        } catch (er:Error) {
        	// Invalid library element
        }
    }
}
} // end package
