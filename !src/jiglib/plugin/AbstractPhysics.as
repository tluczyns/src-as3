package jiglib.plugin {
	import flash.utils.getTimer;
	
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;

	public class AbstractPhysics {
		
		private var initTime		: int;
		private var stepTime		: int;
		private var speed			: Number;
		private var deltaTime		: Number = 0;
		private var physicsSystem	: PhysicsSystem;
		private var _frameTime		: uint = 0; // time need for one frame physics step
		
		public function AbstractPhysics(speed:Number = 5) {
			this.speed = speed;
			initTime = getTimer();
			physicsSystem = PhysicsSystem.getInstance();
			physicsSystem.setCollisionSystem(false); // bruteforce
			//physicsSystem.setCollisionSystem(true,20,20,20,200,200,200); // grid
		}
		
		public function addBody(body:RigidBody):void {
			physicsSystem.addBody(body as RigidBody);
		}
		
		public function removeBody(body:RigidBody):void {
			physicsSystem.removeBody(body as RigidBody);
		}
		
		public function get engine():PhysicsSystem {
			return physicsSystem ;
		}
		
		public function get frameTime():uint {
			return _frameTime;
		}

		public function afterPause():void {
			initTime = getTimer();
		}

		//if dt>0 use the static time step,otherwise use the dynamic time step
		public function step(dt:Number=0):void {
				stepTime = getTimer();
				deltaTime = ((stepTime - initTime) / 1000) * speed;
				initTime = stepTime;
				physicsSystem.integrate((dt>0)?dt:deltaTime);
				_frameTime = getTimer()-initTime;
		}
	}
}