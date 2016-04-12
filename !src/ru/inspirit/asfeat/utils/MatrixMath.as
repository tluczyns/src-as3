package ru.inspirit.asfeat.utils
{
	import apparat.asm.IncLocalInt;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.inline.Inlined;

	/**
	 * @author Eugene Zatepyakin
	 */
	public final class MatrixMath extends Inlined
	{
		public static function completeSymm( matrix:Vector.<Number>, rows:int, cols:int, LtoR:Boolean = false ):void
		{
			var i:int, j:int;
			var j0:int = 0, j1:int = rows;
			
			/*
			var isLtoR:int=int(LtoR);
			var isLtoR_1:int=__cint(1-isLtoR);
	
			j0 = __cint(isLtoR*(i+1));
			j1 = __cint(isLtoR*nrows+isLtoR_1*i);
			*/

			if (LtoR) {
				for ( i = 0; i < rows; ++i )
				{	
					j0 = __cint( i + 1 );
					for ( j = j0; j < j1; ++j )
					{
						matrix[__cint( i * cols + j )] = matrix[__cint( j * cols + i )];
					}
				}
			} else {
				for ( i = 0; i < rows; ++i )
				{
					j1 = i;
					for ( j = j0; j < j1; ++j )
					{
						matrix[__cint( i * cols + j )] = matrix[__cint( j * cols + i )];
					}
				}
			}
		}
		
		public static function setIdentity(src:Vector.<Number>, rows:int, cols:int, value:Number):void
		{
			var len:int = __cint( rows * cols );
			var k:int = len;
			while(--len >= 0) src[len] = 0.0;
			var cols_1:int = __cint(cols + 1);
			len = k;
			k = 0;
			while(k < len) 
			{
				src[k] = value;
				k = __cint(k + cols_1);
			}
		}
		
		public static function crossProductMatrix(x:Vector.<Number>, mat:Vector.<Number>):void
		{
			mat[0] = 0;		mat[1] = -x[2];		mat[2] = x[1];
			mat[3] = x[2];	mat[4] = 0;			mat[5] = -x[0];
			mat[6] = -x[1];	mat[7] = x[0];		mat[8] = 0;
		}
		
		public static function P3x4FromKRT(K:Vector.<Number>, R:Vector.<Number>, t:Vector.<Number>, P:Vector.<Number>):void
		{
			var Pjt:Vector.<Number> = new Vector.<Number>(12, true); // [3, 4]
			
			Pjt[0] = R[0]; Pjt[1] = R[1]; Pjt[2] = R[2];
			Pjt[4] = R[3]; Pjt[5] = R[4]; Pjt[6] = R[5];
			Pjt[8] = R[6]; Pjt[9] = R[7]; Pjt[10] = R[8];
			Pjt[3] = t[0]; Pjt[7] = t[1]; Pjt[11] = t[2];
			
			//MatrixMath.multMat(K, Pjt, P, 3, 3, 4);
			
			var tmp:Number;

			var a:int = 0;
			var pA:int;
			var pB:int;
			var p_B:int;
			var pC:int = 0;
			var i:int,j:int,k:int;

			for (i = 0; i < 3; )
			{
				for (p_B = 0, j = 0; j < 4; )
				{
					pB = p_B;
					pA = a;
					tmp = 0.0;
					for (k = 0; k < 3;)
					{
						tmp += K[pA] * Pjt[pB];
						__asm( IncLocalInt( pA ), IncLocalInt( k ) );
						pB = __cint( pB + 4 );
					}
					P[pC] = tmp;
					__asm( IncLocalInt( p_B ), IncLocalInt( pC ), IncLocalInt( j ) );
				}
				__asm( IncLocalInt( i ) );
				a = __cint( a + 3 );
			}
		}

		public static function multMat( srcA:Vector.<Number>, srcB:Vector.<Number>, dst:Vector.<Number>, Arows:int, Acols:int, Bcols:int ):void
		{
			var tmp:Number;

			var a:int = 0;
			var pA:int;
			var pB:int;
			var p_B:int;
			var pC:int = 0;
			var i:int,j:int,k:int;

			for (i = 0; i < Arows; )
			{
				for (p_B = 0, j = 0; j < Bcols; )
				{
					pB = p_B;
					pA = a;
					tmp = 0.0;
					for (k = 0; k < Acols;)
					{
						tmp += srcA[pA] * srcB[pB];
						__asm( IncLocalInt( pA ), IncLocalInt( k ) );
						pB = __cint( pB + Bcols );
					}
					dst[pC] = tmp;
					__asm( IncLocalInt( p_B ), IncLocalInt( pC ), IncLocalInt( j ) );
				}
				__asm( IncLocalInt( i ) );
				a = __cint( a + Acols );
			}
		}
		
		public static function multMatAdd( srcA:Vector.<Number>, srcB:Vector.<Number>, srcC:Vector.<Number>, dst:Vector.<Number>, Arows:int, Acols:int, Bcols:int ):void
		{
			var tmp:Number;

			var a:int = 0;
			var pA:int = a;
			var pB:int;
			var p_B:int;
			var pC:int = 0;
			var i:int,j:int,k:int;

			for (i = 0; i < Arows; )
			{
				for (p_B = 0, j = 0; j < Bcols; )
				{
					pB = p_B;
					pA = a;
					tmp = 0.0;
					for (k = 0; k < Acols;)
					{
						tmp += srcA[pA] * srcB[pB];
						__asm( IncLocalInt( pA ), IncLocalInt( k ) );
						pB = __cint( pB + Bcols );
					}
					dst[pC] = tmp;
					dst[pC] = tmp + srcC[pC];
					__asm( IncLocalInt( p_B ), IncLocalInt( pC ), IncLocalInt( j ) );
				}
				__asm( IncLocalInt( i ), IncLocalInt( k ) );
				a = __cint( a + Acols );
			}
		}
		
		public static function subMultMat( srcA:Vector.<Number>, srcB:Vector.<Number>, srcC:Vector.<Number>, dst:Vector.<Number>, Arows:int, Acols:int, Bcols:int ):void
		{
			var tmp:Number;

			var a:int = 0;
			var pA:int = a;
			var pB:int;
			var p_B:int;
			var pC:int = 0;
			var i:int,j:int,k:int;

			for (i = 0; i < Arows; )
			{
				for (p_B = 0, j = 0; j < Bcols; )
				{
					pB = p_B;
					pA = a;
					tmp = 0.0;
					for (k = 0; k < Acols;)
					{
						tmp += srcA[pA] * srcB[pB];
						__asm( IncLocalInt( pA ), IncLocalInt( k ) );
						pB = __cint( pB + Bcols );
					}
					dst[pC] = srcC[pC] - tmp;
					//dst[pC] = srcC[pC] - tmp;
					__asm( IncLocalInt( p_B ), IncLocalInt( pC ), IncLocalInt( j ) );
				}
				__asm( IncLocalInt( i ), IncLocalInt( k ) );
				a = __cint( a + Acols );
			}
		}

		public static function mult3x3Mat( srcA:Vector.<Number>, srcB:Vector.<Number>, dst:Vector.<Number> ):void
		{
			var m1_0:Number = srcA[0];
			var m1_1:Number = srcA[1];
			var m1_2:Number = srcA[2];
			var m1_3:Number = srcA[3];
			var m1_4:Number = srcA[4];
			var m1_5:Number = srcA[5];
			var m1_6:Number = srcA[6];
			var m1_7:Number = srcA[7];
			var m1_8:Number = srcA[8];

			var m2_0:Number = srcB[0];
			var m2_1:Number = srcB[1];
			var m2_2:Number = srcB[2];
			var m2_3:Number = srcB[3];
			var m2_4:Number = srcB[4];
			var m2_5:Number = srcB[5];
			var m2_6:Number = srcB[6];
			var m2_7:Number = srcB[7];
			var m2_8:Number = srcB[8];

			dst[0] = m1_0 * m2_0 + m1_1 * m2_3 + m1_2 * m2_6;
			dst[1] = m1_0 * m2_1 + m1_1 * m2_4 + m1_2 * m2_7;
			dst[2] = m1_0 * m2_2 + m1_1 * m2_5 + m1_2 * m2_8;
			dst[3] = m1_3 * m2_0 + m1_4 * m2_3 + m1_5 * m2_6;
			dst[4] = m1_3 * m2_1 + m1_4 * m2_4 + m1_5 * m2_7;
			dst[5] = m1_3 * m2_2 + m1_4 * m2_5 + m1_5 * m2_8;
			dst[6] = m1_6 * m2_0 + m1_7 * m2_3 + m1_8 * m2_6;
			dst[7] = m1_6 * m2_1 + m1_7 * m2_4 + m1_8 * m2_7;
			dst[8] = m1_6 * m2_2 + m1_7 * m2_5 + m1_8 * m2_8;
		}

		public static function transposeMat( src:Vector.<Number>, dst:Vector.<Number>, rows:int, cols:int ):void
		{
			var i:int, j:int;
			var pa:int, pat:int, at:int, a:int;
			for (i = 0, at = 0, a = 0; i < rows;)
			{
				pat = at;
				pa = a;
				for (j = 0; j < cols;)
				{
					// dst[pat] = src[(__cint(pa+j))];

					dst[pat] = src[pa];
					__asm( IncLocalInt( j ), IncLocalInt( pa ) );
					pat = __cint( pat + rows );
				}
				__asm( IncLocalInt( i ), IncLocalInt( at ) );
				a = __cint( a + cols );
			}
		}
		
		public static function transpose3x3Mat(src:Vector.<Number>, dst:Vector.<Number>):void
		{
			dst[0] = src[0];
			dst[1] = src[3];
			dst[2] = src[6];
			
			dst[3] = src[1];
			dst[4] = src[4];
			dst[5] = src[7];
			
			dst[6] = src[2];
			dst[7] = src[5];
			dst[8] = src[8];
		}
		
		public static function det3x3Mat(src:Vector.<Number>):Number
		{
			return    src[0] * src[4] * src[8] - src[0] * src[5] * src[7] -
			          src[3] * src[1] * src[8] + src[3] * src[2] * src[7] +
			          src[6] * src[1] * src[5] - src[6] * src[2] * src[4];
		}
		
		public static function invert3x3(src:Vector.<Number>, inv:Vector.<Number>):void
		{
			var t1:Number;
			var t11:Number;
			var t13:Number;
			var t14:Number;
			var t15:Number;
			var t17:Number;
			var t18:Number;
			var t2:Number;
			var t20:Number;
			var t21:Number;
			var t23:Number;
			var t26:Number;
			var t4:Number;
			var t5:Number;
			var t8:Number;
			var t9:Number;
			t1 = src[4];
			t2 = src[8];
			t4 = src[5];
			t5 = src[7];
			t8 = src[0];
			
			t9 = t8*t1;
			t11 = t8*t4;
			t13 = src[3];
			t14 = src[1];
			t15 = t13*t14;
			t17 = src[2];
			t18 = t13*t17;
			t20 = src[6];
			t21 = t20*t14;
			t23 = t20*t17;
			t26 = 1/(t9*t2-t11*t5-t15*t2+t18*t5+t21*t4-t23*t1);
		    inv[0] = (t1*t2-t4*t5)*t26;
		    inv[1] = -(t14*t2-t17*t5)*t26;
		    inv[2] = -(-t14*t4+t17*t1)*t26;
		    inv[3] = -(t13*t2-t4*t20)*t26;
		    inv[4] = (t8*t2-t23)*t26;
		    inv[5] = -(t11-t18)*t26;
		    inv[6] = -(-t13*t5+t1*t20)*t26;
		    inv[7] = -(t8*t5-t21)*t26;
		    inv[8] = (t9-t15)*t26;
		}
		
		public static function extractRtFrom3x4(rotTrans:Vector.<Number>,
															R:Vector.<Number>, t:Vector.<Number>):void
		{
			R[0] = rotTrans[0]; R[1] = rotTrans[1]; R[2] = rotTrans[2];
			R[3] = rotTrans[4]; R[4] = rotTrans[5]; R[5] = rotTrans[6];
			R[6] = rotTrans[8]; R[7] = rotTrans[9]; R[8] = rotTrans[10];
			
			//t[0] = -rotTrans[3]; t[1] = -rotTrans[7]; t[2] = -rotTrans[11];						t[0] = rotTrans[3]; t[1] = rotTrans[7]; t[2] = rotTrans[11];			
		}
		public static function composeRtTo3x4(rotTrans:Vector.<Number>,
															R:Vector.<Number>, t:Vector.<Number>):void
		{
			rotTrans[0] = R[0]; rotTrans[1] = R[1]; rotTrans[2] = R[2];
			rotTrans[4] = R[3]; rotTrans[5] = R[4]; rotTrans[6] = R[5];
			rotTrans[8] = R[6]; rotTrans[9] = R[7]; rotTrans[10] = R[8];
			
			//rotTrans[3] = -t[0]; rotTrans[7] = -t[1]; rotTrans[11] = -t[2];
			rotTrans[3] = t[0]; rotTrans[7] = t[1]; rotTrans[11] = t[2];			
		}
		public static function conv3x4To4x4(m3x4:Vector.<Number>, m4x4:Vector.<Number>):void
		{
			m4x4[0] = m3x4[0]; m4x4[1] = m3x4[1]; m4x4[2] = m3x4[2]; m4x4[3] = m3x4[3];
			m4x4[4] = m3x4[4]; m4x4[5] = m3x4[5]; m4x4[6] = m3x4[6]; m4x4[7] = m3x4[7];
			m4x4[8] = m3x4[8]; m4x4[9] = m3x4[9]; m4x4[10] = m3x4[10]; m4x4[11] = m3x4[11];
			
			m4x4[12] = 0; m4x4[13] = 0; m4x4[14] = 0; m4x4[15] = 1.0;
		}
		public static function conv4x4To3x4(m4x4:Vector.<Number>, m3x4:Vector.<Number>):void
		{
			m3x4[0] = m4x4[0]; m3x4[1] = m4x4[1]; m3x4[2] = m4x4[2]; m3x4[3] = m4x4[3];
			m3x4[4] = m4x4[4]; m3x4[5] = m4x4[5]; m3x4[6] = m4x4[6]; m3x4[7] = m4x4[7];
			m3x4[8] = m4x4[8]; m3x4[9] = m4x4[9]; m3x4[10] = m4x4[10]; m3x4[11] = m4x4[11];
		}
		public static function mult3x4Mat(srcA:Vector.<Number>, srcB:Vector.<Number>, dst:Vector.<Number>):void
		{
			var va:Vector.<Number> = new Vector.<Number>(16, true);
			var vb:Vector.<Number> = new Vector.<Number>(16, true);
			var vc:Vector.<Number> = new Vector.<Number>(16, true);
			
			MatrixMath.conv3x4To4x4(srcA, va);
			MatrixMath.conv3x4To4x4(srcB, vb);
			
			MatrixMath.multMat(va, vb, vc, 4, 4, 4);
			
			MatrixMath.conv4x4To3x4(vc, dst);
		}
		public static function inv3x4Mat(src:Vector.<Number>, dst:Vector.<Number>):void
		{
			var R:Vector.<Number> = new Vector.<Number>(9, true);
			var Rt:Vector.<Number> = new Vector.<Number>(9, true);
			var t:Vector.<Number> = new Vector.<Number>(3, true);
			var tt:Vector.<Number> = new Vector.<Number>(3, true);
			
			MatrixMath.extractRtFrom3x4(src, R, t);
			MatrixMath.transpose3x3Mat(R, Rt);
			// TODO: may need mult Rt by -1.0
			MatrixMath.multMat(Rt, t, tt, 3, 3, 1);
			MatrixMath.composeRtTo3x4(dst, Rt, tt);
		}
	}
}
