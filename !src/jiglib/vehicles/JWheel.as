package jiglib.vehicles
{
	import flash.geom.Vector3D;
	
	import jiglib.collision.CollisionSystemAbstract;
	import jiglib.data.CollOutBodyData;
	import jiglib.geometry.JSegment;
	import jiglib.math.*;
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;

	public class JWheel
	{

		private const noslipVel:Number = 0.2;
		private const slipVel:Number = 0.4;
		private const slipFactor:Number = 0.7;
		private const smallVel:Number = 3;

		private var _car:JCar;
		private var _pos:Vector3D;
		private var _axisUp:Vector3D;
		private var _spring:Number;
		private var _travel:Number;
		private var _inertia:Number;
		private var _radius:Number;
		private var _sideFriction:Number;
		private var _fwdFriction:Number;
		private var _damping:Number;
		private var _numRays:int;

		private var _angVel:Number;
		private var _steerAngle:Number;
		private var _torque:Number;
		private var _driveTorque:Number;
		private var _axisAngle:Number;
		private var _displacement:Number;
		private var _upSpeed:Number;
		private var _rotDamping:Number;

		private var _locked:Boolean;
		private var _lastDisplacement:Number;
		private var _lastOnFloor:Boolean;
		private var _angVelForGrip:Number;

		private var worldPos:Vector3D;
		private var worldAxis:Vector3D;
		private var wheelFwd:Vector3D;
		private var wheelUp:Vector3D;
		private var wheelLeft:Vector3D;
		private var wheelRayEnd:Vector3D;
		private var wheelRay:JSegment;
		private var groundUp:Vector3D;
		private var groundLeft:Vector3D;
		private var groundFwd:Vector3D;
		private var wheelPointVel:Vector3D;
		private var rimVel:Vector3D;
		private var worldVel:Vector3D;
		private var wheelCentreVel:Vector3D;
		
		// proxy for CollisionSystem, avoid calling singleton every time in loop
		private var _collisionSystem:CollisionSystemAbstract;

		public function JWheel(car:JCar)
		{
			_car = car;
		}

		/*
		 * pos: position relative to car, in car's space
		 * axisUp: in car's space
		 * spring: force per suspension offset
		 * travel: suspension travel upwards
		 * inertia: inertia about the axel
		 * radius: wheel radius
		 */
		public function setup(pos:Vector3D, axisUp:Vector3D,
			spring:Number = 0, travel:Number = 0,
			inertia:Number = 0, radius:Number = 0,
			sideFriction:Number = 0, fwdFriction:Number = 0,
			damping:Number = 0, numRays:int = 0):void
		{
			_pos = pos;
			_axisUp = axisUp;
			_spring = spring;
			_travel = travel;
			_inertia = inertia;
			_radius = radius;
			_sideFriction = sideFriction;
			_fwdFriction = fwdFriction;
			_damping = damping;
			_numRays = numRays;
			reset();
		}

		// power
		public function addTorque(torque:Number):void
		{
			_driveTorque += torque;
		}

		// lock/unlock the wheel
		public function setLock(lock:Boolean):void
		{
			_locked = lock;
		}

		public function setSteerAngle(steer:Number):void
		{
			_steerAngle = steer;
		}

		// get steering angle in degrees
		public function getSteerAngle():Number
		{
			return _steerAngle;
		}

		public function getPos():Vector3D
		{
			return _pos;
		}

		// the suspension axis in the car's frame
		public function getLocalAxisUp():Vector3D
		{
			return _axisUp;
		}

		public function getActualPos():Vector3D
		{
			return _pos.add(JNumber3D.getScaleVector(_axisUp, _displacement));
		}

		// wheel radius
		public function getRadius():Number
		{
			return _radius;
		}

		// the displacement along our up axis
		public function getDisplacement():Number
		{
			return _displacement;
		}

		public function getAxisAngle():Number
		{
			return _axisAngle;
		}

		public function getRollAngle():Number
		{
			return 0.1 * _angVel * 180 / Math.PI;
		}

		public function setRotationDamping(vel:Number):void {
			_rotDamping = vel;
		}
		
		public function getRotationDamping():Number {
			return _rotDamping;
		}
		
		//if it's on the ground.
		public function getOnFloor():Boolean
		{
			return _lastOnFloor;
		}

		// Adds the forces die to this wheel to the parent. Return value indicates if it's on the ground.
		public function addForcesToCar(dt:Number):Boolean
		{
			var force:Vector3D = new Vector3D();
			_lastDisplacement = _displacement;
			_displacement = 0;

			var carBody:JChassis = _car.chassis;
			worldPos = carBody.currentState.orientation.transformVector(_pos);
			worldPos = carBody.currentState.position.add(worldPos);
			worldAxis = carBody.currentState.orientation.transformVector(_axisUp);

			wheelFwd = JMatrix3D.getRotationMatrix(worldAxis.x, worldAxis.y, worldAxis.z, _steerAngle).transformVector(carBody.currentState.getOrientationCols()[2]);
			wheelUp = worldAxis;
			wheelLeft = wheelUp.crossProduct(wheelFwd);
			wheelLeft.normalize();

			var rayLen:Number = 2 * _radius + _travel;
			wheelRayEnd = worldPos.subtract(JNumber3D.getScaleVector(worldAxis, _radius));
			wheelRay = new JSegment(wheelRayEnd.add(JNumber3D.getScaleVector(worldAxis, rayLen)), JNumber3D.getScaleVector(worldAxis, -rayLen));

			if(!_collisionSystem)
				_collisionSystem = PhysicsSystem.getInstance().getCollisionSystem();

			var maxNumRays:int = 10;
			var numRays:int = Math.min(_numRays, maxNumRays);

			var objArr:Vector.<CollOutBodyData> = new Vector.<CollOutBodyData>(numRays, true);
			var segments:Vector.<JSegment> = new Vector.<JSegment>(numRays, true);

			var deltaFwd:Number = (2 * _radius) / (numRays + 1);
			var deltaFwdStart:Number = deltaFwd;

			_lastOnFloor = false;

			var distFwd:Number;
			var yOffset:Number;
			var bestIRay:int = 0;
			var iRay:int = 0;
			var collOutBodyData:CollOutBodyData;
			var segment:JSegment;
			for (iRay = 0; iRay < numRays; iRay++)
			{
				collOutBodyData = objArr[iRay] = new CollOutBodyData();
				distFwd = (deltaFwdStart + iRay * deltaFwd) - _radius;
				yOffset = _radius * (1 - Math.cos(90 * (distFwd / _radius) * Math.PI / 180));
				segment = segments[iRay] = wheelRay.clone();
				segment.origin = segment.origin.add(JNumber3D.getScaleVector(wheelFwd, distFwd).add(JNumber3D.getScaleVector(wheelUp, yOffset)));
				if (_collisionSystem.segmentIntersect(collOutBodyData, segment, carBody))
				{
					_lastOnFloor = true;
					if (collOutBodyData.frac < objArr[bestIRay].frac)
					{
						bestIRay = iRay;
					}
				}
			}

			if (!_lastOnFloor)
			{
				return false;
			}

			var frac:Number = objArr[bestIRay].frac;
			var groundPos:Vector3D = objArr[bestIRay].position;
			var otherBody:RigidBody = objArr[bestIRay].rigidBody;

			var groundNormal:Vector3D = worldAxis.clone();
			if (numRays > 1)
			{
				for (iRay = 0; iRay < numRays; iRay++)
				{
					collOutBodyData = objArr[iRay];
					if (collOutBodyData.frac <= 1)
						groundNormal = groundNormal.add(JNumber3D.getScaleVector(worldPos.subtract(segments[iRay].getEnd()), 1 - collOutBodyData.frac));
				}
				
				groundNormal.normalize();
			}
			else
			{
				groundNormal = objArr[bestIRay].normal;
			}

			_displacement = rayLen * (1 - frac);
			
			if (_displacement < 0)
				_displacement = 0;
			else if (_displacement > _travel)
				_displacement = _travel;

			var displacementForceMag:Number = _displacement * _spring;
			displacementForceMag *= groundNormal.dotProduct(worldAxis);

			var dampingForceMag:Number = _upSpeed * _damping;
			var totalForceMag:Number = displacementForceMag + dampingForceMag;
			if (totalForceMag < 0)
				totalForceMag = 0;
			
			var extraForce:Vector3D = JNumber3D.getScaleVector(worldAxis, totalForceMag);
			force = force.add(extraForce);

			groundUp = groundNormal;
			groundLeft = groundNormal.crossProduct(wheelFwd);
			groundLeft.normalize();
			groundFwd = groundLeft.crossProduct(groundUp);

			var tempv:Vector3D = carBody.currentState.orientation.transformVector(_pos);
			wheelPointVel = carBody.currentState.linVelocity.add(carBody.currentState.rotVelocity.crossProduct(tempv));

			rimVel = JNumber3D.getScaleVector(wheelLeft.crossProduct(groundPos.subtract(worldPos)), _angVel);
			wheelPointVel = wheelPointVel.add(rimVel);

			if (otherBody.movable)
			{
				worldVel = otherBody.currentState.linVelocity.add(otherBody.currentState.rotVelocity.crossProduct(groundPos.subtract(otherBody.currentState.position)));
				wheelPointVel = wheelPointVel.subtract(worldVel);
			}

			var friction:Number = _sideFriction;
			var sideVel:Number = wheelPointVel.dotProduct(groundLeft);
			
			if ((sideVel > slipVel) || (sideVel < -slipVel))
				friction *= slipFactor;
			else if ((sideVel > noslipVel) || (sideVel < -noslipVel))
				friction *= (1 - (1 - slipFactor) * (Math.abs(sideVel) - noslipVel) / (slipVel - noslipVel));
			
			if (sideVel < 0)
			{
				friction *= -1;
			}
			if (Math.abs(sideVel) < smallVel)
			{
				friction *= Math.abs(sideVel) / smallVel;
			}

			var sideForce:Number = -friction * totalForceMag;
			extraForce = JNumber3D.getScaleVector(groundLeft, sideForce);
			force = force.add(extraForce);

			friction = _fwdFriction;
			var fwdVel:Number = wheelPointVel.dotProduct(groundFwd);
			if ((fwdVel > slipVel) || (fwdVel < -slipVel))
			{
				friction *= slipFactor;
			}
			else if ((fwdVel > noslipVel) || (fwdVel < -noslipVel))
			{
				friction *= (1 - (1 - slipFactor) * (Math.abs(fwdVel) - noslipVel) / (slipVel - noslipVel));
			}
			if (fwdVel < 0)
			{
				friction *= -1;
			}
			if (Math.abs(fwdVel) < smallVel)
			{
				friction *= (Math.abs(fwdVel) / smallVel);
			}
			var fwdForce:Number = -friction * totalForceMag;
			extraForce = JNumber3D.getScaleVector(groundFwd, fwdForce);
			force = force.add(extraForce);

			wheelCentreVel = carBody.currentState.linVelocity.add(carBody.currentState.rotVelocity.crossProduct(tempv));
			_angVelForGrip = wheelCentreVel.dotProduct(groundFwd) / _radius;
			_torque += (-fwdForce * _radius);

			carBody.addWorldForce(force, groundPos, false);
			if (otherBody.movable)
			{
				var maxOtherBodyAcc:Number = 500;
				var maxOtherBodyForce:Number = maxOtherBodyAcc * otherBody.mass;
				if (force.lengthSquared > maxOtherBodyForce * maxOtherBodyForce)
				{
					force = JNumber3D.getScaleVector(force, maxOtherBodyForce / force.length);
				}
				otherBody.addWorldForce(JNumber3D.getScaleVector(force, -1), groundPos, false);
			}
			return true;
		}

		// Updates the rotational state etc
		public function update(dt:Number):void
		{
			if (dt <= 0)
			{
				return;
			}
			var origAngVel:Number = _angVel;
			_upSpeed = (_displacement - _lastDisplacement) / Math.max(dt, JMath3D.NUM_TINY);

			if (_locked)
			{
				_angVel = 0;
				_torque = 0;
			}
			else
			{
				_angVel += (_torque * dt / _inertia);
				_torque = 0;

				if (((origAngVel > _angVelForGrip) && (_angVel < _angVelForGrip)) || ((origAngVel < _angVelForGrip) && (_angVel > _angVelForGrip)))
				{
					_angVel = _angVelForGrip;
				}

				_angVel += _driveTorque * dt / _inertia;
				_driveTorque = 0;

				if (_angVel < -100)
				{
					_angVel = -100;
				}
				else if (_angVel > 100)
				{
					_angVel = 100;
				}
				_angVel *= _rotDamping;
				_axisAngle += (_angVel * dt * 180 / Math.PI);
			}

		}

		public function reset():void
		{
			_angVel = 0;
			_steerAngle = 0;
			_torque = 0;
			_driveTorque = 0;
			_axisAngle = 0;
			_displacement = 0;
			_upSpeed = 0;
			_locked = false;
			_lastDisplacement = 0;
			_lastOnFloor = false;
			_angVelForGrip = 0;
			_rotDamping = 0.99;
		}
	}
}