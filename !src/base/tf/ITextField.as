package base.tf {
	import flash.events.IEventDispatcher;
	import flash.text.TextFormat;
	
	public interface ITextField extends IEventDispatcher {
		
		function get text(): String;
		function set text(value: String): void;
		function get htmlText(): String;
		function set htmlText(value: String): void;
		function get autoSize(): String;
		function set autoSize(value: String): void;
		function get textWidth(): Number;
		function get textHeight(): Number;
		function get width(): Number;
		function get height(): Number;
		function get x(): Number;
		function get y(): Number;
		function set x(value: Number): void;
		function set y(value: Number): void;
		function getTextFormat(): TextFormat;
		function setTextFormat(value: TextFormat): void;
		function get defaultTextFormat(): TextFormat;
		function set defaultTextFormat(value: TextFormat): void;
	}
	
}