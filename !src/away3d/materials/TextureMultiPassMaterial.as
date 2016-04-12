package away3d.materials
{
	import away3d.textures.Texture2DBase;
	import away3d.arcane;
	
	use namespace arcane;

	/**
	 * TextureMultiPassMaterial is a multi-pass material that uses a texture to define the surface's diffuse reflection colour (albedo).
	 */
	public class TextureMultiPassMaterial extends MultiPassMaterialBase
	{
		private var _animateUVs:Boolean;

		/**
		 * Creates a new TextureMultiPassMaterial.
		 * @param texture The texture used for the material's albedo color.
		 * @param smooth Indicates whether the texture should be filtered when sampled. Defaults to true.
		 * @param repeat Indicates whether the texture should be tiled when sampled. Defaults to true.
		 * @param mipmap Indicates whether or not any used textures should use mipmapping. Defaults to true.
		 */
		public function TextureMultiPassMaterial(texture:Texture2DBase = null, smooth:Boolean = true, repeat:Boolean = false, mipmap:Boolean = true)
		{
			super();
			this.texture = texture;
			this.smooth = smooth;
			this.repeat = repeat;
			this.mipmap = mipmap;
		}

		/**
		 * Specifies whether or not the UV coordinates should be animated using a transformation matrix.
		 */
		public function get animateUVs():Boolean
		{
			return _animateUVs;
		}
		
		public function set animateUVs(value:Boolean):void
		{
			_animateUVs = value;
		}
		
		/**
		 * The texture object to use for the albedo colour.
		 */
		public function get texture():Texture2DBase
		{
			return diffuseMethod.texture;
		}
		
		public function set texture(value:Texture2DBase):void
		{
			diffuseMethod.texture = value;
		}
		
		/**
		 * The texture object to use for the ambient colour.
		 */
		public function get ambientTexture():Texture2DBase
		{
			return ambientMethod.texture;
		}
		
		public function set ambientTexture(value:Texture2DBase):void
		{
			ambientMethod.texture = value;
			diffuseMethod.useAmbientTexture = Boolean(value);
		}
		
		override protected function updateScreenPasses():void
		{
			super.updateScreenPasses();
			if (_effectsPass)
				_effectsPass.animateUVs = _animateUVs;
		}
	}
}
