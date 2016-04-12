package baseAway3D {
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;

	public class Utils {
		
		public static var toRadians:Number = Math.PI / 180;
		public static var toDegrees:Number = 180 / Math.PI;
		
		public function Utils() { }
		
		public static function getAngleSmallestDifference(angle1: Number, angle2: Number): Number {
			var diff: Number;
			angle1 = (angle1 + 360) % 360;
			angle2 = (angle2 + 360) % 360;
			if (Math.abs(angle1 - angle2) > 180) {
				if (angle1 < 180) { //angle2 jest większe od 180
					diff = - (angle1 + (360 - angle2));
				} else { //angle1 jest większe od 180
					diff = angle2 + (360 - angle1);
				}
			} else {
				diff = angle2 - angle1;
			}
			return diff;
		}
		
		public static function getVertexInFrontOfObject3D(object3D: Object3D, distance: Number, addAngleY: Number = 0, addPosY: Number = 0, object3DRotationX: Number = -1000, object3DRotationY: Number = -1000): Vertex {
			(object3DRotationX != -1000) ? object3DRotationX = object3D.rotationX : null;
			(object3DRotationY != -1000) ? object3DRotationY = object3D.rotationY : null;
			var v: Vertex = new Vertex();
			var objRotationX: Number = (object3D.rotationX + addAngleY) * Utils.toRadians;
			var objRotationY: Number = object3D.rotationY * Utils.toRadians;
			v.y = object3D.y + addPosY + distance * Math.sin(objRotationX);
			var distanceHorizontal: Number = Math.cos(objRotationX) * distance; 
			v.x = object3D.x + distanceHorizontal * Math.sin(objRotationY);
			v.z = object3D.z + distanceHorizontal * Math.cos(objRotationY);
			return v;
		}
		
		public static function getDistanceBeetweenPointAndVector(distancePoint: Number3D, vectorMainStartPoint: Number3D, vectorMain: Number3D): Number {
			var squaredDistance: Number;
			var vectorBetweenDistancePointAndStartPoint: Number3D = new Number3D();
			vectorBetweenDistancePointAndStartPoint.sub(distancePoint, vectorMainStartPoint);
			var scalarVectorBetweenDistancePointAndStartPointAndVectorMain: Number = vectorBetweenDistancePointAndStartPoint.dot(vectorMain);
			if (scalarVectorBetweenDistancePointAndStartPointAndVectorMain < 0) {
				squaredDistance = vectorBetweenDistancePointAndStartPoint.dot(vectorBetweenDistancePointAndStartPoint);
			} else {
				var projectionOfDistancePointOnVectorMain: Number3D = new Number3D();
				projectionOfDistancePointOnVectorMain.scale(vectorMain, scalarVectorBetweenDistancePointAndStartPointAndVectorMain / vectorMain.dot(vectorMain));
				projectionOfDistancePointOnVectorMain.add(vectorMainStartPoint, projectionOfDistancePointOnVectorMain)
				var vectorBetweenDistancePointAndProjectionOfDistancePointOnVectorMain: Number3D = new Number3D();
				vectorBetweenDistancePointAndProjectionOfDistancePointOnVectorMain.sub(distancePoint, projectionOfDistancePointOnVectorMain);
				squaredDistance = vectorBetweenDistancePointAndProjectionOfDistancePointOnVectorMain.dot(vectorBetweenDistancePointAndProjectionOfDistancePointOnVectorMain);
			}
			return Math.pow(squaredDistance, 0.5);
		}
	}
	
}