﻿package jiglib.physics.constraint
{

	import flash.geom.Vector3D;
	
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	import jiglib.physics.PhysicsSystem;

	// Constraints a point on one body to be fixed to a point on another body
	public class JConstraintMaxDistance extends JConstraint
	{

		private const _maxVelMag:Number = 20;
		private const _minVelForProcessing:Number = 0.01;

		private var _body0:RigidBody;
		private var _body1:RigidBody;
		private var _body0Pos:Vector3D;
		private var _body1Pos:Vector3D;
		private var _maxDistance:Number;

		private var r0:Vector3D;
		private var r1:Vector3D;
		private var _worldPos:Vector3D;
		private var _currentRelPos0:Vector3D;

		public function JConstraintMaxDistance(body0:RigidBody, body0Pos:Vector3D, body1:RigidBody, body1Pos:Vector3D, maxDistance:Number = 1)
		{
			super();
			_body0 = body0;
			_body0Pos = body0Pos;
			_body1 = body1;
			_body1Pos = body1Pos;
			_maxDistance = maxDistance;
			
			_constraintEnabled = false;
			enableConstraint();
		}
		
		override public function enableConstraint():void
		{
			if (_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = true;
			_body0.addConstraint(this);
			_body1.addConstraint(this);
			PhysicsSystem.getInstance().addConstraint(this);
		}
		
		override public function disableConstraint():void
		{
			if (!_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = false;
			_body0.removeConstraint(this);
			_body1.removeConstraint(this);
			PhysicsSystem.getInstance().removeConstraint(this);
		}

		override public function preApply(dt:Number):void
		{
			this.satisfied = false;

			r0 = _body0.currentState.orientation.transformVector(_body0Pos);
			r1 = _body1.currentState.orientation.transformVector(_body1Pos);

			var worldPos0:Vector3D,worldPos1:Vector3D;
			worldPos0 = _body0.currentState.position.add(r0);
			worldPos1 = _body1.currentState.position.add(r1);
			_worldPos = JNumber3D.getScaleVector(worldPos0.add(worldPos1), 0.5);

			_currentRelPos0 = worldPos0.subtract(worldPos1);
		}

		override public function apply(dt:Number):Boolean
		{
			this.satisfied = true;

			if (!_body0.isActive && !_body1.isActive)
			{
				return false;
			}

			var clampedRelPos0Mag:Number,normalVel:Number,denominator:Number,tiny:Number=JMath3D.NUM_TINY;
			var currentVel0:Vector3D,currentVel1:Vector3D,predRelPos0:Vector3D,clampedRelPos0:Vector3D,desiredRelVel0:Vector3D,Vr:Vector3D,N:Vector3D,tempVec1:Vector3D,tempVec2:Vector3D,normalImpulse:Vector3D;
			
			currentVel0 = _body0.getVelocity(r0);
			currentVel1 = _body1.getVelocity(r1);

			predRelPos0 = _currentRelPos0.add(JNumber3D.getScaleVector(currentVel0.subtract(currentVel1), dt));
			clampedRelPos0 = predRelPos0.clone();
			clampedRelPos0Mag = clampedRelPos0.length;
			if (clampedRelPos0Mag <= tiny)
			{
				return false;
			}
			if (clampedRelPos0Mag > _maxDistance)
			{
				clampedRelPos0 = JNumber3D.getScaleVector(clampedRelPos0, _maxDistance / clampedRelPos0Mag);
			}

			desiredRelVel0 = JNumber3D.getDivideVector(clampedRelPos0.subtract(_currentRelPos0), dt);
			Vr = currentVel0.subtract(currentVel1).subtract(desiredRelVel0);

			normalVel = Vr.length;
			if (normalVel > _maxVelMag)
			{
				Vr = JNumber3D.getScaleVector(Vr, _maxVelMag / normalVel);
				normalVel = _maxVelMag;
			}
			else if (normalVel < _minVelForProcessing)
			{
				return false;
			}

			N = JNumber3D.getDivideVector(Vr, normalVel);
			tempVec1 = r0.crossProduct(N);
			tempVec1 = _body0.worldInvInertia.transformVector(tempVec1);
			tempVec2 = r1.crossProduct(N);
			tempVec2 = _body1.worldInvInertia.transformVector(tempVec2);
			denominator = _body0.invMass + _body1.invMass + N.dotProduct(tempVec1.crossProduct(r0)) + N.dotProduct(tempVec2.crossProduct(r1));
			if (denominator < tiny)
			{
				return false;
			}

			normalImpulse = JNumber3D.getScaleVector(N, -normalVel / denominator);
			_body0.applyWorldImpulse(normalImpulse, _worldPos, false);
			_body1.applyWorldImpulse(JNumber3D.getScaleVector(normalImpulse, -1), _worldPos, false);

			_body0.setConstraintsAndCollisionsUnsatisfied();
			_body1.setConstraintsAndCollisionsUnsatisfied();
			this.satisfied = true;
			return true;
		}
	}

}