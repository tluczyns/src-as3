package  
{
	
	import customitems.ImageItem;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import treemap.ITreeMapItem;
	import treemap.TreeMap;
	import treemap.TreeMapItem;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class ImageBackgroundSample extends Sprite 
	{
		[Embed(source = '../lib/sourcepic.jpg')]private var src:Class;
		private var source:Bitmap = new src();
		
		private var values:Vector.<TreeMapItem>;
		private var container:Shape;
		private var panel:TextField;
		private var rect:Shape;
		
		public function ImageBackgroundSample() 
		{
			Mouse.hide();
			//create a source pisture
			addChild( source );
			
			//and a place to draw to
			container = new Shape();
			container.x = source.width;
			addChild( container );
			
			//add highlight rectangle
			rect = new Shape();
			addChild( rect );
			
			//add info panel
			panel = new TextField();
			panel.background = true;
			panel.width = 80;
			panel.height = 40;
			addChild( panel );
			
			//create a map, passes the image's source rectangle as the area to compute rectangles
            var map:TreeMap = new TreeMap( new Rectangle( 0, 0, source.width, source.height ) );
			
			//create values
            values = new Vector.<TreeMapItem>;
			
			//populate the values with basics items
			var item:ImageItem;
			for  (var i:int = 0; i < 200; i++ ) 
			{
				item = new ImageItem( .5 + .2 * Math.random(), source );
				values.push( item );
			}
			
			//compute the map
			values = map.compute( values );
			
			//render
			renderCustomItems()
			
			//mouse handling
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseHandler );
			
		}
		
		private function mouseHandler(e:MouseEvent):void 
		{
			for each ( var item:ITreeMapItem in values )
			{
				if ( item.rect.contains( mouseX - source.width, mouseY ) )
				{
					panel.text = 'weight: ' + item.weight.toFixed( 2 ) +'\narea: ' + item.area.toFixed( 2 );
					panel.x = mouseX - panel.width / 2;
					panel.y = mouseY + 20;
					
					rect.graphics.clear();
					rect.graphics.lineStyle( 2, 0xFF0000 );
					rect.graphics.drawRect( source.width + item.rect.x, item.rect.y, item.rect.width, item.rect.height );
					
					return;
				}
			}
		}
		
		private function renderCustomItems():void 
		{
			for each ( var item:ITreeMapItem in values )
			{
				( item as ImageItem ).render( container.graphics );
			}
		}
		
	}
}