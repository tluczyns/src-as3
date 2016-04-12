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

// Output settings. Width and height must be one so it can scale properly via
// the size parameters passed by swfobject.
[SWF(width="1", height="1", frameRate="30", backgroundColor="#333333")]
import flash.geom.Point;

import de.mightypirates.megazine.events.MegaZineEvent;
import de.mightypirates.megazine.interfaces.Constants;
import de.mightypirates.utils.*;

import swfAddress.*;

import flash.display.*;
import flash.events.*;
import flash.system.System;
import flash.utils.setTimeout;

/**
 * Main class for building the containing swf...
 * also handles swfaddress communication.
 * 
 * This creates the console, frames per second measurement and the actual
 * MegaZine object and links them up. It then adds all of them to this
 * object, which represents the stage.
 * 
 * @author fnuecke
 */
public class Main extends MovieClip {

    /** The console object */
    private var console:Console;

    /** The frames per second object */
    private var fps:FPS;

    /** Maximum scaling factor (liquid scaling) */
    private var maximumScale:Number;

    /** Minimum scaling factor (liquid scaling) */
    private var minimumScale:Number;

    /** The megazine object (main part, of course) */
    private var megazine:MegaZine;

    /** Distance to top */
    private var top:Number;
    
    /** Allow self to reposition even if the parent is not the stage? */
    private var allowReposition:Boolean;

    
    /**
     * Program entry. Initializes console, fps and megazine. If not in local
     * mode hooks up with swfaddress. At least it tries to...
     */
    public function Main() {
        if (stage) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }
    
    /**
     * Changes allowance of repositioning self automagically.
     * 
     * @param allow
     *          whether to allow automatic repositioning or not.
     */
    public function setAllowReposition(allow:Boolean):void {
    	allowReposition = allow;
    }
    
    /**
     * Actual initialization.
     */
    private function init(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        // Disable scaling of the content. Hide most entries of the right
        // click menu.
        if (parent == stage || allowReposition) {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.showDefaultContextMenu = false;
        }
		
        // Create the console and the frames per second.
        console = new Console(handleInput);
        fps = new FPS();
        fps.visible = false;
		
        // Create the MegaZine object. Will not begin loading until added to
        // stage. This is because it first has to find out the absolute path to
        // its location, which is only possible via the stage's loaderInfo
        // object - which in turn is only accessible to MegaZine after it has
        // been added to the stage.
        var xmlPath:String = stage.loaderInfo.parameters["xmlFile"] || null;
        var uiPath:String = stage.loaderInfo.parameters["interface"] || null;
        megazine = new MegaZine(xmlPath, uiPath);
		
        // Add the listener to the megazine, to forward log messages to the
        // console.
        Logger.addEventListener(LoggerEvent.MESSAGE,
                function (e:LoggerEvent):void {
                    console.writeln(e.message);
                });
		
        // Setup swfaddress and javascript interaction if not in local mode.
        try {
            SWFAddress.setStrict(false);
            // Only receive events from swfaddress after megazine is ready for
            // turning pages
            megazine.addEventListener(MegaZineEvent.STATUS_CHANGE,
                    function(e:MegaZineEvent):void {
                        if (e.newState == Constants.MEGAZINE_STATUS_READY) {
                            SWFAddress.addEventListener(SWFAddressEvent.CHANGE,
                                    swfAddressChange);
                            megazine.addEventListener(MegaZineEvent.PAGE_CHANGE,
                                    swfAddressUpdate);
                            // Ready for resize events.
                            stage.addEventListener(Event.RESIZE,
                                    handleStageResize);
                        }
                    });
				
            // Connect to javascript.
            JSConnector.connect(megazine);
        } catch (ex:Error) {
            // Something went wrong...
            Logger.log("Main",
                    "Error registering SWFAddress or JavaScript interaction.",
                    Logger.TYPE_WARNING);
        }
		
        // Centered positioning when ready (i.e. the height and width of the
        // pages is known)
        megazine.addEventListener(MegaZineEvent.STATUS_CHANGE,
                handleMegaZineStatusChange);
		
        // Add the megazine and the console to the stage. This triggers
        // MegaZine to begin loading.
        addChild(megazine);
        addChild(console);
        addChild(fps);
		
        top = Helper.validateNumber(stage.loaderInfo.parameters["top"], NaN);
		
        // Liquid scaling parameters
        maximumScale = Helper.validateNumber(
                stage.loaderInfo.parameters["maxScale"], 1.0);
        minimumScale = Helper.validateNumber(
                stage.loaderInfo.parameters["minScale"], 1.0);
    }

    /**
     * Update scaling and position of the megazine when ready.
     * 
     * @param e
     *          unused.
     */
    private function handleMegaZineStatusChange(e:MegaZineEvent):void {
        if (e.newState == Constants.MEGAZINE_STATUS_READY) {
            megazine.removeEventListener(MegaZineEvent.STATUS_CHANGE,
                    handleMegaZineStatusChange);
            scale();
        } else if (e.newState == Constants.MEGAZINE_STATUS_ERROR) {
            megazine.removeEventListener(MegaZineEvent.STATUS_CHANGE,
                    handleMegaZineStatusChange);
        	position();
        }
    }

    /**
     * Update position of the megazine.
     * 
     * @param e
     *          unused.
     */
    private function position():void {
        if (parent == stage || allowReposition) {
        	var newX:int = int(stage.stageWidth * 0.5
                    - megazine.pageWidth * megazine.scaleX); 
            var newY:int;
            if (!isNaN(top)) {
                newY = int(top * megazine.scaleY);
            } else {
                newY = int((stage.stageHeight - megazine.pageHeight)
                        * 0.5 * megazine.scaleY);
            }
            // Might be we're not directly on stage, adjust position so it's
            // stage relative.
            var newPos:Point = globalToLocal(new Point(newX, newY));
            megazine.x = newPos.x;
            megazine.y = newPos.y;
        }
    }

    /**
     * Update scaling of the megazine.
     * 
     * @param e
     *          unused.
     */
    private function scale():void {
        if (parent == stage || allowReposition) {
            if (minimumScale == maximumScale) {
                megazine.scaleX = megazine.scaleY = minimumScale;
            } else {
                var scaleX:Number = stage.stageWidth
                        / (megazine.pageWidth * 2 + 200);
                var scaleY:Number = stage.stageHeight
                        / (megazine.pageHeight * 1.3
                                + (!isNaN(top) ? top : 1.0));
                var scale:Number = Math.max(minimumScale,
                        Math.min(maximumScale, scaleX, scaleY));
                megazine.scaleX = megazine.scaleY = scale;
            }
            position();
        }
    }

    /**
     * For liquid scaling, handle stage resize events.
     * 
     * @param e
     *          unused.
     */
    private function handleStageResize(e:Event):void {
        scale();
    }

    /**
     * Handle console input. This method is calles by the console whenever a
     * user confirms input by pressing the return key. The text in the input
     * box is then passed as a string to this method. The method returns the
     * text that should be printed as a result message to the console output.
     * 
     * @param input
     *          the console input entered and commited by pressing return.
     * @return the text that should be printed as the result message.
     */
    private function handleInput(input:String):String {
		
        // Command line arguments to process... split at spaces.
        var args:Array = input.split(" ");
        // The message to return / output.
        var msg:String = "";
		
        switch (args[0]) {
            case "?":
            case "help":
                msg +=
"The following commands are available:\n" +
"help              - Displays this listing\n" +
"copyright         - Displays copyrights applying to this software\n" +
"cls               - Clears the console of all messages\n" +
"exit              - Closes the console (# to open it again)\n" +
"gc                - Run the Garbage Collector\n" +
"info              - Prints some info about the SWF\n" +
"fps [0|1]         - Toggle frames per second display\n" +
"pages             - Lists page infos\n" +
"reflect [0|1]     - Toggle or set reflection useage\n" +
"shadow [0|1]      - Toggle or set shadow useage\n" +
"End of listing";
                break;
			
            case "cls":
                setTimeout(console.clear, 10);
                msg += "Clearing screen.";
                break;
			
            case "exit":
            case "quit":
                console.hide();
                break;
			
            case "gc":
                try {
                    System["gc"]();
                    msg += "Running garbage collection...";
                } catch (er:Error) {
                	msg += "Only available in debug players.";
                }
                break;
			
            case "info":
                msg += console.sysinfo();
                break;
			
            case "fps":
                var fpsTo:Boolean = args[1]
                        ? Boolean(int(args[1]))
                        : !fps.visible;
                msg += "Setting framerate visibility to "
                        + (fpsTo ? "true" : "false") + ".";
                fps.visible = fpsTo;
                break;
			
            case "reflect":
                var reflectTo:Boolean = args[1]
                        ? Boolean(int(args[1]))
                        : !megazine.reflection;
                msg += "Setting reflection useage to "
                        + (reflectTo ? "true" : "false") + ".";
                megazine.reflection = reflectTo;
                break;
			
            case "shadow":
                var shadowTo:Boolean = args[1]
                        ? Boolean(int(args[1]))
                        : !megazine.shadows;
                msg += "Setting shadow useage to "
                        + (shadowTo ? "true" : "false") + ".";
                megazine.shadows = shadowTo;
                break;
				
            case "copyright":
                msg +=
"Copyrights of this software \n" +
"\n" +
"The MegaZine 3 Engine \n" +
"\n" +
"  Copyright (C) 2007-2009 Florian Nuecke \n" +
"\n" +
"  This program is free software: you can redistribute it and/or modify \n" +
"  it under the terms of the GNU General Public License as published by \n" +
"  the Free Software Foundation, either version 3 of the License, or \n" +
"  any later version." + "\n" +
"\n" +
"  This program is distributed in the hope that it will be useful, \n" +
"  but WITHOUT ANY WARRANTY; without even the implied warranty of \n" +
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the \n" +
"  GNU General Public License for more details.\n" +
"\n" +
"  You should have received a copy of the GNU General Public License \n" +
"  along with this program. If not, see http://www.gnu.org/licenses/.\n" +
"\n" +
"  For the sourcecode, see http://svn.mightypirates.de/megazine/\n" +
"\n" +
"\n" +
"Utility Classes (de.mightypirates.utils package)\n" +
"\n" +
"  Copyright (c) 2007-2009 Florian Nuecke\n" +
"\n" +
"  Permission is hereby granted, free of charge, to any person obtaining \n" +
"  a copy of this software and associated documentation files (the \n" +
"  \"Software\"), to deal in the Software without restriction, including \n" +
"  without limitation the rights to use, copy, modify, merge, publish, \n" +
"  distribute, sublicense, and/or sell copies of the Software, and to \n" +
"  permit persons to whom the Software is furnished to do so, subject to \n" +
"  the following conditions:\n" +
"\n" +
"  The above copyright notice and this permission notice shall be included \n" +
"  in all copies or substantial portions of the Software.\n" +
  "\n" +
"  For the sourcecode, see http://svn.mightypirates.de/megazine/\n" +
"\n" +
"\n" +
"DictionaryUtil\n" +
"\n" +
"  Copyright (c) 2008, Adobe Systems Incorporated\n" +
"  All rights reserved.\n" +
"\n" +
"  Redistribution and use in source and binary forms, with or without \n" +
"  modification, are permitted provided that the following conditions are \n" +
"  met:\n" +
"\n" +
"  * Redistributions of source code must retain the above copyright notice, \n"+
"    this list of conditions and the following disclaimer.\n" +
"\n" +
"  * Redistributions in binary form must reproduce the above copyright \n" +
"    notice, this list of conditions and the following disclaimer in the \n" +
"    documentation and/or other materials provided with the distribution.\n" +
"\n" +
"  * Neither the name of Adobe Systems Incorporated nor the names of its \n" +
"    contributors may be used to endorse or promote products derived from \n" +
"    this software without specific prior written permission.\n";
                break;
			
            default:
                msg += "Unknown command";
        }
        return msg;
    }

    /**
     * Handle a page change that results from flipping a page in the MegaZine or
     * jumping to a page via the navigation. Forward it to SWFAddress so that
     * the addressbar in the browser is kept up to date.
     * @param e
     *          the event.
     */
    private function swfAddressUpdate(e:MegaZineEvent):void {
        SWFAddress.setValue("/" + String(megazine.leftToRight
                ? e.page
                : (megazine.pageCount - e.page)));
    }

    /**
     * Handle an address change in the browser, e.g. going backwards through the
     * history or manually entering another address in the addressbar. Interpret
     * values after the slash primarily as anchors. The gotoAnchor method tries
     * to convert the given value to a page number if no such anchor exists, so
     * numeric input is ok to navigate to pages.
     * 
     * @param e
     *          the SWFAddress event object fired due to the address change.
     */
    private function swfAddressChange(e:SWFAddressEvent):void {
        megazine.gotoAnchor(e.value.replace("/", ""), true);
    }
}
} // end package
