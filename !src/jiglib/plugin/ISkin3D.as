package jiglib.plugin
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.data.TriangleVertexIndices;

	/**
	 * Represents a mesh from a 3D engine inside JigLib.
	 * Its implementation shold allow to get and set a Matrix3D on
	 * the original object.
	 *
	 * In the implementation, JMatrix3D should be translated into
	 * the type proper for a given engine.
	 */
	public interface ISkin3D
	{

		/**
		 * @return A matrix with the current transformation values of the mesh.
		 */
		function get transform():Matrix3D;

		/**
		 * Apply a matrix to the mesh.
		 */
		function set transform(m:Matrix3D):void;
		
		
		function get vertices():Vector.<Vector3D>;
		function get indices():Vector.<TriangleVertexIndices>;
	}
}
