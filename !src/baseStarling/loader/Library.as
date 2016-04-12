package baseStarling.loader {
	import base.types.Singleton;
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.core.Starling;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;

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
		
		public static function getMovieClip(classTextureOrNameClass: Object, classData: Class): MovieClip {
			var texture: Texture;
			if (classTextureOrNameClass is Class) texture = Texture.fromBitmap(new classTextureOrNameClass());
			else texture = Library.getTexture(String(classTextureOrNameClass));
			var data: XML = XML(new classData());
			var textureAtlas: TextureAtlas =  new TextureAtlas(texture, data);
			var mc: MovieClip = new MovieClip(textureAtlas.getTextures(), Starling.current.nativeStage.frameRate);		 
			Starling.juggler.add(mc);
			return mc;
		}
		
		public static function getBitmapData(nameClass: String): BitmapData {
			var classDef: Class = Library.getClassDefinition(nameClass);
			var bmpData: BitmapData;
			if (classDef) {
	 			try {
					var spr: Sprite = new classDef();
					var boundSpr: Rectangle = spr.getBounds(spr);
					bmpData = new BitmapData(boundSpr.width, boundSpr.height, true, 0x00000000);
					bmpData.draw(spr, new Matrix(1, 0, 0, 1, - boundSpr.x, - boundSpr.y), null, null, null, true);
				} catch (e: Error) {
					bmpData = new classDef(0, 0);
				}
			} else trace("### SYMBOL |",nameClass,"| NIE ISTNIEJE W BIBLIOTECE")
			return bmpData;
		}
		
		public static function getTexture(nameClass: String): Texture {
			var bmpData: BitmapData = Library.getBitmapData(nameClass);
			var texture: Texture;
			if (bmpData) {
				texture = Texture.fromBitmapData(bmpData);
				//bmpData.dispose(); //zakomentowane dla zmiany orientacji
			}
			return texture;
		}
		
	}
}