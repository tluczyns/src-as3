package base.sprite {
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.IGraphicsFill;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	public class TestGraphicsDataAndFil extends Sprite {
		
		public function TestGraphicsDataAndFil():void	{
	/*		// Set up drawing data
// gradient fill object
			var myFill:GraphicsGradientFill = new GraphicsGradientFill();
			myFill.colors = [0xEEFFEE, 0x0000FF];
			myFill.matrix = new Matrix();
			myFill.matrix.createGradientBox(300, 300, 0);
			
// path object
			var myPath:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
			myPath.commands.push(1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2);
			myPath.data.push(0, 0, 75, 50, 100, 0, 125, 50, 200, 0, 150, 75, 200, 100, 150, 125, 200, 200, 125, 150, 100, 200, 75, 150, 0, 200, 50, 125, 0, 100, 50, 75, 0, 0);
			
// combine objects for complete drawing
			var myDrawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			myDrawing.push(myFill, myPath);
			
// render the drawing 
			graphics.drawGraphicsData(myDrawing);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, redraw);
			
			function redraw(event:MouseEvent):void
			{
				// use the clear() command to remove the shape with the old coordinates
				graphics.clear();
				var x:Number = event.stageX;
				var y:Number = event.stageY;
				myPath.data.splice(16, 2, x, y);
				graphics.drawGraphicsData(myDrawing);
				
				// if dragged too far, snap back to original shape
				if (x > 350 || y > 300)
				{
					graphics.clear();
					myPath.data.splice(16, 2, 200, 200);
					graphics.drawGraphicsData(myDrawing);
				}
			}*/
		
		
			var myFill:GraphicsSolidFill = new GraphicsSolidFill();
			myFill.color = 0xff0000;
			
			
			var myFill2:GraphicsGradientFill = new GraphicsGradientFill();
			myFill2.colors = [0xEEFFEE, 0x0000FF];
			myFill2.matrix = new Matrix();
			myFill2.matrix.createGradientBox(300, 300, 0);
			
			var myFillClear: GraphicsEndFill = new GraphicsEndFill();
			
			
			// establish the stroke properties and the fill for the stroke
			var myStroke:GraphicsStroke = new GraphicsStroke(2);
			myStroke.fill = new GraphicsSolidFill(0x000000);
			
			// establish the path properties
			var myPath:GraphicsPath = new GraphicsPath(new <int>[1,2,2,2,2], new <Number>[10,10,10, 100,100,100, 100,10, 10,10]);
			 
			
			// populate the IGraphicsData Vector array
			var myDrawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			myDrawing.push(myFill, myStroke, myPath);
			
			
			/*var myDrawing2:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			myDrawing2.push(myFill2, myStroke, myPath);*/
			
			// render the drawing 
			graphics.drawGraphicsData(myDrawing);
			graphics.clear();
			myPath.data[2] = 50;
			graphics.drawGraphicsData(myDrawing2);
	
		}
	}

}

			