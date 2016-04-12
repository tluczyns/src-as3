package base.vspm {
	import flash.display.Sprite;
	import com.google.analytics.GATracker;
	import base.omniture.OmnitureTracker;

	public class Metrics extends Sprite {
		
		static private const GA: String = "ga";
		static private const OMNITURE: String = "omniture";
		static private const ARR_POSSIBLE_TYPE: Array = [GA, OMNITURE];
		
		static public var ARR_METRICS: Array;
		
		public var type: String;
		public var data: Object;
		
		static internal function createArrMetricsFromContent(content: Object): void {
			Metrics.ARR_METRICS = [];
			for (var i: uint = 0; i < Metrics.ARR_POSSIBLE_TYPE.length; i++) {
				var possibleType: String = Metrics.ARR_POSSIBLE_TYPE[i];
				if (content[possibleType]) Metrics.ARR_METRICS.push(new Metrics(possibleType, content[possibleType]));
			}
		}
		
		public function Metrics(type: String, dataPrimitive: Object): void {
			if (Metrics.ARR_POSSIBLE_TYPE.indexOf(type) != -1) {
				this.type = type;
				if (this.type == Metrics.GA) this.data = String(dataPrimitive.value);
				else if (this.type == Metrics.OMNITURE) this.data = dataPrimitive;
				if (this.data) {
					try {
						if (this.type == Metrics.GA) StateModel.gaTracker = new GATracker(this, String(this.data));
						else if (this.type == Metrics.OMNITURE) StateModel.omnitureTracker = new OmnitureTracker(this.data);
					} catch (e: Error) {}
				} else throw new Error("No data in given metrics!");
			} else throw new Error("Metrics is not of possible types!");
		}
		
	}

}