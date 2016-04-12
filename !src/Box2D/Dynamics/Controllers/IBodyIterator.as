﻿/*
* Copyright (c) 2010 Adam Newgas http://www.boristhebrave.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Box2D.Dynamics.Controllers 
{
	import Box2D.Dynamics.b2Body;
	
	/**
	 * A list of bodies that can be looped over once.
	 */
	public interface IBodyIterator 
	{
		/**
		 * Call to see if another body is available
		 */
		function HasNext():Boolean;
		
		/**
		 * Return the current body, and move on to the next.
		 * Only valid to call after HasNext() returns true.
		 */
		function Next():b2Body;
	}
	
}