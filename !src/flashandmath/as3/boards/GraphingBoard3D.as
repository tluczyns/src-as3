/* ***********************************************************************
The classes in the package
bkde.as3.* were created by

Barbara Kaskosz of the University of Rhode Island
(bkaskosz@math.uri.edu) and
Douglas E. Ensley of Shippensburg University
(DEEnsley@ship.edu).

Feel free to use and modify the classes in the package 
bkde.as3.* to create
your own Flash applications for educational purposes under the
following two conditions:

1) Please include a line acknowledging this work and the authors
with your application in a way that is visible in your compiled file
or on your html page. 

2) If you choose to modify the classes in the package 
bkde.as3.*, put them into a package different from
the original. In this case too, please acknowledge this work
in a way visible to the user.

If you wish to use the materials for commercial purposes, you need our
permission.

This work is supported in part by the National Science Foundation
under the grant DUE-0535327.

(Preliminary version. More methods will be added for rendering 3D
objects other than graphs of functions and surfaces.)

Last modified: August 16, 2007
Renamed from bkde to flashandmath on October 31, 2008
************************************************************************ */

package flashandmath.as3.boards {
	
	import flash.display.Sprite;
	
	import flash.display.Shape;
	
	import flash.events.MouseEvent;
	
	import flash.text.*;
	
    import flashandmath.as3.utilities.MatrixUtils;

 public  class GraphingBoard3D extends Sprite {
	
	private var nBoardSize:Number;
	
	private var nCubeSize:Number;
	
	private var spGraphHolder:Sprite;
	
	private var patches:Shape;
	
	private var shBorder:Shape;
	
	private var shBack:Shape;
	
	private var side1:Shape;
	
	private var side2:Shape;
	
	private var side3:Shape;
	
	private var side4:Shape;
	
	private var side5:Shape;
	
	private var side6:Shape;
	
	private var side7:Shape;
	
	private var side8:Shape;
	
	private var side9:Shape;
	
	private var side10:Shape;
	
	private var side11:Shape;
	
	private var side12:Shape;
	
	private var spBoxHolder:Sprite;
	
	private var spMask:Sprite;
	
	private var ErrorFormat:TextFormat;
	
	private var bIsErrorBoxOn:Boolean;
	
	private var ErrorBox:TextField;
	
	private var WaitBox:TextField;
	
	private var WaitFormat:TextFormat;
	
	private var bIsWaitBoxOn:Boolean;
	
	private var xLabel:TextField;
	
	private var yLabel:TextField;
	
	private var zLabel:TextField;
	
	private var xminLabel:TextField;
	
	private var xmaxLabel:TextField;
	
	private var yminLabel:TextField;
	
	private var ymaxLabel:TextField;
	
	private var zminLabel:TextField;
	
	private var zmaxLabel:TextField;
	
	private var LabelsFormat:TextFormat;
	
	private var bAreAxesLabelsOn:Boolean;
	
	public var zRangeBox:TextField;
	
	public var yRangeBox:TextField;
	
	public var xRangeBox:TextField;
	
	private var RangesFormat:TextFormat;
	
	private var bAreRangeBoxesOn:Boolean;
	
	private var p1:Array;
	
	private var p2:Array;
	
	private var p3:Array;
	
	private var p4:Array;
	
	private var p5:Array;
	
	private var p6:Array;
	
	private var p7:Array;
	
	private var p8:Array;
	
	public var fLength:Number;
	
	public var nMesh:Number;
	
	private var nFrameColor:Number;
	
	private var nAxesFront:Number;
	
	private var nAxesBack:Number;
	
	private var legalArray:Array;
	
	private var pixArray:Array;
	
	private var sColorType:String;
	
	private var bColorsLocked:Boolean;
	
	private var nSolidColor:Number;
	
	public var bShowFrame:Boolean;
	
	private var bIsBackground:Boolean;
	
	private var bIsBorder:Boolean;
	
	private var aTilesColors:Array;
	
	public var nOpacity:Number;
	
	
	public function GraphingBoard3D(b:Number){
		
		this.nBoardSize=b;
		
		this.nCubeSize=Math.round(0.28*nBoardSize);
		
		this.fLength=2000;
		
		this.nMesh=20;
	
	    this.nFrameColor=0x333333;
	
	    this.nAxesFront=0x000000;
	
	    this.nAxesBack=0xCCCCCC;
		
		this.nOpacity=1;
	
	    this.legalArray=[];
	
	    this.pixArray=[];
	
	    this.bShowFrame=true;
		
		this.bIsBackground=true;
		
		this.bIsBorder=true;
	
	    this.aTilesColors=[];
		
		this.sColorType="parametric";
		
		this.bColorsLocked=false;
		
		shBack=new Shape();
		
		this.addChild(shBack);
		
		shBorder=new Shape();
		
		this.addChild(shBorder);
		
		spGraphHolder=new Sprite();
		
		this.addChild(spGraphHolder);
		
		spGraphHolder.x=nBoardSize/2;
		
		spGraphHolder.y=nBoardSize/2;
		
		spBoxHolder=new Sprite();
		
		this.addChild(spBoxHolder);
		
		spBoxHolder.x=nBoardSize/2;
		
		spBoxHolder.y=nBoardSize/2;
			
		side1=new Shape();
		
		spGraphHolder.addChild(side1);
		
		side2=new Shape();
		
		spGraphHolder.addChild(side2);
		
		side3=new Shape();
		
		spGraphHolder.addChild(side3);
		
		side4=new Shape();
		
		spGraphHolder.addChild(side4);
		
		side5=new Shape();
		
		spGraphHolder.addChild(side5);
		
		side6=new Shape();
		
		spGraphHolder.addChild(side6);
		
		side7=new Shape();
		
		spGraphHolder.addChild(side7);
		
		side8=new Shape();
		
		spGraphHolder.addChild(side8);
		
		side9=new Shape();
		
		spGraphHolder.addChild(side9);
		
		side10=new Shape();
		
		spGraphHolder.addChild(side10);
		
		side11=new Shape();
		
		spGraphHolder.addChild(side11);
		
		side12=new Shape();
		
		spGraphHolder.addChild(side12);
		
		patches=new Shape();
		
		spGraphHolder.addChild(patches);
		
		spMask=new Sprite();
		
		this.addChild(spMask);
		
		spGraphHolder.mask=spMask;
		
	    drawBack(0xFFFFFF);
		
	    drawBorder(0x000000,1);
		
	    drawMask();
		
		createErrorBox();
		
	    enableErrorBox();
		
		createWaitBox();
		
		enableWaitBox();
		
		createAxesLabels();
		
		enableAxesLabels();
		
		createRangeBoxes();
		
		bAreRangeBoxesOn=false;
		
		prepAxes();
		
		
	}
	
	private function drawBorder(colo:Number,s:Number): void {
		
		shBorder.graphics.clear();
		
		if(bIsBorder){
			
		shBorder.graphics.lineStyle(s,colo);
		shBorder.graphics.moveTo(0,0);
		shBorder.graphics.lineTo(0,nBoardSize);
		shBorder.graphics.lineTo(nBoardSize,nBoardSize);
		shBorder.graphics.lineTo(nBoardSize,0);
		shBorder.graphics.lineTo(0,0);
		
		}
		
	}
		
	
	private function drawBack(colo:Number): void {
		
		shBack.graphics.clear();
		
		if(bIsBackground){
		
		shBack.graphics.lineStyle(1,colo);
		shBack.graphics.moveTo(0,0);
		shBack.graphics.beginFill(colo,1);
		shBack.graphics.lineTo(0,nBoardSize);
		shBack.graphics.lineTo(nBoardSize,nBoardSize);
		shBack.graphics.lineTo(nBoardSize,0);
		shBack.graphics.lineTo(0,0);
		shBack.graphics.endFill();
		
		}
	
	}
	
	private function drawMask(): void {
		
		spMask.graphics.clear();		
		spMask.graphics.moveTo(1,1);		
		spMask.graphics.beginFill(0x666666,1);
		spMask.graphics.lineTo(1,nBoardSize-1);
		spMask.graphics.lineTo(nBoardSize-1,nBoardSize-1);
		spMask.graphics.lineTo(nBoardSize-1,1);
		spMask.graphics.lineTo(1,1);
		spMask.graphics.endFill();
		
		
	}
	
	
	public function setBorder(b:Boolean,colo:Number=0x000000,s:Number=1): void {
		
		bIsBorder=b;
		
		drawBorder(colo,s);
		
	}
	
	public function setBackground(b:Boolean,colo:Number=0xFFFFFF): void {
		
		bIsBackground=b;
		
		drawBack(colo);
		
	}
	
	public function setFrontAxesColor(colo:Number): void {
		
		
		nAxesFront=colo;
		
	}
	
	public function setBackAxesColor(colo:Number): void {
		
		
		nAxesBack=colo;
		
	}
	
	public function setFrameColor(colo:Number): void {
		
		
		nFrameColor=colo;
		
	}
	
	public function showFrame(b:Boolean): void {
		
		
		bShowFrame=b;
		
	}
	
	public function setColorType(t:String,n:Number=0xFFFF00): void {
		
		
		sColorType=t;
		
		if(t=="solid"){
			
			nSolidColor=n;
		}
		
	}
	
	
	
	
	private function createWaitBox(): void {
		
		WaitBox=new TextField();
				
		WaitBox.type=TextFieldType.DYNAMIC;
		
		WaitBox.x=Math.round(nBoardSize/2)-95;
		
		WaitBox.y=5-Math.round(nBoardSize/2);
		
		WaitBox.autoSize=TextFieldAutoSize.LEFT;
		
		WaitBox.wordWrap=false;
		
		WaitBox.border=false;
				
		WaitBox.background=false;
		
		setWaitBoxFormat(0x990099,12,"Processing...");
			
		WaitBox.visible=false;
		
		WaitBox.mouseEnabled=false;
				
	}
	
	
	
	public function setWaitBoxFormat(colo:Number,s:Number,mes:String): void {
				
		WaitFormat=new TextFormat();
		
		WaitFormat.color=colo;
		
		WaitFormat.size=s;
		
		WaitFormat.font="Arial";
		
		WaitFormat.italic=true;
		
		WaitBox.defaultTextFormat=WaitFormat;
		
		WaitBox.text=mes;
		
	}
	
	public function setWaitBoxPos(a:Number,b:Number):void {
				
		WaitBox.x=a-Math.round(nBoardSize/2);
		
		WaitBox.y=b-Math.round(nBoardSize/2);
		
			
	}
	
	public function setWaitBoxVisible(b:Boolean):void {
				
		WaitBox.visible=b;
		
	}
	
	public function enableWaitBox(): void {
		
		spBoxHolder.addChild(WaitBox);
		
		bIsWaitBoxOn=true;
		
	}
	
	public function disableWaitBox(): void {
		
		if(bIsWaitBoxOn){
		 
		 spBoxHolder.removeChild(WaitBox);
		 
		 bIsWaitBoxOn=false;
		 
		}
		 
	 }
	 
	 
	 public function enableRangeBoxes(): void {
		 	 
		 spBoxHolder.addChild(yRangeBox);
		 
		 spBoxHolder.addChild(xRangeBox);
		 
		 spBoxHolder.addChild(zRangeBox);
		 
		 bAreRangeBoxesOn=true;
		 
	 }
	 
	 public function disableRangeBoxes(): void {
		 
		if(bAreRangeBoxesOn){
		
		 spBoxHolder.removeChild(yRangeBox);
		 
		 spBoxHolder.removeChild(xRangeBox);
		 
		 spBoxHolder.removeChild(zRangeBox);
		 
		 bAreRangeBoxesOn=false;
		 
		}
		 
	 }
	 
	
	private function createRangeBoxes(): void {
		
		zRangeBox=new TextField();
		
		yRangeBox=new TextField();
		
		xRangeBox=new TextField();
		
		zRangeBox.type=TextFieldType.DYNAMIC;
		
		yRangeBox.type=TextFieldType.DYNAMIC;
		
		xRangeBox.type=TextFieldType.DYNAMIC;
		
		zRangeBox.wordWrap=false;
		
		zRangeBox.border=false;
		
		zRangeBox.background=false;
		
		zRangeBox.multiline=true;
		
		zRangeBox.text="";
		
		zRangeBox.visible=false;
		
		yRangeBox.wordWrap=false;
		
		yRangeBox.border=false;
		
		yRangeBox.background=false;
		
		yRangeBox.multiline=true;
		
		yRangeBox.text="";
		
		yRangeBox.visible=false;
		
		xRangeBox.wordWrap=false;
		
		xRangeBox.border=false;
		
		xRangeBox.background=false;
		
		xRangeBox.multiline=true;
		
		xRangeBox.text="";
		
		xRangeBox.visible=false;
		
		setRangeBoxesFormat(0x000000,11);
		
		setZRangeBoxPosAndSize(5,5,74,35);
		
		setYRangeBoxPosAndSize(Math.round(nBoardSize)-75,Math.round(nBoardSize)-40,74,35);
		
		setXRangeBoxPosAndSize(5,Math.round(nBoardSize)-40,74,35);
			
		zRangeBox.visible=true;
		
		zRangeBox.mouseEnabled=false;
		
		yRangeBox.visible=true;
		
		yRangeBox.mouseEnabled=false;
		
		xRangeBox.visible=true;
		
		xRangeBox.mouseEnabled=false;
		
	}
	
	public function setZRangeBoxPosAndSize(a:Number,b:Number,w:Number,h:Number):void {
		
		zRangeBox.x=a-Math.round(nBoardSize/2);
		
		zRangeBox.y=b-Math.round(nBoardSize/2);
		
		zRangeBox.width=w;
		
		zRangeBox.height=h;
		
	}
	
	public function setYRangeBoxPosAndSize(a:Number,b:Number,w:Number,h:Number):void {
		
		yRangeBox.x=a-Math.round(nBoardSize/2);
		
		yRangeBox.y=b-Math.round(nBoardSize/2);
		
		yRangeBox.width=w;
		
		yRangeBox.height=h;
		
	}
	
	public function setXRangeBoxPosAndSize(a:Number,b:Number,w:Number,h:Number):void {
		
		xRangeBox.x=a-Math.round(nBoardSize/2);
		
		xRangeBox.y=b-Math.round(nBoardSize/2);
		
		xRangeBox.width=w;
		
		xRangeBox.height=h;
		
	}
	
	public function setRangeBoxesFormat(colo:Number,s:Number):void {
		
		RangesFormat=new TextFormat();
		
		RangesFormat.color=colo;
		
		RangesFormat.size=s;
		
		RangesFormat.font="Arial";
		
		zRangeBox.defaultTextFormat=RangesFormat;
		
		yRangeBox.defaultTextFormat=RangesFormat;
		
		xRangeBox.defaultTextFormat=RangesFormat;
		
	}
	
	private function createErrorBox(): void {
		
		ErrorBox=new TextField();
		
		ErrorBox.type=TextFieldType.DYNAMIC;
		
		ErrorBox.x=20-Math.round(nBoardSize/2);
		
		ErrorBox.y=20-Math.round(nBoardSize/2);
		
		ErrorBox.width=Math.round(nBoardSize)-40;
		
		ErrorBox.height=Math.round(nBoardSize/2);
		
		ErrorBox.wordWrap=true;
		
		ErrorBox.border=true;
				
		ErrorBox.background=true;
		
		ErrorBox.borderColor=0xFFFFFF;
		
		ErrorBox.backgroundColor=0xFFFFFF;
		
		setErrorBoxFormat(0x000000,12);
			
		ErrorBox.visible=false;
		
		ErrorBox.mouseEnabled=false;
				
	}
	
	
	public function setErrorBoxBorder(b:Boolean,colo:Number=0x000000): void {
		
		ErrorBox.border=b;
		
		ErrorBox.borderColor=colo;
		
	}
	
	public function setErrorBoxBackground(b:Boolean,colo:Number=0xFFFFFF): void {
		
		ErrorBox.background=b;
		
		ErrorBox.backgroundColor=colo;
		
	}
	
	
	public function setErrorBoxFormat(colo:Number,s:Number): void {
				
		ErrorFormat=new TextFormat();
		
		ErrorFormat.color=colo;
		
		ErrorFormat.size=s;
		
		ErrorFormat.font="Arial";
		
		ErrorBox.defaultTextFormat=ErrorFormat;
		
	}
	
	public function setErrorBoxSizeAndPos(w:Number,h:Number,a:Number,b:Number): void {
				
		ErrorBox.width=w;
		
		ErrorBox.height=h;
		
		ErrorBox.x=a-Math.round(nBoardSize/2);
		
		ErrorBox.y=b-Math.round(nBoardSize/2);
		
	}
	
	public function setErrorBoxVisible(b:Boolean):void {
				
		ErrorBox.visible=b;
		
	}
	
	public function enableErrorBox(): void {
		
		spBoxHolder.addChild(ErrorBox);
		
		bIsErrorBoxOn=true;
		
	}
	
	public function disableErrorBox(): void {
		 
		 if(bIsErrorBoxOn){
		 
		 spBoxHolder.removeChild(ErrorBox);
		 
		 bIsErrorBoxOn=false;
		 
		 }
		 
	 }
	 
	
	 public function showError(mes:String):void {
		 
	      ErrorBox.text=mes;
		
	      ErrorBox.visible=true;
	
	      xLabel.visible=false;
	
	      yLabel.visible=false;
	
	      zLabel.visible=false;
	
	      zmaxLabel.visible=false;
	
	      zminLabel.visible=false;
	
	      xmaxLabel.visible=false;
	
	      xminLabel.visible=false;
	
	      ymaxLabel.visible=false;
	
	      yminLabel.visible=false;		 
		 
	 }
	 
	
	 
	private function createAxesLabels(): void {
		
		xLabel=new TextField();	
			
		xLabel.type=TextFieldType.DYNAMIC;
		
		xLabel.border=false;
				
		xLabel.background=false;
		
		xLabel.x=0;
		
		xLabel.y=0;
		
		xLabel.wordWrap=false;
		
		xLabel.autoSize=TextFieldAutoSize.LEFT;
		
		yLabel=new TextField();	
		
		yLabel.type=TextFieldType.DYNAMIC;
		
		yLabel.border=false;
				
		yLabel.background=false;
		
		yLabel.x=20;
		
		yLabel.y=0;
		
		yLabel.wordWrap=false;
		
		yLabel.autoSize=TextFieldAutoSize.LEFT;
		
		zLabel=new TextField();	
		
		zLabel.type=TextFieldType.DYNAMIC;
		
		zLabel.border=false;
				
		zLabel.background=false;
		
		zLabel.x=40;
		
		zLabel.y=0;
		
		zLabel.wordWrap=false;
		
		zLabel.autoSize=TextFieldAutoSize.LEFT;
		
		xminLabel=new TextField();
		
		xminLabel.type=TextFieldType.DYNAMIC;
		
		xminLabel.border=false;
				
		xminLabel.background=false;
		
		xminLabel.x=60;
		
		xminLabel.y=0;
		
		xminLabel.wordWrap=false;
		
		xminLabel.autoSize=TextFieldAutoSize.LEFT;
		
		yminLabel=new TextField();
		
		yminLabel.type=TextFieldType.DYNAMIC;
		
		yminLabel.border=false;
				
		yminLabel.background=false;
		
		yminLabel.x=90;
		
		yminLabel.y=0;
		
		yminLabel.wordWrap=false;
		
		yminLabel.autoSize=TextFieldAutoSize.LEFT;
	
		zminLabel=new TextField();
		
		zminLabel.type=TextFieldType.DYNAMIC;
		
		zminLabel.border=false;
				
		zminLabel.background=false;
		
		zminLabel.x=120;
		
		zminLabel.y=0;
		
		zminLabel.wordWrap=false;
		
		zminLabel.autoSize=TextFieldAutoSize.LEFT;
		
		xmaxLabel=new TextField();
		
		xmaxLabel.type=TextFieldType.DYNAMIC;
		
		xmaxLabel.border=false;
				
		xmaxLabel.background=false;
		
		xmaxLabel.x=150;
		
		xmaxLabel.y=0;
		
		xmaxLabel.wordWrap=false;
		
		xmaxLabel.autoSize=TextFieldAutoSize.LEFT;
		
		ymaxLabel=new TextField();
		
		ymaxLabel.type=TextFieldType.DYNAMIC;
		
		ymaxLabel.border=false;
				
		ymaxLabel.background=false;
		
		ymaxLabel.x=180;
		
		ymaxLabel.y=0;
		
		ymaxLabel.wordWrap=false;
		
		ymaxLabel.autoSize=TextFieldAutoSize.LEFT;
		
		zmaxLabel=new TextField();
		
		zmaxLabel.type=TextFieldType.DYNAMIC;
		
		zmaxLabel.border=false;
				
		zmaxLabel.background=false;
		
		zmaxLabel.x=220;
		
		zmaxLabel.y=0;
		
		zmaxLabel.wordWrap=false;
		
		zmaxLabel.autoSize=TextFieldAutoSize.LEFT;
		
		setLabelsFormat(0x000000,11);
		
		xLabel.visible=true;
		
		yLabel.visible=true;
		
		zLabel.visible=true;
		
		xminLabel.visible=true;
		
		yminLabel.visible=true;
		
		zminLabel.visible=true;
		
		xmaxLabel.visible=true;
		
		ymaxLabel.visible=true;
		
		zmaxLabel.visible=true;
				
	    xLabel.mouseEnabled=false;
		
		xminLabel.mouseEnabled=false;
		
		xmaxLabel.mouseEnabled=false;
		
		yLabel.mouseEnabled=false;
		
		yminLabel.mouseEnabled=false;
		
		ymaxLabel.mouseEnabled=false;
		
		zLabel.mouseEnabled=false;
		
		zminLabel.mouseEnabled=false;
		
		zmaxLabel.mouseEnabled=false;
		
	}
	
	public function setLabelsFormat(colo:Number,s:Number,b:String="bold"): void {
				
		LabelsFormat=new TextFormat();
		
		LabelsFormat.color=colo;
		
		LabelsFormat.size=s; 
		
		LabelsFormat.font="Arial";
		
		if(b=="bold"){
		
		LabelsFormat.bold=true;
		
		} else {
			
			LabelsFormat.bold=false;
		}
		
		xLabel.defaultTextFormat=LabelsFormat;
		
		yLabel.defaultTextFormat=LabelsFormat;
		
		zLabel.defaultTextFormat=LabelsFormat;
		
		xminLabel.defaultTextFormat=LabelsFormat;
		
		yminLabel.defaultTextFormat=LabelsFormat;
		
		zminLabel.defaultTextFormat=LabelsFormat;
		
		xmaxLabel.defaultTextFormat=LabelsFormat;
		
		ymaxLabel.defaultTextFormat=LabelsFormat;
		
		zmaxLabel.defaultTextFormat=LabelsFormat;
		
		xLabel.text="x";
		
		yLabel.text="y";
		
		zLabel.text="z";
		
		xminLabel.text="xmin";
		
		yminLabel.text="ymin";
		
		zminLabel.text="zmin";
		
		xmaxLabel.text="xmax";
		
		ymaxLabel.text="ymax";
		
		zmaxLabel.text="zmax";
		
	}
	
	 public function enableAxesLabels():void {
		 
		 spBoxHolder.addChild(xLabel);
		 
		 spBoxHolder.addChild(yLabel);
		 
		 spBoxHolder.addChild(zLabel);
		 		 
		 spBoxHolder.addChild(xminLabel);
		 		 
		 spBoxHolder.addChild(yminLabel);
		 
		 spBoxHolder.addChild(zminLabel);
			
		 spBoxHolder.addChild(xmaxLabel);
		 		 
		 spBoxHolder.addChild(ymaxLabel);
		 
		 spBoxHolder.addChild(zmaxLabel);
		 
		 bAreAxesLabelsOn=true;
		 
	 }
	 
	  public function disableAxesLabels():void {
		  
		  if(bAreAxesLabelsOn){
		 
		 spBoxHolder.removeChild(xLabel);
		 
		 spBoxHolder.removeChild(yLabel);
		 
		 spBoxHolder.removeChild(zLabel);
		 		 
		 spBoxHolder.removeChild(xminLabel);
		 		 
		 spBoxHolder.removeChild(yminLabel);
		 
		 spBoxHolder.removeChild(zminLabel);
			
		 spBoxHolder.removeChild(xmaxLabel);
		 		 
		 spBoxHolder.removeChild(ymaxLabel);
		 
		 spBoxHolder.removeChild(zmaxLabel); 
		 
		 bAreAxesLabelsOn=false;
		 
		  }
		 
	 }
	 
	
	public function getCubeSize():Number {
		
		return nCubeSize;
		
	}
	
	public function setPixArray(A:Array): void {
		
		var i:int;
		
		var j:int;
		
		for(j=0;j<A.length;j++){
			
			pixArray[j]=[];
			
			legalArray[j]=[];
		
		for(i=0;i<A.length;i++){
			
			pixArray[j][i]=[];
			
		    pixArray[j][i][0]=A[j][i][0];
			
			pixArray[j][i][1]=A[j][i][1];
			
			pixArray[j][i][2]=A[j][i][2];
			
			legalArray[j][i]=A[j][i][3];
		
		}
		
		}
		
	}
	
	
	
	public function drawSurface(M:Array):void {
		
		var j:Number;
		var i:Number;
		var avx:Number;
		var avy:Number;
		var avz:Number;
		var gcamer:Number;
		
	    var dispArray=[];
	
	    var depArray=[];
	
	    var n:Number;
	
	    var depLen:Number;
		
		var coloFactor:Number=92/nCubeSize;
		
		var coloFactorS:Number;
		
		if(nMesh==1){
			
			coloFactorS=nMesh;
			
		} else {
			
			coloFactorS=nMesh/(nMesh-1);
			
			}
	
        patches.graphics.clear();
		
		
	if(pixArray.length>0){
		
	for(j=0;j<=nMesh;j++){
		
		dispArray[j]=[];
	     
		for(i=0;i<=nMesh; i++){
						
		pixArray[j][i]=MatrixUtils.MatrixByVector(M,pixArray[j][i]);
					
		dispArray[j][i]=MatrixUtils.projectPoint(pixArray[j][i],fLength);
		
		
	}
	

	}
	
	  
	for(j=0;j<nMesh;j++){
		
		if(!bColorsLocked && sColorType=="parametric"){
			
			aTilesColors[j]=[];
			
		} else if(!bColorsLocked && sColorType=="solid"){
			
			aTilesColors[j]=[];
			
		} else if(!bColorsLocked && sColorType=="function"){
			
			aTilesColors[j]=[];
			
		} else {  }
	     
		for(i=0;i<nMesh;i++){
			
			 if(legalArray[j][i]+legalArray[j+1][i]+legalArray[j][i+1]+legalArray[j+1][i+1]==0){
				
			
   avx=(pixArray[j][i][0]+pixArray[j][i+1][0]+pixArray[j+1][i+1][0]+pixArray[j+1][i][0])/4;

   avy=(pixArray[j][i][1]+pixArray[j][i+1][1]+pixArray[j+1][i+1][1]+pixArray[j+1][i][1])/4;

   avz=(pixArray[j][i][2]+pixArray[j][i+1][2]+pixArray[j+1][i+1][2]+pixArray[j+1][i][2])/4;

   gcamer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
 
		depArray.push([gcamer,j,i]);
		
		if(!bColorsLocked && sColorType=="parametric"){
			
			aTilesColors[j][i]=combineRGB((2*coloFactor*avx+100)*0.8+70,(2*coloFactor*avy+100)*0.8+70,(2*coloFactor*avz+100)*0.8+70);
			
		} else if(!bColorsLocked && sColorType=="function"){
			
			aTilesColors[j][i]=combineRGB(Math.floor(coloFactorS*j/nMesh*200)+55, Math.floor((1-(coloFactorS*j/nMesh)*(coloFactorS*i/nMesh))*160)+55,Math.floor(coloFactorS*i/nMesh*200)+55);
			
		} else if(!bColorsLocked && sColorType=="solid"){
			
			aTilesColors[j][i]=nSolidColor;
			
		} else {  }
		
		  }
		}
		}
		
		depArray.sort(byDist);
		
		depLen=depArray.length;
		
		for(n=0;n<depLen;n++){
			
			j=depArray[n][1]; i=depArray[n][2];
		
				if(bShowFrame){
		
		         patches.graphics.lineStyle(0,nFrameColor);
		
				}
		
		patches.graphics.moveTo(dispArray[j][i][0],dispArray[j][i][1]);
		
		patches.graphics.beginFill(aTilesColors[j][i],nOpacity);
				
    	patches.graphics.lineTo(dispArray[j][i+1][0],dispArray[j][i+1][1]);		
						
		patches.graphics.lineTo(dispArray[j+1][i+1][0],dispArray[j+1][i+1][1]);
				
		patches.graphics.lineTo(dispArray[j+1][i][0],dispArray[j+1][i][1]);	
		
		patches.graphics.lineTo(dispArray[j][i][0],dispArray[j][i][1]);	
		
		patches.graphics.endFill();
			
	}
		}
		
		bColorsLocked=true;
		
	}
	
	
    private function byDist(v:Array,w:Array):Number {
	
	if (v[0]>w[0]){
		
		return -1;
		
	  } else if (v[0]<w[0]){
		
		return 1;
	
	   } else {
		
		return 0;
	  }
	  
  }

	
	
	public function resetBoard():void {
		
		var k:int;
		
		ErrorBox.text="";
	
	    ErrorBox.visible=false;
		
		xLabel.visible=false;
		xminLabel.visible=false;
		xmaxLabel.visible=false;
		yLabel.visible=false;
		yminLabel.visible=false;
		ymaxLabel.visible=false;
		zLabel.visible=false;
		zminLabel.visible=false;
		zmaxLabel.visible=false;
		
		legalArray=[];
		
		pixArray=[];
		
		aTilesColors=[];
		
		bColorsLocked=false;
		
        prepAxes();
	
		patches.graphics.clear();
	
	for(k=1;k<=12;k++){
		
	this["side"+k].graphics.clear();
	
	}
		
		
	}
	
	public function getBoardSize():Number {
		
		return nBoardSize;
		
	}
	
	
	private function signum(a:Number,b:Number):Number {
	
	if(b-a>0){return 1;}
	else if(b-a<0){return -1;}
	else {return 0;}
	
      }
	  
	
	private function prepAxes():void {
	
	p1=[-nCubeSize,-nCubeSize,-nCubeSize];
	
	p2=[-nCubeSize,nCubeSize,-nCubeSize];
	
	p3=[-nCubeSize,nCubeSize,nCubeSize];
	
	p4=[nCubeSize,nCubeSize,nCubeSize];
	
	p5=[nCubeSize,nCubeSize,-nCubeSize];
	
	p6=[nCubeSize,-nCubeSize,-nCubeSize];
	
	p7=[-nCubeSize,-nCubeSize,nCubeSize];
	
	p8=[nCubeSize,-nCubeSize,nCubeSize];
	
     }
	 
	 
	public function setCubeSize(a:Number):void {
		
		nCubeSize=a;
		
		prepAxes();
		
	}
	
	
 public function drawAxes(M:Array):void {
	
    var dp1:Array=[];
	var dp2:Array=[];
	var dp3:Array=[];
	var dp4:Array=[];
	var dp5:Array=[];
	var dp6:Array=[];
	var dp7:Array=[];
	var dp8:Array=[];
	
	var k:Number;
	
	var avx:Number;
	var avy:Number;
	var avz:Number;
	
	var mid1:Number;
	var mid2:Number;
	var mid3:Number;
	var mid4:Number;
	var mid5:Number;
	var mid6:Number;
	
	var index1:Number=0;
	var index2:Number=0;
	var index3:Number=0;
	var index4:Number=0;
	var index5:Number=0;
	var index6:Number=0;
	var index7:Number=0;
	var index8:Number=0;
	var index9:Number=0;
	var index10:Number=0;
	var index11:Number=0;
	var index12:Number=0;
	
	var camer:Number;
	
	var mids:Array=[];
	
	var numObj:Number=spGraphHolder.numChildren;
	
	
	for(k=1;k<=12;k++){
		
	this["side"+k].graphics.clear();
	
	}
	
	p1=MatrixUtils.MatrixByVector(M,p1);
	
	dp1=MatrixUtils.projectPoint(p1,fLength);
	
	p2=MatrixUtils.MatrixByVector(M,p2);
	
	dp2=MatrixUtils.projectPoint(p2,fLength);
	
	p3=MatrixUtils.MatrixByVector(M,p3);
	
	dp3=MatrixUtils.projectPoint(p3,fLength);
	
	p4=MatrixUtils.MatrixByVector(M,p4);
	
	dp4=MatrixUtils.projectPoint(p4,fLength);
	
	p5=MatrixUtils.MatrixByVector(M,p5);
	
	dp5=MatrixUtils.projectPoint(p5,fLength);
	
	p6=MatrixUtils.MatrixByVector(M,p6);
	
	dp6=MatrixUtils.projectPoint(p6,fLength);
	
	p7=MatrixUtils.MatrixByVector(M,p7);
	
	dp7=MatrixUtils.projectPoint(p7,fLength);
	
	p8=MatrixUtils.MatrixByVector(M,p8);
	
	dp8=MatrixUtils.projectPoint(p8,fLength);
	
	
	yLabel.x=(dp2[0]+dp5[0])/2;
	
	yLabel.y=(dp2[1]+dp5[1])/2;
	
	yminLabel.x=dp2[0]+signum(dp2[0],dp5[0])*6;
	yminLabel.y=dp2[1]+signum(dp2[1],dp5[1])*10;
	ymaxLabel.x=dp5[0]-signum(dp2[0],dp5[0])*2;
	ymaxLabel.y=dp5[1]-signum(dp2[1],dp5[1])*2;
	
	xLabel.x=(dp2[0]+dp3[0])/2;
	
	xLabel.y=(dp2[1]+dp3[1])/2;
	
	xminLabel.x=dp2[0]+signum(dp2[0],dp3[0])*2;
	xminLabel.y=dp2[1]+signum(dp2[1],dp3[1])*2;
	
	xmaxLabel.x=dp3[0]-signum(dp2[0],dp3[0])*2;
	xmaxLabel.y=dp3[1]-signum(dp2[1],dp3[1])*2;
	
	zLabel.x=(dp2[0]+dp1[0])/2;
	
	zLabel.y=(dp2[1]+dp1[1])/2;
	
	zminLabel.x=dp2[0]+signum(dp2[0],dp1[0])*8;
	zminLabel.y=dp2[1]+signum(dp2[1],dp1[1])*15;
	zmaxLabel.x=dp1[0]-signum(dp2[0],dp1[0])*2;
	zmaxLabel.y=dp1[1]-signum(dp2[1],dp1[1])*2;
	
	
	
	avx=(p7[0]+p8[0]+p3[0]+p4[0])/4; 
	
	avy=(p7[1]+p8[1]+p3[1]+p4[1])/4; 
	
	avz=(p7[2]+p8[2]+p3[2]+p4[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid1=camer;
	
	avx=(p8[0]+p6[0]+p4[0]+p5[0])/4; 
	
	avy=(p8[1]+p6[1]+p4[1]+p5[1])/4; 
	
	avz=(p8[2]+p6[2]+p4[2]+p5[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid2=camer;
	
	avx=(p1[0]+p6[0]+p2[0]+p5[0])/4; 
	
	avy=(p1[1]+p6[1]+p2[1]+p5[1])/4; 
	
	avz=(p1[2]+p6[2]+p2[2]+p5[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid3=camer;
	
	avx=(p1[0]+p2[0]+p3[0]+p7[0])/4; 
	
	avy=(p1[1]+p2[1]+p3[1]+p7[1])/4; 
	
	avz=(p1[2]+p2[2]+p3[2]+p7[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid4=camer;
	
	avx=(p8[0]+p6[0]+p1[0]+p7[0])/4; 
	
	avy=(p8[1]+p6[1]+p1[1]+p7[1])/4; 
	
	avz=(p8[2]+p6[2]+p1[2]+p7[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid5=camer;
	
	avx=(p2[0]+p3[0]+p4[0]+p5[0])/4; 
	
	avy=(p2[1]+p3[1]+p4[1]+p5[1])/4; 
	
	avz=(p2[2]+p3[2]+p4[2]+p5[2])/4;
	
	camer=Math.sqrt(Math.pow(avx,2)+Math.pow(avy,2)+Math.pow(fLength-avz,2));
    
	mid6=camer;
	
	mids=[mid1,mid2,mid3,mid4,mid5,mid6];
	
	mids.sort(Array.NUMERIC);
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid3 || mids[k]==mid4){
			
			index1=1;
			
		}
		
	}
	
	if(index1==1){ 
	
	    spGraphHolder.setChildIndex(side1,numObj-1);	
	    side1.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side1,0);	
		side1.graphics.lineStyle(1,nAxesBack);
	}
	
	for(k=0; k<3; k++){

		
		if(mids[k]==mid6 || mids[k]==mid4){
			
			index2=1;
			
		}
		
	}
	
	if(index2==1){ 
	    spGraphHolder.setChildIndex(side2,numObj-1);
	    side2.graphics.lineStyle(1,nAxesFront);
		} 
	
	else {
		
		spGraphHolder.setChildIndex(side2,0);	
		side2.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid6 || mids[k]==mid1){
			
			index3=1;
			
		}
		
	}
	
	if(index3==1){ 
	
	spGraphHolder.setChildIndex(side3,numObj-1);	
	side3.graphics.lineStyle(1,nAxesFront);
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side3,0);	
		side3.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid6 || mids[k]==mid2){
			
			index4=1;
			
		}
		
	}
	
	if(index4==1){ 
	
	spGraphHolder.setChildIndex(side4,numObj-1);	
	side4.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side4,0);	
		side4.graphics.lineStyle(1,nAxesBack);
		
		}
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid6 || mids[k]==mid3){
			
			index5=1;
			
		}
		
	}
	
	if(index5==1){ 
	
	spGraphHolder.setChildIndex(side5,numObj-1);	
	side5.graphics.lineStyle(1,nAxesFront);
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side5,0);	
		side5.graphics.lineStyle(1,nAxesBack);
		}
	
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid2 || mids[k]==mid3){
			
			index6=1;
			
		}
		
	}
	
	if(index6==1){ 
	
	spGraphHolder.setChildIndex(side6,numObj-1);	
	side6.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side6,0);	
		side6.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid5 || mids[k]==mid3){
			
			index7=1;
			
		}
		
	}
	
	if(index7==1){ 
	
	spGraphHolder.setChildIndex(side7,numObj-1);	
	side7.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side7,0);	
		side7.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid5 || mids[k]==mid4){
			
			index8=1;
			
		}
		
	}
	
	if(index8==1){ 
	
	spGraphHolder.setChildIndex(side8,numObj-1);
	side8.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side8,0);
		side8.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid5 || mids[k]==mid1){
			
			index9=1;
			
		}
		
	}
	
	if(index9==1){ 
	
	spGraphHolder.setChildIndex(side9,numObj-1);
	side9.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side9,0);
		side9.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid5 || mids[k]==mid2){
			
			index10=1;
			
		}
		
	}
	
	if(index10==1){ 
	
	spGraphHolder.setChildIndex(side10,numObj-1);
	side10.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side10,0);
		side10.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid1 || mids[k]==mid4){
			
			index11=1;
			
		}
		
	}
	
	if(index11==1){ 
	
	spGraphHolder.setChildIndex(side11,numObj-1);
	side11.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side11,0);
		side11.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	for(k=0; k<3; k++){
		
		if(mids[k]==mid1 || mids[k]==mid2){
			
			index12=1;
			
		}
		
	}
	
	if(index12==1){ 
	
	spGraphHolder.setChildIndex(side12,numObj-1);
	side12.graphics.lineStyle(1,nAxesFront);
	
	} 
	
	else {
		
		spGraphHolder.setChildIndex(side12,0);
		side12.graphics.lineStyle(1,nAxesBack);
		
		}
	
	
	if(spGraphHolder.getChildIndex(side1)<4){
		
		zLabel.visible=false;
		
		zmaxLabel.visible=false;
		
		zminLabel.visible=false;
		
	} else {
		
		zLabel.visible=true;
		
		zmaxLabel.visible=true;
		
		zminLabel.visible=true;
		
		}
	
	if(spGraphHolder.getChildIndex(side5)<4){
		
		yLabel.visible=false;
		
		ymaxLabel.visible=false;
		
		yminLabel.visible=false;
		
	} else {
		
		yLabel.visible=true;
		
		ymaxLabel.visible=true;
		
		yminLabel.visible=true;
	}
	
	if(spGraphHolder.getChildIndex(side2)<4){
		
		xLabel.visible=false;
		
		xmaxLabel.visible=false;
		
		xminLabel.visible=false;
		
	} else {
		
		xLabel.visible=true;
		
		xmaxLabel.visible=true;
		
		xminLabel.visible=true;
		
		}
		
		if(Math.abs(xmaxLabel.x)>=nBoardSize/2-xmaxLabel.width || Math.abs(xmaxLabel.y)>=nBoardSize/2-xmaxLabel.height){
			
			xmaxLabel.visible=false;
			
		}
	
	   if(Math.abs(xminLabel.x)>=nBoardSize/2-xminLabel.width || Math.abs(xminLabel.y)>=nBoardSize/2-xminLabel.height){
			
			xminLabel.visible=false;
			
		}
		
		if(Math.abs(xLabel.x)>=nBoardSize/2-xLabel.width || Math.abs(xLabel.y)>=nBoardSize/2-xLabel.height){
			
			xLabel.visible=false;
			
		}
		
		
		if(Math.abs(ymaxLabel.x)>=nBoardSize/2-ymaxLabel.width || Math.abs(ymaxLabel.y)>=nBoardSize/2-ymaxLabel.height){
			
			ymaxLabel.visible=false;
			
		}
	
	   if(Math.abs(yminLabel.x)>=nBoardSize/2-yminLabel.width || Math.abs(yminLabel.y)>=nBoardSize/2-yminLabel.height){
			
			yminLabel.visible=false;
			
		}
		
		if(Math.abs(yLabel.x)>=nBoardSize/2-yLabel.width || Math.abs(yLabel.y)>=nBoardSize/2-yLabel.height){
			
			yLabel.visible=false;
			
		}
		
		
		if(Math.abs(zmaxLabel.x)>=nBoardSize/2-zmaxLabel.width || Math.abs(zmaxLabel.y)>=nBoardSize/2-zmaxLabel.height){
			
			zmaxLabel.visible=false;
			
		}
	
	   if(Math.abs(zminLabel.x)>=nBoardSize/2-zminLabel.width || Math.abs(zminLabel.y)>=nBoardSize/2-zminLabel.height){
			
			zminLabel.visible=false;
			
		}
		
		if(Math.abs(zLabel.x)>=nBoardSize/2-zLabel.width || Math.abs(zLabel.y)>=nBoardSize/2-zLabel.height){
			
			zLabel.visible=false;
			
		}
	
	
	
	side1.graphics.moveTo(dp1[0], dp1[1]);
	
	side1.graphics.lineTo(dp2[0], dp2[1]);
	
	
	
	side2.graphics.moveTo(dp2[0], dp2[1]);
	
	side2.graphics.lineTo(dp3[0], dp3[1]);
		
	
	side3.graphics.moveTo(dp3[0], dp3[1]);
	
	side3.graphics.lineTo(dp4[0], dp4[1]);
	
	
	
	side4.graphics.moveTo(dp4[0], dp4[1]);
	
	side4.graphics.lineTo(dp5[0], dp5[1]);
	
	
	
	side5.graphics.moveTo(dp5[0], dp5[1]);
	
	side5.graphics.lineTo(dp2[0], dp2[1]);
	
	
	
	side6.graphics.moveTo(dp5[0], dp5[1]);
	
	side6.graphics.lineTo(dp6[0], dp6[1]);
	
	
	side7.graphics.moveTo(dp6[0], dp6[1]);
	
	side7.graphics.lineTo(dp1[0], dp1[1]);
	
	
	side8.graphics.moveTo(dp1[0], dp1[1]);
	
	side8.graphics.lineTo(dp7[0], dp7[1]);
	
	
	
	side9.graphics.moveTo(dp7[0], dp7[1]);
	
	side9.graphics.lineTo(dp8[0], dp8[1]);
		
	
	
	side10.graphics.moveTo(dp8[0], dp8[1]);
	
	side10.graphics.lineTo(dp6[0], dp6[1]);
	
	
	side11.graphics.moveTo(dp7[0], dp7[1]);
	
	side11.graphics.lineTo(dp3[0], dp3[1]);
	
	
	side12.graphics.moveTo(dp8[0], dp8[1]);
	
	side12.graphics.lineTo(dp4[0], dp4[1]);
	
	
			
}


    public function combineRGB(red:Number,green:Number,blue:Number):Number {
	
	var RGB:Number;
	
	if(red>255){red=255;}
	if(green>255){green=255;}
	if(blue>255){blue=255;}
	
	if(red<0){red=0;}
	if(green<0){green=0;}
	if(blue<0){blue=0;}
	
	
	RGB=(red<<16) | (green<<8) | blue;
	
	return RGB;	
	
}

    public function destroy():void {
		
		var i:int;
		
		var countBoxes:int=spBoxHolder.numChildren;
		
		var countGraphs:int=spGraphHolder.numChildren;
		
		var countMain:int=this.numChildren;
		
		var k:int;
		
		patches.graphics.clear();
	
	    for(k=1;k<=12;k++){
		
	     this["side"+k].graphics.clear();
	
	       }
			
		shBorder.graphics.clear();
		
		shBack.graphics.clear();
					
		spMask.graphics.clear();
		
		spGraphHolder.mask=null;
		
		legalArray=null;
		
		pixArray=null;
		
		aTilesColors=null;
		
		for(k=1;k<=8;k++){
		
	       this["p"+k]=null;
	
	       }
		
		
		for(i=0;i<countGraphs;i++){
			
			spGraphHolder.removeChildAt(0);
			
		}
		
		
		
		for(i=0;i<countBoxes;i++){
			
			spBoxHolder.removeChildAt(0);
			
		}
		
		for(i=0;i<countMain;i++){
			
			this.removeChildAt(0);
			
		}
		
		
		
		for(k=1;k<=12;k++){
		
	       this["side"+k]=null;
	
	      }
		  
		 
		spMask=null;
		
		spBoxHolder=null;
		
		spGraphHolder=null;
		
		ErrorBox=null;
		
		shBorder=null;
		
		shBack=null;
		
		patches=null;
		
		WaitBox=null;
		
		xLabel=null;
		
		xminLabel=null;
		
		xmaxLabel=null;
		
		yLabel=null;
		
		yminLabel=null;
		
		ymaxLabel=null;
		
		zLabel=null;
		
		zminLabel=null;
		
		zmaxLabel=null;
		
		zRangeBox=null;
		
		yRangeBox=null;
		
		xRangeBox=null;
		
		ErrorFormat=null;
		
		LabelsFormat=null;
		
		WaitFormat=null;
		
		RangesFormat=null;
		
		
	}
			


}

}