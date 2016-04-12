package baseStarling.gallery {
	
	public interface IRenderable {
		
		function get vecNumInDimension(): Vector.<uint>;
		function set vecNumInDimension(value: Vector.<uint>): void;
		
		function get vecNumInRow(): Vector.<uint>;
		function set vecNumInRow(value: Vector.<uint>): void;
		
		function renderInternal(vecTimeRender: Vector.<Number>, startNumDimensionToRender: uint, vecTimeTotal: Vector.<Number>): void;
		
		function dispose(): void;
	}
	
}