package jiglib.plugin.away3d4 {
	
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.geometry.JTerrain;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;
	import jiglib.plugin.away3d4.Away3D4Mesh;

	public class Away3D4Physics extends AbstractPhysics {
		
		private var view:View3D;

		public function Away3D4Physics(view:View3D, speed:Number = 1) {
			this.view = view;
			super(speed);
		}
		
		public function getMesh(body:RigidBody):Mesh {
			if(body.skin!=null){
				return Away3D4Mesh(body.skin).mesh;
			}else {
				return null;
			}
		}
		
		public function createGround(material:MaterialBase,width:int=500,height:int=500, segmentsW:uint = 1, segmentsH:uint = 1, yUp:Boolean = true,level:Number = 0):RigidBody {
			var ground:Plane = new Plane(material, width, height, segmentsW, segmentsH, yUp);

			view.scene.addChild(ground);
			
			var jGround:JPlane = new JPlane(new Away3D4Mesh(ground));
			jGround.y = level;
			jGround.rotationX = 90;
			jGround.movable = false;
			addBody(jGround);
			return jGround;
		}
		
		public function createCube(material:MaterialBase,width:Number=500,height:Number=500,depth:Number=500,segmentsW:uint = 1, segmentsH:uint = 1, segmentsD:uint = 1, tile6:Boolean = true):RigidBody
		{
			var cube:Cube = new Cube(material, width, height, depth, segmentsW, segmentsH, segmentsD, tile6);
			view.scene.addChild(cube);
			
			var jBox:JBox = new JBox(new Away3D4Mesh(cube), width, depth, height);
			addBody(jBox);
			return jBox;
		}
		
		public function createSphere(material:MaterialBase, radius:Number = 50, segmentsW:uint = 16, segmentsH:uint = 12, yUp:Boolean = true):RigidBody 
		{
			var sphere:Sphere = new Sphere(material, radius, segmentsW, segmentsH, yUp);
			view.scene.addChild(sphere);
			var jsphere:JSphere = new JSphere(new Away3D4Mesh(sphere), radius);
			addBody(jsphere);
			return jsphere;
		}
		
		public function createTerrain(material : MaterialBase, heightMap : BitmapData, width : Number = 1000, height : Number = 100, depth : Number = 1000, segmentsW : uint = 30, segmentsH : uint = 30, maxElevation:uint = 255, minElevation:uint = 0, smoothMap:Boolean = false):JTerrain {
			var terrainMap:Away3D4Terrain = new Away3D4Terrain(material, heightMap, width, height, depth, segmentsW, segmentsH, maxElevation, minElevation, smoothMap);
			view.scene.addChild(terrainMap);
			
			var terrain:JTerrain = new JTerrain(terrainMap);
			addBody(terrain);
			
			return terrain;
		}
		
		public function createMesh(skin:Mesh,initPosition:Vector3D,initOrientation:Matrix3D,maxTrianglesPerCell:int = 10, minCellSize:Number = 10):JTriangleMesh{
			var mesh:JTriangleMesh=new JTriangleMesh(new Away3D4Mesh(skin),initPosition,initOrientation,maxTrianglesPerCell,minCellSize);
			addBody(mesh);
			
			return mesh;
		}
	}
}
