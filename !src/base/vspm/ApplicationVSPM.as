package base.vspm {
	import flash.display.Sprite;
	import base.loader.Library;
	import flash.utils.getQualifiedClassName;
	import base.loader.EventLoaderXML;
	import flash.utils.getDefinitionByName;

	public class ApplicationVSPM extends Sprite {
		
		protected var prefixClass: String;
		protected var loaderXMLContent: LoaderXMLContentView;
		private var containerApplication: ContainerApplicationVSPM;
		
		public function ApplicationVSPM(): void {
			Library.addSwf(this);
			new LoaderImgs();
			var nameClassApplication: String = getQualifiedClassName(this);
			this.prefixClass = nameClassApplication.substr(0, nameClassApplication.indexOf('::'));
		}
		
		public function init(pathAssets: String = "", filenameXML: String = "content.xml"): void {
			this.loadXMLContent(pathAssets + "xml/" + filenameXML);
		}
		
		protected function loadXMLContent(pathXML: String): void {
			this.loaderXMLContent = new LoaderXMLContentView(this.prefixClass);
			this.loaderXMLContent.loadXML(pathXML);
			this.loaderXMLContent.addEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
		}
		
		protected function initOnXMLContentLoaded(e: EventLoaderXML = null): void {
			this.loaderXMLContent.removeEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
			this.loadImgs();
			this.initViews();
		}
		
		protected function loadImgs(): void {
			LoaderImgs.instance.loadImgs();
		}
		
		protected function initViews(startIndSection: String = ""): void {
			var classContainerApplication: Class;
			try {
				classContainerApplication = Class(getDefinitionByName(this.prefixClass + ".ContainerApplication"));
			} catch (e: Error) {
				classContainerApplication = ContainerApplicationVSPM;
			}
			this.containerApplication = new classContainerApplication();
			this.addChild(this.containerApplication);
			ManagerPopup.init(containerApplication.containerViewPopup);
			ManagerSection.init(containerApplication.containerViewSection, startIndSection);
			Metrics.createArrMetricsFromContent(LoaderXMLContentView.content);
		}
		
	}

}