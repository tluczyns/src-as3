package com.li.as3bend.utils
{
import com.li.as3bend.vector.PathCommand;

import flash.display.GraphicsPathCommand;
import flash.geom.*;
	
	public class BezierUtils
	{
		static public function splitPathCommand(command:PathCommand):Array
		{
			if(command.type == GraphicsPathCommand.MOVE_TO)
				return [command];
			
			var pMidOnCurve:Point;
			var pMidStartControl:Point;
			var pMidControlEnd:Point;
			var command1:PathCommand;
			var command2:PathCommand;
			
			var type:int = command.type;
			if(type == GraphicsPathCommand.CURVE_TO)
			{
				pMidOnCurve = BezierUtils.getCoordinatesAt(0.5, command);
				pMidStartControl = BezierUtils.getMidPoint(command.pStart, command.pControl);
				pMidControlEnd = BezierUtils.getMidPoint(command.pControl, command.pEnd);
				
				command1 = new PathCommand(type, command.pStart, pMidStartControl, pMidOnCurve);
				command2 = new PathCommand(type, pMidOnCurve, pMidControlEnd, command.pEnd);
			}
			else
			{
				pMidOnCurve = BezierUtils.getMidPoint(command.pStart, command.pEnd);
				
				command1 = new PathCommand(type, command.pStart, null, pMidOnCurve);
				command2 = new PathCommand(type, pMidOnCurve, null, command.pEnd);
			}
			
			return [command1, command2];
		}
		
		static public function getMidPoint(p1:Point, p2:Point):Point
		{
			var mX:Number = (p1.x + p2.x)/2;
			var mY:Number = (p1.y + p2.y)/2;
			
			return new Point(mX, mY);
		}
		
		static public function getCoordinatesAt(t:Number, command:PathCommand):Point
		{
			var tSqr:Number = t*t;
			var invT:Number = 1 - t;
			var invTSqr:Number = invT*invT;
			
			var pX:Number = invTSqr*command.pStart.x + 2*invT*t*command.pControl.x + tSqr*command.pEnd.x;
			var pY:Number = invTSqr*command.pStart.y + 2*invT*t*command.pControl.y + tSqr*command.pEnd.y;
			
			return new Point(pX, pY);
		}
		
		static public function createControlPointForLine(line:PathCommand):void
		{
			if(line.pControl)
				return;
				
			var pX:Number = (line.pStart.x + line.pEnd.x)/2;
			var pY:Number = (line.pStart.y + line.pEnd.y)/2;
			
			line.pControl = new Point(pX, pY);
		}
		
		static public function getDerivativeAt(t:Number, command:PathCommand):Point
		{
			var pX:Number = -2*(1 - t)*command.pStart.x + 2*(1 - 2*t)*command.pControl.x + 2*t*command.pEnd.x;
			var pY:Number = -2*(1 - t)*command.pStart.y + 2*(1 - 2*t)*command.pControl.y + 2*t*command.pEnd.y;
			
			return new Point(pX, pY);
		}
		
		static public function getArcLengthArray(command:PathCommand, delta:Number):Vector.<Number>
		{
			// Get the points on the command for the specified delta.
			var commandPoints:Vector.<Point> = new Vector.<Point>();
			for(var t:Number = 0; t <= 1; t += delta)
				commandPoints.push(BezierUtils.getCoordinatesAt(t, command));
			
			// Incrementally calculate lengths and put them into an array.
			var acumLength:Number = 0;
			var lengths:Vector.<Number> = new Vector.<Number>();
			lengths.push(0);
			var loop:uint = commandPoints.length - 1;
			for(var i:uint; i<loop; ++i)
			{
				var pStart:Point = commandPoints[uint(i)];
				var pEnd:Point = commandPoints[uint(i+1)];
				var dX:Number = pEnd.x - pStart.x;
				var dY:Number = pEnd.y - pStart.y;
				var len:Number = Math.sqrt(dX*dX + dY*dY);
				acumLength += len;
				lengths.push(acumLength);
			}
			
			return lengths;
		}
	}
}