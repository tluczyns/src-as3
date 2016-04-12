/*

To Do:

- add a mask to clip off ends of function lines.
  
- axes

- function interpretation

*/

package com.flashandmath.dg.GUI {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.flashandmath.dg.loaders.AssetLoader;
	import com.flashandmath.dg.objects.ControlPoint;
	import flash.ui.*;

	public class HandDrawnFunctionCCLI extends Sprite {
		
		public static const GRAPH_UPDATED:String="graphUpdated";
		//public static const READY:String = "ready";
		
		public static var copyBuffer:Array = [];
		
		private var clipLoader:AssetLoader;
		private var clipURLArray:Array;
			
		public var functionArray:Array;

		public var boardOutlineColor:uint;
		public var boardColor:uint;
		
		public var axesColor:uint;
		public var axesAlpha:Number;
		public var axesThickness:Number;
		
		public var lineThickness:Number;
		public var lineColor:uint;
		public var lineAlpha:Number;
		
		public var defaultPointColor:uint;
		public var defaultPointRadius:Number;
		public var defaultPointAlpha:Number;
		
		public var boardW:Number;
		public var boardH:Number;
		public var board:Sprite;
		
		private var _numSegments:int;
		public var xMin, xMax, yMin, yMax:Number;
		
		public var deltaT:Number;
		
		public var eps:Number;
		public var originX:Number;
		public var originY:Number;
		public var axes:Sprite;
		
		public var lastPointUpdated:Number;		

		public var isDragging:Boolean;
		public var autosmoothIterations:Number;
		public var smoothWeight:Number;
		private var MaximumPost:Number;
		private var MinimumPost:Number;
		private var MaximumPre:Number;
		private var MinimumPre:Number;
		private var leftmostDragX:Number;
		private var rightmostDragX:Number;
		private var leftIndex:Number;
		private var rightIndex:Number;
		
		public var doRenormalize:Boolean;
		
		public var autoSmoothOn:Boolean;
		public var showAxes:Boolean;
		
		public var showBackground:Boolean;
		public var showFrame:Boolean;
		private var _pointsOn:Boolean;
		
		private var bottomFillOn:Boolean;
		private var bottomFillColor:uint;
		private var bottomFillAlpha:Number;
		
		private var defaultY:Array;
		
		public var btnAuto:Sprite;
		public var btnSmooth:Sprite;
		
		public var btnAutoGraphics:MovieClip;
		public var btnAutoOnGraphics:MovieClip;
		public var btnSmoothGraphics:MovieClip;
				
		private var drawStraightLine:Boolean;
		private var startingX:Number;
		
		public var scaleUpFactor:Number;
		
		private var alternateSmoothWeight:Number;
		private var macroSmoothIterations:Number;
		private var numExtrema:Number=1;
		
		private var leftP:Sprite;
		private var rightP:Sprite;
		private var pointIndex:Number;
		
		private var points:Vector.<ControlPoint>;
		private var lines:Vector.<Sprite>;
		private var bottomTrapezoids:Vector.<Sprite>;
		
		private var frozen:Boolean;
				
		public function HandDrawnFunctionCCLI(bw=200,bh=150,_showBackground = true, _showFrame = true) {
						
			functionArray = [];

			bottomFillColor = 0x000000;
			bottomFillAlpha = 1;
			
			boardOutlineColor = (0x000000);
			boardColor = (0x60809F);
			
			axesColor= (0xFFFFFF);
			axesAlpha = 0.4;
			axesThickness = 2;
			
			lineThickness = 1.5;
			lineColor = (0xC9C894);
			lineAlpha = 1;
			
			defaultPointColor = (0x8888FF);
			defaultPointRadius = 3;
			defaultPointAlpha = 1;
			
			boardW = bw;
			boardH = bh;
			
			_numSegments = Math.floor(boardW/4);
						
			deltaT = boardW/_numSegments;
			eps = deltaT*0.5;
			
			autosmoothIterations = 8;
			smoothWeight = 0.15;
			isDragging = false;
			doRenormalize = false;

			alternateSmoothWeight = .1;
			macroSmoothIterations = 1;
			numExtrema=1;
		
			board = new Sprite();
			this.addChild(board);
			board.x = 0;
			board.y = 0;
			board.mouseChildren = false;
			
			originX = 0;
			originY = 0;
			
			xMin = -1;
			xMax = 1;
			yMin = -1;
			yMax = 1;
			
			defaultY = [];
			createDefaultY();

			axes = new Sprite();

			showBackground = _showBackground;
			showFrame = _showFrame;
			_pointsOn = false;
			bottomFillOn = false;
			
			frozen = false;
			
			drawBoard();
			createTrapezoids();
			createLines();
			createPoints();
			
			//read point positions into function array
			FToArray();
			
			drawPoints();  //uncomment if control points are to be shown
			drawAllLines();
			
			autoSmoothOn = true;
			showAxes = false;
			bottomFillOn = false;
			
			btnAuto = new Sprite();
			btnSmooth = new Sprite();
			
			this.addChild(btnAuto);
			this.addChild(btnSmooth);
			
			//buttons:
			btnAuto.addEventListener(MouseEvent.CLICK, autoHandler);
			btnSmooth.addEventListener(MouseEvent.MOUSE_DOWN, smoothingStart);
			
			loadAssets();
			
			//add mouse move and down listeners after this is added to stage 
			this.addEventListener(Event.ADDED_TO_STAGE, addListeners);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			
			drawStraightLine = false;
			scaleUpFactor = 1.01;
		}
		
		public function set pointsOn(b:Boolean):void {
			_pointsOn = b;
			for (var i:int = 0; i <= _numSegments; i++) {
				points[i].visible = pointsOn;
			}
		}
		
		public function get pointsOn():Boolean {
			return _pointsOn;
		}
		
		public function setInitialWindow(x0:Number, x1:Number, y0:Number, y1:Number):void {
			xMin = x0;
			xMax = x1;
			yMin = y0;
			yMax = y1;
			
			defaultY = [];
			createDefaultY();
			drawAllLines();
		}		
		
		private function keyDownHandler(evt:KeyboardEvent):void {
			this.root.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			this.root.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			if (evt.keyCode == Keyboard.CONTROL) {
				drawStraightLine = true;
			}
		}
		private function keyUpHandler(evt:KeyboardEvent):void {
			this.root.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			this.root.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			drawStraightLine = false;
		}
		
		private function loadAssets():void {
			clipLoader = new AssetLoader();
			var s0:String = "assets/HandDrawnFunction_btnAuto.swf";
			var s1:String = "assets/HandDrawnFunction_btnAutoOn.swf";
			var s2:String = "assets/HandDrawnFunction_btnSmooth.swf";
			
			clipURLArray = [s0,s1,s2];
			clipLoader.loadAssets(clipURLArray);
			clipLoader.addEventListener(AssetLoader.ALL_ASSETS_LOADED, allAssetsLoadedHandler);
		}
		
		private function allAssetsLoadedHandler(evt:Event):void {
			clipLoader.removeEventListener(AssetLoader.ALL_ASSETS_LOADED, allAssetsLoadedHandler);
						
			btnAutoGraphics = MovieClip(clipLoader.assetArray[0]);
			btnAutoOnGraphics = MovieClip(clipLoader.assetArray[1]);
			btnSmoothGraphics = MovieClip(clipLoader.assetArray[2]);
			//add graphics to buttons (which are presently empty Sprites):
			btnAuto.addChild(btnAutoGraphics);
			btnAuto.addChild(btnAutoOnGraphics);
			btnAutoOnGraphics.visible = autoSmoothOn;
			btnSmooth.addChild(btnSmoothGraphics);
			
			//place buttons now - needed to know their size before placement
			var buttonSpacingY:Number = btnAuto.height/2+2;
			
			btnSmooth.x = btnSmooth.width/2+boardW + 4;
			btnSmooth.y = boardH - btnSmooth.height - btnAuto.height;
			btnAuto.x  = btnSmooth.x
			btnAuto.y  = btnSmooth.y + btnSmooth.height + 2;

		}
		
		public function lineStyle(_lineThickness:Number, _lineColor:uint, _lineAlpha:Number):void {
			lineThickness = _lineThickness;
			lineColor = _lineColor;
 			lineAlpha = _lineAlpha;
			drawAllLines();
		}
		
		public function boardStyle(...paramArray):void {
			boardColor = paramArray[0];
			if (paramArray.length > 1) {
				boardOutlineColor = paramArray[1];
			}
			if (paramArray.length > 2) {
				showBackground = paramArray[2];
			}
			drawBoard();
		}
		
		public function setPointStyle(_defaultPointRadius:Number,_defaultPointColor:uint, _defaultPointAlpha:Number):void {
			defaultPointColor = _defaultPointColor;
			defaultPointRadius = _defaultPointRadius;
			defaultPointAlpha = _defaultPointAlpha;
			for (var i:int = 0; i<= numSegments; i++) {
				points[i].radius = defaultPointRadius;
				points[i].color = defaultPointColor;
				points[i].alpha = defaultPointAlpha;
			}
			drawPoints();
		}
		
		function addListeners(evt:Event):void {
			board.addEventListener(MouseEvent.MOUSE_DOWN, dragstart);
			this.root.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		function removeListeners(evt:Event):void {
			board.removeEventListener(MouseEvent.MOUSE_DOWN, dragstart);
			this.root.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		public function set numSegments(n) {
			//remove points, lines, and trapezoids that have been created
			while (board.numChildren > 2) {
				var thisSprite:Sprite = board.getChildAt(2) as Sprite;
				board.removeChild(thisSprite);
			}
			//reset parameters
			_numSegments = Math.max(2,Math.min(boardW, n));
			deltaT = boardW/_numSegments;
			eps = deltaT*0.5;

			//create new objects
			defaultY=[];
			createDefaultY();
			createTrapezoids();
			createLines();
			createPoints();
			 
			//redraw
			drawAllLines();
			drawPoints();
			FToArray();
		}
		
		public function get numSegments() {
			return _numSegments;
		}
		
		public function redraw():void {
			drawAllLines();
			drawPoints();
			FToArray();
			dispatchEvent(new Event(HandDrawnFunctionCCLI.GRAPH_UPDATED));
		}
		
		function drawBoard():void {
			if (showFrame) {
				var frame:Sprite = new Sprite();
				board.addChildAt(frame,0);
				frame.graphics.lineStyle(1, boardOutlineColor);
				frame.graphics.drawRect(0, 0, boardW, boardH);
			}

			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(boardColor);
			bg.graphics.drawRect(0, 0, boardW, boardH);
			bg.graphics.endFill();
			if (!showBackground) {
				bg.alpha = 0;
			}
			else {
				bg.alpha = 1;
			}
			board.addChildAt(bg,0);
			
		}
				
		function drawAxes():void {
			axes.graphics.lineStyle(axesThickness, axesColor);
			axes.alpha = axesAlpha;
			axes.mouseEnabled = false;  //we don't want the axes to interfere with drawing.
			board.addChild(axes);
			axes.graphics.moveTo(originX, 0);
			axes.graphics.lineTo(originX,boardH);
			axes.graphics.moveTo(0, originY);
			axes.graphics.lineTo(boardW, originY);
		}
				
		private function createPoints():void {
			points = new Vector.<ControlPoint>();
			for (var i:Number=0; i <= _numSegments; i++) {
				var thisPoint:ControlPoint = new ControlPoint();
				board.addChild(thisPoint);
				thisPoint.x = i*boardW/_numSegments;
				thisPoint.y = defaultY[i];
				points.push(thisPoint);
			}
		}
		
		public function resetToDefault():void {
			for (var i:Number=0; i <= _numSegments; i++) {
				points[i].y = defaultY[i];
			}
			FToArray();
			redraw();
		}
		
		private function createDefaultY():void {
			for (var i:Number=0; i <= _numSegments; i++) {
				//var thisY:Number = boardH - boardH*i/_numSegments;
				var thisY:Number = yToPix(0);
				defaultY.push(thisY);
				//trace(thisY);
			}
		}
		
		private function createLines():void {
			lines = new Vector.<Sprite>;
			for (var i:Number=0; i <= _numSegments-1; i++) {
				var thisLine:Sprite = new Sprite();
				board.addChild(thisLine);
				lines.push(thisLine);
			}
		}
		
		public function fillBottom(c:uint, a:Number):void {
			bottomFillOn = true;
			bottomFillColor = c;
			bottomFillAlpha = a; 
			drawAllLines();
			//showTrapezoids();
		}
		
		public function set fillAlpha(a:Number):void {
			bottomFillAlpha = a; 
			drawAllLines();
		}
		
		public function get fillAlpha():Number {
			return bottomFillAlpha;
		}			
		
		function createTrapezoids():void {
			bottomTrapezoids = new Vector.<Sprite>;
			for (var i:Number=1; i <= _numSegments; i++) {
				var thisBottomTrapezoid:Sprite = new Sprite();
				thisBottomTrapezoid.mouseEnabled = false;
				board.addChild(thisBottomTrapezoid);
				bottomTrapezoids.push(thisBottomTrapezoid);
			}
		}
		
		function showBottomFill():void {
			for (var i:Number=1; i <= _numSegments; i++) {
				bottomTrapezoids[i].visible = true;
			}
		}
		
		function hideBottomFill():void {
			for (var i:Number=1; i <= _numSegments; i++) {
				bottomTrapezoids[i].visible = false;
			}
		}
		
		function showPoints():void {
			for (var i:Number=0; i <= _numSegments; i++) {
				points[i].visible = true;
			}
			_pointsOn = true;
		}
		
		function hidePoints():void {
			for (var i:Number=0; i <= _numSegments; i++) {
				points[i].visible = false;
			}
			_pointsOn = false;
		}
		
		
		function drawLine(index:int):void {
			lines[index].graphics.clear();
			lines[index].graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			lines[index].graphics.moveTo(points[index].x, points[index].y);
			lines[index].graphics.lineTo(points[index+1].x, points[index+1].y);
			if (bottomFillOn) {
				bottomTrapezoids[index].graphics.clear();
				bottomTrapezoids[index].graphics.lineStyle(0, 0, 0);
				bottomTrapezoids[index].graphics.beginFill(bottomFillColor, bottomFillAlpha);
				bottomTrapezoids[index].graphics.moveTo(points[index].x,boardH);
				bottomTrapezoids[index].graphics.lineTo(points[index].x,points[index].y);
				bottomTrapezoids[index].graphics.lineTo(points[index+1].x, points[index+1].y);
				bottomTrapezoids[index].graphics.lineTo(points[index+1].x, boardH);
				bottomTrapezoids[index].graphics.lineTo(points[index].x,boardH);
				bottomTrapezoids[index].graphics.endFill();
			}
		}
		
		function setPoint(i:Number, thisY:Number):void {
			//thisY should be between 0 and 1
			thisY = Math.max(0, Math.min(1, thisY));
			points[i].y = boardH*(1-thisY);
			functionArray[i] = thisY;
			if (i == 0) {
				drawLine(0);
			}
			else if (i == _numSegments) {
				drawLine(_numSegments-1);
			}
			else {
				drawLine(i-1);
				drawLine(i);
			}
		}
		
		public function setPointColor(i:int, c:uint):void {
			if ((i >= 0)&&(i<=_numSegments)) {
				points[i].color = c;
			}
		}
		
		private function drawAllLines():void {
			for (var i:Number=0;i<=_numSegments-1;i++) {
				drawLine(i);
			}
		}
		
		private function drawPoints():void {
			for (var i:Number=0; i <= _numSegments; i++) {
				points[i].redraw();
				points[i].alpha = defaultPointAlpha;
				points[i].visible = _pointsOn;
			}
		}
				
		private function dragstop(evt:MouseEvent):void {
			this.root.removeEventListener(MouseEvent.MOUSE_MOVE, mouseUpdate);
			this.root.removeEventListener(MouseEvent.MOUSE_UP, dragstop);
			board.addEventListener(MouseEvent.MOUSE_DOWN, dragstart);
			//if user was just drawing curve, then auto-smooth it
			if (autoSmoothOn) {
				for (var j:Number = 1;j<=autosmoothIterations;j++) {
					//Smooth();
					alternateSmooth();
				}
			}
			
			FToArray();
		
			isDragging = false;
			lastPointUpdated = NaN;
			
			dispatchEvent(new Event(HandDrawnFunctionCCLI.GRAPH_UPDATED));
		}
		
		private function dragstart(evt:MouseEvent):void {
			this.root.addEventListener(MouseEvent.MOUSE_MOVE, mouseUpdate);
			this.root.addEventListener(MouseEvent.MOUSE_UP, dragstop);
			board.removeEventListener(MouseEvent.MOUSE_DOWN, dragstart);
			//isDragging = true;
			rightmostDragX = GoodX(board.mouseX);
			leftmostDragX = GoodX(board.mouseX);
			startingX = nearestPointIndex(board.mouseX);
		}
				
		private function GoodY(thisY:Number):Number {
			if (thisY<0) {return(0);}
			if (thisY>boardH) {return(boardH);}
			else return(thisY);
		}
		
		private function GoodX(thisX:Number):Number {
			if (thisX<0) {return(0);}
			if (thisX>boardW) {return(boardW);}
			else return(thisX);
		}
		
		private function nearestPointIndex(thisX:Number):Number {
			if (thisX < 0) {return 0;}
			if (thisX > boardW - eps) {return _numSegments;}
			for (var i:Number = 0; i <=_numSegments-1 ; i++) {
				if ((thisX >= i*deltaT-eps) && (thisX < i*deltaT+eps)) {
					return i;
				}
			}
			return -1;
		}
		
		private function mouseUpdate(evt:MouseEvent):void {
			var n:Number = nearestPointIndex(board.mouseX);
			if (n != -1){				
				//pointi will have fixed x-coord, but changing y-coord.
				points[n].y = GoodY(board.mouseY);
				if (n>0) {drawLine(n-1)}
				if (n < _numSegments) {drawLine(n)}
				
				//if mouse moved too quickly:
				if (Math.abs(n-lastPointUpdated)>1) {
					interpolateMouse(Math.min(n,lastPointUpdated),Math.max(n,lastPointUpdated));
				}
				lastPointUpdated = n;
				
				//for partial smoothing, keep track of interval affected
				if (board.mouseX>rightmostDragX) {
					rightmostDragX = GoodX(board.mouseX);
				}
				if (board.mouseX<leftmostDragX) {
					leftmostDragX = GoodX(board.mouseX);
				}
				
				//if straight line drawing is in effect
				if (drawStraightLine) {
					interpolateMouse(Math.min(n,startingX),Math.max(n,startingX));
				}
				
			}		
			evt.updateAfterEvent();	
		}
		
		private function interpolateMouse(begin:Number, end:Number):void {
			var x0:Number = points[begin].x;
			var y0:Number = points[begin].y;
			var m:Number = (points[end].y-y0)/(points[end].x-x0);
			for (var i:Number = begin+1; i<= end-1; i++) {
				points[i].y = GoodY(y0 + m*(points[i].x - x0));
				if (i>0) {drawLine(i-1)}
			}
			//draw last segment:
			if (end-1 < _numSegments) {
				drawLine(end-1);
			}
		}
		
		private function interpolateFun(thisX:Number):Number {
			var leftIndex:Number = Math.floor(_numSegments*thisX/boardW);
			var rightIndex:Number = leftIndex + 1;
			var leftX:Number = leftIndex*boardW/_numSegments;
			var leftY:Number = functionArray[leftIndex];
			var m:Number = (functionArray[rightIndex] - leftY)/(boardW/_numSegments);
			return m*(thisX - leftX) + leftY;
		}
				
		private function FToArray():void {
			for (var i:Number = 0; i<=_numSegments; i++) {
				functionArray[i] = (boardH-points[i].y)/boardH;
			}
		}
		
		//Graph Interpretation:  NOTE this interpretation assumes that
		//the control points are spaced equally over the interval.
		public function func(input:Number):Number {
			var t = _numSegments*(input - xMin)/(xMax - xMin);
			pointIndex = Math.floor(t);
			if (pointIndex < _numSegments) {
				return yMin + (yMax - yMin)*(functionArray[pointIndex] + (functionArray[pointIndex+1] - functionArray[pointIndex])*(t - pointIndex));
			}
			else if (pointIndex == _numSegments) {
				return yMin + (yMax - yMin)*functionArray[_numSegments];
			}
			return NaN;
		}
						
		public function alternateSmoothAll():void {
			rightmostDragX = boardW;
			leftmostDragX = 0;

			alternateSmooth();
			
			//TESTING:
			//bruteSmooth();
			
			//re-read the function
			FToArray();			
		}
		
		
		private function alternateSmooth():void {
			//find out where to smooth
			leftIndex = int(Math.max(0, Math.floor(leftmostDragX*_numSegments/boardW)));
			rightIndex = int(Math.min(_numSegments, Math.ceil(rightmostDragX*_numSegments/boardW)));
						
			if (Math.abs(rightIndex - leftIndex) <= 1) {
				return;
			}
			//find local maxes and mins
			var lastValue:Number;
			var constantCount:Number = 0;
			var thisMove:String;
			var lastMove:String="";
			var firstPoint:Sprite;
			var temp:Number;
			var numSmoothPoints:Number;
			var extremaIndexArray:Array = [leftIndex];
			var smoothingEndpointsArray:Array = [leftIndex];
			lastValue = points[leftIndex].y;
			for (var i:Number = leftIndex+1; i<=rightIndex; i++) {
								
				if (points[i].y - lastValue > 0) {
					thisMove = "increasing";
				}
				if (points[i].y - lastValue < 0) {
					thisMove = "decreasing";
				}
				if (points[i].y - lastValue == 0) {
					//thisMove = "constant";
					thisMove = lastMove;
				}
				if ((i>1)&&(thisMove != lastMove)) {
					numExtrema=extremaIndexArray.push(i-1);
				}
				lastValue = points[i].y;
				lastMove = thisMove;
			}
			numExtrema=extremaIndexArray.push(rightIndex);	
			
			
			//find smoothing endpoints
			for (i=1; i<=numExtrema-2; i++) {
				temp = Math.round(extremaIndexArray[i]+(extremaIndexArray[i+1]-extremaIndexArray[i])/2);
				numSmoothPoints = smoothingEndpointsArray.push(temp);
			}
			smoothingEndpointsArray.push(rightIndex);
				
			//smooth in between extrema
			for (i=0; i<=numSmoothPoints-1; i++) {
				PartialSmooth(smoothingEndpointsArray[i]+1, smoothingEndpointsArray[i+1]-1)
			}
			
			//redraw
			//updatePoints();
			drawAllLines();
			
			//wipe out array
			extremaIndexArray = [0];
			
			//renormalization not necessary.
		}
		
		//TESTING:
		private function bruteSmooth():void {
			
			PartialSmooth(0, _numSegments)
			
			//redraw
			//updatePoints();
			drawAllLines();
			
		}
		
		private function PartialSmooth(leftIndexInput:Number, rightIndexInput:Number):void {
			var MaximumPost:Number = 0;
			var MinimumPost:Number = boardH;
			var MaximumPre:Number = 0;
			var MinimumPre:Number = boardH;
			var overlap:Number = 1;
			
			var thisLeftIndex = Math.max(0, (leftIndexInput - overlap));
			var thisRightIndex = Math.min(_numSegments, (rightIndexInput + overlap));
			
			var yL:Number;
			var yR:Number;
			var y0:Number;
			var yNew:Number;
			
			//ignore request if indices are no good
			if (leftIndexInput < rightIndexInput-1) {
				//find max and min
				for (var i:Number=thisLeftIndex+1; i <= thisRightIndex-1; i++) {
					MaximumPre = Math.max(MaximumPre, points[i].y);
					MinimumPre = Math.min(MinimumPre, points[i].y);
				}
				//Smooth:
				for (var j:Number = 1; j<=macroSmoothIterations; j++) {
					yL = points[thisLeftIndex].y;
					for (i=thisLeftIndex+1; i <= thisRightIndex-1; i++) {
							yR = points[i+1].y;
							y0 = points[i].y;
							
							yNew = (y0 + alternateSmoothWeight*yL + alternateSmoothWeight*yR)/(1+2*alternateSmoothWeight);
	
							//Experimental:
							//var f:Number = 1-0.5*Math.cos(2*Math.PI*(i-thisLeftIndex-1)/(thisRightIndex-thisLeftIndex-2))
							//var yNew:Number = (y0 + f*alternateSmoothWeight*yL + f*alternateSmoothWeight*yR)/(1+2*f*alternateSmoothWeight);
							
							points[i].y = yNew;
							yL = y0; //setting yL to value before smoothing for next left endpoint.
					}
				}
				//read max and min post smoothing
				for (i=thisLeftIndex+1; i <= thisRightIndex-1; i++) {
					MaximumPost = Math.max(MaximumPost, points[i].y);
					MinimumPost = Math.min(MinimumPost, points[i].y);
				}
				//Renormalize:
				for (i=thisLeftIndex+1; i <= thisRightIndex-1; i++) {
					if ((MaximumPost - MinimumPost) != 0) {
						points[i].y = MinimumPre+(points[i].y - MinimumPost)*(MaximumPre - MinimumPre)/(MaximumPost - MinimumPost);
					}
				}
			}
		}
		////////////////////////////////			
		
		private function autoHandler(evt:MouseEvent):void {
			autoSmoothOn = !autoSmoothOn;
			btnAutoOnGraphics.visible = autoSmoothOn;
		}
		
		private function smoothingStart(evt:MouseEvent):void {
			this.addEventListener(Event.ENTER_FRAME, onEnterSmooth);
			this.root.addEventListener(MouseEvent.MOUSE_UP, smoothingStop);
			btnSmooth.removeEventListener(MouseEvent.MOUSE_DOWN, smoothingStart);
		}
		
		private function smoothingStop(evt:MouseEvent):void {
			this.removeEventListener(Event.ENTER_FRAME, onEnterSmooth);
			this.root.removeEventListener(MouseEvent.MOUSE_UP, smoothingStop);
			btnSmooth.addEventListener(MouseEvent.MOUSE_DOWN, smoothingStart);
			redraw();
		}
		
		private function onEnterSmooth(evt:Event):void {
			//smoothAll();
			alternateSmoothAll();
		}
		
		public function freeze():void {
			frozen = true;
			board.mouseEnabled = false;
			btnSmooth.mouseEnabled = false;
			btnSmooth.mouseChildren = false;
			btnAuto.mouseEnabled = false;
			btnAuto.mouseChildren = false;
		}
		
		public function unfreeze():void {
			frozen = false; 
			board.mouseEnabled = true;
			btnSmooth.mouseEnabled = true;
			btnSmooth.mouseChildren = true;
			btnAuto.mouseEnabled = true;
			btnAuto.mouseChildren = true;
		}
		
		private function pixToY(pixY:Number):Number {
			return (yMin - yMax)/boardH*pixY + yMax;
		}
		
		private function yToPix(thisY:Number):Number {
			return boardH/(yMin - yMax)*(thisY - yMax);
		}
		
		private function pixToX(pixX:Number):Number {
			return (xMax - xMin)/boardW*pixX + xMin;
		}
		
		private function xToPix(thisX:Number):Number {
			return boardW/(xMax - xMin)*(thisX - xMin);
		}
		
		
	}
}
		
		

	
