package baseAway3D.ar {
	import baseAway3D.BaseAway3D;
	import base.loader.LoadContentQueue;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.FLARCode;
	import base.webcam.BmpWebcamCapture;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.support.away3d.FLARCamera3D;
	import org.libspark.flartoolkit.support.away3d.FLARBaseNode;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import away3d.primitives.Trident;
	
	public class BaseAway3DAR extends BaseAway3D {
		
		private var funcInit: Function;
		protected var objParamsInit: Object;
		private var indDataParamInArrContent: uint;
		private var indDataCodeInArrContent: uint;
		
		private var param:FLARParam;
		private var code:FLARCode;
		private var raster: FLARRgbRaster_BitmapData;
		private var detector: * //: FLARSingleMarkerDetector;
		
		private var camera3D: FLARCamera3D;
		protected var baseNode: FLARBaseNode;
		private var objCurrentPositionRotationBaseNode: Object;
		private var objPreviousPositionRotationBaseNode: Object;
		private var transMatResult: FLARTransMatResult = new FLARTransMatResult();
		private var timeoutHideBaseNode: uint;
		private var isBaseNodeInScene: Boolean;
		
		public function BaseAway3DAR(): void {}
		
		override public function init(objParamsAR: Object = null): void {
			this.funcInit = super.init;
			objParamsAR = this.initParamsFilesToLoad(objParamsAR);
			this.objParamsInit = objParamsAR;
			this.loadFiles(objParamsAR);
		}

		private function initParamsFilesToLoad(objParamsARFiles : Object = null): Object {
			if (objParamsARFiles == null) objParamsARFiles = { };
			if ((objParamsARFiles.filenameParam == null) || (String(objParamsARFiles.filenameParam) == "")) objParamsARFiles.filenameParam = "flar/camera.dat";
			objParamsARFiles = this.initParamsFilesCodeToLoad(objParamsARFiles);
			return objParamsARFiles;
		}
		
		protected function initParamsFilesCodeToLoad(objParamsARFiles : Object = null): Object {
			if ((objParamsARFiles.filenameCode == null) || (String(objParamsARFiles.filenameCode) == "")) objParamsARFiles.filenameCode = "flar/pattern/flarlogo.pat";
			if ((objParamsARFiles.dimensionCode == null) || (String(objParamsARFiles.dimensionCode) == "")) objParamsARFiles.dimensionCode = 16;
			return objParamsARFiles;
		}
		
		private function loadFiles(objParamsARFiles: Object): void {
			var loadContentQueue: LoadContentQueue = new LoadContentQueue(this.onFilesLoadCompleteHandler, this);
			this.indDataParamInArrContent = loadContentQueue.addToLoadQueue(objParamsARFiles.filenameParam, 1, 1);
			this.loadFilesCode(loadContentQueue, objParamsARFiles);
			loadContentQueue.startLoading();
		}
		
		protected function loadFilesCode(loadContentQueue: LoadContentQueue, objParamsARFiles: Object): void {
			this.indDataCodeInArrContent = loadContentQueue.addToLoadQueue(objParamsARFiles.filenameCode);
		}
		
		private function onFilesLoadCompleteHandler(arrFile: Array): void {
			var dataParamInArrContent: Object = arrFile[this.indDataParamInArrContent];
			if ((dataParamInArrContent.isLoaded) && (this.onFilesCodeLoadCompleteHandler(arrFile))) {
				this.param = new FLARParam();
				this.param.loadARParam(dataParamInArrContent.content);
				this.funcInit.apply(this, [this.objParamsInit]);
			}
		}
		
		protected function onFilesCodeLoadCompleteHandler(arrFile: Array): Boolean {
			var dataCodeInArrContent: Object = arrFile[this.indDataCodeInArrContent];
			if (dataCodeInArrContent.isLoaded) {
				this.code = new FLARCode(this.objParamsInit.dimensionCode, this.objParamsInit.dimensionCode);
				this.code.loadARPatt(dataCodeInArrContent.content);
				return true;
			} else return false;
		}
		
		override protected function initParams(objParamsAR: Object = null): Object {
			objParamsAR = super.initParams(objParamsAR);
			if ((objParamsAR.codeWidth == null) || (isNaN(Number(objParamsAR.codeWidth)))) objParamsAR.codeWidth = 80;
			return objParamsAR;
		}
		
		override protected function initAway3D(objParamsAR: Object = null): void {
			this.param.changeScreenSize(objParamsAR.dimensionScene.width, objParamsAR.dimensionScene.height);
			var bmpWebcamCaptureHighContrast: BmpWebcamCaptureHighContrast = new BmpWebcamCaptureHighContrast(objParamsAR.dimensionScene.width, objParamsAR.dimensionScene.height);
			bmpWebcamCaptureHighContrast.video.scaleX *= 2;
			bmpWebcamCaptureHighContrast.video.scaleY *= 2;
			bmpWebcamCaptureHighContrast.video.x = bmpWebcamCaptureHighContrast.video.width;
			bmpWebcamCaptureHighContrast.visible = false;
			this.addChild(bmpWebcamCaptureHighContrast);
			this.addChild(bmpWebcamCaptureHighContrast.video);
			this.raster = new FLARRgbRaster_BitmapData(bmpWebcamCaptureHighContrast.bitmapData);
			this.createDetector(objParamsAR);
			objParamsAR.dontRender = true;
			objParamsAR.dimensionScene.width *= 2;
			objParamsAR.dimensionScene.height *= 2;
			super.initAway3D(objParamsAR);
			this.view.x = objParamsAR.dimensionScene.width / 2 - 4;
			this.view.y = objParamsAR.dimensionScene.height / 2;
			this.scaleX = this.stage.stageWidth / objParamsAR.dimensionScene.width;
			this.scaleY = this.stage.stageHeight / objParamsAR.dimensionScene.height;
			this.camera3D = new FLARCamera3D();
			this.camera3D.setParam(this.param);
			this.view.camera = this.camera3D;
			this.baseNode = new FLARBaseNode();
			this.scene.addChild(this.baseNode);
			this.isBaseNodeInScene = false;
			//var trident: Trident = new Trident(1000, true);
			//this.baseNode.addChild(trident)
		}
		
		protected function createDetector(objParamsAR: Object): void {
			this.detector = new FLARSingleMarkerDetector(this.param, this.code, objParamsAR.codeWidth);
			//FLARSingleMarkerDetector(this.detector).setContinueMode(true);	
		}
		
		override protected function processFrame(): void {
			var detected: Boolean = false;
			try {
				detected = this.detector.detectMarkerLite(this.raster, 80) && this.detector.getConfidence() > 0.2;
			} catch (e:Error) { trace("error:" + e) }
			//trace("detected:"+detected)
			if (detected) {
				this.detector.getTransformMatrix(this.transMatResult);
				this.baseNode.setTransformMatrix(this.transMatResult);
				clearTimeout(this.timeoutHideBaseNode);
				if (!this.isBaseNodeInScene) {
					this.scene.addChild(this.baseNode);
					this.isBaseNodeInScene = true;
				}
				
			} else {
				if (this.isBaseNodeInScene) {
					//this.scene.removeChild(this.baseNode);
					//this.isBaseNodeInScene = false;
					//this.moveOrHideBaseNodeWhenNotDetected(this.baseNode);
					clearTimeout(this.timeoutHideBaseNode);
					this.timeoutHideBaseNode = setTimeout(this.removeBaseNodeFromScene, 500);
				}
			}
			this.view.render();
			//this.setPreviousAndCurrentPositionRotationBaseNode(this.baseNode);
		}
		
		private function removeBaseNodeFromScene(): void {
			this.scene.removeChild(this.baseNode);
			this.isBaseNodeInScene = false;
		}
		
		private function moveOrHideBaseNodeWhenNotDetected(baseNode: FLARBaseNode): void {
			if ((baseNode.objCurrentPositionRotation != null) && (baseNode.objPreviousPositionRotation != null)) {
				var ratioPreviousPositionRotation: Number = 1.1;
				baseNode.x += ((baseNode.objCurrentPositionRotation.x - baseNode.objPreviousPositionRotation.x) / ratioPreviousPositionRotation);
				baseNode.y += ((baseNode.objCurrentPositionRotation.y - baseNode.objPreviousPositionRotation.y) / ratioPreviousPositionRotation); 
				baseNode.z += ((baseNode.objCurrentPositionRotation.z - baseNode.objPreviousPositionRotation.z) / ratioPreviousPositionRotation);
				baseNode.rotationX += ((baseNode.objCurrentPositionRotation.rotationX - baseNode.objPreviousPositionRotation.rotationX) / ratioPreviousPositionRotation);
				baseNode.rotationY += ((baseNode.objCurrentPositionRotation.rotationY - baseNode.objPreviousPositionRotation.rotationY) / ratioPreviousPositionRotation);
				baseNode.rotationZ += ((baseNode.objCurrentPositionRotation.rotationZ - baseNode.objPreviousPositionRotation.rotationZ) / ratioPreviousPositionRotation);
			} else this.scene.removeChild(this.baseNode);
		}

		private function setPreviousAndCurrentPositionRotationBaseNode(baseNode: FLARBaseNode): void {
			baseNode.objPreviousPositionRotation = baseNode.objCurrentPositionRotation;
			baseNode.objCurrentPositionRotation = {x: baseNode.x, y: baseNode.y, z: baseNode.z, rotationX: baseNode.rotationX, rotationY: baseNode.rotationY, rotationZ: baseNode.rotationZ};
		}
		
	}

}