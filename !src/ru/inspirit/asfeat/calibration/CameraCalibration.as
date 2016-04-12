package ru.inspirit.asfeat.calibration
{
	import apparat.asm.*;
	import apparat.math.FastMath;
	import ru.inspirit.asfeat.utils.MatrixMath;

	import ru.inspirit.linalg.SVD;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Find Calbration/Intrinsic matrix Focal X/Y parameters 
	 * using given principal point (cx/cy) and several homographies
	 * 
	 * @author Eugene Zatepyakin
	 */
	public final class CameraCalibration extends EventDispatcher
	{
		public var focal:Number;
		public var aspect:Number;

        public var fx:Number;
		public var fy:Number;
		public var cx:Number;
		public var cy:Number;

		protected var A:Vector.<Number>;
		protected var B:Vector.<Number>;
		protected var X:Vector.<Number> = new Vector.<Number>(4, true);
		
		public var count:int;
        public var isReady:Boolean;

        protected var maxToCollect:int;
		
		protected const svd:SVD = new SVD();
		
		public function init(maxHomographies:int = 10):void
		{
			A = new Vector.<Number>(maxHomographies * 2 * 4, true);
			B = new Vector.<Number>(maxHomographies * 2, true);
			count = 0;
            isReady = false;
            maxToCollect = maxHomographies;
		}
		
		/**
		 * This looks stable enough
		 * please make sure to initial principal point coordinates (cx/cy) before using
		 * 
		 * Original code is from openCV lib
		 * @param	H	found homography
		 */
        public function addHomography2(H:Vector.<Number>):void
		{
            if(homographySingular(H))
            {
                return;
            }

            var H0:Number = H[0] - H[6]*cx;
            var H1:Number = H[1] - H[7]*cx;
            var H3:Number = H[3] - H[6]*cy;
            var H4:Number = H[4] - H[7]*cy;

            var h0:Number, h1:Number, h2:Number;
            var v0:Number, v1:Number, v2:Number;
            var d10:Number, d11:Number, d12:Number;
            var d20:Number, d21:Number, d22:Number;
            var n0:Number = 0.0, n1:Number = 0.0;
            var n2:Number = 0.0, n3:Number = 0.0;

            var t0:Number = H0;
            var t1:Number = H1;

            h0 = t0; v0 = t1;
            d10 = (t0 + t1)*0.5;
            d20 = (t0 - t1)*0.5;
            n0 += t0*t0;   n1 += t1*t1;
            n2 += d10*d10; n3 += d20*d20;
            //
            t0 = H3;
            t1 = H4;
            h1 = t0; v1 = t1;
            d11 = (t0 + t1)*0.5;
            d21 = (t0 - t1)*0.5;
            n0 += t0*t0;   n1 += t1*t1;
            n2 += d11*d11; n3 += d21*d21;
            //
            t0 = H[6];
            t1 = H[7];
            h2 = t0; v2 = t1;
            d12 = (t0 + t1)*0.5;
            d22 = (t0 - t1)*0.5;
            n0 += t0*t0;   n1 += t1*t1;
            n2 += d12*d12; n3 += d22*d22;

            n0 = 1.0 / Math.sqrt(n0);
            n1 = 1.0 / Math.sqrt(n1);
            n2 = 1.0 / Math.sqrt(n2);
            n3 = 1.0 / Math.sqrt(n3);

            h0 *= n0; v0 *= n1;
            d10 *= n2; d20 *= n3;
            //
            h1 *= n0; v1 *= n1;
            d11 *= n2; d21 *= n3;
            //
            h2 *= n0; v2 *= n1;
            d12 *= n2; d22 *= n3;

            var ap:int = __cint(count * 4);
            var bp:int = __cint(count * 2);

            A[ap] = h0*v0;
            __asm(IncLocalInt(ap));
            A[ap] = h1*v1;
            __asm(IncLocalInt(ap));
            A[ap] = d10*d20;
            __asm(IncLocalInt(ap));
            A[ap] = d11*d21;

            B[bp] = -h2*v2;
            __asm(IncLocalInt(bp));
            B[bp] = -d12*d22;

            count++;

            if(count == maxToCollect)
            {
                if(calibrate2())
                {
                    isReady = true;
                    dispatchEvent(new Event(Event.COMPLETE));
                } else
                {
                    count = 0;
                }
            }
        }
		/*
		public function addHomography(H:Vector.<Number>):void
		{
            if(homographySingular(H))
            {
                return;
            }

			//H = homography;
			var v_h11:Number = H[0];
	        var v_h12:Number = H[1];
	        var v_h21:Number = H[3];
	        var v_h22:Number = H[4];
	        var v_h31:Number = H[6];
	        var v_h32:Number = H[7];
	        
	        // First row:
	        var j:int = count << 1;
	        var i:int = j << 2;
	        A[i] = v_h21*v_h21 - v_h22*v_h22;
	        __asm(IncLocalInt(i));
	        A[i] = 2 * ( v_h11*v_h31-v_h12*v_h32 );
	        __asm(IncLocalInt(i));
	        A[i] = 2 * ( v_h21*v_h31-v_h22*v_h32 );
	        __asm(IncLocalInt(i));
	        A[i] = v_h31*v_h31 - v_h32*v_h32;
	        __asm(IncLocalInt(i));
	        B[j] = v_h12*v_h12 - v_h11*v_h11;
	        
	        // Second row:
	        __asm(IncLocalInt(j));
	        A[i] = v_h22*v_h21;
	        __asm(IncLocalInt(i));
	        A[i] = v_h11*v_h32 + v_h12*v_h31;
	        __asm(IncLocalInt(i));
	        A[i] = v_h32*v_h21 + v_h22*v_h31;
	        __asm(IncLocalInt(i));
	        A[i] = v_h32*v_h31;
	        B[j] = -v_h11*v_h12;
			
			count++;

            if(count == maxToCollect)
            {
                if(calibrate())
                {
                    isReady = true;
                    dispatchEvent(new Event(Event.COMPLETE));
                } else
                {
                    count = 0;
                }
            }
		}
		*/
		public function reset():void
		{
			count = 0;
            isReady = false;
		}
		/*
		public function calibrate():Boolean
		{
			// solve least squares
			svd.solve(A, count<<1, 4, X, B);
			
			// grab omegas out of X
			var v_w22:Number = X[0];
			var v_w13:Number = X[1];
			var v_w23:Number = X[2];
			var v_w33:Number = X[3];
			
			// calc the estimated intrinsic parameters if possible:
			var f2:Number = (v_w22*v_w33-v_w22*(v_w13*v_w13)-(v_w23*v_w23))/(v_w22*v_w22);
			var a2:Number =  v_w22;
			
			if( a2 < 0 || f2 < 0 )
			{
				// complex values
				return false;
			}
			
			focal = Math.sqrt(f2);
			aspect = Math.sqrt(a2);
            fx = aspect * focal;
            fy = focal;
			cx = -v_w13;
			cy = -v_w23 / v_w22;
			
			return true;
		}
		*/
        /**
         * run when enough homographies added
         * @return true if calibration was successful otherwise false
         */
		public function calibrate2():Boolean
		{
			// solve least squares
			// while it is not about gradient descent search
			// using Gauss Newton
			// inv(At*A)*At*b
			var At:Vector.<Number> = A.concat();
			var AtA:Vector.<Number> = new Vector.<Number>(4, true);
			var AtB:Vector.<Number> = new Vector.<Number>(2, true);
			
			MatrixMath.transposeMat(A, At, count << 1, 2);
			MatrixMath.multMat(At, A, AtA, 2, count << 1, 2);
			MatrixMath.multMat(At, B, AtB, 2, count << 1, 1);
			svd.solve(AtA, 2, 2, X, AtB);
			
			// other way is to skip all above preparations and
			// just solve the system. but it will be way slower
			//svd.solve(A, count<<1, 2, X, B);

            var a2:Number = X[0];
            var f2:Number = X[1];

            if( a2 < 0 || f2 < 0 )
			{
				// complex values
				return false;
			}

            fx = Math.sqrt(FastMath.abs(1.0/a2));
            fy = focal = Math.sqrt(FastMath.abs(1.0/f2));

            aspect = fx / fy;

            return true;
        }

		/**
		 * Check whenever current homography is singular
		 * @param	H input homography 3x3 matrix
		 * @return true if homography is singular
		 */
        public function homographySingular(H:Vector.<Number>):Boolean
        {
            var guessA:Number = 0.0078125;
            var guessB:Number = 0.9;
            var guessC:Number = 0.001953125;
            var pi:Number =  Math.PI;
            var pi2:Number = pi / 2.0;

            var m11:Number, m12:Number, m13:Number;
			var m21:Number, m22:Number, m23:Number;
			var m31:Number, m32:Number, m33:Number;
			var z:Number;

            // Initialze 4 standard measure points:

            var w1x:Number = -1.0; var w1y:Number = -1.0;
            var w2x:Number = -1.0; var w2y:Number =  1.0;
            var w3x:Number =  1.0; var w3y:Number =  1.0;
            var w4x:Number =  1.0; var w4y:Number = -1.0;

            // Project points using the homography:

            m11 = H[0]; m12 = H[1]; m13 = H[2];
            m21 = H[3]; m22 = H[4]; m23 = H[5];
            m31 = H[6]; m32 = H[7]; m33 = H[8];

            z = 1.0 / (m31 * w1x + m32 * w1y + m33);
            var p1x:Number = (m11 * w1x + m12 * w1y + m13) * z;
            var p1y:Number = (m21 * w1x + m22 * w1y + m23) * z;

            z = 1.0 / (m31 * w2x + m32 * w2y + m33);
            var p2x:Number = (m11 * w2x + m12 * w2y + m13) * z;
            var p2y:Number = (m21 * w2x + m22 * w2y + m23) * z;

            z = 1.0 / (m31 * w3x + m32 * w3y + m33);
            var p3x:Number = (m11 * w3x + m12 * w3y + m13) * z;
            var p3y:Number = (m21 * w3x + m22 * w3y + m23) * z;

            z = 1.0 / (m31 * w4x + m32 * w4y + m33);
            var p4x:Number = (m11 * w4x + m12 * w4y + m13) * z;
            var p4y:Number = (m21 * w4x + m22 * w4y + m23) * z;

            // Check for correct angles:
            var a1:Number = vectorAngle(p4x-p1x, p4y-p1y, p2x-p1x, p2y-p1y);
            var a2:Number = vectorAngle(p3x-p2x, p3y-p2y, p1x-p2x, p1y-p2y);
            var a3:Number = vectorAngle(p4x-p3x, p4y-p3y, p2x-p3x, p2y-p3y);
            var a4:Number = vectorAngle(p1x-p4x, p1y-p4y, p3x-p4x, p3y-p4y);

            if( a1 < guessB || (a1 > pi2 - guessA && a1 < pi2 + guessA) || a1 > pi - guessB ||
                a2 < guessB || (a2 > pi2 - guessA && a2 < pi2 + guessA) || a2 > pi - guessB ||
                a3 < guessB || (a3 > pi2 - guessA && a3 < pi2 + guessA) || a3 > pi - guessB ||
                a4 < guessB || (a4 > pi2 - guessA && a4 < pi2 + guessA) || a4 > pi - guessB   ){
                return true;
            }

            // Check for correct distances:
            var dx:Number = p2x-p1x;
            var dy:Number = p2y-p1y;
            a1 = Math.sqrt(dx*dx+dy*dy);
            dx = p3x-p2x; dy = p3y-p2y;
            a2 = Math.sqrt(dx*dx+dy*dy);
            dx = p4x-p3x; dy = p4y-p3y;
            a3 = Math.sqrt(dx*dx+dy*dy);
            dx = p1x-p4x; dy = p1y-p4y;
            a4 = Math.sqrt(dx*dx+dy*dy);
            var d5:Number = ((a1+a2+a3+a4) * 0.25) * guessC;

            if( a1 < d5 || a2 < d5 || a3 < d5 || a4 < d5 )
            {
                return true;
            }

            return false;
        }

        protected function vectorAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number
        {
            var a:Number  = x1*x2+y1*y2;
            var b:Number  = Math.sqrt(x1*x1+y1*y1) * Math.sqrt(x2*x2+y2*y2);
            if( b != 0 )
            {
                return Math.acos(a/b);
            }

            return 0;
        }
	}
}
