package away3d.materials.compilation
{
	import away3d.arcane;
	import away3d.materials.LightSources;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.MethodVOSet;
	import away3d.materials.methods.ShaderMethodSetup;
	import away3d.materials.methods.ShadingMethodBase;

	/**
	 * ShaderCompiler is an abstract base class for shader compilers that use modular shader methods to assemble a
	 * material. Concrete subclasses are used by the default materials.
	 *
	 * @see away3d.materials.methods.ShadingMethodBase
	 */
	public class ShaderCompiler
	{
		protected var _sharedRegisters:ShaderRegisterData;
		protected var _registerCache:ShaderRegisterCache;
		protected var _dependencyCounter:MethodDependencyCounter;
		protected var _methodSetup:ShaderMethodSetup;

		protected var _smooth:Boolean;
		protected var _repeat:Boolean;
		protected var _mipmap:Boolean;
		protected var _enableLightFallOff:Boolean;
		protected var _preserveAlpha:Boolean = true;
		protected var _animateUVs:Boolean;
		protected var _alphaPremultiplied:Boolean;
		protected var _vertexConstantData:Vector.<Number>;
		protected var _fragmentConstantData:Vector.<Number>;

		protected var _vertexCode:String;
		protected var _fragmentCode:String;
		protected var _fragmentLightCode:String;
		protected var _fragmentPostLightCode:String;
		private var _commonsDataIndex:int = -1;

		protected var _animatableAttributes:Vector.<String>;
		protected var _animationTargetRegisters:Vector.<String>;

		protected var _lightProbeDiffuseIndices:Vector.<uint>;
		protected var _lightProbeSpecularIndices:Vector.<uint>;
		protected var _uvBufferIndex:int = -1;
		protected var _uvTransformIndex:int = -1;
		protected var _secondaryUVBufferIndex:int = -1;
		protected var _normalBufferIndex:int = -1;
		protected var _tangentBufferIndex:int = -1;
		protected var _lightFragmentConstantIndex:int = -1;
		protected var _sceneMatrixIndex:int = -1;
		protected var _sceneNormalMatrixIndex:int = -1;
		protected var _cameraPositionIndex:int = -1;
		protected var _probeWeightsIndex:int = -1;

		protected var _specularLightSources:uint;
		protected var _diffuseLightSources:uint;

		protected var _numLights:int;
		protected var _numLightProbes:uint;
		protected var _numPointLights:uint;
		protected var _numDirectionalLights:uint;

		protected var _numProbeRegisters:Number;
		protected var _combinedLightSources:uint;

		protected var _usingSpecularMethod:Boolean;

		protected var _needUVAnimation:Boolean;
		protected var _UVTarget:String;
		protected var _UVSource:String;

		protected var _profile:String;

		protected var _forceSeperateMVP:Boolean;

		use namespace arcane;

		/**
		 * Creates a new ShaderCompiler object.
		 * @param profile The compatibility profile of the renderer.
		 */
		public function ShaderCompiler(profile:String)
		{
			_sharedRegisters = new ShaderRegisterData();
			_dependencyCounter = new MethodDependencyCounter();
			_profile = profile;
			initRegisterCache(profile);
		}

		/**
		 * Whether or not to use fallOff and radius properties for lights. This can be used to improve performance and
		 * compatibility for constrained mode.
		 */
		public function get enableLightFallOff():Boolean
		{
			return _enableLightFallOff;
		}

		public function set enableLightFallOff(value:Boolean):void
		{
			_enableLightFallOff = value;
		}

		/**
		 * Indicates whether the compiled code needs UV animation.
		 */
		public function get needUVAnimation():Boolean
		{
			return _needUVAnimation;
		}

		/**
		 * The target register to place the animated UV coordinate.
		 */
		public function get UVTarget():String
		{
			return _UVTarget;
		}

		/**
		 * The souce register providing the UV coordinate to animate.
		 */
		public function get UVSource():String
		{
			return _UVSource;
		}

		/**
		 * Indicates whether the screen projection should be calculated by forcing a separate scene matrix and
		 * view-projection matrix. This is used to prevent rounding errors when using multiple passes with different
		 * projection code.
		 */
		public function get forceSeperateMVP():Boolean
		{
			return _forceSeperateMVP;
		}

		public function set forceSeperateMVP(value:Boolean):void
		{
			_forceSeperateMVP = value;
		}

		/**
		 * Initialized the register cache.
		 * @param profile The compatibility profile of the renderer.
		 */
		private function initRegisterCache(profile:String):void
		{
			_registerCache = new ShaderRegisterCache(profile);
			_registerCache.vertexAttributesOffset = 1;
			_registerCache.reset();
		}

		/**
		 * Indicate whether UV coordinates need to be animated using the renderable's transformUV matrix.
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
		 * Indicates whether visible textures (or other pixels) used by this material have
		 * already been premultiplied.
		 */
		public function get alphaPremultiplied():Boolean
		{
			return _alphaPremultiplied;
		}

		public function set alphaPremultiplied(value:Boolean):void
		{
			_alphaPremultiplied = value;
		}

		/**
		 * Indicates whether the output alpha value should remain unchanged compared to the material's original alpha.
		 */
		public function get preserveAlpha():Boolean
		{
			return _preserveAlpha;
		}

		public function set preserveAlpha(value:Boolean):void
		{
			_preserveAlpha = value;
		}

		/**
		 * Sets the default texture sampling properties.
		 * @param smooth Indicates whether the texture should be filtered when sampled. Defaults to true.
		 * @param repeat Indicates whether the texture should be tiled when sampled. Defaults to true.
		 * @param mipmap Indicates whether or not any used textures should use mipmapping. Defaults to true.
		 */
		public function setTextureSampling(smooth:Boolean, repeat:Boolean, mipmap:Boolean):void
		{
			_smooth = smooth;
			_repeat = repeat;
			_mipmap = mipmap;
		}

		/**
		 * Sets the constant buffers allocated by the material. This allows setting constant data during compilation.
		 * @param vertexConstantData The vertex constant data buffer.
		 * @param fragmentConstantData The fragment constant data buffer.
		 */
		public function setConstantDataBuffers(vertexConstantData:Vector.<Number>, fragmentConstantData:Vector.<Number>):void
		{
			_vertexConstantData = vertexConstantData;
			_fragmentConstantData = fragmentConstantData;
		}

		/**
		 * The shader method setup object containing the method configuration and their value objects for the material being compiled.
		 */
		public function get methodSetup():ShaderMethodSetup
		{
			return _methodSetup;
		}

		public function set methodSetup(value:ShaderMethodSetup):void
		{
			_methodSetup = value;
		}

		/**
		 * Compiles the code after all setup on the compiler has finished.
		 */
		public function compile():void
		{
			initRegisterIndices();
			initLightData();

			_animatableAttributes = Vector.<String>(["va0"]);
			_animationTargetRegisters = Vector.<String>(["vt0"]);
			_vertexCode = "";
			_fragmentCode = "";

			_sharedRegisters.localPosition = _registerCache.getFreeVertexVectorTemp();
			_registerCache.addVertexTempUsages(_sharedRegisters.localPosition, 1);

			createCommons();
			calculateDependencies();
			updateMethodRegisters();

			for (var i:uint = 0; i < 4; ++i)
				_registerCache.getFreeVertexConstant();

			createNormalRegisters();
			if (_dependencyCounter.globalPosDependencies > 0 || _forceSeperateMVP)
				compileGlobalPositionCode();
			compileProjectionCode();
			compileMethodsCode();
			compileFragmentOutput();
			_fragmentPostLightCode = fragmentCode;
		}

		/**
		 * Creates the registers to contain the normal data.
		 */
		protected function createNormalRegisters():void
		{

		}

		/**
		 * Compile the code for the methods.
		 */
		protected function compileMethodsCode():void
		{
			if (_dependencyCounter.uvDependencies > 0)
				compileUVCode();
			if (_dependencyCounter.secondaryUVDependencies > 0)
				compileSecondaryUVCode();
			if (_dependencyCounter.normalDependencies > 0)
				compileNormalCode();
			if (_dependencyCounter.viewDirDependencies > 0)
				compileViewDirCode();
			compileLightingCode();
			_fragmentLightCode = _fragmentCode;
			_fragmentCode = "";
			compileMethods();
		}

		/**
		 * Compile the lighting code.
		 */
		protected function compileLightingCode():void
		{

		}

		/**
		 * Calculate the view direction.
		 */
		protected function compileViewDirCode():void
		{

		}

		/**
		 * Calculate the normal.
		 */
		protected function compileNormalCode():void
		{

		}

		/**
		 * Calculate the (possibly animated) UV coordinates.
		 */
		private function compileUVCode():void
		{
			var uvAttributeReg:ShaderRegisterElement = _registerCache.getFreeVertexAttribute();
			_uvBufferIndex = uvAttributeReg.index;

			var varying:ShaderRegisterElement = _registerCache.getFreeVarying();

			_sharedRegisters.uvVarying = varying;

			if (animateUVs) {
				// a, b, 0, tx
				// c, d, 0, ty
				var uvTransform1:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
				var uvTransform2:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
				_uvTransformIndex = uvTransform1.index*4;

				_vertexCode += "dp4 " + varying + ".x, " + uvAttributeReg + ", " + uvTransform1 + "\n" +
					"dp4 " + varying + ".y, " + uvAttributeReg + ", " + uvTransform2 + "\n" +
					"mov " + varying + ".zw, " + uvAttributeReg + ".zw \n";
			} else {
				_uvTransformIndex = -1;
				_needUVAnimation = true;
				_UVTarget = varying.toString();
				_UVSource = uvAttributeReg.toString();
			}
		}

		/**
		 * Provide the secondary UV coordinates.
		 */
		private function compileSecondaryUVCode():void
		{
			var uvAttributeReg:ShaderRegisterElement = _registerCache.getFreeVertexAttribute();
			_secondaryUVBufferIndex = uvAttributeReg.index;
			_sharedRegisters.secondaryUVVarying = _registerCache.getFreeVarying();
			_vertexCode += "mov " + _sharedRegisters.secondaryUVVarying + ", " + uvAttributeReg + "\n";
		}

		/**
		 * Compile the world-space position.
		 */
		protected function compileGlobalPositionCode():void
		{
			_sharedRegisters.globalPositionVertex = _registerCache.getFreeVertexVectorTemp();
			_registerCache.addVertexTempUsages(_sharedRegisters.globalPositionVertex, _dependencyCounter.globalPosDependencies);
			var positionMatrixReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_sceneMatrixIndex = positionMatrixReg.index*4;

			_vertexCode += "m44 " + _sharedRegisters.globalPositionVertex + ", " + _sharedRegisters.localPosition + ", " + positionMatrixReg + "\n";

			if (_dependencyCounter.usesGlobalPosFragment) {
				_sharedRegisters.globalPositionVarying = _registerCache.getFreeVarying();
				_vertexCode += "mov " + _sharedRegisters.globalPositionVarying + ", " + _sharedRegisters.globalPositionVertex + "\n";
			}
		}

		/**
		 * Get the projection coordinates.
		 */
		private function compileProjectionCode():void
		{
			var pos:String = _dependencyCounter.globalPosDependencies > 0 || _forceSeperateMVP? _sharedRegisters.globalPositionVertex.toString() : _animationTargetRegisters[0];
			var code:String;

			if (_dependencyCounter.projectionDependencies > 0) {
				_sharedRegisters.projectionFragment = _registerCache.getFreeVarying();
				code = "m44 vt5, " + pos + ", vc0		\n" +
					"mov " + _sharedRegisters.projectionFragment + ", vt5\n" +
					"mov op, vt5\n";
			} else
				code = "m44 op, " + pos + ", vc0		\n";

			_vertexCode += code;
		}

		/**
		 * Assign the final output colour the the output register.
		 */
		private function compileFragmentOutput():void
		{
			_fragmentCode += "mov " + _registerCache.fragmentOutputRegister + ", " + _sharedRegisters.shadedTarget + "\n";
			_registerCache.removeFragmentTempUsage(_sharedRegisters.shadedTarget);
		}

		/**
		 * Reset all the indices to "unused".
		 */
		protected function initRegisterIndices():void
		{
			_commonsDataIndex = -1;
			_cameraPositionIndex = -1;
			_uvBufferIndex = -1;
			_uvTransformIndex = -1;
			_secondaryUVBufferIndex = -1;
			_normalBufferIndex = -1;
			_tangentBufferIndex = -1;
			_lightFragmentConstantIndex = -1;
			_sceneMatrixIndex = -1;
			_sceneNormalMatrixIndex = -1;
			_probeWeightsIndex = -1;
		}

		/**
		 * Prepares the setup for the light code.
		 */
		protected function initLightData():void
		{
			_numLights = _numPointLights + _numDirectionalLights;
			_numProbeRegisters = Math.ceil(_numLightProbes/4);

			if (_methodSetup._specularMethod)
				_combinedLightSources = _specularLightSources | _diffuseLightSources;
			else
				_combinedLightSources = _diffuseLightSources;

			_usingSpecularMethod = Boolean(_methodSetup._specularMethod && (
				usesLightsForSpecular() ||
				usesProbesForSpecular()));
		}

		/**
		 * Create the commonly shared constant register.
		 */
		private function createCommons():void
		{
			_sharedRegisters.commons = _registerCache.getFreeFragmentConstant();
			_commonsDataIndex = _sharedRegisters.commons.index*4;
		}

		/**
		 * Figure out which named registers are required, and how often.
		 */
		protected function calculateDependencies():void
		{
			_dependencyCounter.reset();

			var methods:Vector.<MethodVOSet> = _methodSetup._methods;
			var len:uint;

			setupAndCountMethodDependencies(_methodSetup._diffuseMethod, _methodSetup._diffuseMethodVO);
			if (_methodSetup._shadowMethod)
				setupAndCountMethodDependencies(_methodSetup._shadowMethod, _methodSetup._shadowMethodVO);
			setupAndCountMethodDependencies(_methodSetup._ambientMethod, _methodSetup._ambientMethodVO);
			if (_usingSpecularMethod)
				setupAndCountMethodDependencies(_methodSetup._specularMethod, _methodSetup._specularMethodVO);
			if (_methodSetup._colorTransformMethod)
				setupAndCountMethodDependencies(_methodSetup._colorTransformMethod, _methodSetup._colorTransformMethodVO);

			len = methods.length;
			for (var i:uint = 0; i < len; ++i)
				setupAndCountMethodDependencies(methods[i].method, methods[i].data);

			if (usesNormals)
				setupAndCountMethodDependencies(_methodSetup._normalMethod, _methodSetup._normalMethodVO);

			// todo: add spotlights to count check
			_dependencyCounter.setPositionedLights(_numPointLights, _combinedLightSources);
		}

		/**
		 * Counts the dependencies for a given method.
		 * @param method The method to count the dependencies for.
		 * @param methodVO The method's data for this material.
		 */
		private function setupAndCountMethodDependencies(method:ShadingMethodBase, methodVO:MethodVO):void
		{
			setupMethod(method, methodVO);
			_dependencyCounter.includeMethodVO(methodVO);
		}

		/**
		 * Assigns all prerequisite data for the methods, so we can calculate dependencies for them.
		 */
		private function setupMethod(method:ShadingMethodBase, methodVO:MethodVO):void
		{
			method.reset();
			methodVO.reset();
			methodVO.vertexData = _vertexConstantData;
			methodVO.fragmentData = _fragmentConstantData;
			methodVO.useSmoothTextures = _smooth;
			methodVO.repeatTextures = _repeat;
			methodVO.useMipmapping = _mipmap;
			methodVO.useLightFallOff = _enableLightFallOff && _profile != "baselineConstrained";
			methodVO.numLights = _numLights + _numLightProbes;
			method.initVO(methodVO);
		}

		/**
		 * The index for the common data register.
		 */
		public function get commonsDataIndex():int
		{
			return _commonsDataIndex;
		}

		/**
		 * Assigns the shared register data to all methods.
		 */
		private function updateMethodRegisters():void
		{
			_methodSetup._normalMethod.sharedRegisters = _sharedRegisters;
			_methodSetup._diffuseMethod.sharedRegisters = _sharedRegisters;
			if (_methodSetup._shadowMethod)
				_methodSetup._shadowMethod.sharedRegisters = _sharedRegisters;
			_methodSetup._ambientMethod.sharedRegisters = _sharedRegisters;
			if (_methodSetup._specularMethod)
				_methodSetup._specularMethod.sharedRegisters = _sharedRegisters;
			if (_methodSetup._colorTransformMethod)
				_methodSetup._colorTransformMethod.sharedRegisters = _sharedRegisters;

			var methods:Vector.<MethodVOSet> = _methodSetup._methods;
			var len:int = methods.length;
			for (var i:uint = 0; i < len; ++i)
				methods[i].method.sharedRegisters = _sharedRegisters;
		}

		/**
		 * The amount of vertex constants used by the material. Any animation code to be added can append its vertex
		 * constant data after this.
		 */
		public function get numUsedVertexConstants():uint
		{
			return _registerCache.numUsedVertexConstants;
		}

		/**
		 * The amount of fragment constants used by the material. Any animation code to be added can append its vertex
		 * constant data after this.
		 */
		public function get numUsedFragmentConstants():uint
		{
			return _registerCache.numUsedFragmentConstants;
		}

		/**
		 * The amount of vertex attribute streams used by the material. Any animation code to be added can add its
		 * streams after this. Also used to automatically disable attribute slots on pass deactivation.
		 */
		public function get numUsedStreams():uint
		{
			return _registerCache.numUsedStreams;
		}

		/**
		 * The amount of textures used by the material. Used to automatically disable texture slots on pass deactivation.
		 */
		public function get numUsedTextures():uint
		{
			return _registerCache.numUsedTextures;
		}

		/**
		 * Number of used varyings. Any animation code to be added can add its used varyings after this.
		 */
		public function get numUsedVaryings():uint
		{
			return _registerCache.numUsedVaryings;
		}

		/**
		 * Indicates whether lights are used for specular reflections.
		 */
		protected function usesLightsForSpecular():Boolean
		{
			return _numLights > 0 && (_specularLightSources & LightSources.LIGHTS) != 0;
		}

		/**
		 * Indicates whether lights are used for diffuse reflections.
		 */
		protected function usesLightsForDiffuse():Boolean
		{
			return _numLights > 0 && (_diffuseLightSources & LightSources.LIGHTS) != 0;
		}

		/**
		 * Disposes all resources used by the compiler.
		 */
		public function dispose():void
		{
			cleanUpMethods();
			_registerCache.dispose();
			_registerCache = null;
			_sharedRegisters = null;
		}

		/**
		 * Clean up method's compilation data after compilation finished.
		 */
		private function cleanUpMethods():void
		{
			if (_methodSetup._normalMethod)
				_methodSetup._normalMethod.cleanCompilationData();
			if (_methodSetup._diffuseMethod)
				_methodSetup._diffuseMethod.cleanCompilationData();
			if (_methodSetup._ambientMethod)
				_methodSetup._ambientMethod.cleanCompilationData();
			if (_methodSetup._specularMethod)
				_methodSetup._specularMethod.cleanCompilationData();
			if (_methodSetup._shadowMethod)
				_methodSetup._shadowMethod.cleanCompilationData();
			if (_methodSetup._colorTransformMethod)
				_methodSetup._colorTransformMethod.cleanCompilationData();

			var methods:Vector.<MethodVOSet> = _methodSetup._methods;
			var len:uint = methods.length;
			for (var i:uint = 0; i < len; ++i)
				methods[i].method.cleanCompilationData();
		}

		/**
		 * Define which light source types to use for specular reflections. This allows choosing between regular lights
		 * and/or light probes for specular reflections.
		 *
		 * @see away3d.materials.LightSources
		 */
		public function get specularLightSources():uint
		{
			return _specularLightSources;
		}

		public function set specularLightSources(value:uint):void
		{
			_specularLightSources = value;
		}

		/**
		 * Define which light source types to use for diffuse reflections. This allows choosing between regular lights
		 * and/or light probes for diffuse reflections.
		 *
		 * @see away3d.materials.LightSources
		 */
		public function get diffuseLightSources():uint
		{
			return _diffuseLightSources;
		}

		public function set diffuseLightSources(value:uint):void
		{
			_diffuseLightSources = value;
		}

		/**
		 * Indicates whether light probes are being used for specular reflections.
		 */
		protected function usesProbesForSpecular():Boolean
		{
			return _numLightProbes > 0 && (_specularLightSources & LightSources.PROBES) != 0;
		}

		/**
		 * Indicates whether light probes are being used for diffuse reflections.
		 */
		protected function usesProbesForDiffuse():Boolean
		{
			return _numLightProbes > 0 && (_diffuseLightSources & LightSources.PROBES) != 0;
		}

		/**
		 * Indicates whether any light probes are used.
		 */
		protected function usesProbes():Boolean
		{
			return _numLightProbes > 0 && ((_diffuseLightSources | _specularLightSources) & LightSources.PROBES) != 0;
		}

		/**
		 * The index for the UV vertex attribute stream.
		 */
		public function get uvBufferIndex():int
		{
			return _uvBufferIndex;
		}

		/**
		 * The index for the UV transformation matrix vertex constant.
		 */
		public function get uvTransformIndex():int
		{
			return _uvTransformIndex;
		}

		/**
		 * The index for the secondary UV vertex attribute stream.
		 */
		public function get secondaryUVBufferIndex():int
		{
			return _secondaryUVBufferIndex;
		}

		/**
		 * The index for the vertex normal attribute stream.
		 */
		public function get normalBufferIndex():int
		{
			return _normalBufferIndex;
		}

		/**
		 * The index for the vertex tangent attribute stream.
		 */
		public function get tangentBufferIndex():int
		{
			return _tangentBufferIndex;
		}

		/**
		 * The first index for the fragment constants containing the light data.
		 */
		public function get lightFragmentConstantIndex():int
		{
			return _lightFragmentConstantIndex;
		}

		/**
		 * The index of the vertex constant containing the camera position.
		 */
		public function get cameraPositionIndex():int
		{
			return _cameraPositionIndex;
		}

		/**
		 * The index of the vertex constant containing the scene matrix.
		 */
		public function get sceneMatrixIndex():int
		{
			return _sceneMatrixIndex;
		}

		/**
		 * The index of the vertex constant containing the uniform scene matrix (the inverse transpose).
		 */
		public function get sceneNormalMatrixIndex():int
		{
			return _sceneNormalMatrixIndex;
		}

		/**
		 * The index of the fragment constant containing the weights for the light probes.
		 */
		public function get probeWeightsIndex():int
		{
			return _probeWeightsIndex;
		}

		/**
		 * The generated vertex code.
		 */
		public function get vertexCode():String
		{
			return _vertexCode;
		}

		/**
		 * The generated fragment code.
		 */
		public function get fragmentCode():String
		{
			return _fragmentCode;
		}

		/**
		 * The code containing the lighting calculations.
		 */
		public function get fragmentLightCode():String
		{
			return _fragmentLightCode;
		}

		/**
		 * The code containing the post-lighting calculations.
		 */
		public function get fragmentPostLightCode():String
		{
			return _fragmentPostLightCode;
		}

		/**
		 * The register name containing the final shaded colour.
		 */
		public function get shadedTarget():String
		{
			return _sharedRegisters.shadedTarget.toString();
		}

		/**
		 * The amount of point lights that need to be supported.
		 */
		public function get numPointLights():uint
		{
			return _numPointLights;
		}

		public function set numPointLights(numPointLights:uint):void
		{
			_numPointLights = numPointLights;
		}

		/**
		 * The amount of directional lights that need to be supported.
		 */
		public function get numDirectionalLights():uint
		{
			return _numDirectionalLights;
		}

		public function set numDirectionalLights(value:uint):void
		{
			_numDirectionalLights = value;
		}

		/**
		 * The amount of light probes that need to be supported.
		 */
		public function get numLightProbes():uint
		{
			return _numLightProbes;
		}

		public function set numLightProbes(value:uint):void
		{
			_numLightProbes = value;
		}

		/**
		 * Indicates whether the specular method is used.
		 */
		public function get usingSpecularMethod():Boolean
		{
			return _usingSpecularMethod;
		}

		/**
		 * The attributes that need to be animated by animators.
		 */
		public function get animatableAttributes():Vector.<String>
		{
			return _animatableAttributes;
		}

		/**
		 * The target registers for animated properties, written to by the animators.
		 */
		public function get animationTargetRegisters():Vector.<String>
		{
			return _animationTargetRegisters;
		}

		/**
		 * Indicates whether the compiled shader uses normals.
		 */
		public function get usesNormals():Boolean
		{
			return _dependencyCounter.normalDependencies > 0 && _methodSetup._normalMethod.hasOutput;
		}

		/**
		 * Indicates whether the compiled shader uses lights.
		 */
		protected function usesLights():Boolean
		{
			return _numLights > 0 && (_combinedLightSources & LightSources.LIGHTS) != 0;
		}

		/**
		 * Compiles the code for the methods.
		 */
		protected function compileMethods():void
		{
			var methods:Vector.<MethodVOSet> = _methodSetup._methods;
			var numMethods:uint = methods.length;
			var method:EffectMethodBase;
			var data:MethodVO;
			var alphaReg:ShaderRegisterElement;

			if (_preserveAlpha) {
				alphaReg = _registerCache.getFreeFragmentSingleTemp();
				_registerCache.addFragmentTempUsages(alphaReg, 1);
				_fragmentCode += "mov " + alphaReg + ", " + _sharedRegisters.shadedTarget + ".w\n";
			}

			for (var i:uint = 0; i < numMethods; ++i) {
				method = methods[i].method;
				data = methods[i].data;
				_vertexCode += method.getVertexCode(data, _registerCache);
				if (data.needsGlobalVertexPos || data.needsGlobalFragmentPos)
					_registerCache.removeVertexTempUsage(_sharedRegisters.globalPositionVertex);

				_fragmentCode += method.getFragmentCode(data, _registerCache, _sharedRegisters.shadedTarget);
				if (data.needsNormals)
					_registerCache.removeFragmentTempUsage(_sharedRegisters.normalFragment);
				if (data.needsView)
					_registerCache.removeFragmentTempUsage(_sharedRegisters.viewDirFragment);
			}

			if (_preserveAlpha) {
				_fragmentCode += "mov " + _sharedRegisters.shadedTarget + ".w, " + alphaReg + "\n";
				_registerCache.removeFragmentTempUsage(alphaReg);
			}

			if (_methodSetup._colorTransformMethod) {
				_vertexCode += _methodSetup._colorTransformMethod.getVertexCode(_methodSetup._colorTransformMethodVO, _registerCache);
				_fragmentCode += _methodSetup._colorTransformMethod.getFragmentCode(_methodSetup._colorTransformMethodVO, _registerCache, _sharedRegisters.shadedTarget);
			}
		}

		/**
		 * Indices for the light probe diffuse textures.
		 */
		public function get lightProbeDiffuseIndices():Vector.<uint>
		{
			return _lightProbeDiffuseIndices;
		}

		/**
		 * Indices for the light probe specular textures.
		 */
		public function get lightProbeSpecularIndices():Vector.<uint>
		{
			return _lightProbeSpecularIndices;
		}
	}
}
