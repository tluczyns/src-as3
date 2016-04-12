package base.microphone {
	import flash.events.EventDispatcher;
	import flash.media.Microphone;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	
	public class MicrophoneCapture extends EventDispatcher {
		
		static public var MICROPHONE_NOT_DETECTED: String = "microphoneNotDetected";
		static public var MICROPHONE_DETECTED: String = "microphoneDetected";
		
		public var microphone: Microphone;

		public function MicrophoneCapture(rate: int = 44, gain: Number = 30, isSetLoopBack: Boolean = false, silenceLevel: Number = 20, silenceInterval: int = 0): void {
			if (!Microphone.isSupported) this.dispatchEvent(new Event(MicrophoneCapture.MICROPHONE_NOT_DETECTED));
			this.microphone = Microphone.getMicrophone();
			if (!this.microphone) this.dispatchEvent(new Event(MicrophoneCapture.MICROPHONE_NOT_DETECTED));
			else {
				this.microphone.rate = rate;
				this.microphone.gain = gain;
				this.microphone.setLoopBack(isSetLoopBack);
				this.microphone.setSilenceLevel(silenceLevel, silenceInterval);
				this.microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, this.onMicrophoneSampleData);
				this.microphone.addEventListener(StatusEvent.STATUS, this.onMicrophoneStatus);
			}
		}
		
		private function onMicrophoneSampleData(e: SampleDataEvent): void {trace("onMicrophoneSampleData")}
		
		public function onMicrophoneStatus(e: StatusEvent): void {
			this.microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, this.onMicrophoneSampleData);
			this.microphone.removeEventListener(StatusEvent.STATUS, this.onMicrophoneStatus);
			if (e.code == "Microphone.Muted") this.dispatchEvent(new Event(MicrophoneCapture.MICROPHONE_NOT_DETECTED));
			else if (e.code == "Microphone.Unmuted") this.dispatchEvent(new Event(MicrophoneCapture.MICROPHONE_DETECTED));
		}

		public function destroy(): void {
			if (this.microphone.hasEventListener(StatusEvent.STATUS)) this.microphone.removeEventListener(StatusEvent.STATUS, this.onMicrophoneStatus);
			if (this.microphone.hasEventListener(SampleDataEvent.SAMPLE_DATA)) this.microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, this.onMicrophoneSampleData);
			this.microphone = null;
		}
		
	}

}