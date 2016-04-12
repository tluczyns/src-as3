package baseStarling.game {
	import baseStarling.loader.Library;
	import flash.display.BitmapData;
	
	public class AnimBgRepeatLowMemUsage extends AnimBgRepeat {
		
		private var nameClassBmpDrawableSegment: String;
		
		public function AnimBgRepeatLowMemUsage(nameClassBmpDrawableSegment: String, isAnimXY: uint, valDimensionCover: Number, valDimensionGradientToTransparent: Number = -1, scaleTexture: Number = 1) {
			this.nameClassBmpDrawableSegment = nameClassBmpDrawableSegment;
			this.createBmpDrawableSegment();
			super(this.bmpDrawableSegment, isAnimXY, valDimensionCover, valDimensionGradientToTransparent, scaleTexture)
		}
		
		override public function setDimensionFromDimensionBmpDataSegmentSource(): void {
			this.createBmpDrawableSegment();
			super.setDimensionFromDimensionBmpDataSegmentSource();
			this.removeBmpDrawableSegment();
		}
		
		override protected function setDimensionFromExternal(nameDimensionChanged: String, value: Number): void {
			if (nameDimensionChanged == this.nameDimensionStatic) this.createBmpDrawableSegment();
			super.setDimensionFromExternal(nameDimensionChanged, value);
			this.removeBmpDrawableSegment();
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