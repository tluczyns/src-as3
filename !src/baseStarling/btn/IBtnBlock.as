package baseStarling.btn {
	
	public interface IBtnBlock extends IBtn {

		function get isEnabled(): Boolean;
		function set isEnabled(value: Boolean): void;
		function dispose(): void;
		
	}
	
}