package base.dspObj {
	import base.types.Singleton;
	import flash.utils.Dictionary;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.AutoAlphaPlugin;
	import flash.display.DisplayObject;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.HexColorsPlugin;
	import com.greensock.plugins.TintPlugin;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.greensock.plugins.FramePlugin;
	
	public class DoOperations extends Singleton {
	
		private static var dictOnCompleteHide: Dictionary;
		private static var dictOnCompleteHideParams: Dictionary;
		
		{
			DoOperations.dictOnCompleteHide = new Dictionary();
			DoOperations.dictOnCompleteHideParams = new Dictionary();
			TweenPlugin.activate([AutoAlphaPlugin]);
		}
		
		public static function hideShow(dspObj: DisplayObject, isHideShow: uint, numFrames: int = 10, onComplete: Function = null, onCompleteParams: Array = null): void {
			//if (((isHideShow == 0) && (dspObj.alpha > 0)) || ((isHideShow == 1) && (dspObj.alpha < 1))) {
				if (numFrames == -1) numFrames = 10;
				if (isHideShow == 0) {
					DoOperations.dictOnCompleteHide[dspObj] = onComplete;
					if (DoOperations.dictOnCompleteHide[dspObj] != null) {
						DoOperations.dictOnCompleteHideParams[dspObj] = (onCompleteParams != null) ? onCompleteParams: [];
					}
					onComplete = function(dspObj: DisplayObject): void {
						dspObj.visible = false;
						if (DoOperations.dictOnCompleteHide[dspObj] != null) DoOperations.dictOnCompleteHide[dspObj].apply(null, DoOperations.dictOnCompleteHideParams[dspObj]);
					}
					onCompleteParams = [dspObj]; 
				} else if (isHideShow == 1) {
					dspObj.visible = true;
					if (onComplete != null)
						onCompleteParams = (onCompleteParams != null) ? onCompleteParams : [];
				}
				try {
					TweenLite.killTweensOf(dspObj, false, {autoAlpha: true});
				} catch(e: TypeError) {};
				TweenLite.to(dspObj, numFrames, {autoAlpha: isHideShow, useFrames: true, ease: Linear.easeNone, onComplete: onComplete, onCompleteParams: onCompleteParams});
			//}
		}
		
		public static function setColor(dspObj: DisplayObject, tint: uint, numFrames: int = 10, onComplete: Function = null, onCompleteParams: Array = null): void {
			if (onComplete != null)
				onCompleteParams = (onCompleteParams != null) ? onCompleteParams : [];
			if ((getDefinitionByName(getQualifiedClassName(dspObj)) == TextField) || (getDefinitionByName(getQualifiedSuperclassName(dspObj)) == TextField)) {
				TweenPlugin.activate([HexColorsPlugin, TintPlugin]);
				var objColorTf: Object = {tint: TextField(dspObj).getTextFormat().color};
				TweenLite.killTweensOf(objColorTf, false, {hexColors: true});
				TweenLite.to(objColorTf, numFrames, {hexColors:{tint: tint}, useFrames: true, ease: Linear.easeNone, onUpdate: DoOperations.drawColorTf, onUpdateParams: [TextField(dspObj), objColorTf], onComplete: onComplete, onCompleteParams: onCompleteParams});
			} else {
				
				TweenLite.killTweensOf(dspObj, false, {tint: true});
				TweenLite.to(dspObj, numFrames, {tint: tint, useFrames: true, ease: Linear.easeNone, onComplete: onComplete, onCompleteParams: onCompleteParams});
			}
		}
		
		static private function drawColorTf(tf: TextField, objColorTf: Object): void {
			var tFormat: TextFormat = tf.getTextFormat();
			tFormat.color = objColorTf.tint;
			tf.defaultTextFormat = tFormat;
			tf.setTextFormat(tFormat); 
		}
		
		public static function playToFrame(mc: MovieClip, targetFrame: int = -1, onComplete: Function = null, onCompleteParams: Array = null): void {
			DoOperations.stopPlaying(mc);
			if (targetFrame == -1) targetFrame = mc.totalFrames;
			if (targetFrame != mc.currentFrame) TweenLite.to(mc, Math.abs(targetFrame - mc.currentFrame), {frame: targetFrame, useFrames: true, ease: Linear.easeNone, onComplete: onComplete, onCompleteParams: onCompleteParams});
			else if (Boolean(onComplete)) onComplete.apply(null, onCompleteParams);
		}
		
		public static function stopPlaying(mc: MovieClip): void {
			TweenPlugin.activate([FramePlugin]);
			TweenLite.killTweensOf(mc, false, {frame: true});
		}

	}

}