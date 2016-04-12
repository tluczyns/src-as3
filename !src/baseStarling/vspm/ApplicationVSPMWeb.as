package baseStarling.vspm {
	import flash.display.Sprite;
	import starling.core.Starling;
	import baseStarling.loader.Library;
	import flash.utils.getQualifiedClassName;
	import base.loader.EventLoaderXML;
	import flash.display.StageScaleMode;
	import flash.utils.getDefinitionByName;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import flash.geom.Rectangle;

	public class ApplicationVSPMWeb extends Sprite {
		
		static public var WIDTH: Number;
		static public var HEIGHT: Number;
		static public var FACTOR_SCALE_X: Number;
		static public var FACTOR_SCALE_Y: Number;
		
		private var prefixClass: String;
		private var loaderXMLContent: LoaderXMLContentView;
		protected var starling: Starling;
		protected var containerApplication: ContainerApplicationVSPM;
		
		public function ApplicationVSPMWeb(): void {
			Library.addSwf(this);
			new LoaderImgs();
			var nameClassApplication: String = getQualifiedClassName(this);
			this.prefixClass = nameClassApplication.substr(0, nameClassApplication.indexOf('::'));
		}
		
		public function init(pathAssets: String = "", filenameXML: String = "content.xml"): void {
			this.loadXMLContent(pathAssets + "xml/" + filenameXML);
		}
		
		private function loadXMLContent(pathXML: String): void {
			this.loaderXMLContent = new LoaderXMLContentView(this.prefixClass);
			this.loaderXMLContent.loadXML(pathXML);
			this.loaderXMLContent.addEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
		}
		
		protected function initOnXMLContentLoaded(e: EventLoaderXML = null): void {
			this.loaderXMLContent.removeEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
			this.loadImgs();
			this.createStarling();
		}
		
		protected function loadImgs(): void {
			LoaderImgs.instance.loadImgs();
		}
		
		protected function get antiAliasing(): int {
			return 3;
		}
		
		protected function get stageScaleMode(): String {
			return StageScaleMode.NO_SCALE;
		}
		
		private function createStarling(): void {
			var classContainerApplication: Class;
			try {
				classContainerApplication = Class(getDefinitionByName(this.prefixClass + ".ContainerApplication")) 
			} catch (e: ReferenceError) {
				classContainerApplication = ContainerApplicationVSPM;
			}
			this.stage.scaleMode = StageScaleMode.EXACT_FIT;
			var widthOriginal: Number = this.stage.stageWidth;
			var heightOriginal: Number = this.stage.stageHeight;
			Starling.handleLostContext = true;
			this.starling = new Starling(classContainerApplication, this.stage);
			this.starling.antiAliasing = this.antiAliasing;
			this.starling.addEventListener(Event.ROOT_CREATED, this.onStarlingRootCreated);
			
			if (this.stageScaleMode == StageScaleMode.NO_SCALE) {
				ApplicationVSPMWeb.FACTOR_SCALE_X = ApplicationVSPMWeb.FACTOR_SCALE_Y = 1;
			} else {
				ApplicationVSPMWeb.FACTOR_SCALE_X = widthOriginal / this.stage.stageWidth;
				ApplicationVSPMWeb.FACTOR_SCALE_Y = heightOriginal / this.stage.stageHeight;
				if (this.stageScaleMode == StageScaleMode.SHOW_ALL)
					ApplicationVSPMWeb.FACTOR_SCALE_X = ApplicationVSPMWeb.FACTOR_SCALE_Y = Math.min(ApplicationVSPMWeb.FACTOR_SCALE_X, ApplicationVSPMWeb.FACTOR_SCALE_Y)
				else if (this.stageScaleMode == StageScaleMode.NO_BORDER)
					ApplicationVSPMWeb.FACTOR_SCALE_X = ApplicationVSPMWeb.FACTOR_SCALE_Y = Math.max(ApplicationVSPMWeb.FACTOR_SCALE_X, ApplicationVSPMWeb.FACTOR_SCALE_Y)
			}
			this.starling.stage.addEventListener(ResizeEvent.RESIZE, this.onStageResize);
			this.setDimensionViewPortAndApplication();
			this.starling.start();
		}
		
		private function onStarlingRootCreated(e: Event): void {
			this.starling.removeEventListener(Event.ROOT_CREATED, this.onStarlingRootCreated);
			this.initViews();
		}
		
		protected function onStageResize(e: ResizeEvent): void {
			this.setDimensionViewPortAndApplication();
		}
		
		private function setDimensionViewPortAndApplication(): void {
			this.starling.viewPort = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			ApplicationVSPMWeb.WIDTH = this.starling.stage.stageWidth = Math.round(this.stage.stageWidth * ApplicationVSPMWeb.FACTOR_SCALE_X);
			ApplicationVSPMWeb.HEIGHT = this.starling.stage.stageHeight = Math.round(this.stage.stageHeight * ApplicationVSPMWeb.FACTOR_SCALE_Y);
		}
		
		/*private function onStageDeactivate(event: Event): void {
			this.starling.stop();
			this.stage.addEventListener(Event.ACTIVATE, this.onStageActivate);
		}

		private function onStageActivate(event: Event): void {
			this.stage.removeEventListener(Event.ACTIVATE, this.onStageActivate);
			this.starling.start();
		}*/
		
		protected function initViews(startIndSection: String = ""): void {
			this.containerApplication = ContainerApplicationVSPM(this.starling.root);
			ManagerPopup.init(this.containerApplication.containerViewPopup);
			ManagerSection.init(this.containerApplication.containerViewSection, startIndSection);
			Metrics.createArrMetricsFromContent(LoaderXMLContentView.content);
		}
		
	}

}