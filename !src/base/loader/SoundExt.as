package base.loader {
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import base.sound.ModelSoundEngine;
	import base.sound.EventSoundEngine;
	import flash.media.SoundTransform;
	import com.greensock.TweenNano;
	import com.greensock.easing.*;
	import flash.errors.IOError;
	
	public dynamic class SoundExt extends Sound {
		public var channel: SoundChannel;
		public var isLoop: Boolean;
		public var initVolume: Number;
		private var origVolume: Number;
		private var isToPlay: Boolean;
		private var onLoadComplete: Function;
		private var onLoadProgress: Function;
		private var onLoadError: Function;
		private var onSoundComplete: Function;
		public var positionPause: int = 0;
		
		public function SoundExt(objSoundExt: Object = null) {
			objSoundExt = objSoundExt || {};
			this.isLoop = Boolean(objSoundExt.isLoop);
			this.initVolume = this.origVolume = (objSoundExt.initVolume != undefined) ? objSoundExt.initVolume : 1;
			this.isToPlay = Boolean(objSoundExt.isToPlay);
			this.onLoadComplete = objSoundExt.onLoadComplete || this.onLoadCompleteDefault;
			this.onLoadProgress = objSoundExt.onLoadProgress || this.onLoadProgressDefault;
			this.onLoadError = objSoundExt.onLoadError || this.onLoadErrorDefault;
			this.addEventListener(Event.COMPLETE, this.onLoadComplete);
			this.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			var urlRequest: URLRequest;
			if (objSoundExt.url != null) {
				urlRequest = new URLRequest(objSoundExt.url);
				//urlRequest.useCache = true;
			}
			super(urlRequest);
			if (urlRequest == null) {
				this.initAfterLoading();
			}
		}
		
		//loading and init
		
		private function onLoadCompleteDefault(event:Event): void {
			this.removeLoadListeners();
			this.initAfterLoading();
		}
		
		private function removeLoadListeners(): void {
			this.removeEventListener(Event.COMPLETE, this.onLoadComplete);
			this.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
		}
		
		private function onLoadProgressDefault(event:ProgressEvent): void {
			var ratioLoaded:Number = event.bytesLoaded / event.bytesTotal;
			var percentLoaded: uint = Math.round(ratioLoaded * 100);
		}
	
		private function onLoadErrorDefault(errorEvent:IOErrorEvent): void {}		
		
		public function initAfterLoading(): void {
			ModelSoundEngine.addEventListener(EventSoundEngine.VOLUME_RATIO_CHANGED, this.setVolumeGlobal);
			this.setVolumeGlobal();
			if (this.isToPlay) {
				this.playExt();
			}
		}
		
		//play and stop
		
		public function playExt(onSoundComplete: Function = null, startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null): SoundChannel {
			this.onSoundComplete = onSoundComplete || this.onSoundCompleteDefault;
			this.stop();
			this.channel = this.play(startTime, loops, sndTransform);
			this.channel.addEventListener(Event.SOUND_COMPLETE, this.onSoundComplete);
			this.setVolumeSelf();
			return this.channel;
		}
		
		public function stop(): void {
			if (this.channel) {
				this.positionPause = this.channel.position; 
				this.channel.removeEventListener(Event.SOUND_COMPLETE, this.onSoundComplete);
				this.channel.stop();
				this.channel = null;
			}
		}
		
		private function onSoundCompleteDefault(event:Event): void {
			if (this.isLoop) this.playExt();
			else this.stop();
		}
		
		//set volume
		
		private function setVolumeGlobal(e: EventSoundEngine = null): void { 
			this.setVolume(ModelSoundEngine.volumeRatio, true);
		}

		private function setVolumeSelf(): void { 
			this.setVolume(this.initVolume, false);
		}
		
		public function setVolume(volume: Number, isGlobal: Boolean = false): void {
			if (!isGlobal) {
				this.initVolume = volume;
				volume *= ModelSoundEngine.volumeRatio;
			} else {
				volume *= this.initVolume;
			}
			//trace("volume:" + volume + ", isGlobal:" + isGlobal)
			var soundTransform: SoundTransform = new SoundTransform();
			soundTransform.volume = volume;
			if (this.channel != null) this.channel.soundTransform = soundTransform;
		}

		public function setSoundOffOnFade(isSoundOffOn: Number, stepChangeVolume: Number = 0.1, onComplete: Function = null, onCompleteParams: Array = null): void {
			var destVolume: Number;
			if (isSoundOffOn == 0) {
				this.origVolume = this.initVolume;
				destVolume = 0;
			} else if (isSoundOffOn == 1) {
				destVolume = this.origVolume;
			}
			this.tweenVolume(destVolume, stepChangeVolume, onComplete, onCompleteParams)
		}
		
		public function tweenVolume(destVolume: Number, stepChangeVolume: Number = 0.1, onComplete: Function = null, onCompleteParams: Array = null, ease: * = null): uint {
			var currVolume: Number = ((this.channel) && (this.channel.soundTransform)) ? this.channel.soundTransform.volume : this.initVolume;
			var numFramesChangeVolume: uint = Math.abs(Math.round(Math.abs(destVolume - currVolume) / stepChangeVolume));
			ease = ease || Linear.easeNone
			TweenNano.killTweensOf(this);
			TweenNano.to(this, numFramesChangeVolume, {initVolume: destVolume, useFrames: true, ease: ease, onUpdate: this.setVolumeSelf, onComplete: onComplete, onCompleteParams: onCompleteParams});
			return numFramesChangeVolume;
		}
		
		//destroy
		
		public function destroy(): void {
			try { 
				this.close();
				this.removeLoadListeners();
			}
			catch (error:IOError) {}
			ModelSoundEngine.removeEventListener(EventSoundEngine.VOLUME_RATIO_CHANGED, this.setVolumeGlobal);
			this.stop();
			TweenNano.killTweensOf(this);
		}
		
	}

}