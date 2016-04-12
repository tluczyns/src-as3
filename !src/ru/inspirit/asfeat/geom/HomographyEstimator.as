package ru.inspirit.asfeat.geom 
{
	import apparat.asm.*;
	import apparat.math.FastMath;
	import apparat.math.IntMath;
	import ru.inspirit.asfeat.utils.Random;
	import ru.inspirit.linalg.LU;

	import ru.inspirit.asfeat.utils.MatrixMath;
	import ru.inspirit.linalg.QR;
	import ru.inspirit.linalg.SVD;

	import flash.geom.Point;
	
	/**
	 * 2D homography transformation estimation.
	 * 
	 * This function estimates the homography transformation 
	 * from a list of 2D correspondences 
	 * 
	 * @author Eugene Zatepyakin
	 */
	public final class HomographyEstimator extends ModelEstimator
	{
		public static var OUTLIERS_PROBABILITY:Number = 1e-2;
		
		public const svd:SVD = new SVD();
		public const qr:QR = new QR();
		public const lu:LU = new LU();
		public const levMarq:LevenbergMarquardt = new LevenbergMarquardt(8);
		
		public function estimateLoop(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, H:Vector.<Number>, mask:Vector.<int>, threshold:Number):int
		{
			var i:int, j:int;
			
			if(count < 4) return count;
			
			T1[8] = 1.0; T2[8] = 1.0;

			var normObj:Vector.<Number> = new Vector.<Number>(count<<1, true);
			var normImg:Vector.<Number> = new Vector.<Number>(count<<1, true);
			normalizeIPointSet(count, objPoints, imgPoints, normObj, normImg, T1, T2);
			
			const EPS:Number = 1.0e-5;
			
			var ni:int;
			var k:int;
			var AA:Vector.<Number>;
			var errSum:Number = Number.MAX_VALUE;
			var oldErr:Number;
			var number_of_inliers:int = count;
			var old_number_of_inliers:int = count;
			//var V:Vector.<Number>;
			var tmpM:Vector.<Number> = new Vector.<Number>(9, true);
			var oldH:Vector.<Number>;
			var oldMsk:Vector.<int> = new Vector.<int>(count, true);
			var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var m31:Number, m32:Number;
			var x:Number, y:Number, z:Number, dx:Number, dy:Number;
			var x2:Number, y2:Number;
			threshold *= threshold;
			//var loops:int = 0;
			
			for(i = 0; i < count; ++i) mask[i] = 0xFF;
			
			AA = new Vector.<Number>( __cint((count * 3) * 8), true );
			var B:Vector.<Number> = new Vector.<Number>(__cint(count * 3), true);
			
			do {
				
				// CONSTRUCT SYSTEM TO SOLVE
				ni = 0;
				for( i = 0; i < count; ++i)
				{
					if (mask[i] == 0xFF)
					{
						k = i << 1;
						m11 = normObj[k]; //x1
						m13 = normImg[k]; __asm(IncLocalInt(k));//x2
						m12 = normObj[k]; //y1
						m21 = normImg[k];//y2
						
						j = __cint(ni * 8);
						
						AA[j]           = m11;
						AA[__cint(j+1)] = m12;
						AA[__cint(j+2)] = 1.0;
						AA[__cint(j+6)] = -m13 * m11;
						AA[__cint(j+7)] = -m13 * m12;
						B[ni] = m13;
						
						j = __cint(j + 8);
						
						AA[__cint(j+3)] = m11;
						AA[__cint(j+4)] = m12;
						AA[__cint(j+5)] = 1.0;
						AA[__cint(j+6)] = -m21 * m11;
						AA[__cint(j+7)] = -m21 * m12;
						B[__cint(ni+1)] = m21;
						
						// This ensures better stability
						
						j = __cint(j + 8);
						
						AA[j]           = m21 * m11;
						AA[__cint(j+1)] = m21 * m12;
						AA[__cint(j+2)] = m21;
						AA[__cint(j+3)] = -m13 * m11;
						AA[__cint(j+4)] = -m13 * m12;
						AA[__cint(j+5)] = -m13;
						B[__cint(ni+2)] = 0.0;
						
						ni = __cint(ni + 3);
					}
				}
				
				oldH = H.concat();
				/*
				svd.decompose(AA, (number_of_inliers << 1), 9);
				V = svd.V;
				H[0] = V[8]; H[1] = V[17]; H[2] = V[26];
				H[3] = V[35]; H[4] = V[44]; H[5] = V[53];
				H[6] = V[62]; H[7] = V[71]; H[8] = V[80];
				*/
				qr.solve(AA, __cint(number_of_inliers*3), 8, H, B);
				//svd.solve(AA, __cint(number_of_inliers*3), 8, H, B);
				H[8] = 1.0;
				
				// denormalize matrix
				MatrixMath.mult3x3Mat(T2, H, tmpM);
				MatrixMath.mult3x3Mat(tmpM, T1, H);
				setBottomRightCoefficientToOne(H);
				
				m11 = H[0]; m12 = H[1]; m13 = H[2];
				m21 = H[3]; m22 = H[4]; m23 = H[5];
				m31 = H[6]; m32 = H[7];
				
				// COMPUTE NEW INLIERS
				old_number_of_inliers = number_of_inliers;
				number_of_inliers = 0;
				oldErr = errSum;
				errSum = 0.0;
				for(i = 0; i < count; ++i)
				{
					k = i << 1;
					x = objPoints[k];
					x2 = imgPoints[k];
					__asm(IncLocalInt(k));
					y = objPoints[k];
					y2 = imgPoints[k];
					
					z = 1.0 / (m31 * x + m32 * y + 1.0);
					dx = ((m11 * x + m12 * y + m13) * z) - x2;
					dy = ((m21 * x + m22 * y + m23) * z) - y2;
					var err:Number = dx * dx + dy * dy;
					k = int(err <= threshold);
					errSum += err*k + (1-k) * threshold;
					oldMsk[i] = mask[i];
					mask[i] = __cint(0xFF * k);
					number_of_inliers = __cint(number_of_inliers + k);
				}
				//loops++;
				
			} while (number_of_inliers > 4 && errSum < oldErr && FastMath.abs(errSum-oldErr) > EPS);
			
			if(errSum > oldErr)
			{
				H[0] = oldH[0]; H[1] = oldH[1]; H[2] = oldH[2];
				H[3] = oldH[3]; H[4] = oldH[4]; H[5] = oldH[5];
				H[6] = oldH[6]; H[7] = oldH[7]; H[8] = oldH[8];
				
				for(i = 0; i < count; ++i) mask[i] = oldMsk[i];
			}
			
			//throw new Error('refine loops: ' + [loops, number_of_inliers, old_number_of_inliers]);
			return number_of_inliers;
		}
		
		public function ransac(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, H:Vector.<Number>,
									mask:Vector.<int>, maxIters:int = 1000, threshold:Number = 10, prosacSamples:Boolean = true):int
		{
			if(count < 4) return 0;
			
			const modelPoints:int = 4;
			const P:Number = OUTLIERS_PROBABILITY;
			const logP:Number = Math.log(P);
			var iter:int;
			var nIters:int = maxIters;
			var model:Vector.<Number> = new Vector.<Number>(9, true);//[3, 3]
			var best_model:Vector.<Number>;
			var ms1:Vector.<Number>;
			var ms2:Vector.<Number>;

			if(count == modelPoints)
			{
				nIters = 1;
			}
			
			ms1 = new Vector.<Number>( modelPoints << 1, true);
			ms2 = new Vector.<Number>( modelPoints << 1, true);
			
			var tmpM:Vector.<Number> = new Vector.<Number>(9, true);
			var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var m31:Number, m32:Number;
			var x:Number, y:Number, z:Number, dx:Number, dy:Number;
			var x2:Number, y2:Number;
			var i:int, k:int;
			
			threshold *= threshold;
			
			var errSum:Number;
			var bestErrSum:Number = Number.MAX_VALUE;
			var dsum:Number;
			var number_of_inliers:int = 0;
			var current_number_of_inliers:int = 0;
			var inliers:Vector.<int>;
			var current_inliers:Vector.<int> = new Vector.<int>(count, true);
			var smpCnt:int = prosacSamples ? 10 : count;
			var found:Boolean;
			var break_support:int = int(count * 0.7) | 1;
			break_support = IntMath.max(break_support, 50);
			
			T1[8] = 1.0; T2[8] = 1.0;
			
			while (nIters > iter && number_of_inliers < break_support)
			{
				found = getSubset( objPoints, imgPoints, ms1, ms2, smpCnt, modelPoints, 100 );				
				if (!found) break;
				
				smpCnt = __cint(smpCnt + int(smpCnt < count));
				//
				normalizeIPointSet(modelPoints, ms1, ms2, ms1, ms2, T1, T2);
				
				homographyFrom4Corresp(model,
									ms1[0], ms1[1], ms2[0], ms2[1],
                                    ms1[2], ms1[3], ms2[2], ms2[3],
                                    ms1[4], ms1[5], ms2[4], ms2[5],
                                    ms1[6], ms1[7], ms2[6], ms2[7]);
				
				// denormalize matrix
				MatrixMath.mult3x3Mat(T2, model, tmpM);
				MatrixMath.mult3x3Mat(tmpM, T1, model);
				setBottomRightCoefficientToOne(model);
				
				if(goodHomography(model))
				{
				
					m11 = model[0]; m12 = model[1]; m13 = model[2];
					m21 = model[3]; m22 = model[4]; m23 = model[5];
					m31 = model[6]; m32 = model[7];
					
					// COMPUTE NEW INLIERS
					current_number_of_inliers = 0;
					errSum = 0.0;
					for(i = 0; i < count; ++i)
					{
						k = i << 1;
						x = objPoints[k];
						x2 = imgPoints[k];
						__asm(IncLocalInt(k));
						y = objPoints[k];
						y2 = imgPoints[k];
						
						z = 1.0 / (m31 * x + m32 * y + 1.0);
						dx = ((m11 * x + m12 * y + m13) * z) - x2;
						dy = ((m21 * x + m22 * y + m23) * z) - y2;
						dsum = dx*dx + dy*dy;
						k = int( dsum <= threshold );
						current_inliers[i] = __cint(k*0xFF);
						current_number_of_inliers = __cint(current_number_of_inliers + k);
						errSum += dsum*k + (1-k)*threshold;
					}
					//
					if(errSum < bestErrSum)
					{
						if(current_number_of_inliers > 0)
						{
							var eps:Number = current_number_of_inliers / count;
							var newN:int = logP / Math.log(1.0 - (eps*eps*eps*eps)) + 0.5;
							nIters = IntMath.min(nIters, newN);
						}
						
						bestErrSum = errSum;
						number_of_inliers = current_number_of_inliers;
						inliers = current_inliers.concat();
						best_model = model.concat();
					}
				}
				//
				++iter;
			}
			//
			if (number_of_inliers > 0)
			{
				for(i = 0; i < count; ++i) mask[i] = inliers[i];
				H[0] = best_model[0]; H[1] = best_model[1];
				H[2] = best_model[2]; H[3] = best_model[3];
				H[4] = best_model[4]; H[5] = best_model[5];
				H[6] = best_model[6]; H[7] = best_model[7];
				H[8] = 1.0;
			} else {
				for(i = 0; i < count; ++i) mask[i] = 0xFF;
			}
			
			return number_of_inliers;
		}
		
		public function refine2Steps(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, 
									H:Vector.<Number>, mask:Vector.<int>, threshold:Number = 10):int
		{			
			var i:int, j:int, k:int;
			var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var m31:Number, m32:Number;
			var x:Number, y:Number, z:Number, dx:Number, dy:Number;
			var x2:Number, y2:Number;
			
			threshold *= threshold;
			
			refine(count, objPoints, imgPoints, H, 15);
			
			m11 = H[0]; m12 = H[1]; m13 = H[2];
			m21 = H[3]; m22 = H[4]; m23 = H[5];
			m31 = H[6]; m32 = H[7];
			
			var inliers:int = 0;
			var newObjPoints:Vector.<Number> = new Vector.<Number>( count << 1, true);
			var newImgPoints:Vector.<Number> = new Vector.<Number>( count << 1, true);
			
			// COMPUTE NEW INLIERS
			j = 0;
			for(i = 0; i < count; ++i)
			{
				k = i << 1;
				x = objPoints[k];
				x2 = imgPoints[k];
				__asm(IncLocalInt(k));
				y = objPoints[k];
				y2 = imgPoints[k];
				
				z = 1.0 / (m31 * x + m32 * y + 1.0);
				dx = ((m11 * x + m12 * y + m13) * z) - x2;
				dy = ((m21 * x + m22 * y + m23) * z) - y2;
				
				if(dx * dx + dy * dy <= threshold)
				{
					newObjPoints[j] = x;
					newImgPoints[j] = x2;
					__asm(IncLocalInt(j));
					newObjPoints[j] = y;
					newImgPoints[j] = y2;
					__asm(IncLocalInt(j));
					
					__asm(IncLocalInt(inliers));
				}
			}
			// second refine
			refine(inliers, newObjPoints, newImgPoints, H, 10);
			
			m11 = H[0]; m12 = H[1]; m13 = H[2];
			m21 = H[3]; m22 = H[4]; m23 = H[5];
			m31 = H[6]; m32 = H[7];

            inliers = 0;
			for(i = 0; i < count; ++i)
			{
				k = i << 1;
				x = objPoints[k];
				x2 = imgPoints[k];
				__asm(IncLocalInt(k));
				y = objPoints[k];
				y2 = imgPoints[k];
				
				z = 1.0 / (m31 * x + m32 * y + 1.0);
				dx = ((m11 * x + m12 * y + m13) * z) - x2;
				dy = ((m21 * x + m22 * y + m23) * z) - y2;
				
				k = int(dx * dx + dy * dy <= threshold);
				mask[i] = __cint(0xFF * k);
                inliers = __cint(inliers + k);
			}

            return inliers;
		}
		
		public function homographyFrom4Corresp(R:Vector.<Number>,
									u1:Number, v1:Number, up1:Number, vp1:Number,
                                    u2:Number, v2:Number, up2:Number, vp2:Number,
                                    u3:Number, v3:Number, up3:Number, vp3:Number,
                                    u4:Number, v4:Number, up4:Number, vp4:Number):void
		{			
			var t1:Number = u1;
			var t2:Number = u3;
			var t4:Number = v2;
			var t5:Number = t1 * t2 * t4;
			var t6:Number = v4;
			var t7:Number = t1 * t6;
			var t8:Number = t2 * t7;
			var t9:Number = v3;
			var t10:Number = t1 * t9;
			var t11:Number = u2;
			var t14:Number = v1;
			var t15:Number = u4;
			var t16:Number = t14 * t15;
			var t18:Number = t16 * t11;
			var t20:Number = t15 * t11 * t9;
			var t21:Number = t15 * t4;
			var t24:Number = t15 * t9;
			var t25:Number = t2 * t4;
			var t26:Number = t6 * t2;
			var t27:Number = t6 * t11;
			var t28:Number = t9 * t11;
			var t30:Number = 1.0 / (t21-t24 - t25 + t26 - t27 + t28);
			var t32:Number = t1 * t15;
			var t35:Number = t14 * t11;
			var t41:Number = t4 * t1;
			var t42:Number = t6 * t41;
			var t43:Number = t14 * t2;
			var t46:Number = t16 * t9;
			var t48:Number = t14 * t9 * t11;
			var t51:Number = t4 * t6 * t2;
			var t55:Number = t6 * t14;
			var Hr0:Number = -(t8-t5 + t10 * t11 - t11 * t7 - t16 * t2 + t18 - t20 + t21 * t2) * t30;
			var Hr1:Number = (t5 - t8 - t32 * t4 + t32 * t9 + t18 - t2 * t35 + t27 * t2 - t20) * t30;
			var Hr2:Number = t1;
			var Hr3:Number = (-t9 * t7 + t42 + t43 * t4 - t16 * t4 + t46 - t48 + t27 * t9 - t51) * t30;
			var Hr4:Number = (-t42 + t41 * t9 - t55 * t2 + t46 - t48 + t55 * t11 + t51 - t21 * t9) * t30;
			var Hr5:Number = t14;
			var Hr6:Number = (-t10 + t41 + t43 - t35 + t24 - t21 - t26 + t27) * t30;
			var Hr7:Number = (-t7 + t10 + t16 - t43 + t27 - t28 - t21 + t25) * t30;
			
			t1 = up1;
			t2 = up3;
			t4 = vp2;
			t5 = t1 * t2 * t4;
			t6 = vp4;
			t7 = t1 * t6;
			t8 = t2 * t7;
			t9 = vp3;
			t10 = t1 * t9;
			t11 = up2;
			t14 = vp1;
			t15 = up4;
			t16 = t14 * t15;
			t18 = t16 * t11;
			t20 = t15 * t11 * t9;
			t21 = t15 * t4;
			t24 = t15 * t9;
			t25 = t2 * t4;
			t26 = t6 * t2;
			t27 = t6 * t11;
			t28 = t9 * t11;
			t30 = 1.0 / (t21-t24 - t25 + t26 - t27 + t28);
			t32 = t1 * t15;
			t35 = t14 * t11;
			t41 = t4 * t1;
			t42 = t6 * t41;
			t43 = t14 * t2;
			t46 = t16 * t9;
			t48 = t14 * t9 * t11;
			t51 = t4 * t6 * t2;
			t55 = t6 * t14;
			var Hl0:Number = -(t8-t5 + t10 * t11 - t11 * t7 - t16 * t2 + t18 - t20 + t21 * t2) * t30;
			var Hl1:Number = (t5 - t8 - t32 * t4 + t32 * t9 + t18 - t2 * t35 + t27 * t2 - t20) * t30;
			var Hl2:Number = t1;
			var Hl3:Number = (-t9 * t7 + t42 + t43 * t4 - t16 * t4 + t46 - t48 + t27 * t9 - t51) * t30;
			var Hl4:Number = (-t42 + t41 * t9 - t55 * t2 + t46 - t48 + t55 * t11 + t51 - t21 * t9) * t30;
			var Hl5:Number = t14;
			var Hl6:Number = (-t10 + t41 + t43 - t35 + t24 - t21 - t26 + t27) * t30;
			var Hl7:Number = (-t7 + t10 + t16 - t43 + t27 - t28 - t21 + t25) * t30;
		
			// the following code computes R = Hl * inverse Hr
			t2 = Hr4-Hr7*Hr5;
			t4 = Hr0*Hr4;
			t5 = Hr0*Hr5;
			t7 = Hr3*Hr1;
			t8 = Hr2*Hr3;
			t10 = Hr1*Hr6;
			var t12:Number = Hr2*Hr6;
			t15 = 1.0 / (t4-t5*Hr7-t7+t8*Hr7+t10*Hr5-t12*Hr4);
			t18 = -Hr3+Hr5*Hr6;
			var t23:Number = -Hr3*Hr7+Hr4*Hr6;
			t28 = -Hr1+Hr2*Hr7;
			var t31:Number = Hr0-t12;
			t35 = Hr0*Hr7-t10;
			t41 = -Hr1*Hr5+Hr2*Hr4;
			var t44:Number = t5-t8;
			var t47:Number = t4-t7;
			t48 = t2*t15;
			var t49:Number = t28*t15;
			var t50:Number = t41*t15;
			R[0] = Hl0*t48+Hl1*(t18*t15)-Hl2*(t23*t15);
			R[1] = Hl0*t49+Hl1*(t31*t15)-Hl2*(t35*t15);
			R[2] = -Hl0*t50-Hl1*(t44*t15)+Hl2*(t47*t15);
			R[3] = Hl3*t48+Hl4*(t18*t15)-Hl5*(t23*t15);
			R[4] = Hl3*t49+Hl4*(t31*t15)-Hl5*(t35*t15);
			R[5] = -Hl3*t50-Hl4*(t44*t15)+Hl5*(t47*t15);
			R[6] = Hl6*t48+Hl7*(t18*t15)-t23*t15;
			R[7] = Hl6*t49+Hl7*(t31*t15)-t35*t15;
			R[8] = -Hl6*t50-Hl7*(t44*t15)+t47*t15;
		}
		
		public function refine(count:int, objPoints:Vector.<Number>, imgPoints:Vector.<Number>, model:Vector.<Number>, maxIters:int = 10):void
		{
			var i:int, k:int;
			var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var m31:Number, m32:Number;
			var x:Number, y:Number, z:Number, dx:Number, dy:Number;
			var x2:Number, y2:Number;
			var tmp00:Number, tmp01:Number, tmp02:Number, tmp06:Number, tmp07:Number;
			var tmp16:Number, tmp17:Number, tmp000:Number, tmp001:Number, tmp002:Number;
			var tmp11:Number, tmp011:Number, tmp012:Number;
			
			if(model[8] != 1.0) setBottomRightCoefficientToOne(model);
			
			//levMarq.init( 8, 0, maxIters );
			levMarq.reset( maxIters, 0, 1.e-14);

			for(i = 0; i < 8; ++i) levMarq.param[i] = model[i];
			
			var _param:Vector.<Number>;
			var _JtJ:Vector.<Number>;
			var _JtErr:Vector.<Number>;
			
			while(true)
			{				
				if ( !levMarq.updateAlt() )
				{
					break;
				}

				var updateJacobian:Boolean = levMarq.updateJacobian;
				var updateErrorNorm:Boolean = levMarq.updateErrorNorm;

				if(updateJacobian || updateErrorNorm)
				{
					_JtJ = levMarq.JtJ;
					_JtErr = levMarq.JtErr;
					_param = levMarq.param;
							
					m11 = _param[0]; m12 = _param[1]; m13 = _param[2];
					m21 = _param[3]; m22 = _param[4]; m23 = _param[5];
					m31 = _param[6]; m32 = _param[7];
					
					// COMPUTE ERRORS
					for(i = 0; i < count; ++i)
					{
						k = i << 1;
						x = objPoints[k];
						x2 = imgPoints[k];
						__asm(IncLocalInt(k));
						y = objPoints[k];
						y2 = imgPoints[k];
						
						z = 1.0 / (m31 * x + m32 * y + 1.0);
						var px:Number = (m11 * x + m12 * y + m13) * z;
						var py:Number = (m21 * x + m22 * y + m23) * z;
						dx = px - x2;
						dy = py - y2;
	
						if ( updateJacobian )
						{
							tmp00 = x*z;
							tmp01 = y*z;
							tmp02 = z;
							tmp06 = -x*z*px;
							tmp07 = -y*z*px;
							//
							tmp16 = -x*z*py;
							tmp17 = -y*z*py;
							
							tmp000 = tmp00*tmp00;
							tmp001 = tmp00*tmp01;
							tmp002 = tmp00*tmp02;
							tmp11 = tmp01*tmp01;
							tmp011 = tmp01*tmp02;
							tmp012 = tmp02*tmp02;
							
							_JtJ[0] += tmp000;
							_JtJ[1] += tmp001;
							_JtJ[2] += tmp002;
							_JtJ[6] += tmp00*tmp06;
							_JtJ[7] += tmp00*tmp07;
							_JtJ[9] += tmp11;
							_JtJ[10] += tmp011;
							_JtJ[14] += tmp01*tmp06;
							_JtJ[15] += tmp01*tmp07;
							_JtJ[18] += tmp012;
							_JtJ[22] += tmp02*tmp06;
							_JtJ[23] += tmp02*tmp07;
							_JtJ[27] += tmp000;
							_JtJ[28] += tmp001;
							_JtJ[29] += tmp002;
							_JtJ[30] += tmp00*tmp16;
							_JtJ[31] += tmp00*tmp17;
							_JtJ[36] += tmp11;
							_JtJ[37] += tmp011;
							_JtJ[38] += tmp01*tmp16;
							_JtJ[39] += tmp01*tmp17;
							_JtJ[45] += tmp012;
							_JtJ[46] += tmp02*tmp16;
							_JtJ[47] += tmp02*tmp17;
							_JtJ[54] += tmp06*tmp06+tmp16*tmp16;
							_JtJ[55] += tmp06*tmp07+tmp16*tmp17;
							_JtJ[63] += tmp07*tmp07+tmp17*tmp17;
							
							//
							_JtErr[0] += tmp00*dx;
							_JtErr[1] += tmp01*dx;
							_JtErr[2] += z*dx;
							_JtErr[3] += tmp00*dy;
							_JtErr[4] += tmp01*dy;
							_JtErr[5] += z*dy;
							_JtErr[6] += tmp06*dx + tmp16*dy;
							_JtErr[7] += tmp07*dx + tmp17*dy;
						}
						if (updateErrorNorm)
						{
							levMarq.errNorm += dx * dx + dy * dy;
						}
					}
				}
			}
			
			for (i = 0; i < 8; ++i) model[i] = levMarq.param[i];
		}
		
		public function goodHomography(H:Vector.<Number>):Boolean
		{
			var det:Number = H[0] * H[4] - H[3] * H[1];
			if (det < 0)
			{
				return false;
			}
			var t0:Number = H[0];
			var t1:Number = H[3];
			det = t0 * t0 + t1 * t1;
			if (det > 16 || det < 0.01)
			{
				return false;
			}
			
			t0 = H[1];
			t1 = H[4];
			det = t0 * t0 + t1 * t1;
			if (det > 16 || det < 0.01)
			{
				return false;
			}
			
			t0 = H[6];
			t1 = H[7];
			det = t0 * t0 + t1 * t1;
			if (det > 4e-6)
			{
    			return false;
			}

			return true;
		}
		
		public function transformPoint(H:Vector.<Number>, pt:Point):void
		{
			var m11:Number = H[0], m12:Number = H[1], m13:Number = H[2];
			var m21:Number = H[3], m22:Number = H[4], m23:Number = H[5];
			var m31:Number = H[6], m32:Number = H[7], m33:Number = H[8];
			
			var x:Number = pt.x;
			var y:Number = pt.y;
			var z:Number = 1.0 / (m31*x + m32*y + m33);
			
			pt.x = (m11*x + m12*y + m13) * z;
			pt.y = (m21*x + m22*y + m23) * z;
		}
		
		protected function  homography_from_4pt(x1:Number, x2:Number, y1:Number, y2:Number, 
						z1:Number, z2:Number, w1:Number, w2:Number, cgret:Vector.<Number>):void
		{
			var t1:Number = x1;
			var t2:Number = z1;
			var t4:Number = y2;
			var t5:Number = t1 * t2 * t4;
			var t6:Number = w2;
			var t7:Number = t1 * t6;
			var t8:Number = t2 * t7;
			var t9:Number = z2;
			var t10:Number = t1 * t9;
			var t11:Number = y1;
			var t14:Number = x2;
			var t15:Number = w1;
			var t16:Number = t14 * t15;
			var t18:Number = t16 * t11;
			var t20:Number = t15 * t11 * t9;
			var t21:Number = t15 * t4;
			var t24:Number = t15 * t9;
			var t25:Number = t2 * t4;
			var t26:Number = t6 * t2;
			var t27:Number = t6 * t11;
			var t28:Number = t9 * t11;
			var t30:Number = 1.0 / (-t24 + t21 - t25 + t26 - t27 + t28);
			var t32:Number = t1 * t15;
			var t35:Number = t14 * t11;
			var t41:Number = t4 * t1;
			var t42:Number = t6 * t41;
			var t43:Number = t14 * t2;
			var t46:Number = t16 * t9;
			var t48:Number = t14 * t9 * t11;
			var t51:Number = t4 * t6 * t2;
			var t55:Number = t6 * t14;
			cgret[0] = -(-t5 + t8 + t10 * t11 - t11 * t7 - t16 * t2 + t18 - t20 + t21 * t2) * t30;
			cgret[1] = (t5 - t8 - t32 * t4 + t32 * t9 + t18 - t2 * t35 + t27 * t2 - t20) * t30;
			cgret[2] = t1;
			cgret[3] = (-t9 * t7 + t42 + t43 * t4 - t16 * t4 + t46 - t48 + t27 * t9 - t51) * t30;
			cgret[4] = (-t42 + t41 * t9 - t55 * t2 + t46 - t48 + t55 * t11 + t51 - t21 * t9) * t30;
			cgret[5] = t14;
			cgret[6] = (-t10 + t41 + t43 - t35 + t24 - t21 - t26 + t27) * t30;
			cgret[7] = (-t7 + t10 + t16 - t43 + t27 - t28 - t21 + t25) * t30;
		}
		
		public function setBottomRightCoefficientToOne(H:Vector.<Number>):void
		{
			var inv_H33:Number = 1.0 / H[8];
			H[0] *= inv_H33;
			H[1] *= inv_H33;
			H[2] *= inv_H33;
			H[3] *= inv_H33;
			H[4] *= inv_H33;
			H[5] *= inv_H33;
			H[6] *= inv_H33;
			H[7] *= inv_H33;
			H[8] = 1.0;
		}
		
	}
}
