package base.btn {
	import flash.events.IEventDispatcher;
	
	public interface IBtn extends IEventDispatcher {
		
		function addMouseEvents(): void;
		function removeMouseEvents(): void;
		function get width(): Number;
		function get height(): Number;
		function get x(): Number;
		function get y(): Number;
		function set x(value: Number): void;
		function set y(value: Number): void;
		
	}
	
}