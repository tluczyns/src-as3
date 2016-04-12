package jiglib.physics
{

	public class MaterialProperties
	{

		public var restitution:Number;
		public var friction:Number;

		public function MaterialProperties(_restitution:Number = 0.2, _friction:Number = 0.5)
		{
			restitution = _restitution;
			friction = _friction;
		}
	}
}
