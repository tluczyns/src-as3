package jiglib.geometry {
	import flash.geom.Vector3D;
	
	import jiglib.data.EdgeData;
	import jiglib.math.JNumber3D;
	import jiglib.math.JMath3D;
	
	// An axis-aligned box
	public class JAABox {
		
		public var minPos:Vector3D;
		public var maxPos:Vector3D;
		
		public function JAABox() {
			clear();
		}
		
		public function get sideLengths():Vector3D {
			var pos:Vector3D = maxPos.clone();
			pos = pos.subtract( minPos ); 
			return pos;
		}
		
		public function get centrePos():Vector3D {
			var pos:Vector3D = minPos.clone();
			return JNumber3D.getScaleVector(pos.add(maxPos), 0.5);
		}
		
		public function getAllPoints():Vector.<Vector3D> {
			var center:Vector3D,halfSide:Vector3D;
			var points:Vector.<Vector3D>;
			center = this.centrePos;
			halfSide = JNumber3D.getScaleVector(this.sideLengths, 0.5);
			points = new Vector.<Vector3D>(8, true);
			points[0] = center.add(new Vector3D(halfSide.x, -halfSide.y, halfSide.z));
			points[1] = center.add(new Vector3D(halfSide.x, halfSide.y, halfSide.z));
			points[2] = center.add(new Vector3D(-halfSide.x, -halfSide.y, halfSide.z));
			points[3] = center.add(new Vector3D(-halfSide.x, halfSide.y, halfSide.z));
			points[4] = center.add(new Vector3D(-halfSide.x, -halfSide.y, -halfSide.z));
			points[5] = center.add(new Vector3D(-halfSide.x, halfSide.y, -halfSide.z));
			points[6] = center.add(new Vector3D(halfSide.x, -halfSide.y, -halfSide.z));
			points[7] = center.add(new Vector3D(halfSide.x, halfSide.y, -halfSide.z));
			
			return points;
		}
		
		public function get edges():Vector.<EdgeData> {
			return Vector.<EdgeData>([
			new EdgeData( 0, 1 ), new EdgeData( 0, 2 ), new EdgeData( 0, 6 ),
			new EdgeData( 2, 3 ), new EdgeData( 2, 4 ), new EdgeData( 6, 7 ),
			new EdgeData( 6, 4 ), new EdgeData( 1, 3 ), new EdgeData( 1, 7 ),
			new EdgeData( 3, 5 ), new EdgeData( 7, 5 ), new EdgeData( 4, 5 )]);
		}
		
		public function getRadiusAboutCentre():Number {
			return 0.5 * (maxPos.subtract(minPos).length);
		}
		
		public function move(delta:Vector3D):void {
			minPos.add(delta);
			maxPos.add(delta);
		}
		
		public function clear():void {
			var huge:Number=JMath3D.NUM_HUGE;
			minPos = new Vector3D(huge, huge, huge);
			maxPos = new Vector3D( -huge, -huge, -huge);
		}
		
		public function clone():JAABox {
			var aabb:JAABox = new JAABox();
			aabb.minPos = this.minPos.clone();
			aabb.maxPos = this.maxPos.clone();
			return aabb;
		}
		
		
		
		public function addPoint(pos:Vector3D):void {
			var tiny:Number=JMath3D.NUM_TINY;
			if (pos.x < minPos.x) minPos.x = pos.x - tiny;
			if (pos.x > maxPos.x) maxPos.x = pos.x + tiny;
			if (pos.y < minPos.y) minPos.y = pos.y - tiny;
			if (pos.y > maxPos.y) maxPos.y = pos.y + tiny;
			if (pos.z < minPos.z) minPos.z = pos.z - tiny;
			if (pos.z > maxPos.z) maxPos.z = pos.z + tiny;
		}
		
		public function addBox(box:JBox):void {
			var pts:Vector.<Vector3D> = box.getCornerPoints(box.currentState);
			addPoint(pts[0]);
			addPoint(pts[1]);
			addPoint(pts[2]);
			addPoint(pts[3]);
			addPoint(pts[4]);
			addPoint(pts[5]);
			addPoint(pts[6]);
			addPoint(pts[7]);
		}
		
		
		// todo: the extra if doesn't make sense and bugs the size, also shouldn't this called once and if scaled? 
		public function addSphere(sphere:JSphere):void {
			//if (sphere.currentState.position.x - sphere.radius < _minPos.x) {
				minPos.x = (sphere.currentState.position.x - sphere.radius) - 1;
			//}
			//if (sphere.currentState.position.x + sphere.radius > _maxPos.x) {
				maxPos.x = (sphere.currentState.position.x + sphere.radius) + 1;
			//}
			
			//if (sphere.currentState.position.y - sphere.radius < _minPos.y) {
				minPos.y = (sphere.currentState.position.y - sphere.radius) - 1;
			//}
			//if (sphere.currentState.position.y + sphere.radius > _maxPos.y) {
				maxPos.y = (sphere.currentState.position.y + sphere.radius) + 1;
			//}
			
			//if (sphere.currentState.position.z - sphere.radius < _minPos.z) {
				minPos.z = (sphere.currentState.position.z - sphere.radius) - 1;
			//}
			//if (sphere.currentState.position.z + sphere.radius > _maxPos.z) {
				maxPos.z = (sphere.currentState.position.z + sphere.radius) + 1;
			//}
			//trace("jaabox - add sphere:", _minPos.x,_minPos.y,_minPos.z,_maxPos.x,_maxPos.y,_maxPos.z);
			
			// todo: remove this code
				/*
			if (_minPos.x > _maxPos.x) {
				trace("minpos x ouch");
			}
			if (_minPos.y > _maxPos.y) {
				trace("minpos y ouch");
			}
			if (_minPos.z > _maxPos.z) {
				trace("minpos z ouch");
			}
			*/

		}
		
		public function addCapsule(capsule:JCapsule):void {
			var pos:Vector3D = capsule.getBottomPos(capsule.currentState);
			if (pos.x - capsule.radius < minPos.x) {
				minPos.x = (pos.x - capsule.radius) - 1;
			}
			if (pos.x + capsule.radius > maxPos.x) {
				maxPos.x = (pos.x + capsule.radius) + 1;
			}
			
			if (pos.y - capsule.radius < minPos.y) {
				minPos.y = (pos.y - capsule.radius) - 1;
			}
			if (pos.y + capsule.radius > maxPos.y) {
				maxPos.y = (pos.y + capsule.radius) + 1;
			}
			
			if (pos.z - capsule.radius < minPos.z) {
				minPos.z = (pos.z - capsule.radius) - 1;
			}
			if (pos.z + capsule.radius > maxPos.z) {
				maxPos.z = (pos.z + capsule.radius) + 1;
			}
			
			pos = capsule.getEndPos(capsule.currentState);
			if (pos.x - capsule.radius < minPos.x) {
				minPos.x = (pos.x - capsule.radius) - 1;
			}
			if (pos.x + capsule.radius > maxPos.x) {
				maxPos.x = (pos.x + capsule.radius) + 1;
			}
			
			if (pos.y - capsule.radius < minPos.y) {
				minPos.y = (pos.y - capsule.radius) - 1;
			}
			if (pos.y + capsule.radius > maxPos.y) {
				maxPos.y = (pos.y + capsule.radius) + 1;
			}
			
			if (pos.z - capsule.radius < minPos.z) {
				minPos.z = (pos.z - capsule.radius) - 1;
			}
			if (pos.z + capsule.radius > maxPos.z) {
				maxPos.z = (pos.z + capsule.radius) + 1;
			}
		}
		
		public function addSegment(seg:JSegment):void {
			addPoint(seg.origin);
			addPoint(seg.getEnd());
		}
		
		public function overlapTest(box:JAABox):Boolean {
			return (
				(minPos.z >= box.maxPos.z) ||
				(maxPos.z <= box.minPos.z) ||
				(minPos.y >= box.maxPos.y) ||
				(maxPos.y <= box.minPos.y) ||
				(minPos.x >= box.maxPos.x) ||
				(maxPos.x <= box.minPos.x) ) ? false : true;
		}
		
		public function isPointInside(pos:Vector3D):Boolean {
			return ((pos.x >= minPos.x) && 
				    (pos.x <= maxPos.x) && 
				    (pos.y >= minPos.y) && 
				    (pos.y <= maxPos.y) && 
				    (pos.z >= minPos.z) && 
				    (pos.z <= maxPos.z));
		}
		
		public function segmentAABoxOverlap(seg:JSegment):Boolean {
			var jDir:int,kDir:int,i:int,iFace:int;
			var frac:Number,dist0:Number,dist1:Number,tiny:Number=JMath3D.NUM_TINY;
			
			var pt:Vector.<Number>,minPosArr:Vector.<Number>,maxPosArr:Vector.<Number>,p0:Vector.<Number>,p1:Vector.<Number>,faceOffsets:Vector.<Number>;
			minPosArr = JNumber3D.toArray(minPos);
			maxPosArr = JNumber3D.toArray(maxPos);
			p0 = JNumber3D.toArray(seg.origin);
			p1 = JNumber3D.toArray(seg.getEnd());
			for (i = 0; i < 3; i++ ) {
				jDir = (i + 1) % 3;
				kDir = (i + 2) % 3;
				faceOffsets = Vector.<Number>([minPosArr[i], maxPosArr[i]]);
				
				for (iFace = 0 ; iFace < 2 ; iFace++) {
					dist0 = p0[i] - faceOffsets[iFace];
				    dist1 = p1[i] - faceOffsets[iFace];
				    frac = -1;
					if (dist0 * dist1 < -tiny)
						frac = -dist0 / (dist1 - dist0);
				    else if (Math.abs(dist0) < tiny)
						frac = 0;
				    else if (Math.abs(dist1) < tiny)
						frac = 1;
						
					if (frac >= 0) {
						pt = JNumber3D.toArray(seg.getPoint(frac));
						if((pt[jDir] > minPosArr[jDir] - tiny) && 
						(pt[jDir] < maxPosArr[jDir] + tiny) && 
						(pt[kDir] > minPosArr[kDir] - tiny) && 
						(pt[kDir] < maxPosArr[kDir] + tiny)) {
							return true;
						}
					}
				}
			}
			return false;
		}
	}
}