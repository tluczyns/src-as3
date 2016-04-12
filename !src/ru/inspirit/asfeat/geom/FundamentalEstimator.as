package ru.inspirit.asfeat.geom
{
	import apparat.math.IntMath;
	import apparat.asm.*;
	import apparat.math.FastMath;
	import ru.inspirit.asfeat.utils.Random;

	import ru.inspirit.asfeat.utils.MatrixMath;
	import ru.inspirit.linalg.SVD;
	import ru.inspirit.linalg.Polynomial;
	
	/**
	 * Seven-point algorithm for solving for the fundamental matrix 
	 * from point correspondences. 
	 * It is the fastest (in a robust estimation context) and most robust.
	 * 
	 * @author Eugene Zatepyakin
	 */
	public final class FundamentalEstimator extends ModelEstimator
	{		
		public static var OUTLIERS_PROBABILITY:Number = 1e-2;
		
		public const svd:SVD = new SVD();
		public const poly:Polynomial = new Polynomial();
		
		public function ransac(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, 
								F:Vector.<Number>, mask:Vector.<int>, maxIter:int = 500, threshold:Number = 5):int
		{
			var P:Number = OUTLIERS_PROBABILITY;
			var logP:Number = Math.log(P);
			var iteration:int = 0;
			var min_samples:int = 7;
			var best_num_inliers:int = 0;
			var best_err_sum:Number = Number.MAX_VALUE;
			var err_sum:Number;
			var current_number_of_inliers:int;
			var best_model:Vector.<Number>;
			var curr_model:Vector.<Number>;
			var nIters:int = maxIter;
			var ms1:Vector.<Number>;
			var ms2:Vector.<Number>;
			var ii:int, ik:int;
			
			if(count < min_samples)
			{
				return 0;
			}
			
			ms1 = new Vector.<Number>( min_samples << 1, true);
			ms2 = new Vector.<Number>( min_samples << 1, true);
			
			if(count == min_samples)
			{
				nIters = 1;
			}
			
			var A:Vector.<Number> = new Vector.<Number>(63, true); //[7, 9]
			var V:Vector.<Number>;
			curr_model = new Vector.<Number>(9, true);
			var roots:Vector.<Number> = new Vector.<Number>(3, true);
			var tmp3x3:Vector.<Number> = new Vector.<Number>(9, true);
			
			var inliers:Vector.<int>;
			var current_inliers:Vector.<int> = new Vector.<int>(count, true);
			
			T2[8] = 1.0; T1[8] = 1.0;
			
			threshold = 2.0 * (threshold * threshold);
			
			for (iteration = 0; iteration < nIters; ++iteration)
			{
				var found:Boolean = getSubset( objPoints, imgPoints, ms1, ms2, count, min_samples, 200 );
				if(!found)
				{
					break;
				}
				
				// non isotropic with T2 transposed
				normalizeTPointSet(min_samples, ms1, ms2, ms1, ms2, T1, T2);
				
				// Set up the homogeneous system Af = 0 from the equations x'T*F*x = 0
				for (ii = 0; ii < 7; ++ii) 
				{
					ik = ii << 1;
					var x1:Number = ms1[ik];
					var x2:Number = ms2[ik];
					__asm(IncLocalInt(ik));
					var y1:Number = ms1[ik];
					var y2:Number = ms2[ik];
					
					ik = __cint(ii*9);
					
					A[ik] = x2 * x1;		__asm(IncLocalInt(ik));
					A[ik] = x2 * y1;		__asm(IncLocalInt(ik));
					A[ik] = x2;		 	__asm(IncLocalInt(ik));
					A[ik] = y2 * x1;		__asm(IncLocalInt(ik));
					A[ik] = y2 * y1;		__asm(IncLocalInt(ik));
					A[ik] = y2;		 	__asm(IncLocalInt(ik));
					A[ik] = x1;		 	__asm(IncLocalInt(ik));
					A[ik] = y1;		 	__asm(IncLocalInt(ik));
					A[ik] = 1.0;
				}
				
				// Find the two F matrices in the nullspace of A
				svd.decompose( A, 7, 9 );
				V = svd.V;
				
				var a:Number, b:Number, c:Number, d:Number, e:Number, f:Number, g:Number, h:Number, i:Number;
				var j:Number, k:Number, l:Number, m:Number, n:Number, o:Number, p:Number, q:Number, r:Number;
				j = V[7];  k = V[16]; l = V[25]; 
				m = V[34]; n = V[43]; o = V[52];
				p = V[61]; q = V[70]; r = V[79];
				//
				a = V[8];  b = V[17]; c = V[26]; 
				d = V[35]; e = V[44]; f = V[53];
				g = V[62]; h = V[71]; i = V[80];
				
				// The coefficients are in ascending powers of alpha
				var r0:Number = a*e*i + b*f*g + c*d*h - a*f*h - b*d*i - c*e*g;			    
			    var r1:Number = a*e*r + a*i*n + b*f*p + b*g*o + c*d*q + c*h*m + d*h*l + e*i*j + f*g*k -
			    		a*f*q - a*h*o - b*d*r - b*i*m - c*e*p - c*g*n - d*i*k - e*g*l - f*h*j;
			    var r2:Number = a*n*r + b*o*p + c*m*q + d*l*q + e*j*r + f*k*p + g*k*o + h*l*m + i*j*n -
			    		a*o*q - b*m*r - c*n*p - d*k*r - e*l*p - f*j*q - g*l*n - h*j*o - i*k*m;
			    var r3:Number = j*n*r + k*o*p + l*m*q - j*o*q - k*m*r - l*n*p;
				
				var num_roots:int;
				num_roots = poly.solveCubic2(r2/r3, r1/r3, r0/r3, roots);
				
				// Build the fundamental matrix for each solution
				// Compute costs for each fit

				for (ii = 0; ii < num_roots; ++ii)
				{
					var curr_root:Number = roots[ii];
					curr_model[0] = a + curr_root * j;
					curr_model[1] = b + curr_root * k;
					curr_model[2] = c + curr_root * l;
					curr_model[3] = d + curr_root * m;
					curr_model[4] = e + curr_root * n;
					curr_model[5] = f + curr_root * o;
					curr_model[6] = g + curr_root * p;
					curr_model[7] = h + curr_root * q;
					curr_model[8] = i + curr_root * r;
					
					// denormalize matrix
					MatrixMath.mult3x3Mat(T2, curr_model, tmp3x3);
					MatrixMath.mult3x3Mat(tmp3x3, T1, curr_model);
					
					// error calculation
					var F0:Number = curr_model[0], F1:Number = curr_model[1], F2:Number = curr_model[2];
					var F3:Number = curr_model[3], F4:Number = curr_model[4], F5:Number = curr_model[5];
					var F6:Number = curr_model[6], F7:Number = curr_model[7], F8:Number = curr_model[8];
					
					current_number_of_inliers = 0;
					err_sum = 0.0;
					for(var jj:int = 0; jj < count; ++jj)
					{
						ik = jj << 1;
				
						x1 = objPoints[ik];
						x2 = imgPoints[ik];
						__asm(IncLocalInt(ik));
						y1 = objPoints[ik];
						y2 = imgPoints[ik];
						
						var aa:Number = F0*x1 + F1*y1 + F2;
						var bb:Number = F3*x1 + F4*y1 + F5;
						var cc:Number = F6*x1 + F7*y1 + F8;
		
						//var s2:Number = 1.0 / (aa*aa + bb*bb);
						var s2:Number = aa*aa + bb*bb;
						var d2:Number = x2*aa + y2*bb + cc;
		
						aa = F0*x2 + F3*y2 + F6;
						bb = F1*x2 + F4*y2 + F7;
						cc = F2*x2 + F5*y2 + F8;
		
						//var s1:Number = 1.0 / (aa*aa + bb*bb);
						var s1:Number = aa*aa + bb*bb;
						//var d1:Number = x1*aa + y1*bb + cc;
		
						//var err:Number = FastMath.max( d1 * d1 * s1, d2 * d2 * s2 );
						var err:Number = (d2*d2) / (s2 + s1);
						var is_inlier:int = int( err <= threshold );
						err_sum += err*is_inlier + (1-is_inlier)*threshold;
						current_inliers[jj] = __cint( is_inlier * 0xFF);
						current_number_of_inliers = __cint(current_number_of_inliers + is_inlier);
					}
					
					if(err_sum < best_err_sum)
					{
						if(current_number_of_inliers > 0)
						{
							var ieps:Number = current_number_of_inliers / count;
							var newN:int = logP / Math.log(1.0 - (ieps*ieps*ieps*ieps*ieps*ieps*ieps)) + 0.5;
							nIters = IntMath.min(nIters, newN);
						}
						
						best_num_inliers = current_number_of_inliers;
				        best_model = curr_model.concat();
				        inliers = current_inliers.concat();
				        best_err_sum = err_sum;
					}
				}
			}
			//
			if (best_num_inliers > 0)
			{
				for(ii = 0; ii < count; ++ii) mask[ii] = inliers[ii];
				F[0] = best_model[0]; F[1] = best_model[1]; F[2] = best_model[2]; 
				F[3] = best_model[3]; F[4] = best_model[4]; F[5] = best_model[5];
				F[6] = best_model[6]; F[7] = best_model[7]; F[8] = best_model[8];
			} else {
				for(ii = 0; ii < count; ++ii) mask[ii] = 0xFF;
			}
			
			return best_num_inliers;
		}
	}
}
