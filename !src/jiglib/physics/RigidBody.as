package jiglib.physics
{
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.collision.CollisionInfo;
	import jiglib.collision.CollisionSystemAbstract;
	import jiglib.collision.CollisionSystemGridEntry;
	import jiglib.data.CollOutData;
	import jiglib.geometry.JAABox;
	import jiglib.geometry.JSegment;
	import jiglib.math.*;
	import jiglib.events.JCollisionEvent;
	import jiglib.physics.constraint.JConstraint;
	import jiglib.plugin.ISkin3D;

	public class RigidBody extends EventDispatcher
	{
		private static var idCounter:int = 0;
		
		private var _id:int;
		private var _skin:ISkin3D;
		
		protected var _type:String;
		protected var _boundingSphere:Number;
		protected var _boundingBox:JAABox;
		
		protected var _currState:PhysicsState;
		
		private var _oldState:PhysicsState;
		private var _storeState:PhysicsState;
		private var _invOrientation:Matrix3D;
		private var _currLinVelocityAux:Vector3D;
		private var _currRotVelocityAux:Vector3D;
		
		private var _mass:Number;
		private var _invMass:Number;
		private var _bodyInertia:Matrix3D;
		private var _bodyInvInertia:Matrix3D;
		private var _worldInertia:Matrix3D;
		private var _worldInvInertia:Matrix3D;
		
		private var _force:Vector3D;
		private var _torque:Vector3D;
		
		private var _linVelDamping:Vector3D;
		private var _rotVelDamping:Vector3D;
		private var _maxLinVelocities:Vector3D;
		private var _maxRotVelocities:Vector3D;
		
		private var _movable:Boolean;
		private var _origMovable:Boolean;
		private var _inactiveTime:Number;
		
		// The list of bodies that need to be activated when we move away from our stored position
		private var _bodiesToBeActivatedOnMovement:Vector.<RigidBody>;
		
		private var _storedPositionForActivation:Vector3D; // The position stored when we need to notify other bodies
		private var _lastPositionForDeactivation:Vector3D; // last position for when trying the deactivate
		private var _lastOrientationForDeactivation:Matrix3D; // last orientation for when trying to deactivate
		
		private var _material:MaterialProperties;
		
		private var _rotationX:Number = 0;
		private var _rotationY:Number = 0;
		private var _rotationZ:Number = 0;
		private var _useDegrees:Boolean;
		
		private var _nonCollidables:Vector.<RigidBody>;
		private var _collideBodies:Vector.<RigidBody>;
		private var _constraints:Vector.<JConstraint>;
		
		// Bypass rapid call to PhysicsSystem, will update only when dirty.
		private var _gravity:Vector3D;
		private var _gravityAxis:int;
		// Calculate only when gravity is dirty or mass is dirty.
		private var _gravityForce:Vector3D;
		
		public var collisions:Vector.<CollisionInfo>;//store all collision info of this body
		public var externalData:CollisionSystemGridEntry; // used when collision system is grid 
		public var collisionSystem:CollisionSystemAbstract;
		
		public function RigidBody(skin:ISkin3D)
		{
			_useDegrees = (JConfig.rotationType == "DEGREES") ? true : false;

			_id = idCounter++;

			_skin = skin;
			_material = new MaterialProperties();

			_bodyInertia = new Matrix3D();
			_bodyInvInertia = JMatrix3D.getInverseMatrix(_bodyInertia);

			_currState = new PhysicsState();
			_oldState = new PhysicsState();
			_storeState = new PhysicsState();
			_currLinVelocityAux = new Vector3D();
			_currRotVelocityAux = new Vector3D();

			_force = new Vector3D();
			_torque = new Vector3D();

			_invOrientation = JMatrix3D.getInverseMatrix(_currState.orientation);
			_linVelDamping = new Vector3D(0.999, 0.999, 0.999);
			_rotVelDamping = new Vector3D(0.999, 0.999, 0.999);
			_maxLinVelocities = new Vector3D(JMath3D.NUM_HUGE,JMath3D.NUM_HUGE,JMath3D.NUM_HUGE);
			_maxRotVelocities = new Vector3D(JMath3D.NUM_HUGE,JMath3D.NUM_HUGE,JMath3D.NUM_HUGE);

			_inactiveTime = 0;
			isActive = true;
			_movable = true;
			_origMovable = true;

			collisions = new Vector.<CollisionInfo>();
			_constraints = new Vector.<JConstraint>();
			_nonCollidables = new Vector.<RigidBody>();
			_collideBodies = new Vector.<RigidBody>();

			_storedPositionForActivation = new Vector3D();
			_bodiesToBeActivatedOnMovement = new Vector.<RigidBody>();
			_lastPositionForDeactivation = _currState.position.clone();
			_lastOrientationForDeactivation = _currState.orientation.clone();

			_type = "Object3D";
			_boundingSphere = JMath3D.NUM_HUGE;
			_boundingBox = new JAABox();
			
			externalData=null;
		}

		private function radiansToDegrees(rad:Number):Number
		{
			return rad * 180 / Math.PI;
		}

		private function degreesToRadians(deg:Number):Number
		{
			return deg * Math.PI / 180;
		}

		//update rotation values (rotationX, rotationY, rotationZ) to the actual current values, 
		// these values are not updated based on real-time physics changes 
		// This is currently not done in real-time for performance reasons
		// Useful once you have a physics objects that is no longer in the physics system but you want to manipulate it's rotation.
		// Only needs to be called once after disabling from physics system
		public function updateRotationValues():void
		{
			var rotationVector:Vector3D = _currState.orientation.decompose()[1];
			_rotationX = formatRotation(radiansToDegrees(rotationVector.x));
			_rotationY = formatRotation(radiansToDegrees(rotationVector.y));
			_rotationZ = formatRotation(radiansToDegrees(rotationVector.z));
		}

		//from FIVe3D library - InternalUtils (MIT License)
		protected static function formatRotation(angle:Number):Number
		{
			if (angle >= -180 && angle <= 180)
				return angle;
			
			var angle2:Number = angle % 360;
			if (angle2 < -180)
				return angle2 + 360;
			
			if (angle2 > 180)
				return angle2 - 360;
			
			return angle2;
		}

		public function get rotationX():Number
		{
			return _rotationX; //(_useDegrees) ? radiansToDegrees(_rotationX) : _rotationX;
		}

		public function get rotationY():Number
		{
			return _rotationY; //(_useDegrees) ? radiansToDegrees(_rotationY) : _rotationY;
		}

		public function get rotationZ():Number
		{
			return _rotationZ; //(_useDegrees) ? radiansToDegrees(_rotationZ) : _rotationZ;
		}

		/**
		 * px - angle in Radians or Degrees
		 */
		public function set rotationX(px:Number):void
		{
			//var rad:Number = (_useDegrees) ? degreesToRadians(px) : px;
			_rotationX = px;
			setOrientation(createRotationMatrix());
		}

		/**
		 * py - angle in Radians or Degrees
		 */
		public function set rotationY(py:Number):void
		{
			//var rad:Number = (_useDegrees) ? degreesToRadians(py) : py;
			_rotationY = py;
			setOrientation(createRotationMatrix());
		}

		/**
		 * pz - angle in Radians or Degrees
		 */
		public function set rotationZ(pz:Number):void
		{
			//var rad:Number = (_useDegrees) ? degreesToRadians(pz) : pz;
			_rotationZ = pz;
			setOrientation(createRotationMatrix());
		}

		public function pitch(rot:Number):void
		{
			setOrientation(JMatrix3D.getAppendMatrix3D(currentState.orientation, JMatrix3D.getRotationMatrixAxis(rot, Vector3D.X_AXIS)));
		}

		public function yaw(rot:Number):void
		{
			setOrientation(JMatrix3D.getAppendMatrix3D(currentState.orientation, JMatrix3D.getRotationMatrixAxis(rot, Vector3D.Y_AXIS)));
		}

		public function roll(rot:Number):void
		{
			setOrientation(JMatrix3D.getAppendMatrix3D(currentState.orientation, JMatrix3D.getRotationMatrixAxis(rot, Vector3D.Z_AXIS)));
		}

		private function createRotationMatrix():Matrix3D
		{
			var matrix3D:Matrix3D = new Matrix3D();
			matrix3D.appendRotation(_rotationX, Vector3D.X_AXIS);
			matrix3D.appendRotation(_rotationY, Vector3D.Y_AXIS);
			matrix3D.appendRotation(_rotationZ, Vector3D.Z_AXIS);
			return matrix3D;
		}

		public function setOrientation(orient:Matrix3D):void
		{
			_currState.orientation = orient.clone();
			updateInertia();
			updateState();
		}

		public function get x():Number
		{
			return _currState.position.x;
		}

		public function get y():Number
		{
			return _currState.position.y;
		}

		public function get z():Number
		{
			return _currState.position.z;
		}

		public function set x(px:Number):void
		{
			_currState.position.x = px;
			updateState();
		}

		public function set y(py:Number):void
		{
			_currState.position.y = py;
			updateState();
		}

		public function set z(pz:Number):void
		{
			_currState.position.z = pz;
			updateState();
		}

		public function moveTo(pos:Vector3D):void
		{
			_currState.position = pos.clone();
			updateState();
		}

		protected function updateState():void
		{
			_currState.linVelocity.setTo(0,0,0);
			_currState.rotVelocity.setTo(0,0,0);
			copyCurrentStateToOld();
			updateBoundingBox(); // todo: is making invalid boundingboxes, shouldn't this only be update when it's scaled?
			updateObject3D();
			
			if (collisionSystem) {
				collisionSystem.collisionSkinMoved(this);
			}
		}

		public function setLineVelocity(vel:Vector3D):void
		{
			_currState.linVelocity = vel.clone();
		}

		public function setAngleVelocity(angVel:Vector3D):void
		{
			_currState.rotVelocity = angVel.clone();
		}

		public function setLineVelocityAux(vel:Vector3D):void
		{
			_currLinVelocityAux = vel.clone();
		}

		public function setAngleVelocityAux(angVel:Vector3D):void
		{
			_currRotVelocityAux = angVel.clone();
		}

		/**
		 * CallBack from PhysicsSystem to update gravity force only when gravity or mass is dirty.
		 * @param gravity
		 */		
		public function updateGravity(gravity:Vector3D, gravityAxis:int):void
		{
			_gravity = gravity;
			_gravityAxis = gravityAxis;
			
			_gravityForce = JNumber3D.getScaleVector(_gravity, _mass);
		}

		public function addWorldTorque(t:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
			{
				return;
			}
			_torque = _torque.add(t);
			
			if (active) setActive();
		}

		public function addBodyTorque(t:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
				return;

			addWorldTorque(_currState.orientation.transformVector(t), active);
		}

		// functions to add forces in the world coordinate frame
		public function addWorldForce(f:Vector3D, p:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
				return;

			_force = _force.add(f);
			addWorldTorque(p.subtract(_currState.position).crossProduct(f));
			
			if (active) setActive();
		}

		// functions to add forces in the body coordinate frame
		public function addBodyForce(f:Vector3D, p:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
				return;

			f = _currState.orientation.transformVector(f);
			p = _currState.orientation.transformVector(p);
			addWorldForce(f, _currState.position.add(p), active);
		}

		// This just sets all forces etc to zero.
		public function clearForces():void
		{
			_force.setTo(0,0,0);
			_torque.setTo(0,0,0);
		}

		// functions to add impulses in the world coordinate frame
		public function applyWorldImpulse(impulse:Vector3D, pos:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
			{
				return;
			}
			_currState.linVelocity = _currState.linVelocity.add(JNumber3D.getScaleVector(impulse, _invMass));

			var rotImpulse:Vector3D = pos.subtract(_currState.position).crossProduct(impulse);
			rotImpulse = _worldInvInertia.transformVector(rotImpulse);
			_currState.rotVelocity = _currState.rotVelocity.add(rotImpulse);

			if (active) setActive();
		}

		public function applyWorldImpulseAux(impulse:Vector3D, pos:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
			{
				return;
			}
			_currLinVelocityAux = _currLinVelocityAux.add(JNumber3D.getScaleVector(impulse, _invMass));

			var rotImpulse:Vector3D = pos.subtract(_currState.position).crossProduct(impulse);
			rotImpulse = _worldInvInertia.transformVector(rotImpulse);
			_currRotVelocityAux = _currRotVelocityAux.add(rotImpulse);

			if (active) setActive();
		}

		// functions to add impulses in the body coordinate frame
		public function applyBodyWorldImpulse(impulse:Vector3D, delta:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
			{
				return;
			}
			_currState.linVelocity = _currState.linVelocity.add(JNumber3D.getScaleVector(impulse, _invMass));

			var rotImpulse:Vector3D = delta.crossProduct(impulse);
			rotImpulse = _worldInvInertia.transformVector(rotImpulse);
			_currState.rotVelocity = _currState.rotVelocity.add(rotImpulse);

			if (active) setActive();
		}

		public function applyBodyWorldImpulseAux(impulse:Vector3D, delta:Vector3D, active:Boolean = true):void
		{
			if (!_movable)
			{
				return;
			}
			_currLinVelocityAux = _currLinVelocityAux.add(JNumber3D.getScaleVector(impulse, _invMass));

			var rotImpulse:Vector3D = delta.crossProduct(impulse);
			rotImpulse = _worldInvInertia.transformVector(rotImpulse);
			_currRotVelocityAux = _currRotVelocityAux.add(rotImpulse);

			if (active) setActive();
		}
		
		// implementation updates the velocity/angular rotation with the force/torque.
		public function updateVelocity(dt:Number):void
		{
			if (!_movable || !isActive)
				return;

			_currState.linVelocity = _currState.linVelocity.add(JNumber3D.getScaleVector(_force, _invMass * dt));

			var rac:Vector3D = JNumber3D.getScaleVector(_torque, dt);
			rac = _worldInvInertia.transformVector(rac);
			_currState.rotVelocity = _currState.rotVelocity.add(rac);
		}

		/*
		   // implementation updates the position/orientation with the current velocties.
		   public function updatePosition(dt:Number):void
		   {
		   if (!_movable || !isActive)
		   {
		   return;
		   }

		   var angMomBefore:Vector3D = _currState.rotVelocity.clone();
		   angMomBefore = _worldInertia.transformVector(angMomBefore);

		   _currState.position = _currState.position.add(JNumber3D.getScaleVector(_currState.linVelocity, dt));

		   var dir:Vector3D = _currState.rotVelocity.clone();
		   var ang:Number = dir.length;
		   if (ang > 0)
		   {
		   dir.normalize();
		   ang *= dt;
		   var rot:JMatrix3D = JMatrix3D.rotationMatrix(dir.x, dir.y, dir.z, ang);
		   _currState.orientation = JMatrix3D.getMatrix3D(JMatrix3D.multiply(rot, JMatrix3D.getJMatrix3D(_currState.orientation)));
		   updateInertia();
		   }

		   angMomBefore = _worldInvInertia.transformVector(angMomBefore);
		   _currState.rotVelocity = angMomBefore.clone();
		   }
		 */

		// Updates the position with the auxiliary velocities, and zeros them
		public function updatePositionWithAux(dt:Number):void
		{
			if (!_movable || !isActive)
			{
				_currLinVelocityAux.setTo(0,0,0);
				_currRotVelocityAux.setTo(0,0,0);
				return;
			}

			var ga:int = _gravityAxis;
			if (ga != -1)
			{
				var arr:Vector.<Number> = JNumber3D.toArray(_currLinVelocityAux);
				arr[(ga + 1) % 3] *= 0.1;
				arr[(ga + 2) % 3] *= 0.1;
				JNumber3D.copyFromArray(_currLinVelocityAux, arr);
			}

			_currState.position = _currState.position.add(JNumber3D.getScaleVector(_currState.linVelocity.add(_currLinVelocityAux), dt));

			var dir:Vector3D = _currState.rotVelocity.add(_currRotVelocityAux);
			var ang:Number = dir.length * 180 / Math.PI;
			if (ang > 0)
			{
				dir.normalize();
				ang *= dt;


				var rot:Matrix3D = JMatrix3D.getRotationMatrix(dir.x, dir.y, dir.z, ang);
				_currState.orientation = JMatrix3D.getAppendMatrix3D(_currState.orientation, rot);

				updateInertia();
			}

			_currLinVelocityAux.setTo(0,0,0);
			_currRotVelocityAux.setTo(0,0,0);

		}

		// function provided for the use of Physics system
		public function tryToFreeze(dt:Number):void
		{
			if (!_movable || !isActive)
			{
				return;
			}
			
			if (_currState.position.subtract(_lastPositionForDeactivation).length > JConfig.posThreshold)
			{
				_lastPositionForDeactivation = _currState.position.clone();
				_inactiveTime = 0;
				return;
			}

			var ot:Number = JConfig.orientThreshold;
			var deltaMat:Matrix3D = JMatrix3D.getSubMatrix(_currState.orientation, _lastOrientationForDeactivation);

			var cols:Vector.<Vector3D> = JMatrix3D.getCols(deltaMat);

			if (cols[0].length > ot || cols[1].length > ot || cols[2].length > ot)
			{
				_lastOrientationForDeactivation = _currState.orientation.clone();
				_inactiveTime = 0;
				return;
			}

			if (getShouldBeActive())
			{
				return;
			}

			_inactiveTime += dt;
			if (_inactiveTime > JConfig.deactivationTime)
			{
				_lastPositionForDeactivation = _currState.position.clone();
				_lastOrientationForDeactivation = _currState.orientation.clone();
				setInactive();
			}
		}
		
		public function postPhysics(dt:Number):void
		{
			if (!_movable || !isActive)
			{
				return;
			}
			
			limitVel();
			limitAngVel();
			
			updatePositionWithAux(dt);
			updateBoundingBox(); // todo: is making invalid boundingboxes, shouldn't this only be update when it's scaled?
			updateObject3D();
			
			if (collisionSystem) {
				collisionSystem.collisionSkinMoved(this);
			}
			
			clearForces();
			
			//add gravity
			_force = _force.add(_gravityForce);
		}

		public function set mass(m:Number):void
		{
			_mass = m;
			_invMass = 1 / m;
			setInertia(getInertiaProperties(m));
			
			// mass is dirty have to recalculate gravity force
			var physicsSystem:PhysicsSystem = PhysicsSystem.getInstance();
			updateGravity(physicsSystem.gravity, physicsSystem.gravityAxis);
		}

		public function setInertia(matrix3D:Matrix3D):void
		{
			_bodyInertia = matrix3D.clone();
			_bodyInvInertia = JMatrix3D.getInverseMatrix(_bodyInertia.clone());

			updateInertia();
		}

		public function updateInertia():void
		{
			_invOrientation = JMatrix3D.getTransposeMatrix(_currState.orientation);

			_worldInertia = JMatrix3D.getAppendMatrix3D(_invOrientation, JMatrix3D.getAppendMatrix3D(_currState.orientation, _bodyInertia));

			_worldInvInertia = JMatrix3D.getAppendMatrix3D(_invOrientation, JMatrix3D.getAppendMatrix3D(_currState.orientation, _bodyInvInertia));
		}

		// for deactivation
		public var isActive:Boolean;

		// prevent velocity updates etc 
		public function get movable():Boolean
		{
			return _movable;
		}

		public function set movable(mov:Boolean):void
		{
			if (_type == "PLANE" || _type == "TERRAIN" || _type == "TRIANGLEMESH")
				return;
			
			_movable = mov;
			isActive = mov;
			_origMovable = mov;
		}

		public function internalSetImmovable():void
		{
			_origMovable = _movable;
			_movable = false;
		}

		public function internalRestoreImmovable():void
		{
			_movable = _origMovable;
		}

		public function setActive():void
		{
			if (_movable)
			{
				if (isActive) return;
				_inactiveTime = 0;
				isActive = true;
			}
		}

		public function setInactive():void
		{
			if (_movable) {
				_inactiveTime = JConfig.deactivationTime;
				isActive = false;
			}
		}

		// Returns the velocity of a point at body-relative position
		public function getVelocity(relPos:Vector3D):Vector3D
		{
			return _currState.linVelocity.add(_currState.rotVelocity.crossProduct(relPos));
		}

		// As GetVelocity but just uses the aux velocities
		public function getVelocityAux(relPos:Vector3D):Vector3D
		{
			return _currLinVelocityAux.add(_currRotVelocityAux.crossProduct(relPos));
		}

		// indicates if the velocity is above the threshold for freezing
		public function getShouldBeActive():Boolean
		{
			return ((_currState.linVelocity.length > JConfig.velThreshold) || (_currState.rotVelocity.length > JConfig.angVelThreshold));
		}

		public function getShouldBeActiveAux():Boolean
		{
			return ((_currLinVelocityAux.length > JConfig.velThreshold) || (_currRotVelocityAux.length > JConfig.angVelThreshold));
		}

		// damp movement as the body approaches deactivation
		public function dampForDeactivation():void
		{
			_currState.linVelocity.x *= _linVelDamping.x;
			_currState.linVelocity.y *= _linVelDamping.y;
			_currState.linVelocity.z *= _linVelDamping.z;
			_currState.rotVelocity.x *= _rotVelDamping.x;
			_currState.rotVelocity.y *= _rotVelDamping.y;
			_currState.rotVelocity.z *= _rotVelDamping.z;

			_currLinVelocityAux.x *= _linVelDamping.x;
			_currLinVelocityAux.y *= _linVelDamping.y;
			_currLinVelocityAux.z *= _linVelDamping.z;
			_currRotVelocityAux.x *= _rotVelDamping.x;
			_currRotVelocityAux.y *= _rotVelDamping.y;
			_currRotVelocityAux.z *= _rotVelDamping.z;

			var r:Number = 0.5;
			var frac:Number = _inactiveTime / JConfig.deactivationTime;
			if (frac < r)
				return;

			var scale:Number = 1 - ((frac - r) / (1 - r));
			if (scale < 0)
			{
				scale = 0;
			}
			else if (scale > 1)
			{
				scale = 1;
			}

			_currState.linVelocity.scaleBy(scale);
			_currState.rotVelocity.scaleBy(scale);
		}
		
		// function provided for use of physics system. Activates any
		// body in its list if it's moved more than a certain distance,
		// in which case it also clears its list.
		public function doMovementActivations(physicsSystem:PhysicsSystem):void
		{
			if (_bodiesToBeActivatedOnMovement.length == 0 || _currState.position.subtract(_storedPositionForActivation).length < JConfig.posThreshold)
				return;

			for each (var body:RigidBody in _bodiesToBeActivatedOnMovement)
			{
				physicsSystem.activateObject(body);
			}

			_bodiesToBeActivatedOnMovement.length=0;
		}

		// adds the other body to the list of bodies to be activated if
		// this body moves more than a certain distance from either a
		// previously stored position, or the position passed in.
		public function addMovementActivation(pos:Vector3D, otherBody:RigidBody):void
		{
			if (_bodiesToBeActivatedOnMovement.indexOf(otherBody) > -1)
				return;

			if (_bodiesToBeActivatedOnMovement.length == 0)
				_storedPositionForActivation = pos;

			_bodiesToBeActivatedOnMovement.push(otherBody);
		}

		// Marks all constraints/collisions as being unsatisfied
		public function setConstraintsAndCollisionsUnsatisfied():void
		{
			for each (var _constraint:JConstraint in _constraints)
				_constraint.satisfied = false;

			for each (var _collision:CollisionInfo in collisions)
				_collision.satisfied = false;
		}

		public function segmentIntersect(out:CollOutData, seg:JSegment, state:PhysicsState):Boolean
		{
			return false;
		}

		public function getInertiaProperties(m:Number):Matrix3D
		{
			return new Matrix3D();
		}

		protected function updateBoundingBox():void
		{
		}

		public function hitTestObject3D(obj3D:RigidBody):Boolean
		{
			var num1:Number,num2:Number;
			num1 = _currState.position.subtract(obj3D.currentState.position).length;
			num2 = _boundingSphere + obj3D.boundingSphere;

			if (num1 <= num2)
				return true;

			return false;
		}
		
		//disable the collision between two bodies
		public function disableCollisions(body:RigidBody):void
		{
			if (_nonCollidables.indexOf(body) < 0)
				_nonCollidables.push(body);
		}
		
		//enable the collision between disabled bodies
		public function enableCollisions(body:RigidBody):void
		{
			if (_nonCollidables.indexOf(body) >= 0)
				_nonCollidables.splice(_nonCollidables.indexOf(body), 1);
		}
		
		
		//do not call this function youself, this just used in collision system.
		public function addCollideBody(body:RigidBody):void {
			if (_collideBodies.indexOf(body) < 0) {
				
				_collideBodies.push(body);
				
				var event:JCollisionEvent = new JCollisionEvent(JCollisionEvent.COLLISION_START);
				event.body = body;
				this.dispatchEvent(event);
			}
		}
		
		//do not call this function youself, this just used in collision system.
		public function removeCollideBodies(body:RigidBody):void {
			var i:int = _collideBodies.indexOf(body);
			if (i >= 0) {
				
				_collideBodies.splice(i, 1);
				
				var event:JCollisionEvent = new JCollisionEvent(JCollisionEvent.COLLISION_END);
				event.body = body;
				this.dispatchEvent(event);
			}
		}
		
		//add a constraint to this rigid body, do not need call this function yourself,
		//this just used in constraint system
		public function addConstraint(constraint:JConstraint):void
		{
			if (_constraints.indexOf(constraint) < 0)
			{
				_constraints.push(constraint);
			}
		}
		
		//remove a constraint from this rigid body, do not need call this function yourself,
		//this just used in constraint system
		public function removeConstraint(constraint:JConstraint):void
		{
			if (_constraints.indexOf(constraint) >= 0)
			{
				_constraints.splice(_constraints.indexOf(constraint), 1);
			}
		}
		
		
		// copies the current position etc to old - normally called only by physicsSystem.
		public function copyCurrentStateToOld():void
		{
			_oldState.position = _currState.position.clone();
			_oldState.orientation = _currState.orientation.clone();
			_oldState.linVelocity = _currState.linVelocity.clone();
			_oldState.rotVelocity = _currState.rotVelocity.clone();
		}

		// Copy our current state into the stored state
		public function storeState():void
		{
			_storeState.position = _currState.position.clone();
			_storeState.orientation = _currState.orientation.clone();
			_storeState.linVelocity = _currState.linVelocity.clone();
			_storeState.rotVelocity = _currState.rotVelocity.clone();
		}

		// restore from the stored state into our current state.
		public function restoreState():void
		{
			_currState.position = _storeState.position.clone();
			_currState.orientation = _storeState.orientation.clone();
			_currState.linVelocity = _storeState.linVelocity.clone();
			_currState.rotVelocity = _storeState.rotVelocity.clone();
			
			updateInertia();
		}

		// the "working" state
		public function get currentState():PhysicsState
		{
			return _currState;
		}

		// the previous state - copied explicitly using copyCurrentStateToOld
		public function get oldState():PhysicsState
		{
			return _oldState;
		}

		public function get id():int
		{
			return _id;
		}

		public function get type():String
		{
			return _type;
		}

		public function get skin():ISkin3D
		{
			return _skin;
		}

		public function get boundingSphere():Number
		{
			return _boundingSphere;
		}

		public function get boundingBox():JAABox
		{
			return _boundingBox;
		}

		// force in world frame
		public function get force():Vector3D
		{
			return _force;
		}

		// torque in world frame
		public function get mass():Number
		{
			return _mass;
		}

		public function get invMass():Number
		{
			return _invMass;
		}

		// inertia tensor in world space
		public function get worldInertia():Matrix3D
		{
			return _worldInertia;
		}

		// inverse inertia in world frame
		public function get worldInvInertia():Matrix3D
		{
			return _worldInvInertia;
		}

		public function get nonCollidables():Vector.<RigidBody>
		{
			return _nonCollidables;
		}
		
		public function get constraints():Vector.<JConstraint> {
			return _constraints;
		}
		
		//every dimension should be set to 0-1;
		public function set linVelocityDamping(vel:Vector3D):void
		{
			_linVelDamping.x = JMath3D.getLimiteNumber(vel.x, 0, 1);
			_linVelDamping.y = JMath3D.getLimiteNumber(vel.y, 0, 1);
			_linVelDamping.z = JMath3D.getLimiteNumber(vel.z, 0, 1);
		}

		public function get linVelocityDamping():Vector3D
		{
			return _linVelDamping;
		}

		//every dimension should be set to 0-1;
		public function set rotVelocityDamping(vel:Vector3D):void
		{
			_rotVelDamping.x = JMath3D.getLimiteNumber(vel.x, 0, 1);
			_rotVelDamping.y = JMath3D.getLimiteNumber(vel.y, 0, 1);
			_rotVelDamping.z = JMath3D.getLimiteNumber(vel.z, 0, 1);
		}

		public function get rotVelocityDamping():Vector3D
		{
			return _rotVelDamping;
		}

		//limit the max value of body's line velocity
		public function set maxLinVelocities(vel:Vector3D):void
		{
			_maxLinVelocities = new Vector3D(Math.abs(vel.x),Math.abs(vel.y),Math.abs(vel.z));
		}

		public function get maxLinVelocities():Vector3D
		{
			return _maxLinVelocities;
		}

		//limit the max value of body's angle velocity
		public function set maxRotVelocities(vel:Vector3D):void
		{
			_maxRotVelocities = new Vector3D(Math.abs(vel.x),Math.abs(vel.y),Math.abs(vel.z));
		}

		public function get maxRotVelocities():Vector3D
		{
			return _maxRotVelocities;
		}

		private function limitVel():void
		{
			_currState.linVelocity.x = JMath3D.getLimiteNumber(_currState.linVelocity.x, -_maxLinVelocities.x, _maxLinVelocities.x);
			_currState.linVelocity.y = JMath3D.getLimiteNumber(_currState.linVelocity.y, -_maxLinVelocities.y, _maxLinVelocities.y);
			_currState.linVelocity.z = JMath3D.getLimiteNumber(_currState.linVelocity.z, -_maxLinVelocities.z, _maxLinVelocities.z);
		}

		private function limitAngVel():void
		{
			var fx:Number = Math.abs(_currState.rotVelocity.x) / _maxRotVelocities.x;
			var fy:Number = Math.abs(_currState.rotVelocity.y) / _maxRotVelocities.y;
			var fz:Number = Math.abs(_currState.rotVelocity.z) / _maxRotVelocities.z;
			var f:Number = Math.max(fx, fy, fz);

			if (f > 1)
				_currState.rotVelocity = JNumber3D.getDivideVector(_currState.rotVelocity, f);
		}

		public function getTransform():Matrix3D
		{
			return _skin ? _skin.transform : null;
		}

		//update skin
		private function updateObject3D():void
		{
			if (_skin)
			{
				_skin.transform = JMatrix3D.getAppendMatrix3D(_currState.orientation, JMatrix3D.getTranslationMatrix(_currState.position.x, _currState.position.y, _currState.position.z));
			}
		}

		public function get material():MaterialProperties
		{
			return _material;
		}

		//coefficient of elasticity
		public function get restitution():Number
		{
			return _material.restitution;
		}

		public function set restitution(restitution:Number):void
		{
			_material.restitution = JMath3D.getLimiteNumber(restitution, 0, 1);
		}

		//coefficient of friction
		public function get friction():Number
		{
			return _material.friction;
		}

		public function set friction(friction:Number):void
		{
			_material.friction = JMath3D.getLimiteNumber(friction, 0, 1);
		}
	}
}