package jiglib.collision
{
	import flash.geom.Vector3D;

	import jiglib.physics.MaterialProperties;

	public class CollisionInfo
	{
		public var mat:MaterialProperties = new MaterialProperties();
		public var objInfo:CollDetectInfo;
		public var dirToBody:Vector3D;
		public var pointInfo:Vector.<CollPointInfo>;
		public var satisfied:Boolean;
	}
}
