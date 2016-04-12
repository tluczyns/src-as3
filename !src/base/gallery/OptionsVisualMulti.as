package base.gallery {
	import com.greensock.easing.*;
	
	public class OptionsVisualMulti extends Object {

		public var isDepthManagement: Boolean;
		public var isAlphaManagement: Boolean;
		public var timeMoveOneRenderable: Number;
		public var easeMoveRenderables: Function;
		
		public function OptionsVisualMulti(isDepthManagement: Boolean = true, isAlphaManagement: Boolean = true, timeMoveOneRenderable: Number = 0.7, easeMoveRenderables: Function = null): void {
			this.isDepthManagement = isDepthManagement;
			this.isAlphaManagement = isAlphaManagement;
			this.timeMoveOneRenderable = timeMoveOneRenderable;
			this.easeMoveRenderables = easeMoveRenderables || Cubic.easeInOut //Bounce.easeOut;
		}
		
	}

}