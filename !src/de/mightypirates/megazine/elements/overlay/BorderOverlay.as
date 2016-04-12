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

package de.mightypirates.megazine.elements.overlay {
import de.mightypirates.utils.Helper;

import flash.display.CapsStyle;
import flash.display.DisplayObjectContainer;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.errors.IllegalOperationError;
import flash.filters.GlowFilter;
import flash.filters.BitmapFilterQuality;

/**
 * The border overlay class harbors multiple border styles.
 * Arguments: type
 * For each type there are individual additional attributes possible.
 * +------------+--------------------------------+
 * | Types      | Attributes                     |
 * +------------+--------------------------------+
 * | glow       | color, size                    |
 * | solid      | color, size                    |
 * | dotted     | color, size                    |
 * +------------+--------------------------------+
 */
internal class BorderOverlay extends AbstractOverlay {

    public function BorderOverlay(target:DisplayObjectContainer, args:Array) {
        super(target, args);
        var type:String = "glow";
        if (args.length > 2) {
            type = Helper.validateString(args[2], type);
        }
        // scoping... -.-
        var color:uint;
        var size:int;
        var sizeHalf:Number;
        switch (type) {
            case "glow":
                // Default: border glow
                color = 0xFFFFFF;
                if (args.length > 3) {
                    color = Helper.validateUInt(args[3], color);
                }
                size = int(Math.min(overlayWidth, overlayHeight) / 10);
                if (args.length > 4) {
                    size = Helper.validateInt(args[4], size);
                }
                graphics.beginFill(0);
                graphics.drawRect(0, 0, overlayWidth, overlayHeight);
                graphics.endFill();
                filters = [new GlowFilter(color, 1, size, size, 1,
                        BitmapFilterQuality.MEDIUM, true, true)];
                break;
            case "solid":
                // Solid border.
                color = 0x000000;
                if (args.length > 3) {
                    color = Helper.validateUInt(args[3], color);
                }
                size = 1;
                if (args.length > 4) {
                    size = Helper.validateInt(args[4], size);
                }
                graphics.lineStyle(size, color, 1, false, LineScaleMode.NONE);
                sizeHalf = size * 0.5;
                graphics.moveTo(sizeHalf, sizeHalf);
                graphics.lineTo(overlayWidth - sizeHalf, sizeHalf);
                graphics.lineTo(overlayWidth - sizeHalf, overlayHeight - sizeHalf);
                graphics.lineTo(sizeHalf, overlayHeight - sizeHalf);
                graphics.lineTo(sizeHalf, sizeHalf);
                break;
            case "dotted":
                // Dotted border.
                color = 0x666666;
                if (args.length > 3) {
                    color = Helper.validateUInt(args[3], color);
                }
                size = 1;
                if (args.length > 4) {
                    size = Helper.validateInt(args[4], size);
                }
                graphics.lineStyle(size, color, 1, false, LineScaleMode.NONE,
                        CapsStyle.SQUARE, JointStyle.BEVEL);
                sizeHalf = size * 0.5;
                var left:Number = sizeHalf;
                var right:Number = overlayWidth - sizeHalf;
                var top:Number = sizeHalf;
                var bottom:Number = overlayHeight - sizeHalf;
                var i:Number = left;
                do {
                    graphics.moveTo(i, top);
                    graphics.lineTo(i + 0.15, top);
                    graphics.moveTo(i, bottom);
                    graphics.lineTo(i + 0.15, bottom);
                    i += size * 2;
                } while (i < right);
                i = top + size;
                do {
                    graphics.moveTo(left, i);
                    graphics.lineTo(left, i + 0.15);
                    graphics.moveTo(right, i);
                    graphics.lineTo(right, i + 0.15);
                    i += size * 2;
                } while (i < bottom - size);
                break;
            default:
                throw new IllegalOperationError(
                        "Invalid border type specified.");
        }
    }
}
} // end package
