package baseStarling.game {
	import baseStarling.loader.Library;
	import flash.display.BitmapData;
	
	public class AnimBgRepeatXYLowMemUsage extends AnimBgRepeatXY {
		
		private var nameClassBmpDrawableSegment: String;
		
		public function AnimBgRepeatXYLowMemUsage(nameClassBmpDrawableSegment: String, arrDimensionCover: Array = null, arrDimensionGradientToTransparent: Array = null, scaleTexture: Number = 1) {
			this.nameClassBmpDrawableSegment = nameClassBmpDrawableSegment;
			this.createBmpDrawableSegment();
			super(this.bmpDrawableSegment, arrDimensionCover, arrDimensionGradientToTransparent, scaleTexture)
		}
		
		override public function setDimensionFromDimensionBmpDataSegmentSource(): void {
			this.createBmpDrawableSegment();
			super.setDimensionFromDimensionBmpDataSegmentSource();
			this.removeBmpDrawableSegment();
		}
		
		override public function setDimensionFromExternal(arrDimension: Array): void {
			this.createBmpDrawableSegment();
			super.setDimensionFromExternal(arrDimension);
			//this.removeBmpDrawableSegment();
		}

		private function createBmpDrawableSegment(): void {
			if (!this.bmpDrawableSegment) this.bmpDrawableSegment = Library.getBitmapData(this.nameClassBmpDrawableSegment);
		}	
				
		private function removeBmpDrawableSegment(): void {
			if (this.bmpDrawableSegment) {
				BitmapData(this.bmpDrawableSegment).dispose();
				this.bmpDrawableSegment = null;
			}
			
		}
		
	}
	
}