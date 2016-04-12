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
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.utils.*;
import de.mightypirates.video.FLVPlaybackClean;

import fl.video.*;

import flash.display.*;
import flash.events.*;
import flash.net.URLRequest;
import flash.utils.Timer;

/**
 * The video element can be used to load and play videos. See documentation for
 * supported formats. Uses the FLVPlayback component.
 * 
 * <code>EXTERNAL ELEMENT</code>
 * 
 * @author fnuecke
 */
public class Video extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /**
     * Because the one of the flvplayback gets overwritten when loading the
     * movie.
     */
    private var autoStart:Boolean = true;

    /** Timer for delayed start of the video */
    private var delayTimer:Timer;

    /** Current fade state, 0 = none, 1 = in, 2 = out */
    private var fadeState:int = 0;

    /** The video playback component */
    private var flvPlayback:FLVPlaybackClean;

    /** The interaction area for overlays and such */
    private var interactiveArea:Sprite;

    /** Loop the video? */
    private var doLoop:Boolean = true;

    /** Currently muted even if visible? */
    private var muted:Boolean = false;

    /** Do not pause when the containing page becomes invisible */
    private var noPause:Boolean = false;

    /**
     * Only when the containing page is actually the main page
     * (not when visible via dragged corner).
     */
    private var onlyWhenActive:Boolean = false;

    /** Playstate before the page became invisible */
    private var prevPlayState:Boolean = false;

    /**
     * Restart the playback when the page becomes visible (instead of
     * continuing).
     */
    private var doRestart:Boolean = false;

    /** Volume set in the flvplayback (maybe changed by user, so remember) */
    private var volumeFlvPlayback:Number = 1.0;

    /** The currently targeted volume */
    private var volumeTarget:Number = 0;

    /** Timer to increase or decrease volume if needed */
    private var volumeTimer:Timer;
    
    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //    
    
    public function Video() {
        // Create the playback component
        flvPlayback = new FLVPlaybackClean();
        // Hide initially, until we know real sizes.
        flvPlayback.visible = false;
        // Disable takeover in fullscreen mode
        flvPlayback.fullScreenTakeOver = false;
        // Replay automatically
        flvPlayback.autoRewind = true;
        // Scaling
        flvPlayback.scaleMode = VideoScaleMode.EXACT_FIT;
        // Add it to the stage
        addChild(flvPlayback);
        
        // Interaction area for overlay / linking
        interactiveArea = new Sprite();
    }
    
    
    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Initialize loading.
     */
    override public function init():void {
        // Only play when on the main page (not when visible via dragged corner)
        onlyWhenActive = Helper.validateBoolean(xml.@onlywhenactive,
                onlyWhenActive);
		
        try {
            volumeTimer = new Timer(Helper.validateUInt(xml.@fade, 2000) / 20);
            cleanUpSupport.addTimer(volumeTimer);
            var delay:uint = Helper.validateUInt(xml.@delay, 0);
            if (delay > 0) {
                delayTimer = new Timer(delay, 1);
                cleanUpSupport.make(delayTimer, TimerEvent.TIMER,
                        handleDelayTimer);
            }
			
            // Register volume handling event with timer
            cleanUpSupport.make(volumeTimer, TimerEvent.TIMER, handleFadeTimer);
			
            // Pause when hidden override
            noPause = Helper.validateBoolean(xml.@nopause, noPause);
			
            // Loop the video
            doLoop = Helper.validateBoolean(xml.@loop, doLoop);
			
            // Restart instead of continue
            doRestart = Helper.validateBoolean(xml.@restart, doRestart);
			
            // Setup video
            autoStart = Helper.validateBoolean(xml.@autoplay, true);
			
            var tmpWidth:int = Helper.validateInt(xml.@width, 0);
            if (tmpWidth > 0) {
                flvPlayback.width = tmpWidth;
            }
            var tmpHeight:int = Helper.validateInt(xml.@height, 0);
            if (tmpHeight > 0) {
                flvPlayback.height = tmpHeight;
            }
			
            var url:String = Helper.validateString(xml.@src, "");
            if (url != "") {
                url = megazine.getAbsPath(url);
                // Handle loading errors
                cleanUpSupport.make(flvPlayback, VideoEvent.STATE_CHANGE,
                        handleLoadError);
                // Handle loading done
                cleanUpSupport.make(flvPlayback, VideoEvent.READY,
                        handleVideoReady);
				
                // Auto replay
                if (doLoop) {
                    cleanUpSupport.make(flvPlayback, Event.COMPLETE,
                            handleLoadComplete);
                }
                try {
                    new URLRequest(url);
                    flvPlayback.load(url);
                } catch (ex:Error) {
                    Logger.log("MegaZine Video", "    Error loading video: "
                            + Helper.trimString(url, 40) + " in page "
                            + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
                    super.init();
                }
            } else {
			}
        } catch (e:Error) {
            Logger.log("MegaZine Video",
                    "    Failed setting up 'vid' object in page "
                    + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
            super.init();
        }
    }

    override protected function destroy(e:Event):void {
        super.destroy(e);
        
        // Kill the video player
        flvPlayback.dispose();
        removeChild(flvPlayback);
    }

    /**
     * Error while loading.
     * 
     * @param e
     *          unused.
     */
    private function handleLoadError(e:Event):void {
        var url:String = megazine.getAbsPath(Helper.validateString(
                xml.@src, ""));
        if (flvPlayback.state == VideoState.CONNECTION_ERROR) {
            Logger.log("MegaZine Video", "    Error loading video: "
                    + Helper.trimString(url, 40) + " in page "
                    + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
            super.init();
        }
    }

    /**
     * Done loading, start playback.
     * 
     * @param e
     *          unused.
     */
    private function handleLoadComplete(e:Event):void {
        flvPlayback.play();
    }

    /**
     * Returns the element to use for interactions such as mouseclicks when the
     * element is linked (via url).
     * 
     * @return the InteractiveObject to use.
     */
    override public function getInteractiveObject():InteractiveObject {
        return interactiveArea;
    }

    /**
     * Video loaded completely, set it up.
     * 
     * @param e
     *          unused.
     */
    private function handleVideoReady(e:VideoEvent):void {
        flvPlayback.x = 0;
        flvPlayback.y = 0;
        flvPlayback.getVideoPlayer(0).x = 0;
        flvPlayback.getVideoPlayer(0).y = 0;
        var tmpWidth:int = Helper.validateInt(xml.@width, 0);
        if (tmpWidth > 0) {
            flvPlayback.width = tmpWidth;
        } else {
            flvPlayback.width = flvPlayback.preferredWidth;
        }
        var tmpHeight:int = Helper.validateInt(xml.@height, 0);
        if (tmpHeight > 0) {
            flvPlayback.height = tmpHeight;
        } else {
            flvPlayback.height = flvPlayback.preferredHeight;
        }
		
        // To allow mouse events... it seems flvplayback does not support them.
        interactiveArea.graphics.beginFill(0, 0);
        interactiveArea.graphics.drawRect(0, 0, flvPlayback.width,
                flvPlayback.height);
        interactiveArea.graphics.endFill();
        //_interactiveArea.y = _flvPlayback.getVideoPlayer(0).y;
        flvPlayback.addChildAt(interactiveArea, 1);
		
        // Use overlay?
        if (Helper.validateString(xml.@url, "") != "") {
            AbstractOverlay.createOverlays(interactiveArea, xml.@overlay);
        }
		
        // Set the gui
        if (xml.@gui != undefined && xml.@gui.toString() != "") {
            var gui:String = megazine.getAbsPath(xml.@gui.toString());
            var guicolor:uint = Helper.validateUInt(xml.@guicolor, 0xFF333333);
            var guialpha:Number = ((guicolor >>> 24) == 0)
                    ? 0.75
                    : ((guicolor >>> 24) / 255.0);
            try {
                flvPlayback.skin = gui;
                flvPlayback.skinBackgroundColor = (0xFFFFFF & guicolor);
                flvPlayback.skinBackgroundAlpha = guialpha;
            } catch (ex:Error) {
                Logger.log("MegaZine Video", "    Error loading video gui '"
                        + Helper.trimString(gui, 40) + "' in page "
                        + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
            }
        }
		
        registerListeners();
		
        flvPlayback.visible = true;
		
        // Playback stuff.
        prevPlayState = autoStart;
        flvPlayback.autoPlay = autoStart;
        // If autoplay is on, and we either don't pause when the page is
        // invisible, OR the page is visible and if onlywhenactive is on is
        // actually the active page... play. That's a long one.
        if (flvPlayback.autoPlay
                && (noPause || (pageVisible && (!onlyWhenActive
                        || (page.getNumber(true) + (even ? 0 : 2))
                            == megazine.currentLogicalPage
						))))
		{
            startFadeIn();
        }
		
        // Get current mute state from the megazine
        if (megazine.muted) {
            handleMute(null);
        }
		
        // Done
        super.init();
    }

    /**
     * Delay timer run out, begin actual fadein.
     * 
     * @param e
     *          unused.
     */
    private function handleDelayTimer(e:TimerEvent = null):void {
        if (!noPause && prevPlayState) flvPlayback.play();
        fadeState = 1;
        volumeTarget = muted ? 0 : volumeFlvPlayback;
        if (volumeTimer.delay > 0) {
            volumeTimer.start();
        } else {
            handleFadeTimer();
        }
    }

    /**
     * On page change, check if the page is the new main page.
     * 
     * @param e
     *          unused.
     */
    private function handlePageChange(e:MegaZineEvent):void {
        var pnum:uint = page.getNumber(even);
        pnum += pnum & 1;
        if (e.page == pnum) {
            if (volumeTarget != 1) startFadeIn();
        } else {
            if (volumeTarget != 0) startFadeOut();
        }
    }

    /**
     * Triggers required actions when the containing page becomes visible
     * (start playback if autopaused, fade in volume).
     * 
     * @param e
     *          unused.
     */
    private function startFadeIn(e:MegaZineEvent = null):void {
        if (doRestart && flvPlayback.volume == 0) flvPlayback.seek(0);
        if (delayTimer && !volumeTimer.running) {
            delayTimer.reset();
            delayTimer.start();
        } else {
            handleDelayTimer();
        }
    }

    /**
     * Triggers required actions when the containing page becomes invisible
     * (autopausing playback if not forbidden, fade out volume).
     * 
     * @param e
     *          unused.
     */
    private function startFadeOut(e:MegaZineEvent = null):void {
        if (delayTimer) delayTimer.reset();
        prevPlayState = flvPlayback.playing;
        if (fadeState == 0 && !muted) volumeFlvPlayback = flvPlayback.volume;
        fadeState = 2;
        volumeTarget = 0;
        if (volumeTimer.delay > 0) {
            volumeTimer.start();
        } else {
            handleFadeTimer();
        }
    }

    /**
     * Takes care of fading the volume, triggered by a timer.
     * 
     * @param e
     *          unused.
     */
    private function handleFadeTimer(e:TimerEvent = null):void {
        flvPlayback.volume += flvPlayback.volume < volumeTarget ? 0.05 : -0.05;
        if (Math.abs(flvPlayback.volume - volumeTarget) < 0.1) {
            flvPlayback.volume = volumeTarget;
            if (!noPause && fadeState == 2) {
                flvPlayback.pause();
            }
            fadeState = 0;
            volumeTimer.stop();
        }
    }

    /**
     * Muted.
     * 
     * @param e
     *          unused.
     */
    private function handleMute(e:MegaZineEvent):void {
        if (fadeState > 0) {
            volumeTarget = 0;
        } else if (pageVisible) {
            volumeFlvPlayback = flvPlayback.volume;
        }
        flvPlayback.volume = 0;
        muted = true;
    }

    /**
     * Unmuted.
     * 
     * @param e
     *          unused.
     */
    private function handleUnmute(e:MegaZineEvent):void {
        if (pageVisible) {
            flvPlayback.volume = volumeFlvPlayback;
        }
        muted = false;
    }

    /**
     * Register some listeners...
     */
    private function registerListeners():void {
        if (onlyWhenActive) {
            cleanUpSupport.make(megazine, MegaZineEvent.PAGE_CHANGE,
                    handlePageChange);
        } else {
            if (even) {
                cleanUpSupport.make(page, MegaZineEvent.INVISIBLE_EVEN,
                        startFadeOut);
                cleanUpSupport.make(page, MegaZineEvent.VISIBLE_EVEN,
                        startFadeIn);
            } else {
                cleanUpSupport.make(page, MegaZineEvent.INVISIBLE_ODD,
                        startFadeOut);
                cleanUpSupport.make(page, MegaZineEvent.VISIBLE_ODD,
                        startFadeIn);
            }
        }
		
        // Register for mute / unmute events.
        cleanUpSupport.make(megazine, MegaZineEvent.MUTE, handleMute);
        cleanUpSupport.make(megazine, MegaZineEvent.UNMUTE, handleUnmute);
    }

}
} // end package
