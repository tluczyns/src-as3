package base.video {

	import flash.display.Sprite;
	import flash.events.Event;

	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.BlendMode;
	
	public class ShaderVideoContainer extends VideoContainer {
		
		private var shaderLoader:URLLoader;
		private var shader: Shader;
		private var shaderJob: ShaderJob;
		private var bdFrameFromVideo: BitmapData, bdFrameFromShader: BitmapData;
		private var bmpShader: Bitmap;
		private var _distanceShaderChannels: Number;
		
		public function ShaderVideoContainer(classVideoLoader: VideoLoader = null): void {
			if (classVideoLoader != null) {
				this.init(classVideoLoader);
			}
		}
		
		override internal function init(classVideoLoader: VideoLoader): void {
			this.createShaderBitmap();
			super.init(classVideoLoader);
			this.loadShader();
		}
		
		private function createShaderBitmap(): void {
			this.bmpShader = new Bitmap();
			this.addChild(this.bmpShader);
		}		
			
		private function loadShader(): void {
			this._distanceShaderChannels = 3; //30
			this.shaderLoader = new URLLoader();
            this.shaderLoader.dataFormat = URLLoaderDataFormat.BINARY;
            this.shaderLoader.addEventListener(Event.COMPLETE, this.createShader);
            this.shaderLoader.load(new URLRequest("Glasses3D.pbj"));
		}
		
		private function createShader(event: Event): void {
			this.bdFrameFromVideo = new BitmapData(this.video.width, this.video.height, true, 0xFFFFFFFF);
			this.shader = new Shader(this.shaderLoader.data);
            this.shader.data.src1.input = this.bdFrameFromVideo;
            this.shader.data.src2.input = this.bdFrameFromVideo;
			this.bdFrameFromShader = new BitmapData(this.bdFrameFromVideo.width, this.bdFrameFromVideo.height);
			this.bmpShader.bitmapData = this.bdFrameFromShader;
			this.video.visible = false;
		}
		
		override protected function setVideoDimensionAndPosition(): void {
			super.setVideoDimensionAndPosition();
			this.setShaderBitmapDimensionAndPosition();
		}
		
		private function setShaderBitmapDimensionAndPosition(): void {
			this.bmpShader.x = this.video.x;
			this.bmpShader.y = this.video.y;
		}
		
		public function set distanceShaderChannels(value: Number): void {
			this._distanceShaderChannels = value;
		}
		
		public function get distanceShaderChannels(): Number {
			return this._distanceShaderChannels;
		}
		
		private function drawShaderBitmap() : void {
			this.bdFrameFromVideo.fillRect(this.bdFrameFromVideo.rect, 0x00FFFFFF);
			var mrxTransformVideo: Matrix = new Matrix();
			mrxTransformVideo.scale(this.video.scaleX, this.video.scaleY);
			this.bdFrameFromVideo.draw(this.video, mrxTransformVideo, null, BlendMode.NORMAL);
			this.shader.data.distance.value = [this._distanceShaderChannels];
            this.shaderJob = new ShaderJob(this.shader, this.bdFrameFromShader, this.bdFrameFromVideo.width, this.bdFrameFromVideo.height);
            this.shaderJob.start();
		}
		
		override protected function onEnterFrameHandler(event: Event): void {
			super.onEnterFrameHandler(event);
			if (this.shader) {
				this.drawShaderBitmap();
			}
		}
				
	}
	
}