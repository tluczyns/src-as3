package base.video {
	
	import flash.display.Sprite;
	import flash.events.Event;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.display.BlendMode;
	
	public class AnaglyphVideoContainer extends VideoContainer implements IVideoContainer {
		
		private var bmpRedChannel: Bitmap, bmpCyanChannel: Bitmap;
		private var bdFrameFromVideo: BitmapData;
		private var _distanceAnaglyphChannelFromSourceBitmap: Number;
		
		public function AnaglyphVideoContainer(classVideoLoader: VideoLoader = null): void {
			if (classVideoLoader != null) {
				this.init(classVideoLoader);
			}
		}
		
		override internal function init(classVideoLoader: VideoLoader): void {
			this.createAnaglyphBitmaps();
			super.init(classVideoLoader);
			this.assignAnaglyphBitmapDataToBitmapsAndHideVideo();
		}
		
		private function createAnaglyphBitmaps(): void {
			this._distanceAnaglyphChannelFromSourceBitmap = 4; //30
			this.bmpRedChannel = new Bitmap();
			this.addChild(this.bmpRedChannel);
			this.bmpCyanChannel = new Bitmap();	
			this.addChild(this.bmpCyanChannel);
		}

		private function assignAnaglyphBitmapDataToBitmapsAndHideVideo(): void {
			this.bdFrameFromVideo = new BitmapData(this.video.width, this.video.height, true, 0x00FFFFFF);
			this.bmpRedChannel.bitmapData = this.bdFrameFromVideo;
			this.bmpCyanChannel.bitmapData = this.bdFrameFromVideo;
			this.bmpRedChannel.transform.colorTransform = new ColorTransform(1, 0, 0, 1);
			this.bmpCyanChannel.transform.colorTransform = new ColorTransform(0, 1, 1, 1);
			this.bmpCyanChannel.blendMode = BlendMode.SCREEN;
			this.video.visible = false;
		}
				
		override protected function setVideoDimensionAndPosition(): void {
			super.setVideoDimensionAndPosition();
			this.setAnaglyphBitmapsDimensionAndPosition();
		}

		private function setAnaglyphBitmapsDimensionAndPosition(): void {
			this.bmpRedChannel.x = this.video.x - this._distanceAnaglyphChannelFromSourceBitmap;
			this.bmpCyanChannel.x = this.video.x + this._distanceAnaglyphChannelFromSourceBitmap;
			this.bmpRedChannel.y = this.bmpCyanChannel.y = this.video.y;
		}
		
		public function set distanceAnaglyphChannelFromSourceBitmap(value: Number): void {
			this._distanceAnaglyphChannelFromSourceBitmap = value;
			this.setAnaglyphBitmapsDimensionAndPosition();
			if (this.classVideoLoader.objFlv.addMask) {
				this.classVideoLoader.addVideoMask();
			}
		}
		
		public function get distanceAnaglyphChannelFromSourceBitmap(): Number {
			return this._distanceAnaglyphChannelFromSourceBitmap;
		}
		
		private function drawAnaglyphBitmaps() : void {
			this.bdFrameFromVideo.fillRect(this.bdFrameFromVideo.rect, 0x00FFFFFF);
			var mrxTransformVideo: Matrix = new Matrix();
			mrxTransformVideo.scale(this.video.scaleX, this.video.scaleY);
			this.bdFrameFromVideo.draw(this.video, mrxTransformVideo);
		}
		
		override protected function onEnterFrameHandler(event: Event): void {
			super.onEnterFrameHandler(event);
			this.drawAnaglyphBitmaps();	
		}
		
	}
	
}