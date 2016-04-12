package base.sound {
	import flash.events.EventDispatcher;
	import base.loader.SoundExt;
	import flash.utils.ByteArray;
	import flash.events.SampleDataEvent;
	import baseStarling.vspm.EventModel;

	public class SoundPitch extends EventDispatcher {
		
		static public const POSITION_CHANGED: String = "soundPitchPositionChanged";
		
		private const BLOCK_SIZE: int = 3072;
		
		private var srcSound: SoundExt;
		public var resSound: SoundExt;
		
		private var _target: ByteArray;
		private var _positionSample: Number;
		private var _rate: Number;
		
		private var onSoundCompleteExternal: Function;
		private var isLoop: Boolean;
		
		public function SoundPitch(srcSound: SoundExt) {
			this.srcSound = srcSound;
			_target = new ByteArray();
			this.positionSample = - BLOCK_SIZE;
			_rate = 1.0;
			this.createResSound();
		}
		
		private function createResSound(): void {
			this.resSound = new SoundExt();
			this.resSound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
		}
		
		private function removeResSound(): void {
			this.resSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
			this.resSound.destroy();
		}
		
		public function get rate(): Number {
			return _rate;
		}
		
		public function set rate( value: Number ): void {
			if( value < 0.0 )
				value = 0;
			_rate = value;
		}

		private function sampleData( event: SampleDataEvent ): void {
			//-- REUSE INSTEAD OF RECREATION
			_target.position = 0;
			
			//-- SHORTCUT
			var data: ByteArray = event.data;
			
			var scaledBlockSize: Number = BLOCK_SIZE * _rate;
			this.positionSample += scaledBlockSize;
			var positionSampleInt: int = this.positionSample;
			var alpha: Number = this.positionSample - positionSampleInt;

			var positionTargetNum: Number = alpha;
			var positionTargetInt: int = -1;

			//-- COMPUTE NUMBER OF SAMPLES NEED TO PROCESS BLOCK (+2 FOR INTERPOLATION)
			var need: int = Math.ceil(scaledBlockSize) + 2;
			
			//-- EXTRACT SAMPLES
			var read: int = srcSound.extract( _target, need, positionSampleInt );
			var n: int = ((read == need) ? BLOCK_SIZE : (read / _rate));

			var l0: Number;
			var r0: Number;
			var l1: Number;
			var r1: Number;

			for (var i: int = 0; i < n; i++) {
				//-- AVOID READING EQUAL SAMPLES, IF RATE < 1.0
				if (int(positionTargetNum) != positionTargetInt) {
					positionTargetInt = positionTargetNum;
					
					//-- SET TARGET READ POSITION
					_target.position = positionTargetInt << 3;
	
					//-- READ TWO STEREO SAMPLES FOR LINEAR INTERPOLATION
					l0 = _target.readFloat();
					r0 = _target.readFloat();

					l1 = _target.readFloat();
					r1 = _target.readFloat();
				}
				
				//-- WRITE INTERPOLATED AMPLITUDES INTO STREAM
				data.writeFloat( l0 + alpha * ( l1 - l0 ) );
				data.writeFloat( r0 + alpha * ( r1 - r0 ) );
				
				//-- INCREASE TARGET POSITION
				positionTargetNum += _rate;
				
				//-- INCREASE FRACTION AND CLAMP BETWEEN 0 AND 1
				alpha += _rate;
				while( alpha >= 1.0 ) --alpha;
			}
		
			//-- FILL REST OF STREAM WITH ZEROs
			while(i < BLOCK_SIZE) {
				data.writeFloat( 0.0 );
				data.writeFloat( 0.0 );
				++i;
			}
			
			//if (resSound.channel) trace(resSound.channel.position, this.srcSound.length, this.position, srcSound.bytesTotal, this.positionSample)
			if (this.position >= this.srcSound.length) {
				if (this.isLoop) {
					this.positionSample = 0.0;
					resSound.playExt();
				} else {
					this.resSound.stop();
					if (this.onSoundCompleteExternal != null) this.onSoundCompleteExternal.apply();
				}
			}
		}
		
		public function get positionSample(): Number {
			return this._positionSample;
		}
		
		public function set positionSample(value: Number): void {
			this._positionSample = value;
			this.dispatchEvent(new EventModel(SoundPitch.POSITION_CHANGED, {position: this.position, ratioPosition: this.position / this.srcSound.length}));
		}
		
		public function get position(): Number {
			return (this.positionSample - 2 * BLOCK_SIZE) / 44.1;
		}
		
		public function set position(value: Number): void {
			this.positionSample = value * 44.1 + 2 * BLOCK_SIZE;
		}
		
		//public
		
		public function play(onSoundCompleteExternal: Function = null, isLoop: Boolean = false): void {
			this.onSoundCompleteExternal = onSoundCompleteExternal;
			this.isLoop = isLoop;
			this.resSound.playExt(null, this.resSound.positionPause); //this.position
		}
		
		public function stop(): void {
			this.resSound.stop();
		}
		
		public function destroy(): void {
			this.srcSound.destroy();
			this.removeResSound();
		}
	}
}
