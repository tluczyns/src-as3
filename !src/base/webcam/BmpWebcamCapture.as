package base.webcam {
	import base.math.MathExt;
	import flash.display.Bitmap;
	import flash.media.Camera
	import flash.media.Video;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.ActivityEvent;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	public class BmpWebcamCapture extends Bitmap {
		
		static public var WEBCAM_NOT_DETECTED: String = "webcamNotDetected";
		static public var WEBCAM_DETECTED: String = "webcamDetected";

		public var webcam: Camera;
		public var video: Video;
		private var mrxMirror: Matrix;
		private var timeoutWebcamActivating: uint;
		
		public function BmpWebcamCapture(width: uint, height: uint, fps: uint = 30, isCorrectSizeWebcamToMultiplierNativeDimensionNoYesToSmallerYesToBigger: uint = 0): void {
			
			this.webcam = Camera.getCamera();
			if (!this.webcam) this.dispatchEvent(new Event(BmpWebcamCapture.WEBCAM_NOT_DETECTED));
			else {
				this.webcam.addEventListener(StatusEvent.STATUS, this.onWebcamStatus);
				if (isCorrectSizeWebcamToMultiplierNativeDimensionNoYesToSmallerYesToBigger > 0) {
					var isCorrectSizeWebcamToMultiplierNativeDimensionToSmallerOrBigger: uint = isCorrectSizeWebcamToMultiplierNativeDimensionNoYesToSmallerYesToBigger - 1;
					var multiplierDimension: Number = Math.max(Math[["min", "max"][isCorrectSizeWebcamToMultiplierNativeDimensionToSmallerOrBigger]](width / this.webcam.width, height / this.webcam.height), 1);
					//floor: 1 -> 1, 2 -> 2, 3 -> 2, 4 -> 4, 5 -> 4, 5 -> 4, 6 -> 4, 7 -> 4, 8 -> 8, 9 -> 8, 10 -> 8, ... //ceil: 1 -> 1, 2 -> 2, 3 -> 4, 4 -> 4, 5 -> 8, 5 -> 8, 6 -> 8, 7 -> 8, 8 -> 8, 9 -> 16, 10 -> 16, ...
					var multiplierNativeDimension: Number = Math.pow(2, Math[["floor", "ceil"][isCorrectSizeWebcamToMultiplierNativeDimensionToSmallerOrBigger]](MathExt.roundPrecision(MathExt.log2(multiplierDimension), 3)));
					width = multiplierNativeDimension * this.webcam.width;
					height = multiplierNativeDimension * this.webcam.height;
				}
				this.webcam.setMode(width, height, fps);
				this.video = new Video(width, height);
				this.video.attachCamera(this.webcam);
				this.video.scaleX = -1;
				this.video.x = width;
				this.video.smoothing = true;
				this.mrxMirror = new Matrix();
				this.mrxMirror.scale(-1, 1);
				this.mrxMirror.translate(width, 0);
				this.addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			}
			super(new BitmapData(width, height, false, 0), PixelSnapping.AUTO, true);
		}
		
		private function onWebcamStatus(e: StatusEvent):void {
			this.webcam.removeEventListener(StatusEvent.STATUS, this.onWebcamStatus);
			if (e.code == "Camera.Muted") this.dispatchEvent(new Event(BmpWebcamCapture.WEBCAM_NOT_DETECTED));
			else if (e.code == "Camera.Unmuted") {
				this.webcam.addEventListener(ActivityEvent.ACTIVITY, this.onWebcamActivity);
				this.timeoutWebcamActivating = setTimeout(this.onTimeoutWebcamActivating, 500);
			}
		}
		
		private function onTimeoutWebcamActivating(): void {
			this.webcam.removeEventListener(ActivityEvent.ACTIVITY, this.onWebcamActivity);
			this.dispatchEvent(new Event(BmpWebcamCapture.WEBCAM_NOT_DETECTED));
		}
		
		private function onWebcamActivity(e:ActivityEvent): void {
			clearTimeout(this.timeoutWebcamActivating);
			this.webcam.removeEventListener(ActivityEvent.ACTIVITY, this.onWebcamActivity);			
			if (e.activating) this.dispatchEvent(new Event(BmpWebcamCapture.WEBCAM_DETECTED));
			else this.dispatchEvent(new Event(BmpWebcamCapture.WEBCAM_NOT_DETECTED));
		}
		
		protected function onEnterFrameHandler(e: Event): void {
			this.bitmapData.draw(this.video, this.mrxMirror);
		}
		
		public function destroy(): void {
			if (this.webcam.hasEventListener(ActivityEvent.ACTIVITY)) this.webcam.removeEventListener(ActivityEvent.ACTIVITY, this.onWebcamActivity);
			if (this.webcam.hasEventListener(StatusEvent.STATUS)) this.webcam.removeEventListener(StatusEvent.STATUS, this.onWebcamStatus);
			this.webcam.setMode(160, 120, 15);
			this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
			this.video.clear();
			this.video = null;
		}
		
	}

}