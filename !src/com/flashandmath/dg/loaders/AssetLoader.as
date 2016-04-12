/*

Modified from my PictureLoader class.  Made simpler.

properties:

	.assetArray:Array - an array of bitmap images - use get method
	
	.useFailasset:Boolean - whether to use fail asset in place of intended load
	
	.failassetSize:Number - side length of square fail asset
	
methods:

	assetLoader(_useFailasset = true, _failassetSize = 16)
	
	loadassets(inputURLArray:Array):void

events:

	ALL_assetS_LOADED
	



*/


package com.flashandmath.dg.loaders {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.flashandmath.dg.loaders.IndexedLoader;
	
	public class AssetLoader extends EventDispatcher {
		
		public static const ALL_ASSETS_LOADED:String="allAssetsLoaded";
		
		private function dispatch():void {
			dispatchEvent(new Event(AssetLoader.ALL_ASSETS_LOADED));
		}

		public var assetURLArray:Array = [];
		private var assetLoader:Array = [];
		private var asset:Array=[];
		private var loadCount:Number;
		
		public function AssetLoader() {
			//empty constructor
		}
				
		public function loadAssets(inputURLArray:Array):void {
			assetURLArray = inputURLArray;
			asset = [];
			loadCount = 0;
			setUpLoaders();
		}
								
		private function setUpLoaders():void {
			var thisURL:URLRequest;
			//create a loader for each asset, to load simultaneously.
			for (var n:Number=0; n<= assetURLArray.length-1; n++) {
				var thisLoader:IndexedLoader = new IndexedLoader(n);
				assetLoader.push(thisLoader);
				assetLoader[n].load(new URLRequest(assetURLArray[n]));
				assetLoader[n].contentLoaderInfo.addEventListener(Event.INIT, initListener);
			}
		}
				
		private function initListener(evt:Event):void {
			//copy loaded asset to asset array
			var n:Number = evt.currentTarget.loader.which;
			//trace("asset "+String(n)+" loaded.");
			asset[n] = assetLoader[n].content;
			//remove event listener
			assetLoader[n].contentLoaderInfo.removeEventListener(Event.INIT, initListener);
			loadCount++;
			if (loadCount == assetURLArray.length) {
				dispatch();
			}
		}
		
		public function get assetArray():Array {
			return asset;
		}
	}
}
		
