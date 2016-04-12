package jiglib.physics.constraint
{

	public class JConstraint
	{

		public var satisfied:Boolean;
		protected var _constraintEnabled:Boolean;

		public function JConstraint()
		{
		}

		// prepare for applying constraints - the subsequent calls to
		// apply will all occur with a constant position i.e. precalculate
		// everything possible
		public function preApply(dt:Number):void
		{
			satisfied = false;
		}

		// apply the constraint by adding impulses. Return value
		// indicates if any impulses were applied. If impulses were applied
		// the derived class should call SetConstraintsUnsatisfied() on each
		// body that is involved.
		public function apply(dt:Number):Boolean
		{
			return false;
		}

		// register with the physics system
		public function enableConstraint():void
		{
		}

		// deregister from the physics system
		public function disableConstraint():void
		{
		}

		// are we registered with the physics system?
		public function get constraintEnabled():Boolean
		{
			return _constraintEnabled;
		}
	}

}
