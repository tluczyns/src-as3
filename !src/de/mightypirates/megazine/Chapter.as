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
import de.mightypirates.megazine.MegaZine;
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.*;

import flash.events.*;
import flash.media.*;
import flash.net.URLRequest;
import flash.utils.Timer;

/**
 * Holds data for a chapter in the book (page default values).
 * 
 * <p>
 * This is created for easier propagation of inheritable properties, such as
 * background color and folding effect strength, as well as the obvious
 * grouping of pages.
 * </p>
 * 
 * <p>
 * It is also used to handle the sound playback that may be defined for
 * chapters.
 * </p>
 * 
 * <p>
 * Chapters are not aware of the reading order!
 * </p>
 * 
 * @author fnuecke
 */
internal class Chapter implements IChapter {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The default background color for this chapter */
    private var backgroundColor_:uint;

    /** Delay before fading in the sound */
    private var fadeInDelay_:Number;

    /** The default foldfx alpha for this chapter */
    private var foldEffectAlpha_:Number;

    /** Slide show delay for pages in this chapter */
    private var slideDelay_:uint;

    /** Array storing all the pages in this chapter */
    private var pages:Array; // IPage
	
	
    /** Background sound for this chapter */

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

    /** Value by which to change the volume each timer tick */
    private var volumeIncrement:Number = 0.05;

    /** Is the sound muted even when pages of the chapter visible? */
    private var isMuted:Boolean = false;

    private var cleanUpSupport:CleanUpSupport;
    
    /** The anchor of this chapter, if set */
    private var anchor_:String;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Creates a new chapter.
     * 
     * @param megazine
     *          the megazine this chapter belongs to.
     * @param chapterXML
     *          the chapter xml data.
     * @param settings
     *          settings object with common settings.
     */
    public function Chapter(megazine:MegaZine, chapterXML:XML,
            settings:Settings)
    {
		
        // Initialize variables.
        pages = new Array();
        volumeTimer = new Timer(100);
        soundTrans = new SoundTransform(0);
        cleanUpSupport = new CleanUpSupport();
		
		// The anchor.
		anchor_ = Helper.validateString(chapterXML.@anchor, null);
		
        // Background color.
        backgroundColor_ = Helper.validateUInt(chapterXML.@bgcolor,
                settings.pageBackgroundColor);
		
        // Folding effects alpha value.
        foldEffectAlpha_ = Helper.validateNumber(chapterXML.@foldfx,
                settings.pageFoldEffectAlpha, 0, 1);
		
        // Time in ms to show a page before turning to the next one in seconds.
        slideDelay_ = Helper.validateUInt(chapterXML.@slidedelay,
                settings.slideDelay, 1);
		
        // Background sound
        var url:String = Helper.validateString(chapterXML.@bgsound, "");
        if (url != "") {
			
            url = megazine.getAbsPath(url);
			
            // Check for custom fading time
            if (chapterXML.@fade != undefined
                    && int(chapterXML.@fade.toString()) >= 0)
            {
                if (int(chapterXML.@fade.toString()) == 0) {
                    volumeIncrement = -1;
                } else {
                    volumeIncrement = volumeTimer.delay
                            / uint(chapterXML.@fade.toString());
                }
            }
            fadeInDelay_ = Helper.validateUInt(chapterXML.@delay, 0);
			
            // Create the sound object.
            sound = new Sound();
			
            // Register volume handling event with timer
            cleanUpSupport.make(volumeTimer, TimerEvent.TIMER, handleFadeTimer);
			
            // Handle loading errors
            cleanUpSupport.make(sound, IOErrorEvent.IO_ERROR,
                function(e:IOErrorEvent):void {
                    sound = null;
                    Logger.log("MegaZine Chapter", "    Error loading sound: "
                            + Helper.trimString(url, 30) + " for chapter.",
                            Logger.TYPE_WARNING);
                });
			
            // Loading completion handling
            cleanUpSupport.make(sound, Event.COMPLETE, handleSoundComplete);
			
            try {
				
                // Begin loading
                sound.load(new URLRequest(url), new SoundLoaderContext(1000, true));
            } catch (ex:Error) {
                sound = null;
                Logger.log("MegaZine Chapter", "    Error loading sound: "
                        + Helper.trimString(url, 30) + " for chapter.",
                        Logger.TYPE_WARNING);
            }
        }
		
        // Register for muting events (here and not in the sound loaded part so we
        // do not need to remember the megazine variable).
        cleanUpSupport.make(megazine, MegaZineEvent.MUTE, handleMute);
        cleanUpSupport.make(megazine, MegaZineEvent.UNMUTE, handleUnmute);
		
        // Set initially to muted if the megazine is muted.
        if (megazine.muted) {
        	handleMute(null);
        }
    }

    // ---------------------------------------------------------------------- //
    // Page adding / removing
    // ---------------------------------------------------------------------- //
	
    /**
     * Adds a page to this chapter.
     * 
     * @param page the page to add.
     */
    internal function addPage(page:IPage):void {
        pages.push(page);
        // Only necessary if a background sound is specified.
        if (sound == null) {
            return;
        }
        // Not via cleanup support to make it possible to remove single pages.
        page.addEventListener(MegaZineEvent.INVISIBLE_EVEN, handleInvisible);
        page.addEventListener(MegaZineEvent.VISIBLE_EVEN, handleVisible);
        page.addEventListener(MegaZineEvent.INVISIBLE_ODD, handleInvisible);
        page.addEventListener(MegaZineEvent.VISIBLE_ODD, handleVisible);
    }
    
    /**
     * Clean up after self.
     */
    internal function destroy():void {
        cleanUpSupport.cleanup();
        for each (var page:Page in pages) {
            page.removeEventListener(MegaZineEvent.INVISIBLE_EVEN,
                    handleInvisible);
            page.removeEventListener(MegaZineEvent.VISIBLE_EVEN, handleVisible);
            page.removeEventListener(MegaZineEvent.INVISIBLE_ODD,
                    handleInvisible);
            page.removeEventListener(MegaZineEvent.VISIBLE_ODD, handleVisible);
        }
        pages = null;
    }
    
    // ---------------------------------------------------------------------- //
    // Event handling
    // ---------------------------------------------------------------------- //
	
    /**
     * Mute sound
     * @param	e
     */
    private function handleMute(e:MegaZineEvent):void {
        isMuted = true;
        try {
            volumeTimer.reset();
            soundTrans.volume = 0;
            soundChannel.soundTransform = soundTrans;
        } catch (ex:Error) { 
        }
    }

    /**
     * Unmute sound
     * @param	e
     */
    private function handleUnmute(e:MegaZineEvent):void {
        isMuted = false;
        try {
            soundTrans.volume = volumeTarget;
            soundChannel.soundTransform = soundTrans;
        } catch (ex:Error) { 
        }
    }

    /**
     * A page in this chapter became visible.
     * @param e Event object.
     */
    private function handleVisible(e:MegaZineEvent):void {
        // If no sound is defined, kill listeners
        if (sound == null) {
            (e.target as Page).removeEventListener(e.type, handleVisible);
        }
		
        volumeTarget = 1;
        if (isMuted) return;
        if (volumeIncrement > 0) {
            volumeTimer.start();
        } else {
            handleFadeTimer();
        }
    }

    /**
     * A page in the chapter became invisible.
     * 
     * @param e
     *          used to get the page.
     */
    private function handleInvisible(e:MegaZineEvent):void {
        // If no sound is defined, kill listeners
        if (sound == null) {
            (e.target as Page).removeEventListener(e.type, handleInvisible);
        }
		
        // Check if all pages are invisible.
        var vis:Boolean = false;
        for each (var p:IPage in pages) {
            vis ||= p.getPageVisible(true) || p.getPageVisible(false);
        }
		
        if (!vis) {
            volumeTarget = 0;
            if (isMuted) return;
            if (volumeIncrement > 0) {
                volumeTimer.start();
            } else {
                handleFadeTimer();
            }
        }
    }

    /**
     * Handle sound complete event to restart the sound.
     * 
     * @param e
     *          unused.
     */
    private function handleSoundComplete(e:Event = null):void {
        // Avoid nullpointers...
        if (sound == null) {
            return;
        }
        soundChannel = sound.play();
        soundChannel.soundTransform = soundTrans;
        soundChannel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
    }

    /**
     * Handle volume change timer event.
     * 
     * @param e
     *          unused.
     */
    private function handleFadeTimer(e:TimerEvent = null):void {
        if (soundTrans != null) {
            if (soundTrans.volume < volumeTarget) {
                // Fading in
                if (soundTrans.volume == 0 && volumeTimer.currentCount
                        * volumeTimer.delay < fadeInDelay_)
                {
                	return;
                }
                soundTrans.volume += volumeIncrement;
            } else {
                // Fading out
                soundTrans.volume -= volumeIncrement;
            }
            if (volumeIncrement <= 0 || Math.abs(soundTrans.volume
                    - volumeTarget) <= volumeIncrement)
            {
                soundTrans.volume = volumeTarget;
                volumeTimer.reset();
            }
            if (soundChannel != null) {
                soundChannel.soundTransform = soundTrans;
            }
        }
    }

    // ---------------------------------------------------------------------- //
    // Getters
    // ---------------------------------------------------------------------- //
	
    /**
     * The number of the first page in this chapter. Returns -1 if there are no
     * pages in this chapter.<br/>
     * This will always be the number with the lowest index, i.e. as it would
     * be in left to right reading order.
     * 
     * @return the first page in this chapter.
     */
    public function get firstPage():int {
        var first:int = int.MAX_VALUE;
        for each (var p:IPage in pages) {
            if (p.getNumber(true) < first) {
                first = p.getNumber(true);
            }
        }
        if (first == int.MAX_VALUE) {
        	first = -1;
        }
        return first;
    }

    /**
     * The number of the last page in this chapter. Returns -1 if there are no
     * pages in this chapter.<br/>
     * This will always be the number with the highest index, i.e. as it would
     * be in left to right reading order.
     * 
     * @return the last page in this chapter.
     */
    public function get lastPage():int {
        var last:int = -1;
        for each (var p:IPage in pages) {
            if (p.getNumber(true) > last) {
                last = p.getNumber(true);
            }
        }
        return last;
    }

    /**
     * Get the default page background color for this chapter.
     * 
     * @return background color for the chapter.
     */
    public function containsPage(page:IPage):Boolean {
        for each (var p:IPage in pages) {
            if (p == page) {
                return true;
            }
        }
        return false;
    }

    /**
     * Get the default page background color for this chapter.
     * 
     * @return background color for the chapter.
     */
    public function get backgroundColor():uint {
        return backgroundColor_;
    }

    /**
     * Get the default page folding effects alpha value for this chapter.
     * 
     * @return folding effect alpha value for the chapter.
     */
    public function get foldEffectAlpha():Number {
        return foldEffectAlpha_;
    }

    /**
     * Gets the slide delay for pages in this chapter.
     * 
     * @return the default slide delay setting for pages in this chapter.
     */
    public function get slideDelay():uint {
        return slideDelay_;
    }
    
    /**
     * The anchor of this chapter, if set. Else null.
     */
    internal function get anchor():String {
        return anchor_;
    }
    
}
} // end package
