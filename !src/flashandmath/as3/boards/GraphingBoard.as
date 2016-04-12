/* ***********************************************************************
The classes in the package
flashandmath.as3.* were created by

Barbara Kaskosz of the University of Rhode Island
(bkaskosz@math.uri.edu) and
Douglas E. Ensley of Shippensburg University
(DEEnsley@ship.edu).

Feel free to use and modify the classes in the package 
flashandmath.as3.* to create
your own Flash applications for educational purposes under the
following two conditions:

1) Please include a line acknowledging this work and the authors
with your application in a way that is visible in your compiled file
or on your html page. 

2) If you choose to modify the classes in the package 
flashandmath.as3.*, put them into a package different from
the original. In this case too, please acknowledge this work
in a way visible to the user.

If you wish to use the materials for commercial purposes, you need our
permission.

This work is supported in part by the National Science Foundation
under the grant DUE-0535327.

Last modified: October 23, 2008
************************************************************************ */

package flashandmath.as3.boards {
	
	import com.greensock.easing.Linear;
	import com.greensock.TweenMax;
    import flash.display.*;
    import flash.events.*;   
    import flash.text.*;
	
	import flash.geom.*; //Flashandmath
	import flashandmath.as3.parsers.*; //Flashandmath 
	import com.greensock.TweenMax;

	public class GraphingBoard extends Sprite {
	
		protected var nXSize:Number;
		protected var nYSize:Number;
		
		protected var nMaxNumGraphs:int;
		
		protected var spGraphsHolder:Sprite;
		
		protected var aGraphs:Array;
		protected var spBoard:Sprite;
		protected var shBorder:Shape;
		
		protected var shGrid:Shape; //Flashandmath
		protected var shTicks:Shape; //Flashandmath
		protected var gridX:Number; //Flashandmath
		protected var gridY:Number; //Flashandmath
		protected var tickX:Number; //Flashandmath
		protected var tickY:Number; //Flashandmath
		protected var xTickHeight:Number; //Flashandmath
		protected var yTickWidth:Number; //Flashandmath
		protected var labelFont:String;  //Flashandmath
		protected var labelSize:Number;  //Flashandmath
		protected var labelColor:uint;  //Flashandmath
		protected var spLabels:Sprite; //Flashandmath
		protected var spPoints:Sprite; //Flashandmath
		protected var arrOpenPts:Array; //Flashandmath
		protected var arrClosedPts:Array; //Flashandmath
		protected var arrVerticalAsymps:Array; //Flashandmath
		protected var nPoints:Number;
			
		protected var shAxes:Shape;
		protected var shCross:Shape;
		protected var shArrow:Shape;
		protected var spMask:Sprite;
		
		protected var nBackColor:Number;
		protected var nBackAlpha:Number;	//Flashandmath
		protected var nCircleColor:Number; 	//Flashandmath
		protected var nGridColor:Number;    //Flashandmath
		protected var nAxesColor:Number;
		protected var nAxesThick:Number;
		
		protected var c:Number;
		protected var nBorderColor:Number;
		protected var nBorderThick:Number;
		
		protected var sHorVarName:String;
		protected var sVerVarName:String;
		
		protected var nXmin:Number;
		protected var nXmax:Number;
		protected var nYmin:Number;
		protected var nYmax:Number;
		
		protected var bIsRangeSet:Boolean;
		protected var bIsCoordsOn:Boolean;
		protected var bIsUserDrawEnabled:Boolean;
		protected var bIsTraceOn:Boolean;
		protected var bUserDraw:Boolean;
		
		protected var nUserColor:Number;
		protected var nUserThick:Number;
		
		protected var shUser:Shape;
		
		protected var nCrossSize:Number;
		protected var nCrossColor:Number;
		protected var nCrossThick:Number;
		protected var nArrowSize:Number;
		protected var nArrowColor:Number;
		
		protected var sTraceStyle:String;
		
		protected var CoordsBox:TextField;
		
		public var ErrorBox:TextField;
				
		public function GraphingBoard(w:Number,h:Number){
			this.nXSize=w;
			this.nYSize=h;
			this.nAxesColor=0x000000;
			this.nAxesThick=0;
			this.nBackColor=0xFFFFFF;
					
			this.nBackAlpha=1.0; 			// DEE
			this.nGridColor = 0xCCCCCC;		// DEE
			this.nCircleColor = 0x0000FF; 	// DEE
			this.tickX = 1;					// DEE
			this.tickY = 1;					// DEE
			this.xTickHeight = 10;			// DEE
			this.yTickWidth = 10;			// DEE
			this.gridX = 1;					// DEE
			this.gridY = 1;					// DEE
			this.labelFont = "Arial";		// DEE
			this.labelSize=12;				// DEE
			this.labelColor = nAxesColor;	// DEE
			this.nPoints = w;				// DEE
			
			this.nBorderColor=0x000000;
			this.nBorderThick=1;
			this.nCrossColor=0x000000;
			this.nCrossThick=1;
			this.nCrossSize=6;
			this.nArrowColor=0x000000;
			this.nArrowSize=10;
			this.bIsRangeSet=false;
			
			spBoard=new Sprite();
			this.addChild(spBoard);
			
			spMask=new Sprite();
			this.addChild(spMask);
			
			shBorder=new Shape();
			this.addChild(shBorder);
					
			spBoard.mask=spMask;
			
			shGrid = new Shape();   		//Flashandmath
			spBoard.addChild(shGrid);    	//Flashandmath
			
			shAxes=new Shape();
			spBoard.addChild(shAxes);
			
			shTicks = new Shape();   		//Flashandmath
			spBoard.addChild(shTicks);    	//Flashandmath
			
			spGraphsHolder=new Sprite();
			spBoard.addChild(spGraphsHolder);
			
			spLabels = new Sprite();		//Flashandmath
			spBoard.addChild(spLabels);		//Flashandmaths
			
			spPoints = new Sprite();   		//Flashandmath
			spBoard.addChild(spPoints);    	//Flashandmath
			
			drawBoard();
			drawMask();
	
			arrOpenPts = new Array();	//Flashandmath
			arrClosedPts = new Array();	//Flashandmath
			arrVerticalAsymps = new Array(); //Flashandmath
			
			shCross=new Shape();
			spBoard.addChild(shCross);
			
			shArrow=new Shape();
			spBoard.addChild(shArrow);
			
			shUser=new Shape();
			spBoard.addChild(shUser);
			
			setMaxNumGraphs(99);
			
			ErrorBox=new TextField();
			this.addChild(ErrorBox);
			
			setUpErrorBox();
			setErrorBoxFormat(0xFFFFFF,0xFFFFFF,0x000000,12);
			setErrorBoxSizeAndPos(nXSize-20,nYSize/3,10,10);
			
			CoordsBox=new TextField();
			
			this.addChild(CoordsBox);
			
			setUpCoordsBox();
			
			setCoordsBoxFormat(0xFFFFFF,0xFFFFFF,0x000000,12);
			setCoordsBoxSizeAndPos(60,40,20,Math.max(nYSize-50,0));
			
			setUpListeners();
			
			enableCoordsDisp("x","y");
			disableUserDraw();
			enableTrace();
			
			setTraceStyle("cross");
		}
		
		public function setTraceStyle(s:String):void {
			if(bIsTraceOn){
				if(s=="cross"){
					drawCross();
					crossVisible(false);
					sTraceStyle="cross"
				} else if(s=="arrow"){
					drawArrow();
					arrowVisible(false);
					sTraceStyle="arrow"
				} else { }
			}
		}
		
		public function enableTrace():void {
			bIsTraceOn=true;
		}
		
		public function disableTrace():void {
			bIsTraceOn=false;
		}
		
		public function getArrowSize():Number {
			return nArrowSize;
		}
		
		
		public function arrowVisible(b:Boolean):void {
			shArrow.visible=b;
		}
		
		public function setArrowColor(colo:Number):void {
			nArrowColor=colo;
			drawArrow();
		}
		
		public function setArrowSize(s:Number):void {
			nArrowSize=s;
			drawArrow();
		}
	
		public function setArrowPos(a:Number,b:Number,c:Number):void {
			shArrow.x=a;
			shArrow.y=b;
			shArrow.rotation=c;
		}
		
		protected function drawArrow():void {
			shArrow.graphics.clear();
			shArrow.graphics.beginFill(nArrowColor);
			shArrow.graphics.moveTo(0,0);
			shArrow.graphics.lineTo(-nArrowSize/2,nArrowSize);
			shArrow.graphics.lineTo(nArrowSize/2,nArrowSize);
			shArrow.graphics.lineTo(0,0);
			shArrow.graphics.endFill();
			
			shArrow.x=0;
			shArrow.y=0;
		}
		
		
		public function getCrossSize():Number {
			return nCrossSize;
		}
		
		public function crossVisible(b:Boolean):void {
			shCross.visible=b;
		}
		
		public function setCrossColor(colo:Number):void {
			nCrossColor=colo;
			drawCross();
		}
		
		public function setCrossSizeAndThick(s:Number,t:Number):void {
			nCrossSize=s;
			nCrossThick=t;
			drawCross();
		}
		
		public function setCrossPos(a:Number,b:Number):void {
			shCross.x=a;
			shCross.y=b;
		}
		
		protected function drawCross():void {
			shCross.graphics.clear();
			shCross.graphics.lineStyle(nCrossThick,nCrossColor);
			shCross.graphics.moveTo(0,-nCrossSize);
			shCross.graphics.lineTo(0,nCrossSize);
			shCross.graphics.moveTo(-nCrossSize,0);
			shCross.graphics.lineTo(nCrossSize,0);
		}
		
		public function enableUserDraw(colo:Number,thick:Number):void {
			bIsUserDrawEnabled=true;
			nUserColor=colo;
			nUserThick=thick;
			bUserDraw=false;
		}
		
		public function disableUserDraw():void {
			bIsUserDrawEnabled=false;
			bUserDraw=false;
		}
		
		public function enableCoordsDisp(h:String,v:String):void {
			sHorVarName=h;
			sVerVarName=v;
			bIsCoordsOn=true;
		}
		
		public function disableCoordsDisp():void {
			bIsCoordsOn=false;
		}
		
		protected function setUpListeners():void {
			spBoard.addEventListener(MouseEvent.ROLL_OVER,boardOver);
			spBoard.addEventListener(MouseEvent.ROLL_OUT,boardOut);
			spBoard.addEventListener(MouseEvent.MOUSE_MOVE,boardMove);
			spBoard.addEventListener(MouseEvent.MOUSE_DOWN,boardDown);
			spBoard.addEventListener(MouseEvent.MOUSE_UP,boardUp);
		}
		
		protected function boardOver(e:MouseEvent):void {
			if(bIsCoordsOn && bIsRangeSet){
				CoordsBox.visible=true;
			} 
		}
		
		protected function boardOut(e:MouseEvent):void {
				CoordsBox.visible=false;
				bUserDraw=false;
		}
		
		protected function boardDown(e:MouseEvent):void {
				if(bIsUserDrawEnabled){
					bUserDraw=true;
					shUser.graphics.lineStyle(nUserThick,nUserColor);
					shUser.graphics.moveTo(spBoard.mouseX,spBoard.mouseY);
				} 
				else { 
					bUserDraw=false; 
				}
		}
		
		protected function boardUp(e:MouseEvent):void {
				bUserDraw=false;
		}
		
		protected function boardMove(e:MouseEvent):void {
			var dispx:String="";
			var dispy:String="";
				
			if(bIsRangeSet && bIsCoordsOn){
				  dispx=String(Math.round(xfromPix(spBoard.mouseX)*100)/100);
				  dispy=String(Math.round(yfromPix(spBoard.mouseY)*100)/100);
				  CoordsBox.visible=true;
				  CoordsBox.text=sHorVarName+"="+dispx+"\n"+sVerVarName+"="+dispy;	
			}
			
			if(bIsUserDrawEnabled){
				if(bUserDraw){
					shUser.graphics.lineTo(spBoard.mouseX,spBoard.mouseY);
				}
			}
		}

		protected function setUpCoordsBox():void {
			CoordsBox.type=TextFieldType.DYNAMIC;
			CoordsBox.wordWrap=true;
			CoordsBox.border=true;
			CoordsBox.background=true;
			CoordsBox.text="";
			CoordsBox.visible=false;
			CoordsBox.mouseEnabled=false;
		}
		
		public function setCoordsBoxSizeAndPos(w:Number,h:Number,a:Number,b:Number): void {
			CoordsBox.width=w;
			CoordsBox.height=h;
			CoordsBox.x=a;
			CoordsBox.y=b;
		}
		
		public function setCoordsBoxFormat(colo1:Number,colo2:Number,colo3:Number,s:Number): void {
			var coordsFormat:TextFormat=new TextFormat();
			coordsFormat.color=colo3;
			coordsFormat.size=s;
			coordsFormat.font="Arial";
			CoordsBox.defaultTextFormat=coordsFormat;
			CoordsBox.backgroundColor=colo1;
			CoordsBox.borderColor=colo2;
		}
		
		protected function setUpErrorBox():void {
			ErrorBox.type=TextFieldType.DYNAMIC;
			ErrorBox.wordWrap=true;
			ErrorBox.border=true;
			ErrorBox.background=true;
			ErrorBox.text="";
			ErrorBox.visible=false;
			ErrorBox.mouseEnabled=false;
		}
		
		public function setErrorBoxSizeAndPos(w:Number,h:Number,a:Number,b:Number): void {
			ErrorBox.width=w;
			ErrorBox.height=h;
			ErrorBox.x=a;
			ErrorBox.y=b;
		}
	
		public function setErrorBoxFormat(colo1:Number,colo2:Number,colo3:Number,s:Number): void {
			var errorFormat:TextFormat=new TextFormat();
			errorFormat.color=colo3;
			errorFormat.size=s;
			errorFormat.font="Arial";
			ErrorBox.defaultTextFormat=errorFormat;
			ErrorBox.backgroundColor=colo1;
			ErrorBox.borderColor=colo2;
		}
		
	  public function setMaxNumGraphs(a:int):void {
		  var i:int;
		  aGraphs=[];
		  nMaxNumGraphs=a;
		  
		  for(i=0;i<nMaxNumGraphs;i++){	  
			 aGraphs[i] = new Shape();
			 aGraphs[i].alpha = 0;
			 spGraphsHolder.addChild(aGraphs[i]);
		  }
	   }
	   
	   public function getMaxNumGraphs():int {
			return nMaxNumGraphs;
	   }
	   
	   public function drawGraph(num:int,thick:Number,aVals:Array,colo:Number): Array {
			var i:int;
			var valLen:Number=aVals.length;
			var pixVals:Array=[];
			var aArrowVals:Array=[];
			var ang:Number=0;
			var diff:Array=[0,-1];
			
			if(!bIsRangeSet){
				return [];
			}
			
			if(num<1 || num>nMaxNumGraphs){
				return [];
			}
			
			for(i=0;i<valLen;i++){
				pixVals[i]=[xtoPix(aVals[i][0]),ytoPix(aVals[i][1])];
			}
			TweenMax.killTweensOf(aGraphs[num - 1]);
			TweenMax.to(aGraphs[num-1], 15, {autoAlpha: 1, useFrames: true, ease: Linear.easeNone});
			aGraphs[num-1].graphics.clear();
			aGraphs[num-1].graphics.lineStyle(thick,colo);
			
			for(i=0;i<valLen-1;i++){
				if(isDrawable(pixVals[i][1]) && isDrawable(pixVals[i+1][1]) && isDrawable(pixVals[i][0]) && isDrawable(pixVals[i+1][0])){
			
					aGraphs[num-1].graphics.moveTo(pixVals[i][0],pixVals[i][1]);
					aGraphs[num-1].graphics.lineTo(pixVals[i+1][0],pixVals[i+1][1]);
				}
			}
			
			for(i=0;i<valLen;i++){
				if(isDrawable(pixVals[i][0]) && isDrawable(pixVals[i][1])){
					if(i!=valLen-1){
						diff=[pixVals[i+1][0]-pixVals[i][0],pixVals[i+1][1]-pixVals[i][1]];
					}
					else {
						diff=[0,0];
					}
						
					if(diff[0]==0 && diff[1]==0){
						ang+=0;
					}
					else {
						ang=calcAngle(diff);
					}
					
					aArrowVals[i]=pixVals[i].concat(ang);
				}
				else {
					aArrowVals[i]=[nXSize+nArrowSize,nYSize+nArrowSize,0];
				}
			}
	   return aArrowVals;
	}
		
		protected function calcAngle(v:Array):Number {
			var v1: Number=v[0];
			var v2: Number=v[1];
			var val:Number;
			var vlen:Number=Math.sqrt(Math.pow(v1,2)+Math.pow(v2,2));
			
			if(vlen==0){
				return val;
			} 
			else if (v1>=0){
				val=Math.acos(-v2/vlen)*180/Math.PI;	
				return val;
			} else if(v1<0){
				val=-Math.acos(-v2/vlen)*180/Math.PI;
				return val;
			} else {return val;}
		}
		//Flashandmath
		public function removeGraph(num:Number):void {
			TweenMax.killTweensOf(aGraphs[num - 1]);
			TweenMax.to(aGraphs[num - 1], 15, {autoAlpha: 0, useFrames: true, ease: Linear.easeNone, onComplete: this.finishRemoveGraph, onCompleteParams: [num]});
		}
		
		private function finishRemoveGraph(num:Number):void {
			aGraphs[num - 1].graphics.clear();
		}
		
		public function eraseGraphs():void {
			var i:int;
			for(i=0; i<nMaxNumGraphs; i++){
				aGraphs[i].graphics.clear();
			}
			shAxes.graphics.clear();
			shGrid.graphics.clear();	//Flashandmath
			shTicks.graphics.clear();	//Flashandmath
			clearLabels();				//Flashandmath
		}
		
		public function eraseUserDraw():void {
			shUser.graphics.clear();
		}
		
		public function cleanBoard():void {
			 eraseGraphs();
			 bIsRangeSet=false;
			 ErrorBox.visible=false;
		}
		
	  protected function drawMask():void {
		spMask.graphics.lineStyle(1,0x000000);
		spMask.graphics.beginFill(0x777777);
		spMask.graphics.moveTo(0,0);
		spMask.graphics.lineTo(nXSize+1,1);
		spMask.graphics.lineTo(nXSize+1,nYSize+1);
		spMask.graphics.lineTo(0,nYSize+1);
		spMask.graphics.lineTo(0,0);
		spMask.graphics.endFill();
	  }
	
		protected function drawBoard():void {
			spBoard.graphics.clear();
			spBoard.graphics.beginFill(nBackColor,nBackAlpha);
			spBoard.graphics.moveTo(0,0);
			spBoard.graphics.lineTo(nXSize,0);
			spBoard.graphics.lineTo(nXSize,nYSize);
			spBoard.graphics.lineTo(0,nYSize);
			spBoard.graphics.lineTo(0,0);
			spBoard.graphics.endFill();
			drawBorder();
		}
	
	   protected function drawBorder():void {
		   shBorder.graphics.lineStyle(nBorderThick,nBorderColor);	   
		   shBorder.graphics.moveTo(0,0);	
		   shBorder.graphics.lineTo(nXSize,0);	
		   shBorder.graphics.lineTo(nXSize,nYSize);	
		   shBorder.graphics.lineTo(0,nYSize);	
		   shBorder.graphics.lineTo(0,0);	   
	   }
	
		public function changeBorderColorAndThick(colo:Number,t:Number): void {
			nBorderColor=colo;
			nBorderThick=t;
			drawBoard();
		}
		
		public function changeBackColor(colo:Number): void {
			nBackColor=colo;
			drawBoard();
		}
		//Flashandmath
		public function addChildToBoard(obj:DisplayObject):void {
			spBoard.addChild(obj);
		}
		
		//Flashandmath	
		public function changeBackAlpha(alph:Number): void {
			nBackAlpha=alph;
			drawBoard();
		}
		
		//Flashandmath
		public function setGridColor(colo:Number): void {
			nGridColor=colo;
		}
		
		//Flashandmath
		public function setCircleColor(colo:Number): void {
			nCircleColor=colo;
		}
		
		//Flashandmath
		public function setNumPoints(np:Number):void {
			nPoints = np;
		}
		
		//Flashandmath
		public function getNumPoints():Number {
			return nPoints;
		}
		
		public function setAxesColorAndThick(colo:Number,t:Number): void {
			nAxesColor=colo;
			nAxesThick=t;
		}
		
		public function getBoardWidth():Number {
			return nXSize;
		}
		
		public function getBoardHeight():Number {
			return nYSize;
		}
		
		public function setVarsRanges(a:Number,b:Number,c:Number,d:Number): void {
			if(isLegal(a) && isLegal(b) && isLegal(c) && isLegal(d)){
				if(a<b && c<d){
					  nXmin=a;
					  nXmax=b;
					  nYmin=c;
					  nYmax=d;
		
					  bIsRangeSet=true;
				 }
			}
		}
		
		// Flashandmath ...added to be consistent with the book.  setVarsRanges is preferred.
		public function setVarRange(a:Number,b:Number,c:Number,d:Number): void {
			trace("setVarRange added to to flashandmath.com for consistency.  setVarsRanges is preferred.");
			setVarsRanges(a,b,c,d);
		}
		
		public function isDrawable(a:*):Boolean {
			if((typeof a)!="number" || isNaN(a) || !isFinite(a)) {
				return false; 
			} 
			if(Math.abs(a)>=5000){
				return false;
			}
			return true;
		}
		
		public function isLegal(a:*):Boolean {
			if((typeof a)!="number" || isNaN(a) || !isFinite(a)){
				return false; } 
			return true;
		}
		
		public function getVarsRanges(): Array {
			if(bIsRangeSet){
				return [nXmin,nXmax,nYmin,nYmax];
			} 
			else {
				return [];
			}
		}
		
		
		public function drawAxes(): void {
			
			var yzero:Number;
			var xzero:Number;
			
			if(bIsRangeSet){
				shAxes.graphics.clear();
				shAxes.graphics.lineStyle(nAxesThick,nAxesColor);
				yzero=ytoPix(0);		
				xzero=xtoPix(0);
				shAxes.graphics.moveTo(0, yzero);
				shAxes.graphics.lineTo(nXSize,yzero);
				shAxes.graphics.moveTo(xzero,0);
				shAxes.graphics.lineTo(xzero,nYSize);
			}           		
		}
		
		//Flashandmath
		public function setGrid(xsize:Number,ysize:Number): void {
			gridX = xsize;
			gridY = ysize;
			drawGrid();
		}
		
		//Flashandmath
		public function drawGrid():void {
			var xscl:Number = Math.ceil(nXmin/gridX);
			var thisX:Number = xscl*gridX;
			
			var yscl:Number = Math.ceil(nYmin/gridY);
			var thisY:Number = yscl*gridY;
	
			shGrid.graphics.clear();
			shGrid.graphics.lineStyle(1,nGridColor);
		
			while (thisX <= nXmax) {
				shGrid.graphics.moveTo(xtoPix(thisX),ytoPix(nYmin));
				shGrid.graphics.lineTo(xtoPix(thisX),ytoPix(nYmax));
				thisX += gridX;
			}
			
			while (thisY <= nYmax) {
				shGrid.graphics.moveTo(xtoPix(nXmin),ytoPix(thisY));
				shGrid.graphics.lineTo(xtoPix(nXmax),ytoPix(thisY));
				thisY += gridY;
			}
		}
		
		//Flashandmath
		public function setTicks(xsize:Number,ysize:Number,xheight:Number,ywidth:Number): void {
			tickX = xsize;
			tickY = ysize;
			xTickHeight = xheight;
			yTickWidth = ywidth;
			drawTicks();
		}
			
		//Flashandmath
		public function drawTicks():void {
			var xscl:Number = Math.ceil(nXmin/tickX);
			var thisX:Number = xscl*tickX;
			
			var yscl:Number = Math.ceil(nYmin/tickY);
			var thisY:Number = yscl*tickY;
	
			shTicks.graphics.clear();
			shTicks.graphics.lineStyle(1,nAxesColor);
		
			while (thisX <= nXmax) {
				shTicks.graphics.moveTo(xtoPix(thisX),ytoPix(0)+xTickHeight/2);
				shTicks.graphics.lineTo(xtoPix(thisX),ytoPix(0)-xTickHeight/2);
				thisX += tickX;
			}
			
			while (thisY <= nYmax) {
				shTicks.graphics.moveTo(xtoPix(0)+yTickWidth/2,ytoPix(thisY));
				shTicks.graphics.lineTo(xtoPix(0)-yTickWidth/2,ytoPix(thisY));
				thisY += tickY;
			}
		}
		
		//Flashandmath
		public function setLabelFormat(f:String,n:Number,c:uint):void {
			labelFont = f;
			labelSize = n;
			labelColor = c;
		}
	
		//Flashandmath
		public function addLabels():void {
			var xscl:Number = Math.ceil(nXmin/tickX);
			var thisX:Number = xscl*tickX;
			
			var yscl:Number = Math.ceil(nYmin/tickY);
			var thisY:Number = yscl*tickY;
			
			var numValue:Number;
			
			clearLabels();
			
			var thisTextField:TextField;
			
			while (thisX <= nXmax) {
				thisTextField = new TextField();
				thisTextField.autoSize = TextFieldAutoSize.CENTER;
				thisTextField.defaultTextFormat = new TextFormat(labelFont,labelSize,labelColor);
				numValue = Math.round(100*thisX)/100;
				thisTextField.text = String(numValue);
				thisTextField.x = xtoPix(thisX) - thisTextField.width/2;
				thisTextField.y = ytoPix(0) + xTickHeight;
				if ((thisX != 0) && ( thisTextField.x + thisTextField.width/2 > 0) && ((thisTextField.x - thisTextField.width/2) < nXSize)) { 
					spLabels.addChild(thisTextField);
				}
				thisX += tickX;
			}
			
			while (thisY <= nYmax) {
				thisTextField = new TextField();
				thisTextField.autoSize = TextFieldAutoSize.CENTER;
				thisTextField.defaultTextFormat = new TextFormat(labelFont,labelSize,labelColor);
				numValue = Math.round(thisY*100)/100;
				thisTextField.text = String(numValue);
				thisTextField.x = xtoPix(0) - yTickWidth - thisTextField.width;
				thisTextField.y = ytoPix(thisY) - thisTextField.height/2;
				if ((thisY != 0) && ( thisTextField.y + thisTextField.height/2 > 0) && ((thisTextField.y - thisTextField.height/2) < nYSize)) { 
					spLabels.addChild(thisTextField);
				}
				thisY += tickY;
			}
		}
		
		//TŁ - dodaje label
		public function addCustomLabel(strLabel: String, posX: Number, posY: Number): TextField {
			var tf: TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.defaultTextFormat = new TextFormat(labelFont,labelSize,labelColor);
			tf.text = strLabel;
			tf.x = xtoPix(posX);
			tf.y = ytoPix(posX);
			spLabels.addChild(tf);
			return tf;
		}
		
		//Flashandmath
		public function clearLabels():void {
			while (spLabels.numChildren > 0) {
				spLabels.removeChildAt(0);
			}
		}
	
		//Flashandmath
		private function openCircle(ocp:Point):Shape {
			var shCircle:Shape = new Shape();
			shCircle.graphics.lineStyle(2,nCircleColor);
			shCircle.graphics.beginFill(nBackColor,nBackAlpha);
			shCircle.graphics.drawCircle(0,0,5);
			shCircle.graphics.endFill();
			shCircle.x = xtoPix(ocp.x);
			shCircle.y = ytoPix(ocp.y);
			return shCircle;
		}
		
		//Flashandmath
		private function closedCircle(ocp:Point):Shape {
			var shCircle:Shape = new Shape();
			shCircle.graphics.lineStyle(2,nCircleColor);
			shCircle.graphics.beginFill(nCircleColor);
			shCircle.graphics.drawCircle(0,0,5);
			shCircle.graphics.endFill();
			shCircle.x = xtoPix(ocp.x);
			shCircle.y = ytoPix(ocp.y);
			return shCircle;
		}
		
		//Flashandmath
		private function verticalAsymptote(xc:Number):Shape {
			var shDashed:Shape = new Shape();
			var i:int;
			shDashed.graphics.lineStyle(2,nAxesColor);
			for (i=0; i<20; i++) {
				shDashed.graphics.moveTo(xtoPix(xc),2*i*nYSize/25);
				shDashed.graphics.lineTo(xtoPix(xc),(2*i+1)*nYSize/25);
			}
			return shDashed;
		}
		
		//Flashandmath
		public function drawPoints():void {
			var i:int;
			for (i=0; i<arrOpenPts.length; i++) {
				if (isLegal(arrOpenPts[i].x) && isLegal(arrOpenPts[i].y)) {
					spPoints.addChild(openCircle(arrOpenPts[i]));
				}
			}
			
			for (i=0; i<arrClosedPts.length; i++) {
				if (isLegal(arrClosedPts[i].x) && isLegal(arrClosedPts[i].y)) {
					spPoints.addChild(closedCircle(arrClosedPts[i]));
				}
			}
			
			for (i=0; i<arrVerticalAsymps.length; i++) {
				if (isLegal(arrVerticalAsymps[i])) {
					spPoints.addChild(verticalAsymptote(arrVerticalAsymps[i]));
				}
			}
		}
		
		//Flashandmath
		public function addOpenPoint(p:Point):void {
			arrOpenPts.push(p);
			drawPoints();
		}
		
		//Flashandmath
		public function addClosedPoint(p:Point):void {
			arrClosedPts.push(p);
			drawPoints();
		}
		
		//Flashandmath
		public function addVertAsymptote(nx:Number):void {
			arrVerticalAsymps.push(nx);
			drawPoints();
		}
		
		//Flashandmath
		public function clearPoints():void {
			while (spPoints.numChildren > 0) {
				spPoints.removeChildAt(0);
			}
			arrOpenPts = new Array();
			arrClosedPts = new Array();
			arrVerticalAsymps = new Array();
		}
		
		public function xtoPix(a:Number): Number {
			var xconv:Number;
			if(bIsRangeSet){
				xconv=nXSize/(nXmax-nXmin);
				return (a-nXmin)*xconv;
			} 
			else 
			{
				return NaN;
			}
		}
		
		public function ytoPix(a:Number): Number {
			var yconv:Number;
			if(bIsRangeSet){
			  yconv=nYSize/(nYmax-nYmin);
			return nYmax*yconv-a*yconv;
			} else {
				return NaN;
			}
		}
		
		public function xfromPix(a:Number): Number {
			var xconv:Number;
			if(bIsRangeSet){
			   xconv=nXSize/(nXmax-nXmin);
			return a/xconv+nXmin;
			} else {		
				return NaN;
			}
		}
		
		public function yfromPix(a:Number): Number {
			var yconv:Number;
			if(bIsRangeSet){
			   yconv=nYSize/(nYmax-nYmin);
			
			return nYmax-a/yconv;	
			
			} else {
				
				return NaN;
				
			}
		}
		
		//TŁ
		public function lengthXToPix(lx: Number): Number {
			if(bIsRangeSet){
				var xconv: Number = nXSize/(nXmax-nXmin);
				return lx*xconv;
			} else return NaN;
		}
		
		//TŁ
		public function lengthXFromPix(lx: Number): Number {
			if(bIsRangeSet){
				var xconv: Number = nXSize/(nXmax-nXmin);
				return lx/xconv;
			} else return NaN;
		}
		
		
		// Deprecated name for xfromPix & yfromPix
		public function xtoFun(a:Number): Number {
			var xconv:Number;
			if(bIsRangeSet){
			   xconv=nXSize/(nXmax-nXmin);
			return a/xconv+nXmin;
			} else {		
				return NaN;
			}
		}
		
		public function ytoFun(a:Number): Number {
			var yconv:Number;
			if(bIsRangeSet){
			   yconv=nYSize/(nYmax-nYmin);
			
			return nYmax-a/yconv;	
			
			} else {
				
				return NaN;
				
			}
		}

		
		public function destroy():void {
			var i:int;
			var countBoard:int=spBoard.numChildren;
			var countHolder:int=spGraphsHolder.numChildren;
			var countMain:int=this.numChildren;
				
			spBoard.removeEventListener(MouseEvent.ROLL_OVER,boardOver);
			spBoard.removeEventListener(MouseEvent.ROLL_OUT,boardOut);
			spBoard.removeEventListener(MouseEvent.MOUSE_MOVE,boardMove);
			spBoard.removeEventListener(MouseEvent.MOUSE_DOWN,boardDown);
			spBoard.removeEventListener(MouseEvent.MOUSE_UP,boardUp);
			
			spBoard.mask=null;
			
			shAxes.graphics.clear();
			shBorder.graphics.clear();
			shCross.graphics.clear();
			shArrow.graphics.clear();
			shUser.graphics.clear();
			spBoard.graphics.clear();
			spMask.graphics.clear();
			spPoints.graphics.clear();			//Flashandmath
			arrOpenPts:Array; 					//Flashandmath
			arrClosedPts = new Array();			//Flashandmath
			arrVerticalAsymps = new Array();	//Flashandmath
			
			for(i=0;i<nMaxNumGraphs;i++){
				aGraphs[i].graphics.clear();
			}
			
			//Flashandmath
			while (spLabels.numChildren > 0) {	
				spLabels.removeChildAt(0);
			}
			
			while (spGraphsHolder.numChildren > 0) {
				spGraphsHolder.removeChildAt(0);
			}
			
			while (spBoard.numChildren > 0) {
				spBoard.removeChildAt(0);
			}
			
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			spMask=null;
			spBoard=null;
			spGraphsHolder=null;
			ErrorBox=null;
			spMask=null;
			shBorder=null;
			CoordsBox=null;
		}
		
		//Flashandmath
		public function graphSimple(sExp:String, sVar:String, num:int, thick:Number, colo:Number):void {
			var procFun:MathParser=new MathParser([sVar]);
			var co:CompiledObject = new CompiledObject;
			var fArray:Array=[];
			var curx: Number,cury: Number,xstep: Number,xmin: Number,xmax: Number,ymin: Number,ymax:Number;
			var i:int;
			
			if (sExp.length == 0) {
				ErrorBox.visible = true;
				ErrorBox.text = "No expression given.";
				shAxes.graphics.clear();
				return;
			}
			
			co = procFun.doCompile(sExp);
			if (co.errorStatus==1) {
				ErrorBox.visible=true;
				ErrorBox.text="Error in f(x). "+co.errorMes;
				shAxes.graphics.clear();
				return;
			}
			
			xstep = (nXmax-nXmin)/nPoints;
			
			for(i=0;i<=nPoints;i++){
				curx=nXmin+xstep*i;
				cury=procFun.doEval(co.PolishArray,[curx]);
			    fArray[i]=[curx,cury];
			}
			drawGraph(num,thick,fArray,colo);
		}
	}
}