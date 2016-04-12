package base.mvc.section {
	import flash.display.Sprite;
	import gearsandcogs.text.UndoTextFields;
	import base.app.InitUtils;
	import base.loader.Library;
	import flash.utils.getQualifiedClassName;
	import base.loader.EventLoaderXML;

	public class ApplicationWithViewSectionWithContent extends Sprite {
		
		private var undoTextFields: UndoTextFields;
		private var loaderXMLContent: LoaderXMLContentViewSection;
		protected var containerViewSection: ContainerViewSection;
		
		public function ApplicationWithViewSectionWithContent(): void {
			//InitUtils.initApp(this);
			Library.addSwf(this);
			new LoaderImgs();
			this.createUndoTextFields();
		}
		
		private function createUndoTextFields(): void {
			this.undoTextFields = new UndoTextFields();
			this.undoTextFields.target = this;
		}
		
		public function init(pathAssets: String = "", filenameXML: String = "content.xml"): void {
			this.loadXMLContent(pathAssets + "xml/" + filenameXML);
		}
		
		private function loadXMLContent(pathXML: String): void {
			this.loaderXMLContent = new LoaderXMLContentViewSection(getQualifiedClassName(this).substr(0, getQualifiedClassName(this).indexOf('::')));
			this.loaderXMLContent.loadXML(pathXML);
			this.loaderXMLContent.addEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
		}
		
		protected function initOnXMLContentLoaded(e: EventLoaderXML = null): void {
			this.loaderXMLContent.removeEventListener(EventLoaderXML.XML_LOADED, this.initOnXMLContentLoaded);
			this.createBg();
			this.createContainerViewSection();
			this.createFg();
			this.loadImgs();
			this.initViewSections("", []);
		}
		
		protected function createBg(): void {}
		
		protected function createContainerViewSection(): void {
			this.containerViewSection = new ContainerViewSection();
			this.containerViewSection.addEventListener(ContainerViewSection.FINISHED_SHOW, this.initViewSections);
			this.addChild(this.containerViewSection);
		}
		
		protected function createFg(): void {}
		
		protected function loadImgs(): void {
			LoaderImgs.instance.loadImgs();
		}
		
		protected function initViewSections(startIndSection: String = "",  arrMetrics: Array = null): void {
			ViewSectionManager.init(this.containerViewSection, startIndSection, arrMetrics);
		}
		
	}

}