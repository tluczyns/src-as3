package com.li.as3bend.display
{
import flash.display.Sprite;

public class OpenSprite extends Sprite
{
    private var _graphicsOpen:OpenGraphics;

    public function OpenSprite()
    {
        super();

        _graphicsOpen = new OpenGraphics(graphics);
    }

    public function get graphicsOpen():OpenGraphics
    {
        return _graphicsOpen;
    }

    public function set graphicsOpen(value:OpenGraphics):void
    {
        _graphicsOpen = value;
    }
}
}
