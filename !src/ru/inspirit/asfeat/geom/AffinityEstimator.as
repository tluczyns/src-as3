package ru.inspirit.asfeat.geom
{
	import apparat.asm.DecLocalInt;
	import apparat.asm.IncLocalInt;
	import apparat.asm.Jump;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.math.FastMath;
	import apparat.math.IntMath;
	import ru.inspirit.asfeat.utils.Random;

	import ru.inspirit.linalg.LU;
	
	/**
	 * 2D Affine transformation estimation
	 * 
	 * This function can be used in order to estimate the affine transformation
	 * between two sets of points with known 2D correspondences.
	 * 
	 * @author Eugene Zatepyakin
	 */
	public final class AffinityEstimator
	{
		public static var OUTLIERS_PROBABILITY:Number = 1e-2;
		
		public const lu:LU = new LU();
		
		public function estimate3Points(u1:Number, v1:Number, up1:Number, vp1:Number,
										u2:Number, v2:Number, up2:Number, vp2:Number,
										u3:Number, v3:Number, up3:Number, vp3:Number,
										affinity:Vector.<Number>):void
		{
			var AA:Vector.<Number> = new Vector.<Number>(36, true);//6, 6
			var X:Vector.<Number> = new Vector.<Number>(6, true);
			var B:Vector.<Number> = new Vector.<Number>(6, true);// 6, 1
			//
			AA[4] = 1.0; AA[11] = 1.0; AA[16] = 1.0;
			AA[23] = 1.0; AA[28] = 1.0; AA[35] = 1.0;
			//
			AA[0] = u1; AA[1] = v1;
			AA[8] = u1; AA[9] = v1;
			
			AA[12] = u2; AA[13] = v2;
			AA[20] = u2; AA[21] = v2;
			
			AA[24] = u3; AA[25] = v3;
			AA[32] = u3; AA[33] = v3;
			
			B[0] = up1; B[1] = vp1; B[2] = up2; B[3] = vp2; B[4] = up3; B[5] = vp3;

			lu.solve(AA, 6, X, B);
			
			affinity[0] = X[0];
			affinity[1] = X[1];
			affinity[2] = X[4];
			affinity[3] = X[2];
			affinity[4] = X[3];
			affinity[5] = X[5];
			affinity[6] = 0.0;
			affinity[7] = 0.0;
			affinity[8] = 1.0;
		}
		
		public function ransac(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, A:Vector.<Number>,
									mask:Vector.<int>, maxIters:int = 1000, threshold:Number = 10, prosacSamples:Boolean = true):int
		{
			const P:Number = OUTLIERS_PROBABILITY;
			const logP:Number = Math.log(P);
			const AA:Vector.<Number> = new Vector.<Number>(36, true);//6, 6
			const X:Vector.<Number> = new Vector.<Number>(6, true);
			const B:Vector.<Number> = new Vector.<Number>(6, true);// 6, 1
			const current_inliers:Vector.<int> = new Vector.<int>(count, true);
			var i:int, j:int, k:int;
			var x:Number, x2:Number, y:Number, y2:Number;
			var dx:Number, dy:Number;
			var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var bm11:Number, bm12:Number, bm13:Number;
			var bm21:Number, bm22:Number, bm23:Number;
			var iteration:int = 0;
			var support:int;
			var best_support:int = -1;
			var errSum:Number;
			var bestErrSum:Number = Number.MAX_VALUE;
			var best_inliers:Vector.<int>;
			threshold *= threshold;
			
			var break_support:int = int(count * 0.7) | 1;
			break_support = 50;//IntMath.max(break_support, 50);
			var smpCnt:int = prosacSamples ? 8 : count;
			var nIters:int = maxIters;
			
			AA[4] = 1.0; AA[11] = 1.0; AA[16] = 1.0;
			AA[23] = 1.0; AA[28] = 1.0; AA[35] = 1.0;
			
			var _seed:Number = Random.seed;
			var n1:int, n2:int, n3:int;
			var a0x:Number, a0y:Number, b0x:Number, b0y:Number;
			var a1x:Number, a1y:Number, b1x:Number, b1y:Number;
			var a2x:Number, a2y:Number, b2x:Number, b2y:Number; 
			var shot:int;

			while (iteration < nIters && best_support < break_support)
			{
				__asm('SubSet:');
				
				_seed = (_seed * 16807) % 2147483647;
				n1 = _seed % Number(smpCnt);
				
				shot = 0;
				do {
					_seed = (_seed * 16807) % 2147483647;
					n2 = _seed % Number(smpCnt);
					__asm(IncLocalInt(shot));
				}
				while(n2 == n1 && shot < 100);
				if (shot >= 100) __asm(Jump('exitAff'));
				
				shot = 100;
				do {
					_seed = (_seed * 16807) % 2147483647;
					n3 = _seed % Number(smpCnt);
					__asm(DecLocalInt(shot));
				}
				while(__cint((int(n3==n1)+int(n3==n2))*shot));
				if (shot <= 0) __asm(Jump('exitAff'));
				
				
				n1 <<= 1;
				n2 <<= 1;
				n3 <<= 1;
				
				a0x = objPoints[n1];
				b0x = imgPoints[n1]; __asm(IncLocalInt(n1));
				
				a0y = objPoints[n1];
				b0y = imgPoints[n1];
				
				a1x = objPoints[n2];
				b1x = imgPoints[n2]; __asm(IncLocalInt(n2));
				
				a1y = objPoints[n2];
				b1y = imgPoints[n2];
				
				a2x = objPoints[n3];
				b2x = imgPoints[n3]; __asm(IncLocalInt(n3));
				
				a2y = objPoints[n3];					
				b2y = imgPoints[n3];
				
				// additional check for non-complanar vectors
				if( FastMath.abs((a1x - a0x)*(a2y - a0y) - (a1y - a0y)*(a2x - a0x)) < 1 ||
                    FastMath.abs((b1x - b0x)*(b2y - b0y) - (b1y - b0y)*(b2x - b0x)) < 1 )
				{
					__asm(Jump('SubSet'));
				}
				
				smpCnt = __cint(smpCnt + int(smpCnt < count));
				
				//
				// solve system
				//
				
				AA[0] = a0x; AA[1] = a0y;
				AA[8] = a0x; AA[9] = a0y;
				
				AA[12] = a1x; AA[13] = a1y;
				AA[20] = a1x; AA[21] = a1y;
				
				AA[24] = a2x; AA[25] = a2y;
				AA[32] = a2x; AA[33] = a2y;
				
				B[0] = b0x; B[1] = b0y; B[2] = b1x; B[3] = b1y; B[4] = b2x; B[5] =  b2y;
	
				lu.solve(AA, 6, X, B);
				//
				
				m11 = X[0]; m12 = X[1]; m13 = X[4];
				m21 = X[2]; m22 = X[3]; m23 = X[5];
				
				var det:Number = m11 * m22 - m21 * m12;

				if (det < 0. || det > 16)
				{
					// bad transform
					__asm(Jump('nextIter'));
				}
				
				// calc number of inliers
				support = 0;
				errSum = 0.0;
				j = 0;
				for(i = 0; i < count; ++i)
				{
					x = objPoints[j];
					x2 = imgPoints[j]; __asm(IncLocalInt(j));
					y = objPoints[j];
					y2 = imgPoints[j]; __asm(IncLocalInt(j));
					
					dx = (m11 * x + m12 * y + m13) - x2;
					dy = (m21 * x + m22 * y + m23) - y2;
					var err:Number = dx*dx + dy*dy;
					k = int( err <= threshold );
					current_inliers[i] = __cint(k*0xFF);
					support = __cint(support + k);
					errSum += err*k + (1-k)*threshold;
				}

				if(errSum < bestErrSum)
				{
					// save best values
					bestErrSum = errSum;
					best_support = support;
					bm11 = m11; bm12 = m12; bm13 = m13;
					bm21 = m21; bm22 = m22; bm23 = m23;
					best_inliers = current_inliers.concat();
					
					if (support > 0)
					{
						var eps:Number = support / count;
						var newN:int = logP / Math.log(1.0 - (eps*eps*eps)) + 0.5;
						nIters = IntMath.min(nIters, newN);
					}						
				}
				
				__asm('nextIter:');
				
				__asm(IncLocalInt(iteration));
			}
			
			__asm('exitAff:');
			
			Random.seed = _seed;
			
			//
			//
			if (best_support > 0)
			{
				for(i = 0; i < count; ++i) mask[i] = best_inliers[i];
				A[0] = bm11; A[1] = bm12; A[2] = bm13;
				A[3] = bm21; A[4] = bm22; A[5] = bm23;
				A[6] = 0.0; A[7] = 0.0; A[8] = 1.0;
			} else {
				for(i = 0; i < count; ++i) mask[i] = 0xFF;
			}
			
			return best_support;
		}
	}
}
