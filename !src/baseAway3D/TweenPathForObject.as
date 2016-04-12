package baseAway3D {
	import away3d.animators.data.Path;
	import away3d.animators.PathAnimator;
	import caurina.transitions.Tweener;
	import flash.utils.Dictionary;
	
	public class TweenPathForObject {
		
		private static var dictObjTimePathAnimatorForObject: Dictionary;
		
		private static function onUpdateTweenPathForObject(object: Object): void {
			var objTimePathAnimatorForObject: Object = TweenPathForObject.dictObjTimePathAnimatorForObject[object];
			if (objTimePathAnimatorForObject != null) {
				objTimePathAnimatorForObject.pathAnimator.update(objTimePathAnimatorForObject.timePathAnimator);
				if (objTimePathAnimatorForObject.onUpdate != null) {
					if (objTimePathAnimatorForObject.onUpdateParams == null) objTimePathAnimatorForObject.onUpdateParams = [];
					objTimePathAnimatorForObject.onUpdate.apply(objTimePathAnimatorForObject.onUpdateScope, [objTimePathAnimatorForObject.timePathAnimator].concat(objTimePathAnimatorForObject.onUpdateParams));
				}
			}
		}
		
		private static function onCompleteTweenPathForObject(object: Object): void {
			var objTimePathAnimatorForObject: Object = TweenPathForObject.dictObjTimePathAnimatorForObject[object];
			if ((objTimePathAnimatorForObject != null) && (objTimePathAnimatorForObject.onComplete != null)) {
				objTimePathAnimatorForObject.onComplete.apply(objTimePathAnimatorForObject.onCompleteScope, objTimePathAnimatorForObject.onCompleteParams);
			}
			delete TweenPathForObject.dictObjTimePathAnimatorForObject[object];
		}
		
		public static function start(object: Object, arrPath: Array, objInit: Object = null, numFrames: uint = 20, transition: String = "linear", onComplete: Function = null, onCompleteScope: Object = null, onCompleteParams: Array = null, onUpdate: Function = null, onUpdateScope: Object = null, onUpdateParams: Array = null) {
			Tweener.removeTweens(object);
			if (TweenPathForObject.dictObjTimePathAnimatorForObject == null) TweenPathForObject.dictObjTimePathAnimatorForObject = new Dictionary();
			if (TweenPathForObject.dictObjTimePathAnimatorForObject[object] != null) {
				Tweener.removeTweens(TweenPathForObject.dictObjTimePathAnimatorForObject[object]);
			}
			var path: Path = new Path(arrPath);
			if (objInit == null) objInit = {lookat:false, aligntopath:false, targetobject:null, offset:null, rotations:null};
			var objTimePathAnimatorForObject: Object = {timePathAnimator: 0, pathAnimator: new PathAnimator(path, object, objInit), onComplete: onComplete, onCompleteScope: onCompleteScope, onCompleteParams: onCompleteParams, onUpdate: onUpdate, onUpdateScope: onUpdateScope, onUpdateParams: onUpdateParams};
			TweenPathForObject.dictObjTimePathAnimatorForObject[object] = objTimePathAnimatorForObject;
			Tweener.addTween(objTimePathAnimatorForObject, {timePathAnimator: 1, time: numFrames, useFrames: true, transition: transition, onUpdate: TweenPathForObject.onUpdateTweenPathForObject, onUpdateScope: TweenPathForObject, onUpdateParams: [object], onComplete: TweenPathForObject.onCompleteTweenPathForObject, onCompleteScope: TweenPathForObject, onCompleteParams: [object]});
		}
		
		public static function isTweening(object: Object): Boolean {
			return ((TweenPathForObject.dictObjTimePathAnimatorForObject != null) && (TweenPathForObject.dictObjTimePathAnimatorForObject[object] != null));
		}
		
		public static function getTweeningTime(object: Object): Number {
			if ((TweenPathForObject.dictObjTimePathAnimatorForObject != null) && (TweenPathForObject.dictObjTimePathAnimatorForObject[object] != null)) {
				return TweenPathForObject.dictObjTimePathAnimatorForObject[object].timePathAnimator;
			} else {
				return -1;
			}
		}
		
		
	}
	
}