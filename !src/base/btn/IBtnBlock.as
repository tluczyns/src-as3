package base.btn {
	
	public interface IBtnBlock extends IBtn {

		function get isEnabled(): Boolean;
		function set isEnabled(value: Boolean): void;
		function destroy(): void;
		
	}
	
}