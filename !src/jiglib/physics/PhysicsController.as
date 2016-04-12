package jiglib.physics
{

	public class PhysicsController
	{

		protected var _controllerEnabled:Boolean;

		public function PhysicsController()
		{
			_controllerEnabled = false;
		}

		// implement this to apply whatever forces are needed to the objects this controls
		public function updateController(dt:Number):void
		{
		}

		// register with the physics system
		public function enableController():void
		{
		}

		// deregister from the physics system
		public function disableController():void
		{
		}

		// are we registered with the physics system?
		public function get controllerEnabled():Boolean
		{
			return _controllerEnabled;
		}
	}
}
