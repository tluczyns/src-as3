package base.math
{
import flash.display.Sprite;
import flash.display.MovieClip;
public class FingersExample extends Sprite
{
public function FingersExample()
{
// This is a sample use of `Fingers`.
// Fingers are micro AS3 extension for
// handling events, inspired on C#.
// --
// Enjoy,
// Filip Zawada (the author)
 
// We will use MovieClip, however you
// can use any IEventDispatcher you wish.
// `Fingers` uses native AS3 events - it's just a wrapper.
var obj:MovieClip = new MovieClip();
obj.graphics.beginFill(0xff0000, 1);
obj.graphics.drawRect(0, 0, 100, 100);
obj.graphics.endFill();
obj.buttonMode = true;
addChild(obj);

// go to next frame, when user click obj.
// (listening for an event example)
on(obj).click = function() {
	trace("click")
};
 
// Pure AS3 isn't so friendly:
// obj.addEventListener(MouseEvent.CLICK, function ():void {
// obj.nextFrame();
// });
 
// add another listener
// (without removing previous one)
on(obj).click += function():void
{
obj.alpha = 0.5;
trace("click2")
}
 
// dispatch an event!
on(obj).click();
 
// remove all obj click listeners (only those added with `on`)
//on(obj).click = null;
 
// remove all obj listeners added (only those added with `on`)
//on(obj).removeAllListeners();
 
// more docs soon...
//
// homepage: http://filimanjaro.com/fingers
// download: https://github.com/FilipZawada/Fingers
}
}
}