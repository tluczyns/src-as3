package baseAway3D.ar {
	import base.loader.LoadContentQueue;
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	
	public class BaseAway3DAR_MMD extends BaseAway3DAR {
		
		private var arrCode: Array;
		
		public function BaseAway3DAR_MMD(): void {}
		
		override protected function initParamsFilesCodeToLoad(objParamsARFiles : Object = null): Object {
			if ((objParamsARFiles.arrObjFilenameDimensionCode == null) || (Array(objParamsARFiles.arrObjFilenameDimensionCode.length) == 0)) objParamsARFiles.arrObjFilenameDimensionCode = [{filename: "data/flarlogo.pat", dimension: 16}];
			return objParamsARFiles;
		}
		
		override protected function loadFilesCode(loadContentQueue: LoadContentQueue, objParamsARFiles: Object): void {
			for (var i:uint = 0; i < objParamsARFiles.arrObjFilenameDimensionCode.length; i++) {
				var objFilenameDimensionCode: Object = objParamsARFiles.arrObjFilenameDimensionCode[i];
				objFilenameDimensionCode.inDataInArrContent = loadContentQueue.addToLoadQueue(objFilenameDimensionCode.filename);
				objParamsARFiles.arrObjFilenameDimensionCode[i] = objFilenameDimensionCode;
			}
		}
		
		override protected function onFilesCodeLoadCompleteHandler(arrFile: Array): Boolean {
			var isAllLoaded: Boolean = true;
			this.arrCode = new Array(this.objParamsInit.arrObjFilenameDimensionCode.length);
			for (var i:uint = 0; i < this.objParamsInit.arrObjFilenameDimensionCode.length; i++) {
				var objFilenameDimensionCode: Object = this.objParamsInit.arrObjFilenameDimensionCode[i];
				var dataCodeInArrContent: Object = arrFile[objFilenameDimensionCode.indDataInArrContent];
				if (dataCodeInArrContent.isLoaded) {
					var code: FLARCode = new FLARCode(objFilenameDimensionCode.dimension, objFilenameDimensionCode.dimension);
					code.loadARPatt(dataCodeInArrContent.content);
					this.arrCode[i] = code;
				} else isAllLoaded = false;
			}
			return isAllLoaded;
		}
		
		override protected function initParams(objParamsAR: Object = null): Object {
			objParamsAR = super.initParams(objParamsAR);
			if ((objParamsAR.arrCodeWidth == null) || (Array(objParamsAR.arrCodeWidth).length == 0)) objParamsAR.arrCodeWidth = [80];
			if (objParamsAR.arrCodeWidth.length < this.arrCode.length) {
				for (var i: uint = objParamsAR.arrCodeWidth.length; i < this.arrCode.length; i++) {
					objParamsAR.arrCodeWidth.push(objParamsAR.arrCodeWidth[0]);
				}
			}
			return objParamsAR;
		}
		
		override protected function createDetector(): void {
			this.detector = new FLARMultiMarkerDetector(this.param, this.arrCode, objParamsAR.arrCodeWidth, this.arrCode.length);
			FLARMultiMarkerDetector(this.detector).setContinueMode(true)
			FLARMultiMarkerDetector(this.detector).detectMarkerLite
			FLARMultiMarkerDetector(this.detector).getTransmationMatrix(
		}
		
		
		private function detectMarkers () :void {
			var numFoundMarkers:int = 0;
			try {
				// detect marker(s)
				numFoundMarkers = this.detector.detectMarkerLite(this.flarRaster, this.threshold);
			} catch (e:FLARException) {
				// error in FLARToolkit processing; send to console
				trace(e);
				return;
			}
			
			var activeMarker:FLARMarker;
			var i:uint;
			if (numFoundMarkers == 0) {
				// if no markers found, remove any existing markers and exit
				i = this._activeMarkers.length;
				while (i--) {
					this.queueMarkerForRemoval(this._activeMarkers[i]);
				}
				return;
			}
			
			// build list of detected markers
			var arrMarkersDetected: Array = new Array();
			var detectedMarkerResult:FLARMultiMarkerDetectorResult;
			var patternIndex:int;
			var detectedPattern:FLARPattern;
			var confidence:Number;
			var confidenceSum:Number = 0;
			var minConfidenceSum:Number = 0;
			var transmat:FLARTransMatResult;
			i = numFoundMarkers;
			while (i--) {
				detectedMarkerResult = this.markerDetector.getResult(i);
				patternIndex = this.markerDetector.getARCodeIndex(i);
				detectedPattern = this.allPatterns[patternIndex];
				confidence = this.markerDetector.getConfidence(i);
				confidenceSum += confidence;
				minConfidenceSum += detectedPattern.minConfidence;
				if (confidence < detectedPattern.minConfidence) {
					// detected marker's confidence is below the minimum required confidence for its pattern.
					continue;
				}
				
				transmat = new FLARTransMatResult();
				try {
					this.markerDetector.getTransmationMatrix(i, transmat);
				} catch (e:Error) {
					// FLARException happens with rotationX of approx -60 and +60, and rotY&Z of 0.
					// not sure why...
					continue;
				}
				
				arrMarkersDetected.push(new FLARMarker(detectedMarkerResult, transmat, this.flarSource, detectedPattern));
			}
			this.averageConfidence = confidenceSum / numFoundMarkers;
			this.averageMinConfidence = minConfidenceSum / numFoundMarkers;
			
			// compare detected markers against active markers
			i = arrMarkersDetected.length;
			var j:uint, k:uint;
			var detectedMarker:FLARMarker;
			var closestMarker:FLARMarker;
			var closestDist:Number = Number.POSITIVE_INFINITY;
			var dist:Number;
			var updatedMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var newMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var removedMarker:FLARMarker;
			var bRemovedMarkerMatched:Boolean = false;
			while (i--) {
				j = this._activeMarkers.length;
				detectedMarker = arrMarkersDetected[i];
				closestMarker = null;
				closestDist = Number.POSITIVE_INFINITY;
				while (j--) {
					activeMarker = this._activeMarkers[j];
					if (detectedMarker.patternId == activeMarker.patternId) {
						dist = Point.distance(detectedMarker.centerpoint3D, activeMarker.targetCenterpoint3D);
						if (dist < closestDist && dist < this._markerUpdateThreshold) {
							closestMarker = activeMarker;
							closestDist = dist;
						}
					}
				}
				
				if (closestMarker) {
					// updated marker
					closestMarker.copy(detectedMarker);
					detectedMarker.dispose();
					if (this._smoothing) {
						if (!this._smoother) {
							// TODO: log as a WARN-level error
							trace("no smoother set; specify FLARManager.smoother to enable smoothing."); 
						} else {
							closestMarker.applySmoothing(this._smoother, this._smoothing);
						}
					}
					updatedMarkers.push(closestMarker);
					
					// if closestMarker is pending removal, restore it.
					k = this.markersPendingRemoval.length;
					while (k--) {
						if (this.markersPendingRemoval[k] == closestMarker) {
							closestMarker.resetRemovalAge();
							this.markersPendingRemoval.splice(k, 1);
						}
					}
					
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_UPDATED, closestMarker));
				} else {
					// new marker
					newMarkers.push(detectedMarker);
					detectedMarker.setSessionId();
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_ADDED, detectedMarker));
				}
			}
			
			i = this._activeMarkers.length;
			while (i--) {
				activeMarker = this._activeMarkers[i];
				if (updatedMarkers.indexOf(activeMarker) == -1) {
					// if activeMarker was not updated, queue it for removal.
					this.queueMarkerForRemoval(activeMarker);
				}
			}
			
			this._activeMarkers = this._activeMarkers.concat(newMarkers);
		}
		
		//dm.getARCodeIndex
		
	}

}