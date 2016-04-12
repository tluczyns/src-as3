package com.li.as3bend.modify
{
import com.li.as3bend.display.OpenSprite;

import com.li.as3bend.utils.BezierUtils;
import com.li.as3bend.vector.PathCommand;

import flash.display.GraphicsPath;
import flash.display.GraphicsPathCommand;
import flash.display.IGraphicsData;
import flash.geom.Point;

public class PathModifier
{
    private var _spriteCache:OpenSprite;
    private var _sprite:OpenSprite;
    private var _path:GraphicsPath;
    private var _totalLength:Number;
    private var _lengths:Vector.<Number>;
    private var _commands:Vector.<PathCommand>;
    private var _lengthArrays:Vector.<Vector.<Number>>;
    private var _arcLengthPrecision:Number = 0.01;

    public var fast:Boolean = false;
    public var restrain:Boolean = false;
    public var offset:Point = new Point();

    public function PathModifier()
    {
    }

    public function set sprite(value:OpenSprite):void
    {
        _sprite = value;

        // Remember the original vertices of the sprite.
        _spriteCache = new OpenSprite();
        _spriteCache.graphicsOpen = _sprite.graphicsOpen.clone(_spriteCache.graphics);
    }

    public function set path(value:GraphicsPath):void
    {
        _path = value;

        _totalLength = 0;
        _lengthArrays = new Vector.<Vector.<Number>>();
        _lengths = new Vector.<Number>();
        _commands = new Vector.<PathCommand>();

        // Identify the curves in the path.
        var i:uint, index:uint;
        var loop:uint = _path.commands.length;
        var data:Vector.<Number> = _path.data;
        var start:Point, control:Point, end:Point;
        var lastEnd:Point;
        for(i = 0; i<loop; ++i)
        {
            var type:int = _path.commands[i];

            if(type != GraphicsPathCommand.MOVE_TO)
            {
                var command:PathCommand;

                start = lastEnd;

                if(type == GraphicsPathCommand.CURVE_TO)
                {
                    control = new Point(data[index++], data[index++]);
                    end = new Point(data[index++], data[index++]);
                    command = new PathCommand(type, start, control, end);
                }
                else if(type == GraphicsPathCommand.LINE_TO)
                {
                    end = new Point(data[index++], data[index++]);
                    command = new PathCommand(type, start, control, end);
                    BezierUtils.createControlPointForLine(command);
                }

                lastEnd = end;

                _commands.push(command);
            }
            else
            {
                lastEnd = new Point(data[index++], data[index++]);
            }
        }

        // Get arc length info for all curves.
        loop = _commands.length;
        for(i = 0; i<loop; ++i)
        {
            command = _commands[uint(i)];

            var commandLengthsArray:Vector.<Number> = BezierUtils.getArcLengthArray(command, _arcLengthPrecision);
            _lengthArrays.push(commandLengthsArray);

            var commandTotalLength:Number = commandLengthsArray[commandLengthsArray.length-1];
            _lengths.push(commandTotalLength);
            _totalLength += commandTotalLength;
        }
    }

    public function apply():void
    {
        var i:uint;
        var j:uint;
        var m:uint;
        var n:uint;

        // Warp the sprites's points onto the curve.
        var loop:uint, subLoop:uint, subSubLoop:uint, subSubSubLoop:uint, index:uint;
        var origData:Vector.<IGraphicsData> = _spriteCache.graphicsOpen.graphicsData;
        var transData:Vector.<IGraphicsData> = _sprite.graphicsOpen.graphicsData;
        var element:IGraphicsData;
        loop = origData.length;
        for(m = 0; m<loop; ++m)
        {
            element = origData[m];
            if(element is GraphicsPath)
            {
                var origPath:Vector.<Number> = GraphicsPath(element).data;
                var transPath:Vector.<Number> = GraphicsPath(transData[m]).data;

                subLoop = origPath.length/2;
                for(n = 0; n < subLoop; ++n)
                {
                    index = 2*n;
                    var origVertex:Point = new Point(origPath[uint(index)], origPath[uint(index + 1)]);

                    // Get the x position marker for the vertex.
                    var X:Number = origVertex.x + offset.x;

                    if(X > 0)
                    {
                        while(X > _totalLength)
                            X -= _totalLength;
                    }
                    else
                    {
                        while(X < 0)
                            X += _totalLength;
                    }

                    // Evaluate into which curve the X marker falls.
                    var acumLength:Number = 0;
                    subSubLoop = _lengths.length;
                    for(i = 0; i < subSubLoop; ++i)
                    {
                        acumLength += _lengths[uint(i)];

                        if(acumLength > X)
                            break; // The loop breaks and i represents the index of the curve that contains the marker.
                    }

                    // Remove the last length from acumLength to obtain the local t in the landing curve.
                    acumLength -= _lengths[uint(i)];
                    var u:Number = (X - acumLength)/_lengths[uint(i)];

                    if(!fast)
                    {
                        // Arc-length parameterization.
                        //-----------------------------------------------------------------
                        // Find a t that yields uniform arc length.
                        subSubSubLoop = _lengthArrays[uint(i)].length - 2;
                        for(j = 0; j < subSubSubLoop; ++j)
                        {
                            var currentLength:Number = _lengthArrays[uint(i)][uint(j)];
                            if(currentLength/_lengths[uint(i)] > u)
                                break;
                        }

                        var t:Number = 0;
                        if(_lengthArrays[uint(i)][uint(j)]/_lengths[uint(i)] == u)
                            t = j/(_lengthArrays[uint(i)].length - 1);
                        else  // need to interpolate between two points
                        {
                            var lengthBefore:Number = _lengthArrays[uint(i)][uint(j)];
                            var lengthAfter:Number = _lengthArrays[uint(i)][uint(j + 1)];
                            var segmentLength:Number = lengthAfter - lengthBefore;

                            // determine where we are between the 'before' and 'after' points.
                            var segmentFraction:Number = (u*_lengths[uint(i)] - lengthBefore)/segmentLength;

                            // add that fractional amount to t
                            t = (j + segmentFraction)/(_lengthArrays[uint(i)].length - 1);
                        }
                        //-----------------------------------------------------------------
                    }
                    else
                        t = u;

                    // Get the coordinates of the curve at t.
                    var s:Point = BezierUtils.getCoordinatesAt(t, _commands[uint(i)]);

                    // Get the normal at t.
                    var tangent:Point = BezierUtils.getDerivativeAt(t, _commands[uint(i)]);

                    var tX:Number = restrain ? -Math.abs(tangent.y) : -tangent.y;
                    var tY:Number = restrain ? Math.abs(tangent.x) : tangent.x;
                    var p:Point = new Point(tX, tY);
                    var len:Number = p.length;
                    p.x /= len;
                    p.y /= len;
                    len = origVertex.y + offset.y;
                    p.x *= len;
                    p.y *= len;

                    // Warp the point.
                    transPath[index]     = s.x + p.x;
                    transPath[index + 1] = s.y + p.y;
                }
            }
        }
    }
}
}
