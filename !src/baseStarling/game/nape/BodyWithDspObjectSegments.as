package baseStarling.game.nape {
	import nape.space.Space;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import nape.shape.Polygon;
	import nape.phys.BodyType;
	
	public class BodyWithDspObjectSegments extends BodyWithDspObj {
		
		protected var widthBetweenSegments: Number;
		private var xOnScreenWhenAddNewSegment: Number;
		protected var countPlacesForSegments: uint;
		private var arrSegment: Array;
		
		public function BodyWithDspObjectSegments(refContainerDspObj: DisplayObjectContainer, refSpace: Space, widthBetweenSegments: Number, xOnScreenWhenAddNewSegment: Number, countPlacesForSegmentsEmpty: Number = 0): void {
			super(refContainerDspObj, refSpace, false);
			this.widthBetweenSegments = widthBetweenSegments;
			this.xOnScreenWhenAddNewSegment = xOnScreenWhenAddNewSegment;
			this.countPlacesForSegments = countPlacesForSegmentsEmpty;
			this.arrSegment = [];
		}
		
		override protected function getInstanceDspObj(): DisplayObjectContainer {
			return new Sprite();
		}
		
		override protected function createBody(): void {
			super.createBody();
			this.body.shapes.add(new Polygon(Polygon.box(1, 1)));
		}
		
		override protected function get bodyType(): BodyType {
			return BodyType.KINEMATIC;
		}
		
		override internal function step(): void {
			//trace("this.refContainerDspObj.hero.xOnTerrain:", this.refContainerDspObj.hero.xOnTerrain)
			while (- this.refContainerDspObj.hero.xOnTerrain + this.countPlacesForSegments * this.widthBetweenSegments < this.xOnScreenWhenAddNewSegment) {
				//dodajemy nowy segment	z prawej strony
				var segmentNew: Segment = this.createSegment();
				this.dspObj.addChild(segmentNew.dspObjDraw);
				this.arrSegment.push(segmentNew);
				this.countPlacesForSegments++;
			}
			while ((this.countPlacesForSegments - this.arrSegment.length + 1) * this.widthBetweenSegments <= this.refContainerDspObj.hero.xOnTerrain) {
				//usuwamy segment z lewej strony
				this.removeSegment(Segment(this.arrSegment.splice(0, 1)[0]));
			}
		}
		
		protected function createSegment(): Segment {
			throw new Error("createSegment must be implemented!");
		}
			
		private function removeSegment(segmentRemoved: Segment): void {
			this.dspObj.removeChild(segmentRemoved.dspObjDraw);
			this.body.shapes.remove(segmentRemoved.shpBody);
		}
		
		private function removeSegments(): void {
			for (var i: uint = 0; i < this.arrSegment.length; i++)
				this.removeSegment(Segment(this.arrSegment[i]));
			this.arrSegment = [];
			this.countPlacesForSegments = 0;
		}
		
		override public function destroy(): void {
			this.removeSegments();
			super.destroy();
		}
		
	}

}