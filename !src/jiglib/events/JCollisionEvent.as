package jiglib.events 
{
	import flash.events.Event;
	import jiglib.physics.RigidBody;
	
	public class JCollisionEvent extends Event
	{
		//called when the body occur a new collision
		public static const COLLISION_START:String = "collisionStart";
		
		//called when the body lose a collision
		public static const COLLISION_END:String = "collisionEnd";
		
		
		public var body:RigidBody;
		
		public function JCollisionEvent(type : String) 
		{
			super(type);
		}
	}

}