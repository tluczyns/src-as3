package baseStarling.game.nape {
	import nape.phys.Material;
	import nape.space.Space;
	import starling.display.DisplayObjectContainer;
	import nape.callbacks.CbType;
	import starling.display.DisplayObject;
	import nape.phys.Body;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	
	public class BodyWithDspObj extends Object {
		
		protected var refContainerDspObj: DisplayObjectContainer;
		protected var refSpace: Space;
		private var isImageAnimated: Boolean;
		private var scale: Number;
		private var materialBody: Material;
		
		internal var cbType: CbType;
		internal var dspObj: DisplayObject;
		private var mcTimelineWithIsoBody: ImageAnimatedWithIsoBody;
		protected var body: Body;
		
		public function BodyWithDspObj(refContainerDspObj: DisplayObjectContainer, refSpace: Space, isImageAnimated: Boolean = false, scale: Number = 1, materialBody: Material = null): void {
			this.refContainerDspObj = refContainerDspObj;
			this.refSpace = refSpace;
			this.isImageAnimated = isImageAnimated;
			this.scale = scale;
			this.materialBody = materialBody;
			this.cbType = new CbType();
			this.createBody();
			this.createDspObj();
		}
		
		protected function createDspObj(): void {
			if (!this.isImageAnimated) {
				this.dspObj = this.getInstanceDspObj();
			} else {
				this.mcTimelineWithIsoBody = new ImageAnimatedWithIsoBody(this.nameClassImageAnimated, this.body, this.scale, this.materialBody);
				this.dspObj = this.mcTimelineWithIsoBody.mc;
			}	
			this.refContainerDspObj.addChild(this.dspObj);
		}
		
		protected function getInstanceDspObj(): DisplayObjectContainer {
			throw new Error("getInstanceDspObj must be implemented");
		}
		
		protected function get nameClassImageAnimated(): String {
			throw new Error("get nameClassMovieClip must be implemented");
		}

		protected function removeDspObj(): void {
			this.refContainerDspObj.removeChild(this.dspObj);
			this.dspObj = null;
			if (this.isImageAnimated) {
				this.mcTimelineWithIsoBody.destroy();
				this.mcTimelineWithIsoBody = null;
			}
		}
		
		protected function createBody(): void {
			this.body = new Body(this.bodyType);
			this.body.velocity = Vec2.get();
			this.body.allowRotation = false;
			this.body.space = this.refSpace;
			if (!this.isImageAnimated) this.createBodyGeometry();
			this.body.cbTypes.add(this.cbType);
		}
		
		protected function createBodyGeometry(): void {
			throw new Error("createBodyGeometry must be implemented (in non movieclip timeline)");
		}
		
		protected function get bodyType(): BodyType {
			throw new Error("get bodyType must be implemented");
		}
		
		private function removeBody(): void {
			this.refSpace.bodies.remove(this.body);
			this.body.shapes.clear();
			this.body = null;
		}
		
		public function step(): void {
			//if (this.isImageAnimated) 
		}
		
		public function destroy(): void {
			this.removeBody();
			this.removeDspObj();
		}		
		
	}

}