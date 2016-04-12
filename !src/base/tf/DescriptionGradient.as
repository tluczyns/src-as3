package base.tf {
	import base.math.MathExt;

	public class DescriptionGradient extends Object {
		
		public var colors: Array;
		public var alphas: Array;
		public var ratios: Array;
		public var rotationGradient: Number;
		public var gradientType: String;
		public var tx: Number;
		public var ty: Number;
		
		public function DescriptionGradient(colors: Array, alphas: Array = null, ratios: Array = null, rotationGradient: Number = 90, gradientType: String = "linear", tx: Number = 0, ty: Number = 0): void {
			this.colors = colors;
			var i: uint;
			if ((!alphas) || (!alphas.length)) {
				alphas = new Array(colors.length);
				for (i = 0; i < colors.length; i++) alphas[i] = 1;
			}
			this.alphas = alphas;
			if ((!ratios) || (!ratios.length)) {
				ratios = new Array(colors.length);
				for (i = 0; i < colors.length; i++) ratios[i] = Math.round(255 * (i / colors.length));
			}
			this.ratios = ratios;
			this.rotationGradient = rotationGradient * MathExt.TO_RADIANS;
			this.gradientType = gradientType;
			this.tx = tx;
			this.ty = ty;
			
		}
		
	}

}