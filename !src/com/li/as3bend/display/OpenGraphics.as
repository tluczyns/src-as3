package com.li.as3bend.display
{
import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;

public class OpenGraphics
{
    private var _graphicsData:Vector.<IGraphicsData>;
    private var _activeFill:GraphicsSolidFill;
    private var _activeStroke:GraphicsStroke;
    private var _activePath:GraphicsPath;
    private var _graphics:Graphics;

    public function OpenGraphics(target:Graphics)
    {
        _graphics = target;
        _graphicsData = new Vector.<IGraphicsData>();
    }

    public function clone(graphics:Graphics):OpenGraphics
    {
        var clone:OpenGraphics = new OpenGraphics(graphics);

        var gd:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();

        var i:uint;
        var loop:uint = _graphicsData.length;
        var element:IGraphicsData;
        for(i = 0; i < loop; ++i)
        {
            element = _graphicsData[i];

            if(element is GraphicsSolidFill || element is GraphicsStroke)
            {
                gd.push(element);
            }
            else if(element is GraphicsPath)
            {
                if(GraphicsPath(element).commands)
                {
                    var gp:GraphicsPath = new GraphicsPath();
                    gp.commands = GraphicsPath(element).commands.concat();
                    gp.data = GraphicsPath(element).data.concat();
                    gd.push(gp);
                }
            }
        }

        clone.graphicsData = gd;

        return clone;
    }

    public function get graphicsData():Vector.<IGraphicsData>
    {
        return _graphicsData;
    }
    public function set graphicsData(value:Vector.<IGraphicsData>):void
    {
        _graphicsData = value;
    }

    public function draw():void
    {
        // Perform the draw.
        _graphics.clear();
        _graphics.drawGraphicsData(_graphicsData);
    }

    public function beginFill(color:uint, alpha:Number = 1):void
    {
        // Make sure last fill was ended.
        endFill();

        // Create a new fill object.
        var fill:GraphicsSolidFill = new GraphicsSolidFill(color, alpha);
        _activeFill = fill;

        // Create a dummy stroke object.
        var stroke:GraphicsStroke = new GraphicsStroke(1, false);
        stroke.fill = fill;
        _activeStroke = stroke;

        // Create a new path object.
        var path:GraphicsPath = new GraphicsPath();
        _activePath = path;
    }

    public function endFill():void
    {
        if(_activeFill && _activeStroke && _activePath)
            _graphicsData.push(_activeFill, _activeStroke, _activePath);
    }

    public function clear():void
    {
        _graphicsData = new Vector.<IGraphicsData>();
    }

    public function moveTo(anchorX:Number, anchorY:Number):void
    {
        _activePath.moveTo(anchorX, anchorY);
    }

    public function lineTo(anchorX:Number, anchorY:Number):void
    {
        _activePath.lineTo(anchorX, anchorY);
    }

    public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void
    {
        _activePath.curveTo(controlX, controlY, anchorX, anchorY);
    }
}
}
