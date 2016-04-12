package base.mvc.section {
	import flash.display.Sprite;
	import com.google.analytics.GATracker;
	import base.omniture.OmnitureTracker;

	public class Metrics extends Sprite {
		
		static public const GA: String = "ga";
		static public const OMN: String = "omn";
		
		internal var type: String;
		internal var data: Object;
		
		public function Metrics(type: String, data: Object = null): void {
			this.type = type;
			this.data = data;
		}
		
		public function parse(): void {
			if (this.data == null) {
				if ((this.type == Metrics.GA) && (LoaderXMLContentViewSection.content.ga)) this.data = String(LoaderXMLContentViewSection.content.ga.value);
				else if (this.type == Metrics.OMN) this.data = LoaderXMLContentViewSection.content.omniture;
			}	
			if (this.data) {
				try {
					if (this.type == Metrics.GA) ModelSection.gaTracker = new GATracker(this, String(this.data));
					else if (this.type == Metrics.OMN) ModelSection.omnitureTracker = new OmnitureTracker(this.data);
				} catch (e: Error) {}
			}
		}
		
	}

}