package jiglib.collision
{
	import flash.geom.Vector3D;
	
	import jiglib.data.CollOutBodyData;
	import jiglib.geometry.JAABox;
	import jiglib.geometry.JSegment;
	import jiglib.math.JMath3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;

	public class CollisionSystemGrid extends CollisionSystemAbstract
	{
		private var gridEntries 	: Vector.<CollisionSystemGridEntry>;		
		
		private var overflowEntries	: CollisionSystemGridEntry;
		
		private var nx				: int;
		private var ny				: int;
		private var nz				: int;
		
		private var dx				: Number;
		private var dy				: Number;
		private var dz				: Number;
		
		private var sizeX			: Number;
		private var sizeY			: Number;
		private var sizeZ			: Number;
		
		// minimum of the grid deltas
		private var minDelta		: Number;

		/*
		* Initializes a new CollisionSystem which uses a grid to speed up collision detection.
		* Use this system for larger scenes with many objects.
		* @param sx start point of grid in X axis.
		* @param sy start point of grid in Y axis.
		* @param sz start point of grid in Z axis.
		* @param nx Number of GridEntries in X Direction.
		* @param ny Number of GridEntries in Y Direction.
		* @param nz Number of GridEntries in Z Direction.
		* @param dx Size of a single GridEntry in X Direction.
		* @param dy Size of a single GridEntry in Y Direction.
		* @param dz Size of a single GridEntry in Z Direction.
		*/
		public function CollisionSystemGrid(sx:Number = 0, sy:Number = 0, sz:Number = 0, nx:int = 20, ny:int = 20, nz:int = 20, dx:Number = 200, dy:Number = 200, dz:Number = 200)
		{
			super();
			
			this.nx = nx; this.ny = ny; this.nz = nz;
			this.dx = dx; this.dy = dy; this.dz = dz;
			this.sizeX = nx * dx;
			this.sizeY = ny * dy;
			this.sizeZ = nz * dz;
			this.minDelta = Math.min(dx, dy, dz);
			
			startPoint = new Vector3D(sx, sy, sz);
			
			gridEntries = new Vector.<CollisionSystemGridEntry>(nx*ny*nz,true);
			
			var len:int=gridEntries.length;
			for (var j:int = 0; j < len; ++j)
			{
				var gridEntry:CollisionSystemGridEntry = new CollisionSystemGridEntry(null);
				gridEntry.gridIndex = j;
				gridEntries[j]=gridEntry;
			}
			
			overflowEntries = new CollisionSystemGridEntry(null);
			overflowEntries.gridIndex = -1;
		}
		
		private function calcIndex(i:int, j:int, k:int):int
		{
			var _i:int = i % nx;
			var _j:int = j % ny;
			var _k:int = k % nz;
			
			return (_i + nx * _j + (nx + ny) * _k);
		}
		
		private function calcGridForSkin3(colBody:RigidBody):Vector3D
		{
			var i:int;var j:int;var k:int;
			var sides:Vector3D = colBody.boundingBox.sideLengths;
			
			if ((sides.x > dx) || (sides.y > dy) || (sides.z > dz))
			{
				i = j = k = -1;
				return new Vector3D(i,j,k);
			}
			
			var min:Vector3D = colBody.boundingBox.minPos.clone();
			min.x = JMath3D.getLimiteNumber(min.x, startPoint.x, startPoint.x + sizeX);
			min.y = JMath3D.getLimiteNumber(min.y, startPoint.y, startPoint.y + sizeY);
			min.z = JMath3D.getLimiteNumber(min.z, startPoint.z, startPoint.z + sizeZ);
			
			i = int( ((min.x - startPoint.x) / dx) % nx);
			j = int( ((min.y - startPoint.y) / dy) % ny);
			k = int( ((min.z - startPoint.z) / dz) % nz);
			
			return new Vector3D(i,j,k);
		}
		
		
		public function calcGridForSkin6(colBody:RigidBody):Object
		{
			var tempStoreObject:Object = new Object;
			var i:int;var j:int;var k:int;
			var fi:Number;var fj:Number;var fk:Number;
			
			var sides:Vector3D = colBody.boundingBox.sideLengths;
			
			if ((sides.x > dx) || (sides.y > dy) || (sides.z > dz))
			{
				//trace("calcGridForSkin6 -- Rigidbody to big for gridsystem - putting it into overflow list (lengths,type,id):", sides.x,sides.y,sides.z,colBody.type,colBody.id,colBody.boundingBox.minPos,colBody.boundingBox.maxPos);
				i = j = k = -1;
				fi = fj = fk = 0.0;
				tempStoreObject.i = i; tempStoreObject.j = j; tempStoreObject.k = k; tempStoreObject.fi = fi; tempStoreObject.fj = fj; tempStoreObject.fk = fk;
				return tempStoreObject;
			}
			
			var min:Vector3D = colBody.boundingBox.minPos.clone();

			min.x = JMath3D.getLimiteNumber(min.x, startPoint.x, startPoint.x + sizeX);
			min.y = JMath3D.getLimiteNumber(min.y, startPoint.y, startPoint.y + sizeY);
			min.z = JMath3D.getLimiteNumber(min.z, startPoint.z, startPoint.z + sizeZ);
			
			fi = (min.x - startPoint.x) / dx;
			fj = (min.y - startPoint.y) / dy;
			fk = (min.z - startPoint.z) / dz;
			
			i = int(fi);
			j = int(fj);
			k = int(fk);
			
			if (i < 0) { i = 0; fi = 0.0; }
			else if (i >= int(nx)) { i = 0; fi = 0.0; }
			else fi -= Number(i);
			
			if (j < 0) { j = 0; fj = 0.0; }
			else if (j >= int(ny)) { j = 0; fj = 0.0; }
			else fj -= Number(j);
			
			if (k < 0) { k = 0; fk = 0.0; }
			else if (k >= int(nz)) { k = 0; fk = 0.0; }
			else fk -= Number(k);
			
			tempStoreObject.i = i; tempStoreObject.j = j; tempStoreObject.k = k; tempStoreObject.fi = fi; tempStoreObject.fj = fj; tempStoreObject.fk = fk;
			//trace(i,j,k,fi,fj,fk);
			//trace(colBody.x,colBody.y,colBody.z);
			return tempStoreObject;
		}

		
		private function calcGridIndexForBody(colBody:RigidBody):int
		{
			var tempStoreVector:Vector3D = calcGridForSkin3(colBody);
			
			if (tempStoreVector.x == -1) return -1;
			return calcIndex(tempStoreVector.x, tempStoreVector.y, tempStoreVector.z);
		}
		
		override public function addCollisionBody(body:RigidBody):void
		{
			if (collBody.indexOf(body) < 0)
				collBody.push(body);
			
			body.collisionSystem = this;

			// also do the grid stuff - for now put it on the overflow list
			var entry:CollisionSystemGridEntry = new CollisionSystemGridEntry(body);
			body.externalData = entry;
			
			// add entry to the start of the list
			CollisionSystemGridEntry.insertGridEntryAfter(entry, overflowEntries);
			collisionSkinMoved(body);
		}
			
		// not tested yet
		override public function removeCollisionBody(body:RigidBody):void
		{
			if (body.externalData != null)
			{
				body.externalData.collisionBody = null;
				CollisionSystemGridEntry.removeGridEntry(body.externalData);
				body.externalData = null;
			}

			if (collBody.indexOf(body) >= 0)
				collBody.splice(collBody.indexOf(body), 1);
		}
		
		override public function removeAllCollisionBodies():void
		{
			for each(var body:RigidBody in collBody){
				if (body.externalData != null)
				{
					body.externalData.collisionBody = null;
					CollisionSystemGridEntry.removeGridEntry(body.externalData);
				}
			}
			collBody.length=0;
		}

		
		// todo: only call when really moved, make it override public add into abstract ?
		override public function collisionSkinMoved(colBody:RigidBody):void
		{
			var entry:CollisionSystemGridEntry = colBody.externalData;
			if (entry == null)
			{
				//trace("Warning rigidbody has grid entry null!");
				return;
			}
			
			var gridIndex:int = calcGridIndexForBody(colBody);
						
			// see if it's moved grid
			if (gridIndex == entry.gridIndex)
				return;

			//trace(gridIndex);
			var start:CollisionSystemGridEntry;
			//if (gridIndex >= 0**)
			if (gridEntries.length-1 > gridIndex && gridIndex >=0) // check if it's outside the gridspace, if so add to overflow
				start = gridEntries[gridIndex];
			else
				start = overflowEntries;
			
			CollisionSystemGridEntry.removeGridEntry(entry);
			CollisionSystemGridEntry.insertGridEntryAfter(entry, start);
		}

		
		private function getListsToCheck(colBody:RigidBody):Vector.<CollisionSystemGridEntry>
		{
			var entries:Vector.<CollisionSystemGridEntry> = new Vector.<CollisionSystemGridEntry>; 
			
			var entry:CollisionSystemGridEntry = colBody.externalData;
			if (entry == null)
			{
				//trace("Warning skin has grid entry null!");
				return null;
			}
			
			// todo - work back from the mGridIndex rather than calculating it again...
			var i:int, j:int, k:int;
			var fi:Number, fj:Number, fk:Number;
			var tempStoreObject:Object = calcGridForSkin6(colBody);
			i = tempStoreObject.i; j = tempStoreObject.j; k = tempStoreObject.k; fi = tempStoreObject.fi; fj = tempStoreObject.fj; fk = tempStoreObject.fk;
			
			if (i == -1)
			{
				//trace("ADD ALL!");
				entries=gridEntries.concat();
				entries.push(overflowEntries);
				return entries;
			}
			
			// always add the overflow
			entries.push(overflowEntries);
			
			var delta:Vector3D = colBody.boundingBox.sideLengths; // skin.WorldBoundingBox.Max - skin.WorldBoundingBox.Min;
			var maxI:int = 1, maxJ:int = 1, maxK:int = 1;
			if (fi + (delta.x / dx) < 1)
				maxI = 0;
			if (fj + (delta.y / dy) < 1)
				maxJ = 0;
			if (fk + (delta.z / dz) < 1)
				maxK = 0;
			
			// now add the contents of all grid boxes - their contents may extend beyond the bounds
			for (var di:int = -1; di <= maxI; ++di)
			{
				for (var dj:int = -1; dj <= maxJ; ++dj)
				{
					for (var dk:int = -1; dk <= maxK; ++dk)
					{
						var thisIndex:int = calcIndex(i + di, j + dj, k + dk); // + ((nx*ny*nz)*0.5);
						//trace("ge", gridEntries.length);
						if (gridEntries.length-1 > thisIndex && thisIndex >=0) {
							var start:CollisionSystemGridEntry = gridEntries[thisIndex];
						 
							//trace(thisIndex,gridEntries.length);
							if (start != null && start.next != null)
							{
								entries.push(start);
							}
						}
					}
				}
			}
			return entries;
		}
		

		override public function detectAllCollisions(bodies:Vector.<RigidBody>, collArr:Vector.<CollisionInfo>):void // collisionFunctor:collCollisionFunctor , CollisionSkinPredicate2 collisionPredicate, float collTolerance)
		{
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			var bodyID:int;
			var bodyType:String;
			_numCollisionsChecks = 0;
			
			for each(var body:RigidBody in bodies)
			{
				if (!body.isActive)
					continue;

				bodyID = body.id;
				bodyType = body.type;
				
				var lists:Vector.<CollisionSystemGridEntry>=getListsToCheck(body);
				
				for each(var entry:CollisionSystemGridEntry in lists)
				{
					
					for (entry = entry.next; entry != null; entry = entry.next)
					{
						if (body == entry.collisionBody)
							continue;
						
						if (entry.collisionBody.isActive && bodyID > entry.collisionBody.id)
							continue;
						
						if (checkCollidables(body, entry.collisionBody) && detectionFunctors[bodyType + "_" + entry.collisionBody.type] != undefined)
						{
							info = new CollDetectInfo();
							info.body0 = body;
							info.body1 = entry.collisionBody;
							fu = detectionFunctors[info.body0.type + "_" + info.body1.type];
							fu.collDetect(info, collArr);
							_numCollisionsChecks += 1;
						} //check collidables
 					}// loop over entries
				} // loop over lists
			} // loop over bodies
		}
		
	}
}