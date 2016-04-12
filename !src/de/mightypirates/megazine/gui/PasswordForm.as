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
import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.*;
import de.mightypirates.utils.Localizer;

import flash.display.*;
import flash.events.*;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Timer;

/**
 * Dispatched when the correct password was entered.
 * 
 * @eventType de.mightypirates.megazine.events.MegaZineEvent.PASSWORD_CORRECT
 */
[Event(name = 'password_correct',
        type = 'de.mightypirates.megazine.events.MegaZineEvent')]

/**
 * PasswordForm for asking users for a password before showing the book's
 * contents.
 * 
 * <p>
 * Fires an event of type {@link MegaZineEvent#PASSWORD_CORRECT} when the
 * correct password has been entered by the user.
 * </p>
 * 
 * @author fnuecke
 */
public class PasswordForm extends Sprite {

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The function to call if the user enters the right password */
    private var functionToCall:Function;

    /** Text prompt (displays the text "Password") */
    private var lblPassword:TextField;

    /** The text field for inputting the password */
    private var passwordInput:TextField;

    /** The password that is required */
    private var passwordRequired:String;

    /** The graphics to hint that the password was wrong */
    private var passwordWrong:DisplayObject;

    /** Timer for fading out the wrong effect */
    private var wrongEffectFadeTimer:Timer;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Setup the password form with we require
     * 
     * @param password
     *          the required password.
     * @param localizer
     *          localizer used to localize strings.
     * @param library
     *          library used to get graphics.
     * @throws an error if the necessary gui parts could not be loaded from the
     *          library.
     */
    public function PasswordForm(password:String, localizer:Localizer,
            library:ILibrary)
    {
        // Store password
        passwordRequired = password;
		
        // Try to load the graphics
        try {
            var gui:DisplayObjectContainer = library.getInstanceOf(
                    LibraryConstants.PASSWORD_FORM) as DisplayObjectContainer;
            addChild(gui);
            passwordWrong = gui["passwordWrong"];
            passwordInput = gui["passwordInput"];
            lblPassword = gui["lblPassword"];
        } catch (e:Error) {
        }
        if (lblPassword == null || passwordInput == null
                || passwordWrong == null)
        {
            throw new Error("Failed loading gui for PasswordForm.");
        }
		
        // Add event listener for returns to check the password
        passwordInput.addEventListener(KeyboardEvent.KEY_DOWN,
            handlePasswordEntered);
		
        // Initially hide the wrong effect
        passwordWrong.alpha = 0;
		
        // Timer for fading out the wrong effect
        wrongEffectFadeTimer = new Timer(100);
        wrongEffectFadeTimer.addEventListener(TimerEvent.TIMER,
                handleWrongEffectFadeTimer);
		
        localizer.registerObject(lblPassword, "text", "LNG_PASSWORD");
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Checks if the password is correct (if the user presses return).
     * 
     * @param e
     *      used to see if enter was pressed.
     */
    private function handlePasswordEntered(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ENTER) {
            if (passwordInput.text == passwordRequired) {
                passwordInput.removeEventListener(KeyboardEvent.KEY_DOWN,
                        handlePasswordEntered);
                wrongEffectFadeTimer.stop();
                wrongEffectFadeTimer.removeEventListener(TimerEvent.TIMER,
                        handleWrongEffectFadeTimer);
                dispatchEvent(new MegaZineEvent(
                        MegaZineEvent.PASSWORD_CORRECT));
            } else {
                passwordWrong.alpha = 1;
                wrongEffectFadeTimer.start();
            }
        }
    }

    /**
     * Fade out the "input was wrong" effect...
     * 
     * @param e
     *          unused.
     */
    private function handleWrongEffectFadeTimer(e:TimerEvent):void {
        passwordWrong.alpha -= 0.05;
        if (passwordWrong.alpha <= 0) {
            wrongEffectFadeTimer.stop();
        }
    }
}
} // end package
