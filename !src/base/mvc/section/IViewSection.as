package base.mvc.section {
	
	public interface IViewSection {
		
		function init(): void;
		function show(): void;
		function hide(): void;
			
		function get x(): Number;
		function set x(value: Number): void;
		function get y(): Number;
		function set y(value: Number): void;
	}
	
}