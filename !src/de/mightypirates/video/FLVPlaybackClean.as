/*
 * FLVPlaybackClean - Taking care of the FLVPlayback's memory leaks.
 * Copyright (C) 2007-2009 Florian Nuecke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package de.mightypirates.video {

import fl.video.FLVPlayback;
import fl.video.VideoPlayer;
import fl.video.flvplayback_internal;

import flash.events.TimerEvent;
import flash.net.NetConnection;

use namespace flvplayback_internal;

/**
 * This class provides a dispose() method which performs all necessary steps to
 * make the FLVPlayback component garbage collection friendly. This function
 * should not be called unless the component will not be used anymore, because
 * it will most likely break the behavior of the component.
 * 
 * @author fnuecke
 */
public class FLVPlaybackClean extends FLVPlayback {
	
    public function FLVPlaybackClean() {
        super();
    }

    /**
     * This method takes care of killing off any references, timers and so on
     * that might hinder garbage collection of this FLVPlayback component.
     * Important: do not call this unless the component is definitely no
     * longer needed, as it will most likely break behavior.
     */
    public function dispose():void {
        // Stopping the video comes first.
        stop();

        // Then remove timers responsible for gui fading and so on.
        if (skinShowTimer) {
            skinShowTimer.stop();
            skinShowTimer.removeEventListener(TimerEvent.TIMER, showSkinNow);
        }
        if (uiMgr) {
            uiMgr._volumeBarTimer.reset();
            uiMgr._bufferingDelayTimer.reset();
            uiMgr._seekBarTimer.reset();
            uiMgr._skinAutoHideTimer.reset();
            uiMgr._skinFadingTimer.reset();

            uiMgr._seekBarTimer.removeEventListener(
                    TimerEvent.TIMER, uiMgr.seekBarListener);
            uiMgr._volumeBarTimer.removeEventListener(
                    TimerEvent.TIMER, uiMgr.volumeBarListener);
            uiMgr._bufferingDelayTimer.removeEventListener(
                    TimerEvent.TIMER, uiMgr.doBufferingDelay);
            uiMgr._skinAutoHideTimer.removeEventListener(
                    TimerEvent.TIMER, uiMgr.skinAutoHideHitTest);
            uiMgr._skinFadingTimer.removeEventListener(
                    TimerEvent.TIMER, uiMgr.skinFadeMore);
        }

        // Finally, close all used video players, to close network connections
        // and remove playback related timers.
        for (var i:int = 0; i < videoPlayers.length; ++i) {
            var videoPlayer:VideoPlayer = getVideoPlayer(i);
            videoPlayer.stop();
            videoPlayer.close();
        }
    }
}
} // end package
