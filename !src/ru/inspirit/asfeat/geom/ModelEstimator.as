package ru.inspirit.asfeat.geom 
{
	import apparat.asm.__cint;
	import apparat.asm.IncLocalInt;
	import apparat.asm.__asm;
	import apparat.math.FastMath;
	import ru.inspirit.asfeat.utils.Random;
	
	/**
	 * ...
	 * @author Eugene Zatepyakin
	 */
	public class ModelEstimator 
	{
		protected const T1:Vector.<Number> = new Vector.<Number>(9, true);
		protected const T2:Vector.<Number> = new Vector.<Number>(9, true);
		
		public function ModelEstimator() 
		{
			//
		}
		
		public function getSubset(objPoints:Vector.<Number>, imgPoints:Vector.<Number>,
									ms1:Vector.<Number>, ms2:Vector.<Number>, 
									count:int, modelPoints:int = 4, maxAttempts:int = 100):Boolean
		{
			var idx:Vector.<int> = new Vector.<int>( modelPoints, true );
			var i:int = 0, j:int, idx_i:int, iters:int = 0, k:int;
			
			var _seed:Number = Random.seed;
			
			for(; iters < maxAttempts; ++iters)
			{
				for( i = 0; i < modelPoints && iters < maxAttempts; )
				{
					_seed = (_seed * 16807) % 2147483647;
					idx[i] = idx_i = _seed % Number(count);
					for( j = 0; j < i; ++j )
						if( idx_i == idx[j] )
							break;
					//
					if( j < i ) continue;
					//
					k = idx_i << 1;
					j = i << 1;
					ms1[j] = objPoints[k];
					ms2[j] = imgPoints[k]; __asm(IncLocalInt(k), IncLocalInt(j));
					ms1[j] = objPoints[k];
					ms2[j] = imgPoints[k];
					//
					i++;
				}
				if( i == modelPoints && (!checkSubset( ms1, i ) || !checkSubset( ms2, i )) )
				{
					continue;
				}
				break;
			}
			
			Random.seed = _seed;
			
			return i == modelPoints && iters < maxAttempts;
		}
		
		public function checkSubset(m:Vector.<Number>, count:int):Boolean
		{
			var FLT_EPSILON:Number = 1.1920929e-7;
			
			var j:int, k:int, i:int, i0:int, i1:int;
			var ii:int, jj:int;
			i0 = 0;
			i1 = __cint(count - 1);
			
			for( i = i0; i <= i1; ++i )
			{
				// check that the i-th selected point does not belong
				// to a line connecting some previously selected points
				for( j = 0; j < i; ++j )
				{
					ii = i << 1;
					jj = j << 1;
					var dx1:Number = m[jj] - m[ii];
					var dy1:Number = m[__cint(jj+1)] - m[__cint(ii+1)];
					for( k = 0; k < j; ++k )
					{
						jj = k << 1;
						var dx2:Number = m[jj] - m[ii];
						var dy2:Number = m[__cint(jj+1)] - m[(__cint(ii+1))];
						if( FastMath.abs(dx2*dy1 - dy2*dx1) < FLT_EPSILON*(FastMath.abs(dx1) + FastMath.abs(dy1) + FastMath.abs(dx2) + FastMath.abs(dy2)))
						{
							break;
						}
					}
					//
					if( k < j ) break;
				}
				//
				if( j < i ) break;
			}
			
			return i >= i1;
		}
		
		// non isotropic
		public function normalizeIPointSet(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>,
											normObj:Vector.<Number>, normImg:Vector.<Number>, T1:Vector.<Number>, T2i:Vector.<Number>):void
		{
			var mean_x1:Number = 0.0;
			var mean_y1:Number = 0.0;
			var mean_x2:Number = 0.0;
			var mean_y2:Number = 0.0;
			
			var variance_x1:Number = 0.0;
			var variance_y1:Number = 0.0;
			var variance_x2:Number = 0.0;
			var variance_y2:Number = 0.0;
			
			var j:int = 0;
			for(var i:int = 0; i < count; ++i)
			{
				var x1:Number = objPoints[j];
				var x2:Number = imgPoints[j];
				__asm(IncLocalInt(j));
				mean_x1 += x1;
				mean_x2 += x2;
				variance_x1 += x1*x1;
				variance_x2 += x2*x2;
				
				x1 = objPoints[j];
				x2 = imgPoints[j];
				__asm(IncLocalInt(j));
				mean_y1 += x1;
				mean_y2 += x2;
				variance_y1 += x1*x1;
				variance_y2 += x2*x2;
			}
			var invN:Number = 1.0 / count;
			mean_x1 *= invN;
			mean_y1 *= invN;
			mean_x2 *= invN;
			mean_y2 *= invN;
			
			variance_x1 = variance_x1 * invN - (mean_x1*mean_x1);
			variance_y1 = variance_y1 * invN - (mean_y1*mean_y1);
			variance_x2 = variance_x2 * invN - (mean_x2*mean_x2);
			variance_y2 = variance_y2 * invN - (mean_y2*mean_y2);
			
			var xfactor1:Number = Math.sqrt(2.0 / variance_x1);
			var yfactor1:Number = Math.sqrt(2.0 / variance_y1);
			var xfactor2:Number = Math.sqrt(2.0 / variance_x2);
			var yfactor2:Number = Math.sqrt(2.0 / variance_y2);
			
			// transform
			var m11:Number = xfactor1, m13:Number = -xfactor1*mean_x1;
			var m22:Number = yfactor1, m23:Number = -yfactor1*mean_y1;
			
			T1[0] = m11; T1[2] = m13;
			T1[4] = m22; T1[5] = m23;
			//
			var n11:Number = xfactor2, n13:Number = -xfactor2*mean_x2;
			var n22:Number = yfactor2, n23:Number = -yfactor2*mean_y2;
			
			
			T2i[0] = 1.0/n11; T2i[2] = mean_x2;
			T2i[4] = 1.0/n22; T2i[5] = mean_y2;
			
			j = 0;
			for(i = 0; i < count; ++i)
			{
				x1 = objPoints[j];
				x2 = imgPoints[j];
				normObj[j] = m11*x1 + m13;
				normImg[j] = n11*x2 + n13;
				__asm(IncLocalInt(j));
				
				x1 = objPoints[j];
				x2 = imgPoints[j];
				normObj[j] = m22*x1 + m23;
				normImg[j] = n22*x2 + n23;
				__asm(IncLocalInt(j));
			}
		}
		
		public function normalizeTPointSet(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>,
											normObj:Vector.<Number>, normImg:Vector.<Number>, T1:Vector.<Number>, T2t:Vector.<Number>):void
		{
			var mean_x1:Number = 0.0;
			var mean_y1:Number = 0.0;
			var mean_x2:Number = 0.0;
			var mean_y2:Number = 0.0;
			
			var variance_x1:Number = 0.0;
			var variance_y1:Number = 0.0;
			var variance_x2:Number = 0.0;
			var variance_y2:Number = 0.0;
			
			var j:int = 0;
			for(var i:int = 0; i < count; ++i)
			{
				var x1:Number = objPoints[j];
				var x2:Number = imgPoints[j];
				__asm(IncLocalInt(j));
				mean_x1 += x1;
				mean_x2 += x2;
				variance_x1 += x1*x1;
				variance_x2 += x2*x2;
				
				x1 = objPoints[j];
				x2 = imgPoints[j];
				__asm(IncLocalInt(j));
				mean_y1 += x1;
				mean_y2 += x2;
				variance_y1 += x1*x1;
				variance_y2 += x2*x2;
			}
			var invN:Number = 1.0 / count;
			mean_x1 *= invN;
			mean_y1 *= invN;
			mean_x2 *= invN;
			mean_y2 *= invN;
			
			variance_x1 = variance_x1 * invN - (mean_x1*mean_x1);
			variance_y1 = variance_y1 * invN - (mean_y1*mean_y1);
			variance_x2 = variance_x2 * invN - (mean_x2*mean_x2);
			variance_y2 = variance_y2 * invN - (mean_y2*mean_y2);
			
			var xfactor1:Number = Math.sqrt(2.0 / variance_x1);
			var yfactor1:Number = Math.sqrt(2.0 / variance_y1);
			var xfactor2:Number = Math.sqrt(2.0 / variance_x2);
			var yfactor2:Number = Math.sqrt(2.0 / variance_y2);
			
			// transform
			var m11:Number = xfactor1, m13:Number = -xfactor1*mean_x1;
			var m22:Number = yfactor1, m23:Number = -yfactor1*mean_y1;
			
			T1[0] = m11; T1[2] = m13;
			T1[4] = m22; T1[5] = m23;
			//
			var n11:Number = xfactor2, n13:Number = -xfactor2*mean_x2;
			var n22:Number = yfactor2, n23:Number = -yfactor2*mean_y2;
			
			T2t[0] = n11; T2t[6] = n13;
			T2t[4] = n22; T2t[7] = n23;
			
			j = 0;
			for(i = 0; i < count; ++i)
			{
				x1 = objPoints[j];
				x2 = imgPoints[j];
				normObj[j] = m11*x1 + m13;
				normImg[j] = n11*x2 + n13;
				__asm(IncLocalInt(j));
				
				x1 = objPoints[j];
				x2 = imgPoints[j];
				normObj[j] = m22*x1 + m23;
				normImg[j] = n22*x2 + n23;
				__asm(IncLocalInt(j));
			}
		}
		
	}

}