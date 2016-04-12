package base.sound {
	import flash.events.Event;

	public class EventSoundEngine extends Event {
		
		//events to sound engine
		static public const SOUND_OFF_ON_STATE_CHANGED: String = "soundOffOnStateChanged";
		//events from sound engine
		static public const VOLUME_RATIO_CHANGED: String = "volumeRatioChanged";
		static public const TWEEN_VOLUME_RATIO_CHANGED: String = "tweenVolumeRatioChanged";
		
		
		
		public function EventSoundEngine(type: String, bubbles: Boolean = false) {
			super(type, bubbles);
		}
		
	}

}