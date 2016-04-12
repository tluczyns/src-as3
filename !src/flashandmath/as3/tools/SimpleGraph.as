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

This work was supported in part by the National Science Foundation
under the grant DUE-0535327.

Last modified: October 23, 2008
************************************************************************ */

package flashandmath.as3.tools {
	
    import flash.display.*;
    import flash.events.*;   
    import flash.text.*;
	
	import flashandmath.as3.parsers.*; 
	import flashandmath.as3.boards.*; 
	
	public class SimpleGraph extends Sprite {
		protected var aPixData:Array;
		protected var aCompObj:Array;
		protected var aVariable:Array;
		protected var _hasError:Boolean;
		protected var numPoints:int;
		
		public var board:GraphingBoard;
				
		public function SimpleGraph(w:Number,h:Number){
			board = new GraphingBoard(w,h);
			this.addChild(board);
			aPixData = [ ];
			aCompObj = [ ];
			aVariable = [ ];
			numPoints = w;
		}
		
		public function getPixData(nGraph:int):Array {
		   return aPixData[nGraph-1];
	   }
	   
   		public function getCompiledObject(nGraph:int):Array {
		   return aCompObj[nGraph-1];
	   	}
		
   		public function getVariable(nGraph:int):String {
		   return String(aVariable[nGraph-1]);
	   	}
	   
   		public function getNumPoints():int{
		   return numPoints;
	   	}

   		public function setNumPoints(np):void{
		   numPoints = np;
	   	}
	   
	   public function rectangularValueAt(nGraph:int, xval:Number):Number {
		   var mp:MathParser = new MathParser([String(aVariable[nGraph-1])]);
		   return (mp.doEval(aCompObj[nGraph-1][0].PolishArray, [xval]) );
	   }
	   
	   public function rectangularEval(nGraph:int, xval:Number):Number {
			trace("rectangularEval added to flashandmath for consistency. rectangularValueAt is preferred.");
			return rectangularValueAt(nGraph,xval);
		}

   	   public function polarValueAt(nGraph:int, theta:Number):Number {
		   var mp:MathParser = new MathParser([String(aVariable[nGraph-1])]);
		   return (mp.doEval(aCompObj[nGraph-1][0].PolishArray, [theta]) );
	   }
	   
	   	public function polarEval(nGraph:int, theta:Number):Number {
		   	trace("polarEval added to flashandmath for consistency. polarValueAt is preferred.");
			return polarValueAt(nGraph,theta);
		}

	   public function parametricValueAt(nGraph:int, tval:Number):Array {
		   var mp:MathParser = new MathParser([String(aVariable[nGraph-1])]);
		   return ( [ mp.doEval(aCompObj[nGraph-1][0].PolishArray, [tval]), mp.doEval(aCompObj[nGraph-1][1].PolishArray, [tval]) ]  );
	   }
	   
	   public function parametricEval(nGraph:int, tval:Number):Array {
		   	trace("parametricEval added to flashandmath for consistency. parametricValueAt is preferred.");
			return parametricValueAt(nGraph,tval);
		}
	   
	   public function hasError():Boolean {
		   return _hasError;
	   }
		
		public function setWindow(sXmn:String, sXmx:String, sYmn:String, sYmx:String):void {
			var procRange:RangeParser=new RangeParser();
			var oRange:RangeObject;
			var xmn,xmx,ymn,ymx:Number;
			
			board.ErrorBox.visible=false;
			board.ErrorBox.text="";
			_hasError = false;
			
			board.cleanBoard();
			
			oRange = procRange.parseRangeFour(sXmn,sXmx,sYmn,sYmx);
			
		    if (oRange.errorStatus==1){		
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in range.";
				_hasError = true;
				return;
			}
			
			xmn = oRange.Values[0];
			xmx = oRange.Values[1];	
			ymn = oRange.Values[2];
			ymx = oRange.Values[3];
			
			board.setVarsRanges(xmn,xmx,ymn,ymx);
		}
		
		public function addChildToBoard(obj:DisplayObject):void {
			board.addChildToBoard(obj);
		}

		public function graphRectangular(sExp:*, sVar:String, num:int, thick:Number, colo:Number, marginX: Number = 0):void {
			var procFun:MathParser=new MathParser([sVar]);
			var co:CompiledObject = new CompiledObject;
			var fArray:Array=[];
			var curx,cury,xstep,xmin,xmax:Number;
			var i:int;

			board.ErrorBox.visible=false;
			board.ErrorBox.text="";
			_hasError = false;
			
			if (sExp.length == 0) {
				board.cleanBoard();
				board.ErrorBox.visible = true;
				board.ErrorBox.text = "No expression given.";
				_hasError = true;
				return;
			}
			if (sExp is Array) co = new CompiledObject(sExp)
			else co = procFun.doCompile(sExp);
			if (co.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in f(x). "+co.errorMes;
				_hasError = true;
				return;
			}
			
			xmin = board.getVarsRanges()[0] + marginX;
			xmax = board.getVarsRanges()[1] - marginX;
			
			xstep = (xmax-xmin)/numPoints;
			
			for(i=0;i<=numPoints;i++){
				curx=xmin+xstep*i;
				cury=procFun.doEval(co.PolishArray,[curx]);
			    fArray[i]=[curx,cury];
			}
			aPixData[num-1] = board.drawGraph(num,thick,fArray,colo);
			aCompObj[num-1] = [ co ];
			aVariable[num-1] = [ sVar ];
		}
		
		public function graphVerticalHorizontalLine(isVerticalHorizontal: uint, posYX: Number, minPosXY: Number, maxPosXY: Number, num:int, thick:Number, colo:Number):void {
			board.ErrorBox.visible=false;
			board.ErrorBox.text="";
			_hasError = false;
			if ((isNaN(posYX)) || ((isVerticalHorizontal != 0) && (isVerticalHorizontal != 1))) {
				board.cleanBoard();
				board.ErrorBox.visible = true;
				board.ErrorBox.text = "No posYX or isVerticalHorizontal given.";
				_hasError = true;
				return;
			}
			if (isNaN(minPosXY)) minPosXY = board.getVarsRanges()[isVerticalHorizontal * 2];
			if (isNaN(maxPosXY)) maxPosXY = board.getVarsRanges()[1 + isVerticalHorizontal * 2];
			var fArray:Array = new Array(2);
			if (isVerticalHorizontal == 0) {
				fArray[0] = [minPosXY, posYX];
				fArray[1] = [maxPosXY, posYX];
			} else if (isVerticalHorizontal == 1) {	
				fArray[0] = [posYX, minPosXY];
				fArray[1] = [posYX, maxPosXY];
			}
			aPixData[num-1] = board.drawGraph(num,thick,fArray,colo);
			aCompObj[num-1] = [ null ];
			aVariable[num-1] = [ null ];
		}
		
		public function drawRectangular(sExp:String, sVar:String, num:int, thick:Number, colo:Number):void {
			trace("drawRectangular added to flashandmath for consistency. graphRectangular is preferred.");
			graphRectangular(sExp,sVar,num,thick,colo);
		}
		
		public function graphParametric(sExp1:String, sExp2:String, sVar:String, sTmin:String, sTmax:String, num:int, thick:Number, colo:Number):void {
			var procFun:MathParser=new MathParser([sVar]);
			var co1, co2:CompiledObject;
			var rp:RangeParser = new RangeParser();
			var ro:RangeObject;
			
			var fArray:Array=[];
			var curx,cury,curt,tstep,tmin,tmax,xmin,xmax,ymin,ymax:Number;
			var i:int;

			board.ErrorBox.visible=false;
			board.ErrorBox.text="";
			_hasError = false;
			
			if (sExp1.length == 0) {
				board.cleanBoard();
				board.ErrorBox.visible = true;
				board.ErrorBox.text = "Missing expression.";
				_hasError = true;
				return;
			}
			
			if (sExp2.length == 0) {
				board.cleanBoard();
				board.ErrorBox.visible = true;
				board.ErrorBox.text = "Missing expression.";
				_hasError = true;
				return;
			}

			co1 = procFun.doCompile(sExp1);
			if (co1.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in expression. " + co1.errorMes;
				_hasError = true;
				return;
			}
			
			co2 = procFun.doCompile(sExp2);
			if (co2.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in expression. " + co2.errorMes;
				_hasError = true;
				return;
			}
			
			xmin = board.getVarsRanges()[0];
			xmax = board.getVarsRanges()[1];
			ymin = board.getVarsRanges()[2];
			ymax = board.getVarsRanges()[3];
			
			ro = rp.parseRangeTwo(sTmin,sTmax);
			
			if (ro.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in parameter range.";
				_hasError = true;
				return;
			}
			
			tmin = ro.Values[0];
			tmax = ro.Values[1];
			tstep = (tmax-tmin)/numPoints;
			
			for(i=0;i<=numPoints;i++){
				curt=tmin+tstep*i;
				curx=procFun.doEval(co1.PolishArray,[curt])
				cury=procFun.doEval(co2.PolishArray,[curt]);
			    fArray[i]=[curx,cury];
			}
			aPixData[num-1] = board.drawGraph(num,thick,fArray,colo);
			aCompObj[num-1] = [ co1, co2 ];
			aVariable[num-1] = [ sVar ];
		}
		
		public function drawParametric(sExp1:String, sExp2:String, sVar:String, sTmin:String, sTmax:String, num:int, thick:Number, colo:Number):void {
			trace("drawParametric added to flashandmath for consistency. graphParametric is preferred.");
			graphParametric(sExp1, sExp2, sVar, sTmin, sTmax, num, thick, colo);
		}
		
		public function graphPolar(stR:String, sTheta:String, sTmin:String, sTmax:String, num:int, thick:Number, colo:Number):void {
			var procFun:MathParser=new MathParser([sTheta]);
			var co:CompiledObject;
			var rp:RangeParser = new RangeParser();
			var ro:RangeObject;
			
			var fArray:Array=[];
			var curx,cury,curr,curt,tstep,tmin,tmax,xmin,xmax,ymin,ymax:Number;
			var i:int;

			board.ErrorBox.visible=false;
			board.ErrorBox.text="";
			_hasError = false;
			
			if (stR.length == 0) {
				board.cleanBoard();
				board.ErrorBox.visible = true;
				board.ErrorBox.text = "Missing expression.";
				_hasError = true;
				return;
			}
			
			co = procFun.doCompile(stR);
			if (co.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in expression. " + co.errorMes;
				_hasError = true;
				return;
			}
			
			xmin = board.getVarsRanges()[0];
			xmax = board.getVarsRanges()[1];
			ymin = board.getVarsRanges()[2];
			ymax = board.getVarsRanges()[3];
			
			ro = rp.parseRangeTwo(sTmin,sTmax);
			
			if (ro.errorStatus==1) {
				board.cleanBoard();
				board.ErrorBox.visible=true;
				board.ErrorBox.text="Error in parameter range.";
				_hasError = true;
				return;
			}
			
			tmin = ro.Values[0];
			tmax = ro.Values[1];
			tstep = (tmax-tmin)/numPoints;
			
			for(i=0;i<=numPoints;i++){
				curt=tmin+tstep*i;
				curr=procFun.doEval(co.PolishArray,[curt]);
				curx=Math.cos(curt) * curr;
				cury=Math.sin(curt) * curr;
			    fArray[i]=[curx,cury];
			}
			aPixData[num-1] = board.drawGraph(num,thick,fArray,colo);
			aCompObj[num-1] = [ co ];
			aVariable[num-1] = [ sTheta ];
		}
		
		public function drawPolar(stR:String, sTheta:String, sTmin:String, sTmax:String, num:int, thick:Number, colo:Number):void {
			trace("drawPolar added to flashandmath for consistency. graphPolar is preferred.");
			graphPolar(stR, sTheta, sTmin, sTmax, num, thick, colo);
		}

		public function removeGraph(num:Number):void {
			board.removeGraph(num);
			aPixData[num-1] = [ ];
			aCompObj[num-1] = [ ];
			aVariable[num-1] = [ ];
		}
		
		public function isGraph(num:Number):Boolean{
			return Boolean((aCompObj[num-1]) && (aCompObj[num-1].length > 0));
		}
		
		public function destroy():void {
			board.destroy();
			aPixData = [ ];
			aCompObj = [ ];
			aVariable = [ ];
			board = null;
		}
	}
}