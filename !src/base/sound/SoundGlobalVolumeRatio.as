package base.sound {
	import base.sharedObjects.SharedObjectInstance;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	public class SoundGlobalVolumeRatio extends Object {

		private var so: SharedObjectInstance;
		private var stepChangeVolumeRatio: Number;
		private var origVolumeRatio: Number;
		
		function SoundGlobalVolumeRatio(soName: String, stepChangeVolumeRatio: Number = 0.05): void {
			ModelSoundEngine.addEventListener(EventSoundEngine.VOLUME_RATIO_CHANGED, this.onVolumeRatioChanged);
			ModelSoundEngine.addEventListener(EventSoundEngine.SOUND_OFF_ON_STATE_CHANGED, this.setSoundOffOnFade);
			ModelSoundEngine.addEventListener(EventSoundEngine.TWEEN_VOLUME_RATIO_CHANGED, this.onTweenVolumeRatioChanged);
			this.so = new SharedObjectInstance(soName);
			this.stepChangeVolumeRatio = stepChangeVolumeRatio;
			ModelSoundEngine.volumeRatio = this.so.getPropValue("volumeRatio", 1);
			ModelSoundEngine.isSoundOffOn = uint(ModelSoundEngine.volumeRatio > 0);
			ModelSoundEngine.volumeRatio = ModelSoundEngine.isSoundOffOn;
		}
			
		private function onVolumeRatioChanged(e: EventSoundEngine): void {
			this.origVolumeRatio = Math.max(0.5, ModelSoundEngine.volumeRatio);
			this.so.setPropValue("volumeRatio", ModelSoundEngine.volumeRatio);
		}
		
		private function setSoundOffOnFade(e: EventSoundEngine): void {
			ModelSoundEngine.tweenVolumeRatio = [0, this.origVolumeRatio][ModelSoundEngine.isSoundOffOn];
		}
		
		private function onTweenVolumeRatioChanged(e: EventSoundEngine): void {
			if (this.origVolumeRatio != ModelSoundEngine.tweenVolumeRatio)
				this.origVolumeRatio = Math.max(0.5, ModelSoundEngine.volumeRatio);
			var numFramesChangeVolumeRatio: Number = Math.round(Math.abs(ModelSoundEngine.volumeRatio - ModelSoundEngine.tweenVolumeRatio) / this.stepChangeVolumeRatio);
			TweenMax.to(ModelSoundEngine, numFramesChangeVolumeRatio, {volumeRatio: ModelSoundEngine.tweenVolumeRatio, useFrames: true, ease: Linear.easeNone});
			this.so.setPropValue("volumeRatio", String(ModelSoundEngine.tweenVolumeRatio));
		}
		
	}
}