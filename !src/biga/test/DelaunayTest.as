package  biga.test
{
	import biga.utils.Delaunay;
	import biga.utils.PRNG;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * @author Nicolas Barradeau
	 * @website http://en.nicoptere.net
	 */
	public class DelaunayTest extends Sprite 
	{
		
		private var delaunay:Delaunay;
		private var indices:Vector.<int>;
		private var points:Vector.<Point>;
		
		public function DelaunayTest() 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			delaunay = new Delaunay();
			
			points = new Vector.<Point>();
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			reset();
			
		}
		
		private function onMouseDownHandler(e:MouseEvent):void 
		{
			reset();
		}
		
		private function reset():void 
		{
			graphics.clear();
			
			points.length = 0;
			for (var i:int = 0; i < 100; i++) 
			{
				var p:Point = new Point( PRNG.random() * stage.stageWidth, PRNG.random() * stage.stageHeight );
				points.push( p );
				graphics.drawCircle( p.x, p.y, 2 );
			}
			
			indices = delaunay.compute( points );
			
			graphics.lineStyle( 0, 0xDDDDDD );
			delaunay.render( graphics, points, indices );
			
			/*
			//alternate rendering
			var vertices:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < points.length; i++) vertices.push( points[ i ].x, points[ i ].y );
			graphics.drawTriangles( vertices, indices );
			**/
			
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill( 0xCC0000 );
			for ( i = 0; i < points.length; i++) 
			{
				graphics.drawCircle( points[ i ].x, points[ i ].y, 2 );
			}
			graphics.endFill();
		}
		
	}
	
}