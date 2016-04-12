package  customitems
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import treemap.ITreeMapItem;
	import treemap.TreeMapItem;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class ImageItem extends TreeMapItem
	{
		
		private var _picture:Bitmap;
		
		public function ImageItem( weight:Number, picture:Bitmap ) 
		{
			//passing itself as the data
			super( weight );
			
			//stores custom data
			this._picture = picture;
			
        }  
		
		override public function clone():ITreeMapItem
		{
			var item:ImageItem = new ImageItem( weight, _picture );
			item.area = area;
			
			if ( rect != null )	item.rect = rect.clone();
			else				item.rect = new Rectangle();
			
			return item;
		}
		
		public function render( graphics:Graphics ):void 
		{
			if ( rect.width < 1 ) rect.width = 1;
			if ( rect.height < 1 ) rect.height = 1;
			
			var bd:BitmapData = new BitmapData( rect.width, rect.height );
			bd.copyPixels( _picture.bitmapData, rect, new Point );
			graphics.beginBitmapFill( bd );
			graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			
		}
	}

}