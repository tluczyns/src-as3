package ru.inspirit.asfeat.geom
{
	import apparat.math.FastMath;
	
	/**
	 * Converts a rotation vector to rotation matrix or vice versa. 
	 * Rotation vector is a compact representation of rotation matrix. 
	 * Direction of the rotation vector is the rotation axis 
	 * and the length of the vector is the rotation angle around the axis.
	 * 
	 * @author	Eugene Zatepyakin
	 * @see		http://blog.inspirit.ru
	 */
	 
	public final class Rodrigues
	{
		/**
		*	Converts a rotation vector to rotation matrix
		*	@param vec		input 3x length rotation vector
		*	@param mat		output 3x3 rotation Matrix
		*	@param jacobian	output 3x9 jacobian Matrix (derivative)
		**/
		public function vector2Matrix(vec:Vector.<Number>, mat:Vector.<Number>, jacobian:Vector.<Number> = null):void
		{
			const small:Number = 1e-6;
			var vec0:Number = vec[0];
			var vec1:Number = vec[1];
			var vec2:Number = vec[2];
			var th:Number = Math.sqrt( vec0*vec0 + vec1*vec1 + vec2*vec2 );
			
			if( th < small ) 
			{
				mat[0] = 1.0 ; mat[3] = 0.0 ; mat[6] = 0.0;
				mat[1] = 0.0 ; mat[4] = 1.0 ; mat[7] = 0.0;
				mat[2] = 0.0 ; mat[5] = 0.0 ; mat[8] = 1.0;

				if(null != jacobian) 
				{
					jacobian[0] = 0;  jacobian[9]  = 0;  jacobian[18] = 0;
					jacobian[1] = 0;  jacobian[10] = 0;  jacobian[19] = 1;
					jacobian[2] = 0;  jacobian[11] = -1; jacobian[20] = 0;

					jacobian[3] = 0;  jacobian[12] = 0;  jacobian[21] = -1;
					jacobian[4] = 0;  jacobian[13] = 0;  jacobian[22] = 0;
					jacobian[5] = 1;  jacobian[14] = 0;  jacobian[23] = 0;

					jacobian[6] = 0;  jacobian[15] = 1;  jacobian[24] = 0;
					jacobian[7] = -1; jacobian[16] = 0;  jacobian[25] = 0;
					jacobian[8] = 0;  jacobian[17] = 0;  jacobian[26] = 0;
				}
				return;
			}
			
			var x:Number = vec0 / th;
		    var y:Number = vec1 / th;
		    var z:Number = vec2 / th;

		    var xx:Number = x*x;
		    var xy:Number = x*y;
		    var xz:Number = x*z;
		    var yy:Number = y*y;
		    var yz:Number = y*z;
		    var zz:Number = z*z;

		    const yx:Number = xy;
		    const zx:Number = xz;
		    const zy:Number = yz;

		    var sth:Number = Math.sin(th);
		    var cth:Number = Math.cos(th);
		    // u can use faster macro here 
		    // but if u gonna pack/unpack the same data
		    // it may loose too much precision
			//MathMacro.sincos2(th, sth, cth);
		    var mcth:Number = 1.0 - cth;
		
			mat[0] = 1          - mcth * (yy+zz);
		    mat[1] =     sth*z  + mcth * xy;
		    mat[2] =   - sth*y  + mcth * xz;

		    mat[3] =   - sth*z  + mcth * yx;
		    mat[4] = 1          - mcth * (zz+xx);
		    mat[5] =     sth*x  + mcth * yz;

		    mat[6] =     sth*y  + mcth * xz;
		    mat[7] =   - sth*x  + mcth * yz;
		    mat[8] = 1          - mcth * (xx+yy);
		
			if(null != jacobian)
			{
				var a:Number = sth / th;
				var b:Number = mcth / th;
				var c:Number = cth - a;
				var d:Number = sth - 2*b;
				
				// TODO: precompute reused values
				
				jacobian[0] =                         - d * (yy+zz) * x;
				jacobian[1] =        b*y   + c * zx   + d * xy      * x;
				jacobian[2] =        b*z   - c * yx   + d * xz      * x;

				jacobian[3] =        b*y   - c * zx   + d * xy      * x;
				jacobian[4] =     -2*b*x              - d * (zz+xx) * x;
				jacobian[5] =  a           + c * xx   + d * yz      * x;

				jacobian[6] =        b*z   + c * yx   + d * zx      * x;
				jacobian[7] = -a           - c * xx   + d * zy      * x;
				jacobian[8] =     -2*b*x              - d * (yy+xx) * x;

				jacobian[9] =     -2*b*y              - d * (yy+zz) * y;
				jacobian[10] =        b*x   + c * zy   + d * xy      * y;
				jacobian[11] = -a           - c * yy   + d * xz      * y;

				jacobian[12] =        b*x   - c * zy   + d * xy      * y;
				jacobian[13] =                         - d * (zz+xx) * y;
				jacobian[14] =        b*z   + c * xy   + d * yz      * y;

				jacobian[15] = a            + c * yy   + d * zx      * y;
				jacobian[16] =        b*z   - c * xy   + d * zy      * y;
				jacobian[17] =     -2*b*y              - d * (yy+xx) * y;

				jacobian[18] =     -2*b*z              - d * (yy+zz) * z;
				jacobian[19] =  a           + c * zz   + d * xy      * z;
				jacobian[20] =        b*x   - c * yz   + d * xz      * z;

				jacobian[21] =  -a          - c * zz   + d * xy      * z;
				jacobian[22] =     -2*b*z              - d * (zz+xx) * z;
				jacobian[23] =        b*y   + c * xz   + d * yz      * z;

				jacobian[24] =        b*x   + c * yz   + d * zx      * z;
				jacobian[25] =        b*y   - c * xz   + d * zy      * z;
				jacobian[26] =                         - d * (yy+xx) * z;
			}
		}
		
		/**
		*	Converts a rotation matrix to rotation vector
		*	@param mat		input 3x3 rotation Matrix
		*	@param vec		output 3x length rotation Vector
		*	@param jacobian	output 9x3 jacobian Matrix (derivative)
		**/
		public function matrix2Vector(mat:Vector.<Number>, vec:Vector.<Number>, jacobian:Vector.<Number> = null):void
		{
			const small:Number = 1e-6;
			var x:Number, y:Number, z:Number;
			var W0:Number, W1:Number, W2:Number, W3:Number;
			var W4:Number, W5:Number, W6:Number, W7:Number;
			var W8:Number;
			var th:Number = Math.acos(0.5*(FastMath.max(mat[0]+mat[4]+mat[8],-1.0) - 1.0));
			var sth:Number = Math.sin(th);
		    var cth:Number = Math.cos(th);
		    // u can use faster macro here 
		    // but if u gonna pack/unpack the same data
		    // it may loose too much precision
			//MathMacro.sincos2(th, sth, cth);
			var asth:Number = FastMath.abs(sth);
			
			if(asth < small && cth < 0)
			{
				W0 = 0.5*( mat[0] + mat[0] ) - 1.0;
			    W1 = 0.5*( mat[1] + mat[3] );
			    W2 = 0.5*( mat[2] + mat[6] );

			    W3 = 0.5*( mat[3] + mat[1] );
			    W4 = 0.5*( mat[4] + mat[4] ) - 1.0;
			    W5 = 0.5*( mat[5] + mat[7] );

			    W6 =  0.5*( mat[6] + mat[2] );
			    W7 =  0.5*( mat[7] + mat[5] );
			    W8 =  0.5*( mat[8] + mat[8] ) - 1.0;

			    /* these are only absolute values */
			    x = Math.sqrt( 0.5 * (W0-W4-W8) );
			    y = Math.sqrt( 0.5 * (W4-W8-W0) );
			    z = Math.sqrt( 0.5 * (W8-W0-W4) );
			
				/* set the biggest component to + and use the element of the
			    ** matrix W to determine the sign of the other components
			    ** then the solution is either (x,y,z) or its opposite */
				if( x >= y && x >= z ) 
				{
					y = (W1 >=0) ? y : -y;
					z = (W2 >=0) ? z : -z;
			    } 
				else if( y >= x && y >= z )
				{
					z = (W5 >=0) ? z : -z;
					x = (W1 >=0) ? x : -x;
			    }
				else
				{
					x = (W2 >=0) ? x : -x;
					y = (W5 >=0) ? y : -y;
			    }
			
				/* we are left to chose between (x,y,z) and (-x,-y,-z)
			    ** unfortunately we cannot (as the rotation is too close to pi) and
			    ** we just keep what we have. */
				var scale:Number = th / Math.sqrt( 1 - cth );
				vec[0] = scale * x;
				vec[1] = scale * y;
				vec[2] = scale * z;

				// jacobian can't be computed
			}
			else
			{
				var a:Number = (asth < small) ? 1.0 : th/sth;
				var b:Number;
				var vec0:Number = 0.5*a*(mat[5] - mat[7]);
				var vec1:Number = 0.5*a*(mat[6] - mat[2]);
				var vec2:Number = 0.5*a*(mat[1] - mat[3]);
				vec[0] = vec0;
				vec[1] = vec1;
				vec[2] = vec2;
			
				if(null != jacobian)
				{
					if( asth < small )
					{
						a = 0.5;
						b = 0;
					}
					else
					{
						a = th/(2*sth);
						b = (th*cth - sth)/(2*sth*sth)/th;
					}
					//
					jacobian[0] = jacobian[12] = jacobian[24] = b*vec0;
					jacobian[1] = jacobian[13] = jacobian[25] = b*vec1;
					jacobian[2] = jacobian[14] = jacobian[26] = b*vec2;

					jacobian[3] = 0;
					jacobian[4] = 0;
					jacobian[5] = a;

					jacobian[6] = 0;
					jacobian[7] = -a;
					jacobian[8] = 0;

					jacobian[9] = 0;
					jacobian[10] = 0;
					jacobian[11] = -a;

					//jacobian[12] = b*vec0;
					//jacobian[13] = b*vec1;
					//jacobian[14] = b*vec2;

					jacobian[15] = a;
					jacobian[16] = 0;
					jacobian[17] = 0;

					jacobian[18] = 0;
					jacobian[19] = a;
					jacobian[20] = 0;

					jacobian[21] = -a;
					jacobian[22] = 0;
					jacobian[23] = 0;

					//jacobian[24] = b*vec0;
					//jacobian[25] = b*vec1;
					//jacobian[26] = b*vec2;
				}
			}
		}
	}
}
