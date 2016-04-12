package baseStarling.btn {
	
	public interface IBtn {
		
		function addTouchEvents(): void;
		function removeTouchEvents(): void;
		function get width(): Number;
		function get height(): Number;
		function get x(): Number;
		function get y(): Number;
		function set x(value: Number): void;
		function set y(value: Number): void;
		
	}
	
}