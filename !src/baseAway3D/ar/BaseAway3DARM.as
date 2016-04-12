package baseAway3D.ar {
	import baseAway3D.BaseAway3D;
	//types
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.utils.smoother.FLARMatrixSmoother_Average;
	import flash.utils.Dictionary;
	//init flar manager
	import flash.events.Event;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import flash.events.ErrorEvent;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import com.transmote.flar.source.FLARCameraSource;
	//away 3d
	import away3d.containers.Scene3D;
	import com.transmote.flar.camera.FLARCamera_Away3D;
	import away3d.containers.View3D;
	import com.transmote.flar.marker.FLARMarker;
	import away3d.core.base.Object3D;
	import com.transmote.utils.time.FramerateDisplay;
	//events
	import com.transmote.flar.marker.FLARMarkerEvent;
	import away3d.containers.ObjectContainer3D;
	//process
	import away3d.core.math.MatrixAway3D;
	import flash.geom.Vector3D;
	import com.transmote.flar.utils.geom.AwayGeomUtils;
	
	public class BaseAway3DARM extends BaseAway3D {
		
		private var objParamsInit: Object;
		public var flarManager:FLARManager;
		private var camera: FLARCamera_Away3D;
		private var arrOfArrMarkerByIdPattern:Vector.<Vector.<FLARMarker>>;
		private var dictObject3DByIdPattern: Dictionary;
		private var dictContainer3DByMarker: Dictionary;
		public var isPaused: Boolean;
		
		public function BaseAway3DARM(): void {}
		
		//////init flar manager
		
		override public function init(objParams: Object = null): void {
			this.objParamsInit = objParams;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			if (this.stage)	this.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
		}
		
		private function onAddedToStage(e: Event = null): void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.initParamsFlar();
			this.createFlarManager();
		}	
		
		private function initParamsFlar(): void {
			if (this.objParamsInit == null) this.objParamsInit = { };
			this.objParamsInit.dontRender = false;
			if ((this.objParamsInit.pathFlarConfig == null) || (String(this.objParamsInit.pathFlarConfig) == "")) this.objParamsInit.pathFlarConfig = "./flar/config.xml";
			if (this.objParamsInit.classFlarTrackerManager == null) this.objParamsInit.classFlarTrackerManager = FLARToolkitManager; //FlareManager, FlareNFTManager (IFLARTrackerManager ) http://words.transmote.com/wp/inside-flarmanager-tracking-engines/
			if ((this.objParamsInit.markerUpdateThreshold  == null) || (isNaN(Number(String(this.objParamsInit.markerUpdateThreshold))))) this.objParamsInit.markerUpdateThreshold = 400;
			if ((this.objParamsInit.minChangePositionContainer3D  == null) || (isNaN(Number(String(this.objParamsInit.minChangePositionContainer3D))))) this.objParamsInit.minChangePositionContainer3D = 30;
			if ((this.objParamsInit.minChangeRotationContainer3D == null) || (isNaN(Number(String(this.objParamsInit.minChangeRotationContainer3D))))) this.objParamsInit.minChangeRotationContainer3D = 4;
			if ((this.objParamsInit.minChangeScaleContainer3D == null) || (isNaN(Number(String(this.objParamsInit.minChangeScaleContainer3D))))) this.objParamsInit.minChangeScaleContainer3D =  0.06;
		}
		
		private function createFlarManager(): void {
			this.flarManager = new FLARManager(this.objParamsInit.pathFlarConfig, new this.objParamsInit.classFlarTrackerManager(), this.stage);
			this.flarManager.markerRemovalDelay = 2;
			this.flarManager.markerUpdateThreshold = this.objParamsInit.markerUpdateThreshold;
			this.flarManager.smoother = new FLARMatrixSmoother_Average();
			this.flarManager.smoothing = 1//1000;
			this.flarManager.adaptiveSmoothingCenter = 1000;
			this.flarManager.addEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.addChild(Sprite(this.flarManager.flarSource));
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}

		protected function onFlarManagerError(e: ErrorEvent) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			trace(e.text);
		}
		
		private function onFlarManagerInited(e: Event) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			FLARCameraSource(this.flarManager.flarSource).camera.setQuality(0, 100);
			//FLARCameraSource(this.flarManager.flarSource).camera.setMotionLevel(0, 0)
			this.objParamsInit.dimensionScene = new Rectangle(0, 0, FLARCameraSource(this.flarManager.flarSource).width, FLARCameraSource(this.flarManager.flarSource).height);
			super.init(this.objParamsInit);
		}
		
		//////away 3d
		
		override protected function initAway3D(objParams: Object = null): void {
			this.arrOfArrMarkerByIdPattern = new Vector.<Vector.<FLARMarker>>();
			this.dictObject3DByIdPattern = new Dictionary(true);
			this.dictContainer3DByMarker = new Dictionary(true);
			this.dontRender = objParams.dontRender;
			this.scene = new Scene3D();
			this.camera = new FLARCamera_Away3D(this.flarManager, objParams.dimensionScene);
			this.view = new View3D({scene: this.scene, camera: this.camera, x: objParams.dimensionScene.width / 2, y: objParams.dimensionScene.height / 2, stats: objParams.stats});
			this.setClippingAndRendererAndAddView3D(this.view, objParams);
		}
		
		public function assignObject3DToPattern(object3D: Object3D, idPattern: int = -1): uint {
			if (idPattern == -1) {
				for (var strIdPattern: String in this.dictObject3DByIdPattern)
					idPattern = Math.max(idPattern, uint(strIdPattern));
				idPattern++;
			}
			if (this.dictObject3DByIdPattern[idPattern]) this.unassignObject3DFromPattern(object3D, idPattern);
			if (idPattern >= this.dictObject3DByIdPattern.length) this.dictObject3DByIdPattern.length = idPattern + 1;
			this.dictObject3DByIdPattern[idPattern] = object3D;
			this.addOrRemoveObject3DAfterAssignUnassignToPattern(1, idPattern);
			return idPattern;
		}

		public function unassignObject3DFromPattern(object3D: Object3D, idPattern: int = -1): void {
			var isFoundIdPattern: Boolean = true;
			if (idPattern == -1) {
				isFoundIdPattern = false;
				for (var strIdPattern: String in this.dictObject3DByIdPattern)
					if (this.dictObject3DByIdPattern[strIdPattern] == object3D) {
						isFoundIdPattern = true;
						idPattern = uint(strIdPattern);
						break;
					}
			}
			if (isFoundIdPattern) {
				this.addOrRemoveObject3DAfterAssignUnassignToPattern(0, idPattern);
				delete Object3D(this.dictObject3DByIdPattern[idPattern]);
				this.dictObject3DByIdPattern[idPattern] = null;
			}
		}
		
		private function addOrRemoveObject3DAfterAssignUnassignToPattern(isRemoveAdd: uint, idPattern: uint): void {
			if ((idPattern < this.arrOfArrMarkerByIdPattern.length) && (this.arrOfArrMarkerByIdPattern[idPattern] != null)) {
				var arrMarkerByIdPattern: Vector.<FLARMarker> = this.arrOfArrMarkerByIdPattern[idPattern];
				for (var i: uint = 0; i < arrMarkerByIdPattern.length; i++) {
					var marker: FLARMarker = arrMarkerByIdPattern[i];
					if (isRemoveAdd == 0) this.removeObject3DFromMarkerPattern(marker);
					else if (isRemoveAdd == 1) this.addObject3DFromMarkerPattern(marker);
				}
			}
		}
		
		/*override protected function init3d(): void {
			this.light = new DirectionalLight3D({x:-1000, y:1000, z:-1000, brightness:1});
			this.scene3D.addLight(light);
		}*/
		
		/*override protected function init2d(): void {
			var framerateDisplay: FramerateDisplay = new FramerateDisplay();
			this.addChild(framerateDisplay);
		}*/
		
		//////events
		
		override protected function initEvents(): void {
			super.initEvents()
			this.isPaused = false;
			this.addMarkerEventsForFlarManager();
		}
		
		private function addMarkerEventsForFlarManager(): void {
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function onMarkerAdded (e:FLARMarkerEvent) :void {
			var marker: FLARMarker = FLARMarker(e.marker);
			//trace("["+marker.patternId+"] added");
			this.storeMarker(marker);
			this.addObject3DFromMarkerPattern(marker);
		}
		
		private function storeMarker (marker:FLARMarker) :void {
			var arrMarkerByIdPattern:Vector.<FLARMarker>;
			if (marker.patternId < this.arrOfArrMarkerByIdPattern.length) 
				arrMarkerByIdPattern = this.arrOfArrMarkerByIdPattern[marker.patternId];
			else this.arrOfArrMarkerByIdPattern.length = marker.patternId + 1;
			//trace("arrMarkerByIdPattern:"+arrMarkerByIdPattern)
			if (arrMarkerByIdPattern == null) {
				arrMarkerByIdPattern = new Vector.<FLARMarker>();
				this.arrOfArrMarkerByIdPattern[marker.patternId] = arrMarkerByIdPattern;
			}
			arrMarkerByIdPattern.push(marker);
		}
		
		private function addObject3DFromMarkerPattern(marker: FLARMarker): void {
			if (this.dictObject3DByIdPattern[marker.patternId]) {
				var container3D: ObjectContainer3D = new ObjectContainer3D();
				container3D.addChild(Object3D(this.dictObject3DByIdPattern[marker.patternId]).clone()); //czy można bez clone?
				this.scene.addChild(container3D);
				this.dictContainer3DByMarker[marker] = container3D;
			}
		}
		
		private function onMarkerUpdated (e: FLARMarkerEvent) :void {
			var marker: FLARMarker = FLARMarker(e.marker);
			//trace("["+marker.patternId+"] updated");
		}
		
		private function onMarkerRemoved(e: FLARMarkerEvent): void {
			var marker: FLARMarker = FLARMarker(e.marker);
			//trace("["+marker.patternId+"] removed");
			this.disposeMarker(marker);
			this.removeObject3DFromMarkerPattern(marker);
		}
		
		private function disposeMarker(marker:FLARMarker): void {
			var arrMarkerByIdPattern:Vector.<FLARMarker>;
			if ((marker.patternId < this.arrOfArrMarkerByIdPattern.length) && (this.arrOfArrMarkerByIdPattern[marker.patternId] != null)) {
				arrMarkerByIdPattern = this.arrOfArrMarkerByIdPattern[marker.patternId];
				var indMarker: int = arrMarkerByIdPattern.indexOf(marker);
				if (indMarker != -1) {
					arrMarkerByIdPattern.splice(indMarker, 1);
					if (arrMarkerByIdPattern.length == 0) this.arrOfArrMarkerByIdPattern[marker.patternId] = null;
				}
			}
		}
		
		private function removeObject3DFromMarkerPattern(marker: FLARMarker): void {
			if (this.dictObject3DByIdPattern[marker.patternId]) {
				var container3D: ObjectContainer3D = this.dictContainer3DByMarker[marker];
				if (container3D) {
					//container3D.removeChild(Object3D(container3D.getChildByName("object3D")))
					this.scene.removeChild(container3D);
				}
				delete this.dictContainer3DByMarker[marker];
			}
		}
		
		//////process
		
		override protected function processFrame(): void {
			if (!this.isPaused) {
				var arrMarkerByIdPattern: Vector.<FLARMarker>;
				var marker: FLARMarker;
				var container3D: ObjectContainer3D;
				for (var i: uint = 0; i < this.arrOfArrMarkerByIdPattern.length; i++) {
					if (this.arrOfArrMarkerByIdPattern[i] != null) {
						arrMarkerByIdPattern = this.arrOfArrMarkerByIdPattern[i];
						for (var j: uint = 0; j < arrMarkerByIdPattern.length; j++) {
							marker = arrMarkerByIdPattern[j];
							if (this.dictContainer3DByMarker[marker]) {
								container3D = this.dictContainer3DByMarker[marker];
								var oldTransformContainer3D: MatrixAway3D = container3D.transform;
								var vectorOldPosContainer3D: Vector3D = new Vector3D(container3D.x, container3D.y, container3D.z);
								var vectorOldRotationContainer3D: Vector3D = new Vector3D(container3D.rotationX, container3D.rotationY, container3D.rotationZ);
								var oldScaleContainer3D: Number = container3D.scaleX;
								
								container3D.transform = AwayGeomUtils.convertMatrixToAwayMatrix(marker.transformMatrix, this.flarManager.mirrorDisplay);
								container3D.scale(Math.max(container3D.scaleX, container3D.scaleY, container3D.scaleZ));
								var vectorNewPosContainer3D: Vector3D = new Vector3D(container3D.x, container3D.y, container3D.z);
								var vectorNewRotationContainer3D: Vector3D = new Vector3D(container3D.rotationX, container3D.rotationY, container3D.rotationZ);
								var newScaleContainer3D: Number = container3D.scaleX;
								if (Vector3D.distance(vectorOldPosContainer3D, vectorNewPosContainer3D) < this.objParamsInit.minChangePositionContainer3D) {
									container3D.x = vectorOldPosContainer3D.x;
									container3D.y = vectorOldPosContainer3D.y;
									container3D.z = vectorOldPosContainer3D.z;
								}
								if (Vector3D.distance(vectorOldRotationContainer3D, vectorNewRotationContainer3D) < this.objParamsInit.minChangeRotationContainer3D) {
									container3D.rotationX = vectorOldRotationContainer3D.x;
									container3D.rotationY = vectorOldRotationContainer3D.y;
									container3D.rotationZ = vectorOldRotationContainer3D.z;
								}
								if (Math.abs(newScaleContainer3D - oldScaleContainer3D) < this.objParamsInit.minChangeScaleContainer3D) {
									container3D.scaleX = container3D.scaleY = container3D.scaleZ = oldScaleContainer3D;
								}
							}
						}	
					}
				}
			}
		}		
		
		//////destroy
		
		private function removeMarkerEventsForFlarManager(): void {
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		override public function destroy(): void {
			if (this.dictContainer3DByMarker != null) {
				for (var strMarker: String in this.dictContainer3DByMarker) {
					delete ObjectContainer3D(this.dictContainer3DByMarker[strMarker]);
				}
				this.dictContainer3DByMarker = null;
			}
			if (this.dictObject3DByIdPattern != null) {
				for (var strIdPattern: String in this.dictObject3DByIdPattern) {
					delete Object3D(this.dictObject3DByIdPattern[strIdPattern]);
				}
				this.dictObject3DByIdPattern = null;
			}
			if (this.flarManager != null) {
				if (this.flarManager.hasEventListener(Event.INIT)) {
					this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
					this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
				} else this.removeMarkerEventsForFlarManager();
				this.flarManager.dispose();
			}
			super.destroy();
		}
		
	}
	
}