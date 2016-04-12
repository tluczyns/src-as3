package base {
	import caurina.transitions.Tweener;
	
	public class Tween01 {
		
		public var objRatio: Object;
		
		public function Tween01() {
			this.objRatio = { value: 0 };
		}
		
		private function initParams(objParams: Object): Object {
			if (objParams == null) objParams = {};
			if (objParams.targetRatio == null) objParams.targetRatio = 1;
			if (objParams.transition == null) objParams.transition = "linear";
			if (objParams.totalFrames == null) objParams.totalFrames = 30;
			if (objParams.numFrames == null) objParams.numFrames = Math.abs(objParams.targetRatio - this.objRatio.value) * objParams.totalFrames;
			if (objParams.onUpdateParams == null) objParams.onUpdateParams = [];
			return objParams;
		}

		public function tween(objParams: Object = null): void {
			objParams = this.initParams(objParams);
			Tweener.addTween(this.objRatio, {value: objParams.targetRatio, time: objParams.numFrames, useFrames: true, transition: objParams.transition, onUpdate: objParams.onUpdate, onUpdateScope: objParams.onUpdateScope, onUpdateParams: objParams.onUpdateParams, onComplete: objParams.onComplete, onCompleteScope: objParams.onCompleteScope, onCompleteParams: objParams.onCompleteParams});
		}
		
		public function stop(): void {
			if (Tweener.isTweening(this.objRatio)) Tweener.removeTweens(this.objRatio, "value");
		}
	}
	
}