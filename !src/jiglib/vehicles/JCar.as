package jiglib.vehicles
{
	import flash.geom.Vector3D;
	
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.plugin.ISkin3D;

	public class JCar
	{

		private var _maxSteerAngle:Number;
		private var _steerRate:Number;
		private var _driveTorque:Number;

		private var _destSteering:Number;
		private var _destAccelerate:Number;

		private var _steering:Number;
		private var _accelerate:Number;
		private var _HBrake:Number;

		private var _chassis:JChassis;
		private var _wheels:Array;
		private var _steerWheels:Array;

		public function JCar(skin:ISkin3D):void
		{
			_chassis = new JChassis(this, skin);
			_wheels = [];
			_steerWheels = [];
			_destSteering = _destAccelerate = _steering = _accelerate = _HBrake = 0;
			setCar();
		}

		/*
		 * maxSteerAngle: the max steer angle
		 * steerRate: the flexibility of steer
		 * driveTorque: the max torque of wheel
		 */
		public function setCar(maxSteerAngle:Number = 45, steerRate:Number = 1, driveTorque:Number = 500):void
		{
			_maxSteerAngle = maxSteerAngle;
			_steerRate = steerRate;
			_driveTorque = driveTorque;
		}

		/*
		 * _name: name of wheel
		 * pos: position of wheel relative to the car's center
		 * wheelSideFriction: side friction
		 * wheelFwdFriction: forward friction
		 * wheelTravel: suspension travel upwards
		 * wheelRadius: wheel radius
		 * wheelRestingFrac: elasticity coefficient
		 * wheelDampingFrac: suspension damping
		 */
		public function setupWheel(_name:String, pos:Vector3D,
			wheelSideFriction:Number = 2, wheelFwdFriction:Number = 2,
			wheelTravel:Number = 3, wheelRadius:Number = 10,
			wheelRestingFrac:Number = 0.5, wheelDampingFrac:Number = 0.5,
			wheelNumRays:int = 1):void
		{
			var mass:Number = _chassis.mass;
			var mass4:Number = 0.25 * mass;
			
			var gravity:Vector3D = PhysicsSystem.getInstance().gravity.clone();
			var gravityLen:Number = PhysicsSystem.getInstance().gravity.length;
			gravity.normalize();
			var axis:Vector3D = JNumber3D.getScaleVector(gravity, -1);
			var spring:Number = mass4 * gravityLen / (wheelRestingFrac * wheelTravel);
			var inertia:Number = 0.015 * wheelRadius * wheelRadius * mass;
			var damping:Number = 2 * Math.sqrt(spring * mass);
			damping *= (0.25 * wheelDampingFrac);

			_wheels[_name] = new JWheel(this);
			_wheels[_name].setup(pos, axis, spring, wheelTravel, inertia,
				wheelRadius, wheelSideFriction, wheelFwdFriction,
				damping, wheelNumRays);
		}

		public function get chassis():JChassis
		{
			return _chassis;
		}

		public function get wheels():Array
		{
			return _wheels;
		}

		public function setAccelerate(val:Number):void
		{
			_destAccelerate = val;
		}

		public function setSteer(wheels:Array, val:Number):void
		{
			_destSteering = val;
			_steerWheels = [];
			for (var i:String in wheels)
			{
				if (findWheel(wheels[i]))
				{
					_steerWheels[wheels[i]] = _wheels[wheels[i]];
				}
			}
		}

		private function findWheel(_name:String):Boolean
		{
			for (var i:String in _wheels)
			{
				if (i == _name)
				{
					return true;
				}
			}
			return false;
		}

		public function setHBrake(val:Number):void
		{
			_HBrake = val;
		}

		public function addExternalForces(dt:Number):void
		{
			for each (var wheel:JWheel in wheels)
			{
				wheel.addForcesToCar(dt);
			}
		}

		// Update stuff at the end of physics
		public function postPhysics(dt:Number):void
		{
			var wheel:JWheel;
			for each (wheel in wheels)
			{
				wheel.update(dt);
			}

			var deltaAccelerate:Number,deltaSteering:Number,dAccelerate:Number,dSteering:Number,alpha:Number,angleSgn:Number;
			deltaAccelerate = dt;
			deltaSteering = dt * _steerRate;
			dAccelerate = _destAccelerate - _accelerate;
			if (dAccelerate < -deltaAccelerate)
			{
				dAccelerate = -deltaAccelerate;
			}
			else if (dAccelerate > deltaAccelerate)
			{
				dAccelerate = deltaAccelerate;
			}
			_accelerate += dAccelerate;

			dSteering = _destSteering - _steering;
			if (dSteering < -deltaSteering)
			{
				dSteering = -deltaSteering;
			}
			else if (dSteering > deltaSteering)
			{
				dSteering = deltaSteering;
			}
			_steering += dSteering;

			for each (wheel in wheels)
			{
				wheel.addTorque(_driveTorque * _accelerate);
				wheel.setLock(_HBrake > 0.5);
			}

			alpha = Math.abs(_maxSteerAngle * _steering);
			angleSgn = (_steering > 0) ? 1 : -1;
			for each (var _steerWheel:JWheel in _steerWheels)
			{
				_steerWheel.setSteerAngle(angleSgn * alpha);
			}
		}

		public function getNumWheelsOnFloor():int
		{
			var count:int = 0;
			for each (var wheel:JWheel in wheels)
			{
				if (wheel.getOnFloor())
				{
					count++;
				}
			}
			return count;
		}
	}

}
