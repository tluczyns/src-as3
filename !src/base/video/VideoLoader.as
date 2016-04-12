package base.video {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	
	public class VideoLoader extends Sprite {
		
		private var dimensionVideoDefault: Object;
		public var objFlv: Object;
		private var nc: NetConnection;
		public var ns: NetStream;
		public var metaData:Object;
		public var videoContainer: IVideoContainer;
		private var videoMask: Sprite;
		private var isVideoLoaded: Boolean;
		
		public function VideoLoader(objFlv: Object = null) {
			this.dimensionVideoDefault = { width: 720, height: 576 };
			if (objFlv != null) {
				this.init(objFlv);
			}
		}
			
		public function init(objFlv: Object): void {
			this.objFlv = objFlv;
			(this.objFlv.classVideoContainer == null) ? this.objFlv.classVideoContainer = VideoContainer : null;
			(this.objFlv.addMask == null) ? this.objFlv.addMask = true : null;
			(this.objFlv.isPlayOnce == null) ? this.objFlv.isPlayOnce = true : null;
			(this.objFlv.isHideAfterStop == null) ? this.objFlv.isHideAfterStop = true : null;
			if (this.objFlv.width == null) {
				this.objFlv.width = this.dimensionVideoDefault.width;
				this.objFlv.isWidthVideoDefaultApplied = true;	
			} else { 
				this.objFlv.isWidthVideoDefaultApplied = false;	
			}
			if (this.objFlv.height == null) {
				this.objFlv.height = this.dimensionVideoDefault.height;
				this.objFlv.isHeightVideoDefaultApplied = true;	
			} else { 
				this.objFlv.isHeightVideoDefaultApplied = false;	
			}
			(this.objFlv.x == null) ? this.objFlv.x = 0 : null;
			(this.objFlv.y == null) ? this.objFlv.y = 0 : null;
			this.loadFlv();
		}

		private function loadFlv(): void {
			this.nc = new NetConnection();
			this.nc.connect(null);
			this.ns = new NetStream(this.nc);
			this.ns.bufferTime = 6;
			this.ns.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStreamStatus);
			this.metaData = { onCuePoint: this.onCuePoint, onMetaData: this.onMetaData };
			this.ns.client = this.metaData;
			this.addVideoContainer();
			this.isVideoLoaded = false;
			this.playVideo();
		}
		
		private function onNetStreamStatus(objStatus: Object): void {
			//trace("objStatus.info.code:" + objStatus.info.code);
			if (objStatus.info.code == "NetStream.Play.Start") {
				this.ns.seek(0);
			} else if (objStatus.info.code == "NetStream.Buffer.Full") {
			} else if (objStatus.info.code == "NetStream.Play.Stop") {
				if (this.objFlv.isPlayOnce) {
					this.stopVideo();
				}
			}
		}
		
		private function onCuePoint(ob: Object): void {
			for each(var o:String in ob.parameters) {
				trace(ob[o]+" "+o);
			}
		}
       
        private function onMetaData(md: Object): void {
			this.metaData.width = md.width;
			this.metaData.height = md.height;
			this.metaData.seekPoints = md.seekpoints;
			this.metaData.frameRate = md.videoframerate;
			this.metaData.duration = md.duration;
		}
		
		private function addVideoContainer(): void {
			this.videoContainer = new this.objFlv.classVideoContainer(this);
			this.addChild(this.objFlv.classVideoContainer(this.videoContainer));
			if (this.objFlv.addMask) {
				this.addVideoMask();
			}
		}
		
		internal function addVideoMask(): void {
			if (this.videoContainer != null) {
				if ((this.videoMask != null) && (this.contains(this.videoMask))) {
					this.removeChild(this.videoMask);
				}
				var video: Video = VideoContainer(this.videoContainer).video;
				var xMarginMask: Number = 0;
				if (this.objFlv.classVideoContainer == AnaglyphVideoContainer) {
					xMarginMask = Math.abs(AnaglyphVideoContainer(this.videoContainer).distanceAnaglyphChannelFromSourceBitmap);
				}
				this.videoMask = new Sprite();
				this.videoMask.graphics.lineStyle();
				this.videoMask.graphics.beginFill(0xFFFFFF, 0);
				this.videoMask.graphics.moveTo(video.x + xMarginMask, video.y);
				this.videoMask.graphics.lineTo(video.x + video.width - xMarginMask, video.y);
				this.videoMask.graphics.lineTo(video.x + video.width - xMarginMask, video.y + video.height);
				this.videoMask.graphics.lineTo(video.x + xMarginMask, video.y + video.height);
				this.videoMask.graphics.lineTo(video.x + xMarginMask, video.y);
				this.videoMask.graphics.endFill();
				this.addChild(this.videoMask);
				this.objFlv.classVideoContainer(this.videoContainer).mask = this.videoMask;
			}
		}
		
		public function playVideo(): void {
			if (this.objFlv.isHideAfterStop) {
				VideoContainer(this.videoContainer).visible = true;
			}
			if (this.isVideoLoaded) {
				this.ns.seek(0);
				this.ns.resume();
			} else {
				this.isVideoLoaded = true;
				this.ns.play(this.objFlv.url);
			}
		}

		public function stopVideo(): void {
			//this.videoContainer.btn.enabled = false;
			this.ns.pause();
			if (this.objFlv.isHideAfterStop) {
				VideoContainer(this.videoContainer).visible = false
			}
		}

		private function pauseVideoAtInit(): void {
			//this.videoContainer.showControls();
			//this.videoContainer.streamPausePlay(0);
		}
		
	}
	
}