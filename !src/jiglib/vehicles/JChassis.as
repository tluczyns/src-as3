package jiglib.vehicles
{
	import jiglib.geometry.JBox;
	import jiglib.plugin.ISkin3D;

	public class JChassis extends JBox
	{

		private var _car:JCar;

		public function JChassis(car:JCar, skin:ISkin3D, width:Number = 40, depth:Number = 70, height:Number = 30)
		{
			super(skin, width, depth, height);

			_car = car;
		}

		public function get car():JCar
		{
			return _car;
		}

		override public function postPhysics(dt:Number):void
		{
			super.postPhysics(dt);
			_car.addExternalForces(dt);
			_car.postPhysics(dt);
		}
	}
}
