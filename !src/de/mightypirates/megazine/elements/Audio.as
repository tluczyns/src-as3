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
import de.mightypirates.megazine.events.*;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.events.*;
import flash.media.*;
import flash.net.URLRequest;
import flash.utils.Timer;

/**
 * The <code>Audio (snd)</code> class is used to load sounds into pages.
 * 
 * <p>
 * This object loads a sound file, such as an mp3, and starts playing it. The
 * volume will be adjusted, depending on whether the page containing the sound
 * element is currently visile (sound audible) or not (sound muted).
 * </p>
 * 
 * @author fnuecke
 */
public class Audio extends AbstractElement {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The delay in milliseconds to wait before starting the sound */
    private var delay:Number = 0;

    /** Value by which to change the volume each timer tick */
    private var increment:Number = 0.05;

    /**
     * Loop the sound? This makes most sense when used together with 'restart'.
     */
    private var doLoop:Boolean = true;

    /** Is the sound _muted even when visible? */
    private var muted:Boolean = false;

    /**
     * Only when the containing page is actually the main page
     * (not when visible via dragged corner).
     */
    private var onlyWhenActive:Boolean = false;

    /**
     * Restart the playback when the page becomes visible (instead of
     * continuing).
     */
    private var doRestart:Boolean = false;

    /** The sound that should be played */
    private var sound:Sound;

    /**
     * The soundchannel of the currently playing sound (necessary for volume
     * adjustments).
     */
    private var soundChannel:SoundChannel;

    /** Sound transform for the sound channel (the volume adjustment) */
    private var soundTrans:SoundTransform;

    /** The currently targeted volume */
    private var volumeTarget:Number = 0;

    /** Timer to increase or decrease volume if needed */
    private var volumeTimer:Timer;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new sound object, which in turn loads a sound an plays it while
     * the page the sound element resides in is visible.
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
    public function Audio(megazine:IMegaZine, localizer:Localizer,
            library:ILibrary, page:IPage, even:Boolean, xml:XML, number:uint)
    {
        super(megazine, localizer, library, page, even, xml, number);
        sound = new Sound();
        soundTrans = new SoundTransform(0);
        volumeTimer = new Timer(100);
        cleanUpSupport.addTimer(volumeTimer);
    }

    /**
     * Initialize loading.
     */
    override public function init():void {
        // Restart instead of continue
        doRestart = Helper.validateBoolean(xml.@restart, doRestart);
		
        // Only play when on the main page (not when visible via dragged corner)
        onlyWhenActive = Helper.validateBoolean(xml.@onlywhenactive,
                onlyWhenActive);
		
        // Loop the sound
        doLoop = Helper.validateBoolean(xml.@loop, doLoop);
		
        // Load the sound
        var url:String = Helper.validateString(xml.@src, "");
        if (url != "") {
			
            url = megazine.getAbsPath(url);
			
            // Regis_megazine volume handling event with timer
            cleanUpSupport.make(volumeTimer, TimerEvent.TIMER, handleTimer);
            // Check for custom fading time
            var fade:int = Helper.validateInt(xml.@fade, -1);
            if (fade >= 0) {
                if (fade == 0) {
                    increment = -1;
                } else {
                    increment = volumeTimer.delay / fade;
                }
            }
            delay = Helper.validateUInt(xml.@delay, 0);
			
            // Handle loading errors
            cleanUpSupport.make(sound, IOErrorEvent.IO_ERROR, handleLoadError);
			
            // Handle successful loading
            cleanUpSupport.make(sound, Event.COMPLETE, handleComplete);
			
            try {
                // Begin loading
                sound.load(new URLRequest(url),
                        new SoundLoaderContext(1000, true));
            } catch (ex:Error) {
                Logger.log("MegaZine Audio",
                        "    Error loading sound: " + Helper.trimString(url, 40)
                        + " in page " + (page.getNumber(even) + 1),
                        Logger.TYPE_WARNING);
                super.init();
            }
        } else {
            Logger.log("MegaZine Audio",
                    "    No source defined for 'snd' object in page "
                    + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
            super.init();
        }
    }

    /**
     * Stop playback and kill the listener.
     * 
     * @param e
     *          unused.
     */
    override protected function destroy(e:Event):void {
        super.destroy(e);
        try {
            if (soundChannel != null) {
                soundChannel.stop();
                soundChannel.removeEventListener(Event.SOUND_COMPLETE,
                        handleSoundComplete);
            }
            sound.close();
        } catch (er:Error) {
        }
    }

    /**
     * Error loading the sound.
     * 
     * @param e
     *          unused.
     */
    private function handleLoadError(e:IOErrorEvent):void {
        var url:String = megazine.getAbsPath(
                Helper.validateString(xml.@src, ""));
        Logger.log("MegaZine Audio", "    Error loading sound: "
                + Helper.trimString(url, 40) + " in page "
                + (page.getNumber(even) + 1), Logger.TYPE_WARNING);
        super.init();
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Sound loading complete, begin playback.
     * 
     * @param e
     *          unused.
     */
    private function handleComplete(e:Event):void {
        registerListeners();
        // Register with megazine onMute and onUnmute events.
        cleanUpSupport.make(megazine, MegaZineEvent.MUTE, handleMute);
        cleanUpSupport.make(megazine, MegaZineEvent.UNMUTE, handleUnmute);
        super.init();
        handleSoundComplete();
        // If the page is visible: make audible
        if (page.getPageVisible(even)) {
            startFadeIn();
        }
        if (megazine.muted) {
            handleMute(null);
        }
    }

    /**
     * Sound completed playback, restart it for infinite loop.
     * 
     * @param e
     *          unused.
     */
    private function handleSoundComplete(e:Event = null):void {
        if (doLoop) {
            restart();
        } else if (soundChannel != null) {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE,
                    handleSoundComplete);
            soundChannel = null;
        }
    }

    /**
     * Restarts the sound from the beginning.
     */
    private function restart():void {
        // Remove listener from old sound channel
        if (soundChannel != null) {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE,
                    handleSoundComplete);
        }
        // Get new one by restarting playback
        soundChannel = sound.play();
        soundChannel.soundTransform = soundTrans;
        soundChannel.addEventListener(Event.SOUND_COMPLETE,
                handleSoundComplete);
    }

    /**
     * Sound should be muted.
     * 
     * @param e
     *          unused.
     */
    private function handleMute(e:MegaZineEvent):void {
        muted = true;
        try {
            volumeTimer.reset();
            soundTrans.volume = 0;
            soundChannel.soundTransform = soundTrans;
        } catch (ex:Error) { 
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
     * Unmute sound.
     * 
     * @param e
     *          unused.
     */
    private function handleUnmute(e:MegaZineEvent):void {
        muted = false;
        try {
            soundTrans.volume = volumeTarget;
            soundChannel.soundTransform = soundTrans;
        } catch (ex:Error) { 
        }
    }

    /**
     * Restore sound when visible (and not muted).
     * 
     * @param e
     *          unused.
     */
    private function startFadeIn(e:MegaZineEvent = null):void {
        volumeTarget = 1;
        if (doRestart && (soundChannel == null || soundTrans.volume == 0)) {
        	 restart();
        }
        if (muted) {
        	return;
        }
        if (increment > 0) {
            volumeTimer.start();
        } else {
            handleTimer();
        }
    }

    /**
     * Make inaudible when page gets hidden.
     * 
     * @param e
     *          unused.
     */
    private function startFadeOut(e:MegaZineEvent = null):void {
        volumeTarget = 0;
        if (muted) {
        	return;
        }
        if (increment > 0) {
            volumeTimer.start();
        } else {
            handleTimer();
        }
    }

    /**
     * Update volume level (volume fader).
     * 
     * @param e
     *          unused.
     */
    private function handleTimer(e:TimerEvent = null):void {
        if (soundTrans.volume < volumeTarget) {
            // Fading in
            if (soundTrans.volume == 0
                    && volumeTimer.currentCount * volumeTimer.delay < delay)
            {
            	return;
            }
            soundTrans.volume += increment;
        } else {
            // Fading out
            soundTrans.volume -= increment;
        }
        if (increment <= 0
                || Math.abs(soundTrans.volume - volumeTarget) <= increment)
        {
            soundTrans.volume = volumeTarget;
            volumeTimer.reset();
        }
        if (soundChannel != null) {
            soundChannel.soundTransform = soundTrans;
        }
    }

    /**
     * Register event listeners (done when sound was loaded completely)
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
    }
}
} // end package
