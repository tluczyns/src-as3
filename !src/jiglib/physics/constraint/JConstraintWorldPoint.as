package jiglib.physics.constraint {

	import flash.geom.Vector3D;
	
	import jiglib.math.*;
	import jiglib.physics.RigidBody;
	import jiglib.physics.PhysicsSystem;
	import jiglib.collision.CollisionInfo;
	
	// Constrains a point within a rigid body to remain at a fixed world point
	public class JConstraintWorldPoint extends JConstraint {
		
		private const minVelForProcessing:Number = 0.001;
		private const allowedDeviation:Number = 0.01;
		private const timescale:Number = 4;
		
		private var _body:RigidBody;
		private var _pointOnBody:Vector3D;
		private var _worldPosition:Vector3D;
		
		// pointOnBody is in body coords
		public function JConstraintWorldPoint(body:RigidBody, pointOnBody:Vector3D, worldPosition:Vector3D) {
			super();
			_body = body;
			_pointOnBody = pointOnBody;
			_worldPosition = worldPosition;
			
			_constraintEnabled = false;
			enableConstraint();
		}
		
		public function set worldPosition(pos:Vector3D):void {
			_worldPosition = pos;
		}
		
		public function get worldPosition():Vector3D {
			return _worldPosition;
		}
		
		override public function enableConstraint():void
		{
			if (_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = true;
			_body.addConstraint(this);
			PhysicsSystem.getInstance().addConstraint(this);
		}
		
		override public function disableConstraint():void
		{
			if (!_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = false;
			_body.removeConstraint(this);
			PhysicsSystem.getInstance().removeConstraint(this);
		}
		
		override public function apply(dt:Number):Boolean {
			this.satisfied = true;

			var deviationDistance:Number,normalVel:Number,denominator:Number,normalImpulse:Number,dot:Number;
			var worldPos:Vector3D,R:Vector3D,currentVel:Vector3D,desiredVel:Vector3D,deviationDir:Vector3D,deviation:Vector3D,N:Vector3D,tempV:Vector3D;
			
			worldPos = _body.currentState.orientation.transformVector(_pointOnBody);
			worldPos = worldPos.add( _body.currentState.position);
			R = worldPos.subtract(_body.currentState.position);
			currentVel = _body.currentState.linVelocity.add(_body.currentState.rotVelocity.crossProduct(R));
			
			deviation = worldPos.subtract(_worldPosition);
			deviationDistance = deviation.length;
			if (deviationDistance > allowedDeviation) {
				deviationDir = JNumber3D.getDivideVector(deviation, deviationDistance);
				desiredVel = JNumber3D.getScaleVector(deviationDir, (allowedDeviation - deviationDistance) / (timescale * dt));
			} else {
				desiredVel = new Vector3D();
			}
			
			N = currentVel.subtract(desiredVel);
			normalVel = N.length;
			if (normalVel < minVelForProcessing) {
				return false;
			}
			N = JNumber3D.getDivideVector(N, normalVel);
			
			tempV = R.crossProduct(N);
			tempV = _body.worldInvInertia.transformVector(tempV);
			denominator = _body.invMass + N.dotProduct(tempV.crossProduct(R));
			 
			if (denominator < JMath3D.NUM_TINY) {
				return false;
			}
			 
			normalImpulse = -normalVel / denominator;
			
			_body.applyWorldImpulse(JNumber3D.getScaleVector(N, normalImpulse), worldPos, false);
			
			_body.setConstraintsAndCollisionsUnsatisfied();
			this.satisfied = true;
			
			return true;
		}
	}
}
