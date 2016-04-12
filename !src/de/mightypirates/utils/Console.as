/*
 * Console - A very simplistic and flexible console class.
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

package de.mightypirates.utils {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Timer;

/**
 * Simple console class allowing for output by either simply appending text, or appending
 * text and adding a newline after it.
 * Input is redirected to a method passed to the constructor which must handle input
 * appropriately.
 * Note that a top left aligned stage is required for proper displaying!
 * 
 * @author fnuecke
 * @version 1.17
 */
public class Console extends Sprite {

    // ---------------------------------------------------------------------- //
    // Constants
    // ---------------------------------------------------------------------- //
	
    /** Hotkey that opens the console */
    private static const _hotKey:String = "#";

    // ---------------------------------------------------------------------- //
    // Variables
    // ---------------------------------------------------------------------- //
	
    /** The background for the console */
    private var background:Sprite;

    /** Last entered commands */
    private var commands:Array;

    /** Current index in the command history */
    private var current:int = 0;

    /** The input text */
    private var input:TextField;

    /** The function that will handle the user input */
    private var inputHandler:Function;

    /** The output text */
    private var output:TextField;

    
    // ---------------------------------------------------------------------- //
    // Constructor
    // ---------------------------------------------------------------------- //
	
    /**
     * Constructor.
     * 
     * @param inputHandler
     *          a function that handles text input, must take a string with the
     *          input text and return a string with the system's response
     *          message.
     * @param baseWidth
     *          the basic width of the stage. If not given it is assumed the
     *          stage is at its basic width on instantiation of this object.
     * @param baseHeight
     *          the basic height of the stage. If not given it is assumed the
     *          stage is at its basic width on instantiation of this object.
     */
    /*
    Basic example for an inputHandler function,
    assuming the Console object is named "console":
	
    function handleInput(input:String):String
    {
		
    var args:Array = input.split(" ");
		
    var msg:String = "";
		
    switch (args[0])
    {
			
    case "list":
    case "cmdlist":
    case "listcmds":
    case "help":
    case "?":
    msg += "The following commands are available:\n";
    msg += "cls               - Clears the console of all messages\n";
    msg += "exit              - Closes the console (# to open it again)\n";
    msg += "help              - Displays this listing\n";
    msg += "End of listing";
    break;
			
    case "cls":
    setTimeout(console.clear, 10);
    msg += "Clearing screen...";
    break;
			
    case "exit":
    case "quit":
    console.hide();
    break;
			
    default:
    msg += "Unknown command";
			
    }
		
    return msg;
		
    }
     */
    public function Console(inputHandler:Function) {
		
        // Initialize command history array
        commands = new Array();
        commands.push("");
		
        // Remember the handler function
        this.inputHandler = inputHandler;
		
        // Create the background
        background = new Sprite();
        background.graphics.beginFill(0x333333, 0.8);
        background.graphics.drawRect(0, 0, 200, 100);
        background.graphics.endFill();
        addChild(background);
		
        // Create the output
        output = new TextField();
        output.defaultTextFormat = new TextFormat("Lucida Console", "11", "0xEEEEEE");
        output.multiline = true;
        output.wordWrap = true;
        output.selectable = true;
        output.width = 200;
        output.height = 100;
        addChild(output);
		
        // Create the input
        input = new TextField();
        input.type = TextFieldType.INPUT;
        input.defaultTextFormat = new TextFormat("Lucida Console", "11");
        input.background = true;
        input.border = true;
        input.x = 3;
        input.width = 200;
        input.height = 16;
        addChild(input);
		
        // Event listener for final initialization (when added to stage)
        addEventListener(Event.ADDED_TO_STAGE, init);
		
        // Input handling
        input.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
        input.addEventListener(Event.CHANGE, handleInputChange);
		
		
        // Clear the screen
        clear();
		
        // Hide self initially
        hide();
    }

    private function handleInputChange(e:Event):void {
        commands[current] = input.text;
    }

    // ---------------------------------------------------------------------- //
    // Initialization
    // ---------------------------------------------------------------------- //
	
    /**
     * Finalizes initialisation of the console.
     * 
     * @param e
     *          unused.
     */
    private function init(e:Event):void {
		
        // Only fire once
        removeEventListener(Event.ADDED_TO_STAGE, init);
		
        // Add event listener, to resize the console if the stage is resized
        stage.addEventListener(Event.RESIZE, redraw);
		
        // Add an event listener for showing / hiding the console
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		
        // Do a first redraw to set sizes and such
        redraw();
    }

    private function handleKeyDown(e:KeyboardEvent):void {
        if (e.charCode == _hotKey.charCodeAt() && !visible) {
            show();
            // Set focus with a slight delay, otherwise the hotkey will
            // be added to the input...
            oneShotTimer(focus, 10);
        } else if (e.keyCode == Keyboard.ESCAPE && visible) {
            hide();
        }
    }

    // ---------------------------------------------------------------------- //
    // Methods
    // ---------------------------------------------------------------------- //
	
    /**
     * Remove all messages from the display.
     */
    public function clear():void {
        output.text = "";
        writeln("Very Simple Console [Version 1.12]\n"
                + "(C) Copyright 2007-2009 Florian Nuecke.\n"
                + "\n"
                + "Type \"help\" for command listing.\n");
    }

    /**
     * Sets focus to the console's input.
     */
    public function focus():void {
        stage.focus = input;
    }

    /**
     * Handle keyboard events (key presses).
     * 
     * @param e
     *          used to get the pressed key.
     */
    private function handleInput(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ENTER && input.text != "") {
            // Update the actual current entry and clear the input text
            commands[0] = input.text;
            input.text = "";
			
            // Call the input handler
            writeln("> " + commands[0] + "\n" + inputHandler(commands[0]));
			
            // Add a new empty entry (next command)
            commands.unshift("");
            current = 0;
        } else if (e.keyCode == Keyboard.UP) {
            // Backwards, increase and ensure limits, then override display
            current++;
            current = current < commands.length ? current
                    : commands.length - 1;
            input.text = commands[current];
        } else if (e.keyCode == Keyboard.DOWN) {
            // Forwards, decrease and ensure limits, then override display
            current--;
            current = current < 0 ? 0 : current;
            input.text = commands[current];
        }
    }

    /**
     * Hide the console. Plain and simple for now...
     */
    public function hide():void {
        this.visible = false;
        input.text = "";
    }

    /**
     * Update sizes of the elements.
     * 
     * @param e
     *          unused.
     */
    private function redraw(e:Event = null):void {
        var newPos:Point = parent.globalToLocal(new Point(0, 0));
		
        x = newPos.x;
        y = newPos.y;
		
        background.width = stage.stageWidth;
        background.height = stage.stageHeight * 0.5;
		
        output.width = stage.stageWidth;
        output.height = stage.stageHeight * 0.5 - input.height - 8;
		
        input.width = stage.stageWidth - 7;
        input.y = output.height + 4;
    }

    /**
     * Show the console.
     */
    public function show():void {
        output.scrollV = output.maxScrollV;
        this.visible = true;
    }

    /**
     * Add a message to the console output.
     * 
     * @param msg
     *          the message to add.
     */
    public function write(... msg:Array):void {
        var p:Object;
        for each (var o:Object in msg) {
            if (p != null) {
                output.appendText(" ");
            }
            if (o != null) {
                output.appendText(String(o));
            }
            p = o;
        }
        output.scrollV = output.maxScrollV;
    }

    /**
     * Add a message to the console output and insert a new line at the end.
     * 
     * @param msg
     *          the message to add.
     */
    public function writeln(... msg:Array):void {
        var p:Object;
        for each (var o:Object in msg) {
            if (p != null) {
                output.appendText(" ");
            }
            if (o != null) {
                output.appendText(String(o));
            }
            p = o;
        }
        output.appendText("\n");
        output.scrollV = output.maxScrollV;
    }

    // ---------------------------------------------------------------------- //
    // Miscellaneous
    // ---------------------------------------------------------------------- //
	
    /**
     * Helper function, like setTimeout but using a <code>Timer</code>.
     * 
     * @param calls
     *          the function to call.
     * @param after
     *          the delay in ms.
     */
    private function oneShotTimer(calls:Function, after:Number):void {
        var t:Timer = new Timer(after, 1);
        t.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
            calls(); 
        });
        t.start();
    }

    /**
     * Get some environment info.
     */
    public function sysinfo():String {
        var msg:String = "";
		
        if (stage != null) {
            msg += "Stage: ";
            msg += "width=" + stage.stageWidth;
            msg += "; height=" + stage.stageHeight;
            msg += "; framerate=" + stage.frameRate;
            msg += "\n";
        }
		
        msg += "Movie: ";
        msg += "asVersion=";
        try {
            msg += root.loaderInfo.actionScriptVersion;
        } catch (e:Error) {
            msg += "N/A";
        }
		
        msg += "; swfVersion=";
        try {
            msg += root.loaderInfo.swfVersion;
        } catch (e:Error) {
            msg += "N/A";
        }
		
        msg += "; url=" + stage.loaderInfo.url;
        msg += "\n";
		
        msg += "Memory Used: ";
        try {
            msg += System.totalMemory + " (~" + Math.round(System.totalMemory / 1024 / 1024) + "mb)";
        } catch (e:Error) {
            msg += "N/A";
        }
        msg += "\n";
		
        msg += "System: " + "os=" + Capabilities.os + "; language=" + Capabilities.language + "; codepage=" + (System.useCodePage != false ? System.useCodePage : "Unicode") + "; time=" + new Date().toString() + "; playerVersion=" + Capabilities.version + "; playerIsDebugger=" + Capabilities.isDebugger;
		
        return msg;
    }
}
} // end package
