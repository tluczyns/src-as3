package base.bitmapOutline {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class ExtractedShapeCollection{
		
		private var _shapes:Array;
		public function get shapes():Array{return _shapes;}
		public function set shapes(a:Array):void{_shapes=a;}
		
		private var _negative_shapes:Array;
		public function get negative_shapes():Array{return _negative_shapes;}
		public function set negative_shapes(a:Array):void{_negative_shapes=a}
		
		public function get all_shapes():Array{return _shapes.concat(_negative_shapes);}
		public function set all_shapes(a:Array):void{}
		
		public function ExtractedShapeCollection(){
			_shapes=new Array();
			_negative_shapes=new Array();
		}
		
		public function addShape(bmd:BitmapData):void{
			//trace("ExtractedShapeCollection.addShape()");
			_shapes.push(bmd);
		}
		public function addNegativeShape(bmd:BitmapData):void{
			_negative_shapes.push(bmd);
		}

	}
}