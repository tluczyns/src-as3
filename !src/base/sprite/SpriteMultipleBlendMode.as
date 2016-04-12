package base.sprite {
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	
	public class SpriteMultipleBlendMode extends Sprite {
		
		protected var arrDspObjBlendMode: Array;
		
		public function SpriteMultipleBlendMode(classDspObjForMultipleBlendModes: Class, arrBlendMode: Array): void {
			this.arrDspObjBlendMode = new Array(arrBlendMode.length);
			var isBmpData: Boolean = (getDefinitionByName(getQualifiedSuperclassName(classDspObjForMultipleBlendModes)) == BitmapData);
			for (var i: uint = 0; i < arrBlendMode.length; i++) {
				var dspObjBlendMode: DisplayObject;
				if (isBmpData) dspObjBlendMode = new Bitmap(new classDspObjForMultipleBlendModes(), "auto", true);
				else dspObjBlendMode = new classDspObjForMultipleBlendModes();
				dspObjBlendMode.blendMode = arrBlendMode[i];
				this.addChild(dspObjBlendMode);
				this.arrDspObjBlendMode[i] = dspObjBlendMode;
			}
		}
		
		public function destroy(): void {
			for (var i: uint = 0; i < this.arrDspObjBlendMode.length; i++) {
				var dspObjBlendMode: DisplayObject = this.arrDspObjBlendMode[i];
				this.removeChild(dspObjBlendMode);
				if (dspObjBlendMode is Bitmap) Bitmap(dspObjBlendMode).bitmapData.dispose();
				dspObjBlendMode = null;
			}
			this.arrDspObjBlendMode = [];
		}
		
	}

}