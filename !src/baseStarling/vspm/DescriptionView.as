package baseStarling.vspm {
	import starling.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	//import base.types.DictionaryExt;
	import base.types.ObjectUtils;
	
	public class DescriptionView extends Object {
		
		public var ind: String;
		public var nameClass: Class;
		public var content: ContentView;
		public var x: Number;
		public var y: Number;
		public var containerView: DisplayObjectContainer;
		public var view: View;
		
		public function DescriptionView(ind: String, nameClass: Class, content: ContentView, x: Number = 0, y: Number = 0, containerView: DisplayObjectContainer = null): void {
			this.ind = ind;
			this.nameClass = nameClass;
			this.content = content;
			this.x = x;
			this.y = y;
			this.containerView = containerView;
			this.view = null;
			this.addToDictInManager();
		}
		
		protected function getDictDescriptionViewInManager(): Dictionary { //DictionaryExt
			throw new Error("getDictDescriptionViewFromManager must be implemented");
		}
		
		private function addToDictInManager(): void {
			var dictDescriptionViewInManager: Dictionary = this.getDictDescriptionViewInManager();  //DictionaryExt
			if (dictDescriptionViewInManager[this.ind]) DescriptionView(dictDescriptionViewInManager[this.ind]).addAdditionalContent(this);
			else dictDescriptionViewInManager[this.ind] = this;
		}
		
		internal function addAdditionalContent(descriptionView: DescriptionView): void {
			if (!this.nameClass) this.nameClass = descriptionView.nameClass;
			this.content = ContentView(ObjectUtils.populateObj(descriptionView.content, this.content));
		}
		
		protected function createViewInstance(): View {
			throw new Error("createViewInstance must be implemented");
		}
		
		protected function getDefaultContainerView(): DisplayObjectContainer {
			throw new Error("getDefaultContainerView must be implemented");
		}
		
		private function getContainerView(): DisplayObjectContainer {
			return (this.containerView != null) ? this.containerView : this.getDefaultContainerView();
		}
		
		public function createView(): void {
			var containerView: DisplayObjectContainer = this.getContainerView();
			if ((this.view == null) && (this.nameClass)) {
				this.view = this.createViewInstance();
				this.view.description = this;
				this.view.x = this.x;
				this.view.y = this.y;
				containerView.addChild(this.view);
				containerView.setChildIndex(this.view, containerView.numChildren - 1);
				this.view.init();
			}
		}
		
		public function removeView(): void {
			var containerView: DisplayObjectContainer = this.getContainerView();
			if (this.view != null) {
				containerView.removeChild(this.view);
				this.view = null;
			}
		}
		
	}

}