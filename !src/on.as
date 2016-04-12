package
{
import base.math.Finger;


import flash.events.IEventDispatcher;

/**
 * Wrap your object with on(), then add your listeners
 * <pre>on(yourDispatcher).click = clickListener;</pre>
 * <pre>on(yourDispatcher).click += clickListener2;</pre>
 *
 * Complete tutorial available at: http://filimanjaro.com/fingers
 *
 * @param obj any EventDispatcher
 * @return Finger, a wrapper for your dispatcher;
 */
public function on(obj:IEventDispatcher):Finger
{
	_on.openWith(obj);
    return _on;
}

}
import base.math.Finger;

internal var _on:Finger = new Finger();

