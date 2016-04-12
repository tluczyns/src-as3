package baseStarling.vspm {
	import flash.display.Sprite;
	import starling.core.Starling;
	import baseStarling.loader.Library;
	import flash.utils.getQualifiedClassName;
	import base.loader.EventLoaderXML;
	import flash.display.StageScaleMode;
	import flash.utils.getDefinitionByName;
	import starling.events.Event;
	import flash.events.StageOrientationEvent;
	import starling.events.ResizeEvent;
	import flash.geom.Rectangle;

	public class ApplicationVSPM extends Sprite {
		
		static public const START_ORIENTATION_CHANGE: String = "startOrientationChange";
		static public const END_ORIENTATION_CHANGE: String = "endOrientationChange";
		
		static public var WIDTH: Number;
		static public var HEIGHT: Number;
		static public var FACTOR_SCALE_X: Number;
		static public var FACTOR_SCALE_Y: Number;
		
		private var prefixClass: String;
		private var loaderXMLContent: LoaderXMLContentView;
		protected var starling: Starling;
		private var isOrientationChanging: Boolean;
		protected var containerApplication: ContainerApplicationVSPM;
		
		public function ApplicationVSPM(): void {
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
				ApplicationVSPM.FACTOR_SCALE_X = ApplicationVSPM.FACTOR_SCALE_Y = 1;
			} else {
				ApplicationVSPM.FACTOR_SCALE_X = widthOriginal / this.stage.stageWidth;
				ApplicationVSPM.FACTOR_SCALE_Y = heightOriginal / this.stage.stageHeight;
				if (this.stageScaleMode == StageScaleMode.SHOW_ALL)
					ApplicationVSPM.FACTOR_SCALE_X = ApplicationVSPM.FACTOR_SCALE_Y = Math.min(ApplicationVSPM.FACTOR_SCALE_X, ApplicationVSPM.FACTOR_SCALE_Y)
				else if (this.stageScaleMode == StageScaleMode.NO_BORDER)
					ApplicationVSPM.FACTOR_SCALE_X = ApplicationVSPM.FACTOR_SCALE_Y = Math.max(ApplicationVSPM.FACTOR_SCALE_X, ApplicationVSPM.FACTOR_SCALE_Y)
			}
			this.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, this.dispatchStartOrientationChange);
			this.starling.addEventListener(Event.CONTEXT3D_CREATE, this.dispatchEndOrientationChange);
			this.starling.stage.addEventListener(ResizeEvent.RESIZE, this.onStageResize);
			this.setDimensionViewPortAndApplication();
			this.starling.start();
		}
		
		private function dispatchStartOrientationChange(e: StageOrientationEvent = null): void {
			if (!this.isOrientationChanging) {
				this.isOrientationChanging = true;
				this.stage.dispatchEvent(new flash.events.Event(ApplicationVSPM.START_ORIENTATION_CHANGE));
				this.addEventListener(flash.events.Event.ENTER_FRAME, this.checkIsContextAndDispatchEndOrientationChange);
			}
		}
		
		private function checkIsContextAndDispatchEndOrientationChange(e: flash.events.Event): void {
			if ((this.starling.context) && (this.starling.context.driverInfo != "Disposed"))
				this.dispatchEndOrientationChange();
		}
		
		private function dispatchEndOrientationChange(e: Event = null): void {
			if (this.isOrientationChanging) {
				this.isOrientationChanging = false;
				this.removeEventListener(flash.events.Event.ENTER_FRAME, this.checkIsContextAndDispatchEndOrientationChange);
				this.stage.dispatchEvent(new flash.events.Event(ApplicationVSPM.END_ORIENTATION_CHANGE));
			}
		}
		
		private function onStarlingRootCreated(e: Event): void {
			this.starling.removeEventListener(Event.ROOT_CREATED, this.onStarlingRootCreated);
			this.initViews();
		}
		
		protected function onStageResize(e: ResizeEvent): void {
			this.setDimensionViewPortAndApplication();
			this.dispatchStartOrientationChange();
		}
		
		private function setDimensionViewPortAndApplication(): void {
			this.starling.viewPort = new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			ApplicationVSPM.WIDTH = this.starling.stage.stageWidth = Math.round(this.stage.stageWidth * ApplicationVSPM.FACTOR_SCALE_X);
			ApplicationVSPM.HEIGHT = this.starling.stage.stageHeight = Math.round(this.stage.stageHeight * ApplicationVSPM.FACTOR_SCALE_Y);
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