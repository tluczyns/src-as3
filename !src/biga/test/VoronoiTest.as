package  biga.test
{
	import biga.utils.Delaunay;
	import biga.utils.PRNG;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import biga.utils.Voronoi;
	/**
	 * @author Nicolas Barradeau
	 * @website http://en.nicoptere.net
	 */
	public class VoronoiTest extends Sprite 
	{
		
		private var voronoi:Voronoi;
		private var indices:Vector.<int>;
		private var points:Vector.<Point>;
		
		public function VoronoiTest() 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			voronoi = new Voronoi();
			
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
			
			graphics.beginFill( 0xCC0000 );
			points.length = 0;
			for (var i:int = 0; i < 100; i++) 
			{
				var p:Point = new Point( PRNG.random() * stage.stageWidth, PRNG.random() * stage.stageHeight );
				points.push( p );
				graphics.drawCircle( p.x, p.y, 2 );
			}
			graphics.endFill();
			
			graphics.lineStyle( 0, 0x0066DD );
			voronoi.render( graphics, voronoi.compute( points ) );
			
		}
		
	}
	
}