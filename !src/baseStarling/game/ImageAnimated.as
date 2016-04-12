package baseStarling.game {
	import base.types.DictionaryExt;
	import flash.display.MovieClip;
	import starling.display.Sprite;
	import flash.display.Bitmap;
	import baseStarling.loader.Library;
	import starling.core.Starling;
	import base.bitmap.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	
	public class ImageAnimated extends Object {
		
		static private var DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC: DictionaryExt = new DictionaryExt();
		static private var DICT_NAME_CLASS_TO_ARR_BOUNDS_MC: DictionaryExt = new DictionaryExt();
		
		private var nameClass: String;
		private var scale: Number;
		public var mc: MovieClip;
		private var bmpMC: Bitmap;
		protected var mcSrc: MovieClip;
		private var arrBmpDataMC: Array;
		private var arrBoundsMC: Array;
		private var _currentFrame: uint;
		protected var currentFrameOnTimeline: uint;
		
		public function ImageAnimated(nameClass: String, scale: Number = 1) {
			this.nameClass = nameClass;
			this.scale = scale;
			this.createMC();
			this.createMCSrc();
			this.arrBmpDataMC = new Array(this.mcSrc.totalFrames);
			this.arrBoundsMC = new Array(this.mcSrc.totalFrames);
		}
		
		private function createMC(): void {
			this.mc = new Sprite();
			this.bmpMC = new Bitmap(null, "auto", true);
			this.mc.addChild(this.bmpMC);
		}
		
		protected function removeMC(): void {
			this.mc.removeChild(this.bmpMC);
			this.bmpMC = null;
			this.mc = null;
		}
		
		private function createMCSrc(): void {
			this.mcSrc = Library.getMovieClip(this.nameClass);
			this.mcSrc.scaleX = this.mcSrc.scaleY = this.scale;
			this.mcSrc.stop();
			this.mcSrc.x = this.mcSrc.y = -2000;
			Starling.current.nativeStage.addChild(this.mcSrc);
		}
		
		protected function removeMCSrc(): void {
			Starling.current.nativeStage.removeChild(this.mcSrc);
			this.mcSrc = null;
		}
		
		internal function get totalFrames(): uint {
			return this.mcSrc.totalFrames;
		}
		
		internal function get currentFrame(): uint {
			return this._currentFrame;
		}
		
		internal function set currentFrame(value: uint): void {
			if (int(value) != int(this._currentFrame)) {
				this._currentFrame = value % this.mcSrc.totalFrames;
				this.currentFrameOnTimeline = uint(this._currentFrame + 1);
				this.processFrame();
			}				
		}
		
		protected function processFrame(): void {
			//draw bmp data
			if (!this.arrBmpDataMC[this.currentFrameOnTimeline]) {
				if ((!ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC[this.nameClass][this.currentFrameOnTimeline]) && (!ImageAnimated.DICT_NAME_CLASS_TO_ARR_BOUNDS_MC[this.nameClass][this.currentFrameOnTimeline])) {
					this.mcSrc.gotoAndStop(this.currentFrameOnTimeline);
					ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC[this.nameClass][this.currentFrameOnTimeline] = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(this.mcSrc); 
					ImageAnimated.DICT_NAME_CLASS_TO_ARR_BOUNDS_MC[this.nameClass][this.currentFrameOnTimeline] = this.mcSrc.getBounds(this.mcSrc);
				}
				this.arrBmpDataMC[this.currentFrameOnTimeline] = ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC[this.nameClass][this.currentFrameOnTimeline];
				this.arrBoundsMC[this.currentFrameOnTimeline] = ImageAnimated.DICT_NAME_CLASS_TO_ARR_BOUNDS_MC[this.nameClass][this.currentFrameOnTimeline];
			}
			this.bmpMC.bitmapData = this.arrBmpDataMC[this.currentFrameOnTimeline];
			this.bmpMC.smoothing = true;
			var boundsMC: Rectangle =  this.arrBoundsMC[this.currentFrameOnTimeline];
			this.mc.x = boundsMC.x * this.scale;
			this.mc.y = boundsMC.y * this.scale;
		}
		
		// destroy
		
		public function destroy(): void {
			this.removeMCSrc();
			this.removeMC();
		}
		
		static public function destroy(): void {
			for (var nameClass: String in ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC) {
				var arrBmpDataMCForImageAnimated: Array = ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC[nameClass];
				for (var i: uint = 0; i < arrBmpDataMCForImageAnimated.length; i++) BitmapData(arrBmpDataMCForImageAnimated[i]).dispose();	
				ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC[nameClass] = null;
			}
			ImageAnimated.DICT_NAME_CLASS_TO_ARR_BMP_DATA_MC = new DictionaryExt();
			ImageAnimated.DICT_NAME_CLASS_TO_ARR_BOUNDS_MC = new DictionaryExt();
		}
		
	}

}