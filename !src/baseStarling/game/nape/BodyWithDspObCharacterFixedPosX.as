package baseStarling.game.nape {
	import gamesStarling.gamePlatformSanta.viewSection.game.BodyWithDspObj;
	import gamesStarling.gamePlatformSanta.viewSection.game.Playground;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import base.loader.Library;
	
	public class BodyWithDspObCharacterFixedPosX extends BodyWithDspObj {
		
		static private const MATERIAL_BODY: Material = new Material(0.5, 0, 0, 1, 0);
		static private var MATERIAL_BODY_LIGHT: Material;
		{
			MATERIAL_BODY_LIGHT = MATERIAL_BODY.copy();
			MATERIAL_BODY_LIGHT.density = 0.1;
		}
		static internal const X_ON_SCREEN: Number = 150;
		static private const COLLISTION_GROUP: uint = 2;
		
		private var _numFrameMC: Number;
		
		public function BodyWithDspObCharacterFixedPosX(classPlayground: Playground, classSpace: Space, xOnScreen: Number): void {
			super(classPlayground, classSpace);
			this._numFrameMC = -1;
			this.numFrameMC = 0;
		}
		
				
		override protected function createDspObj(): void {
			super.createDspObj();
			this.mc = MovieClip(this.dspObj);
			this.mc.stop();
		}
		
		override protected function getInstanceDspObj(): DisplayObjectContainer {
			return Library.getMovieClip("gamePlatformSanta.mcHero");
		}
		
		override protected function createBody(): void {
			super.createBody();
			this.body.shapes.add(new Polygon(Polygon.rect(0, 0, 60, 60), Hero.MATERIAL_BODY));
			this.body.allowRotation = false;
			//this.body.setShapeMaterials(Skier.MATERIAL_BODY);
			this.body.setShapeFilters(new InteractionFilter(Hero.COLLISTION_GROUP));
			this.body.cbTypes.add(this.cbType);
		}
		
		override protected function get bodyType(): BodyType {
			return BodyType.DYNAMIC;
		}
		
		internal function get xOnTerrain(): Number {
			return this.body.position.x - Hero.X_ON_SCREEN;
		}
		
		internal function setPositionBody(pos: Vec2): void {
			this.body.position = pos;
			this.setPositionRotationDspObj();
		}
		
		override internal function step(): void {
			//this.numFrameMC += (this.body.velocity.length / 400);
			this.setPositionRotationDspObj();
			this.setFrameMC();
			this.applyCustomImpulsesOnStep();
		}
		
		private function get numFrameMC(): Number {
			return this._numFrameMC;
		}
		
		private function set numFrameMC(value: Number): void {
			if (int(value) != int(this._numFrameMC)) {
				this._numFrameMC = value % this.mc.totalFrames;
				this.mc.gotoAndStop(uint(this._numFrameMC + 1));
			}
		}
		
		
		
	}

}