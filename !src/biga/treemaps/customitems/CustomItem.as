package  customitems
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import treemap.ITreeMapItem;
	import treemap.TreeMapItem;
	
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class CustomItem extends TreeMapItem
	{
		
		private var _message:String;
		private var _parent:DisplayObjectContainer;
		private var txt:TextField;
		private var _color:uint;
		
		public function CustomItem( weight:Number, parent:DisplayObjectContainer, message:String = null ) 
		{
			//passing itself as the data
			super( weight );
			
			//stores custom data
			this._parent = parent;
			this._message = message;
			color = Math.random() * 0x808080 + 0x808080;
			
			//do some stuff
			txt = new TextField();
			txt.wordWrap = true;
			txt.multiline = true;
			txt.selectable = false;
			txt.defaultTextFormat = new TextFormat( "Verdana", (.5 + weight) * 15, 0, true, null, null, null, null, TextFieldAutoSize.CENTER );
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.text = weight.toFixed(2);
			_parent.addChild( txt );
			
        }  
		
		override public function clone():ITreeMapItem
		{
			var item:CustomItem = new CustomItem( weight, _parent, _message );
			item.area = area;
			
			if ( rect != null )	item.rect = rect.clone();
			else				item.rect = new Rectangle();
			
			return item;
		}
		
		public function render(graphics:Graphics):void 
		{
			
			graphics.beginFill( color );
			graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			
			txt.x = rect.x;
			txt.y = rect.y;
			
			txt.width = rect.width;
			txt.height = rect.height;
			
		}
		
		public function get message():String { return _message; }
		public function set message(value:String):void 
		{
			_message = value;
		}
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void 
		{
			_color = value;
		}
	}

}