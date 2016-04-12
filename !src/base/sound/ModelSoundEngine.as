package base.sound {
	import base.types.Singleton;
	import flash.events.EventDispatcher;

	public class ModelSoundEngine extends Singleton {
		
		static private var modelDispatcher: EventDispatcher = new EventDispatcher();
		
		static private var _volumeRatio: Number	= 1;
		static private var _tweenVolumeRatio: Number;
		static private var _isSoundOffOn: uint = 1;
		
		static public function addEventListener(type: String, func: Function, priority: int = 0): void {
			ModelSoundEngine.modelDispatcher.addEventListener(type, func, false, priority);
		}
	
		static public function removeEventListener(type: String, func: Function): void {
			ModelSoundEngine.modelDispatcher.removeEventListener(type, func);
		}
		
		static public function dispatchEvent(type: String): void {
			ModelSoundEngine.modelDispatcher.dispatchEvent(new EventSoundEngine(type));
		}
		
		static public function get volumeRatio(): Number { 
			return ModelSoundEngine._volumeRatio;
		}
		
		static public function set volumeRatio(value: Number): void {
			ModelSoundEngine._volumeRatio = value;
			ModelSoundEngine.dispatchEvent(EventSoundEngine.VOLUME_RATIO_CHANGED); 
		}

		static public function get tweenVolumeRatio(): Number { 
			return ModelSoundEngine._tweenVolumeRatio;
		}
		
		static public function set tweenVolumeRatio(value: Number): void {
			ModelSoundEngine._tweenVolumeRatio = value;
			ModelSoundEngine.dispatchEvent(EventSoundEngine.TWEEN_VOLUME_RATIO_CHANGED); 
		}
		
		static public function get isSoundOffOn(): uint {
			return ModelSoundEngine._isSoundOffOn;
		}
		
		static public function set isSoundOffOn(value: uint): void {
			ModelSoundEngine._isSoundOffOn = value;
			ModelSoundEngine.dispatchEvent(EventSoundEngine.SOUND_OFF_ON_STATE_CHANGED); 
		}
		
	}

}