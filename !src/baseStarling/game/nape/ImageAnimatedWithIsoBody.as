package baseStarling.game.nape {
	import baseStarling.game.ImageAnimated;
	import base.types.DictionaryExt;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.geom.DisplayObjectIso;
	import nape.geom.IsoBody;
	import nape.phys.BodyType;
	import nape.geom.Vec2;
	import nape.shape.ShapeList;

	public class ImageAnimatedWithIsoBody extends ImageAnimated {
		
		static private var DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC: DictionaryExt;
		
		private var body: Body;
		private var materialBody: Material;
		private var arrListShapeMC: Array;
		
		public function ImageAnimatedWithIsoBody(nameClassMovieClip: String, body: Body, scale: Number = 1, materialBody: Material = null): void {
			this.body = body;
			this.materialBody = materialBody;
			super(nameClassMovieClip, scale);
			this.arrListShapeMC = new Array(this.mcSrc.totalFrames);
		}
		
		override protected function processFrame(): void {
			if (!this.arrListShapeMC[this.currentFrameOnTimeline]) {
				if (!ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[this.nameClass][this.currentFrameOnTimeline]) {
					this.mcSrc.gotoAndStop(this.currentFrameOnTimeline);
					var isoMC: DisplayObjectIso = new DisplayObjectIso(this.mcSrc);
					var bodyMC: Body = IsoBody.run(isoMC, BodyType.DYNAMIC, isoMC.bounds, null, Vec2.weak(8, 8));
					bodyMC = bodyMC.align();
					if (this.materialBody) bodyMC.setShapeMaterials(this.materialBody);
					ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[this.nameClass][this.currentFrameOnTimeline] = bodyMC.shapes;
					bodyMC = null;
				}
				//Body(this.arrListShapeMC[this.currentFrameOnTimeline]).shapes.merge(Body(ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[this.nameClass][this.currentFrameOnTimeline]).shapes.copy());
				//this.arrListShapeMC[this.currentFrameOnTimeline] = ShapeList(ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[this.nameClass][this.currentFrameOnTimeline]).copy();
				var listShapeBodyMCSrc: ShapeList = ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[this.nameClass][this.currentFrameOnTimeline];
				var listShapeBodyMCDest: ShapeList = new ShapeList();
				for (var i: uint = 0; i < listShapeBodyMCSrc.length; i++)
					listShapeBodyMCDest.add(listShapeBodyMCSrc.at(i).copy());
				this.arrListShapeMC[this.currentFrameOnTimeline] = listShapeBodyMCDest;
			}
			this.body.shapes.clear();
			this.body.shapes.merge(this.arrListShapeMC[this.currentFrameOnTimeline]);
			super.processFrame();
		}
		
		//destroy
		
		override public function destroy(): void {
			super.destroy();
		}
		
		static public function destroy(): void {
			for (var nameClass: String in ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC) {
				var arrListShapeMC: Array = ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[nameClass];
				for (var i: uint = 0; i < arrListShapeMC.length; i++) {
					ShapeList(arrListShapeMC[i]).clear();
					arrListShapeMC[i] = null;
				}
				ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC[nameClass] = null;
			}
			ImageAnimatedWithIsoBody.DICT_NAME_CLASS_TO_ARR_LIST_SHAPE_MC = new DictionaryExt();
			ImageAnimated.destroy();
		}
		
	}

}