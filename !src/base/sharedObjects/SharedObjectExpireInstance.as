package base.sharedObjects {
	import flash.net.SharedObject;
	
	public class SharedObjectExpireInstance extends SharedObjectInstance {
		
		private var timeExpire: uint;
		private var soTimeStart: SharedObjectInstance;
		private var soTimeExpire: SharedObjectInstance;
		
		public function SharedObjectExpireInstance(soName: String, timeExpire: uint = 3600000): void {
			super(soName);
			this.soTimeStart = new SharedObjectInstance(soName + "TimeStart");
			this.soTimeExpire = new SharedObjectInstance(soName + "TimeExpire");
			this.timeExpire = timeExpire;
		}
		
		public function setPropValueWithExpire(propName: String, propValue: *, timeExpire: uint = 0): void {
			if (super.setPropValue(propName, propValue)) {
				if (timeExpire == 0) timeExpire = this.timeExpire;
				this.soTimeStart.setPropValue(propName, (new Date()).getTime());
				this.soTimeExpire.setPropValue(propName, timeExpire);
			}
		}
		
		override public function setPropValue(propName: String, propValue: *): Boolean {
			delete this.soTimeStart.setPropValue(propName, undefined);
			return super.setPropValue(propName, propValue);
		}
		
		override public function getPropValue(propName: String, defaultValue: * = undefined): * {
			var isExpired: Boolean = false;
			var timeStart: uint = uint(this.soTimeStart.getPropValue(propName));
			var timeExpire: uint = uint(this.soTimeExpire.getPropValue(propName));
			if ((timeStart > 0) && (timeExpire > 0)) {
				var timeLive: uint = (new Date()).getTime() - timeStart;
				if (timeLive > timeExpire) isExpired = true;
			}
			if (isExpired) this.setPropValue(propName, undefined);
			return super.getPropValue(propName, defaultValue);
		}
		
	}

}