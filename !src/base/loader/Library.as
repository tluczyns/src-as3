package base.loader {
	import base.types.Singleton;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.system.ApplicationDomain;
	import flash.display.Bitmap;
	
	public class Library extends Singleton {
		
		private static var arrSwf: Array = [];
		
		public function Library(): void {}
		
		public static function addSwf(swf: DisplayObject): void {
			Library.arrSwf.push(swf);
		}
		
		public static function getClassDefinition(nameClass: String): Class {
			var i: uint = 0;
			var classDef: Class;
			while ((i < Library.arrSwf.length) && (classDef == null)) {
				try {
					classDef = Class(DisplayObject(Library.arrSwf[i]).loaderInfo.applicationDomain.getDefinition(nameClass));
				} catch (e:Error) { }
				i++;
			}
			return classDef;
		}
		
		public static function getMovieClip(nameClass: String, ... params): * {
			var classDef: Class = Library.getClassDefinition(nameClass);
			if (classDef) {
				var mc: *;
				if (params.length) mc = new classDef(params);
				else mc = new classDef();
				return mc;
			} else {
				trace("### ELEMENT |",nameClass,"| NIE ISTNIEJE W BIBLIOTECE")
				return null;
			}
		}
		
		public static function getBitmapData(nameClass: String): BitmapData {
			var classDef: Class = Library.getClassDefinition(nameClass);
			if (classDef) {
				return(new classDef(0, 0));
			}else {
				trace("### ELEMENT |",nameClass,"| NIE ISTNIEJE W BIBLIOTECE")
				return null;
			}
		}
		
		public static function getBitmap(nameClass: String): Bitmap {
			var bmpData: BitmapData = Library.getBitmapData(nameClass);
			if (bmpData) return new Bitmap(bmpData, "auto", true);
			else return null;
		}
		
		public static function getDisplayObject(nameClass: String): DisplayObject {
			var dspObj: DisplayObject = Library.getMovieClip(nameClass)
			if (!dspObj) dspObj = Library.getBitmap(nameClass);
			return dspObj;
		}
		
	}
}