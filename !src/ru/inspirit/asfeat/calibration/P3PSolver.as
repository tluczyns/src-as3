package ru.inspirit.asfeat.calibration 
{
	import apparat.asm.CallProperty;
	import apparat.asm.IncLocalInt;
	import apparat.asm.SetLocal;
	import apparat.asm.__as3;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.math.FastMath;
	import apparat.math.IntMath;

	import ru.inspirit.asfeat.utils.MatrixMath;
	import ru.inspirit.linalg.Polynomial;
	import ru.inspirit.linalg.SVD;
	
	/**
	 * @author Eugene Zatepyakin
	 * 
	 * This is an implementation of the classic P3P(Perspective 3-Points) algorithm problem solution 
	 * in the Ransac paper "M. A. Fischler, R. C. Bolles. Random Sample Consensus: A Paradigm for 
	 * Model Fitting with Applications to Image Analysis and Automated Cartography. Comm. of the ACM, 
	 * Vol 24, pp 381-395, 1981.". The algorithm gives the four probable solutions of the P3P problem, 
	 * and can be used as input of the consequent RANSAC step.
	 */
	 
	public final class P3PSolver 
	{		
		protected const svd:SVD = new SVD();
		protected const poly:Polynomial = new Polynomial();
        
        protected var fx:Number;
        protected var fy:Number;
        protected var cx:Number;
        protected var cy:Number;
        
        // TODO: try with inverse
        public function updateIntrinsicParams(params:IntrinsicParameters):void
		{
			// focals
			fx = params.fx;
            fy = params.fy;
            
            // principal point
            cx = params.cx;
            cy = params.cy;
            /*
            fx = params.intrinsicInverse[0];
            fy = params.intrinsicInverse[4];
            cx = params.intrinsicInverse[2];
            cy = params.intrinsicInverse[5];
            */
		}
		
		/**
		* p3dx0, p3dy0, p3dz0 .. p3dz2 - 3 input 3D points
		* p2dx0, p2dy0 .. p2dy2 - 3 input 2D image points
		* Rs - possible solutions for Rotation 3x3 Matrix (should be preallocated)
		* ts - possible solutions for Translation 3x1 vector (should be preallocated)
		* return amount of available solutions
		**/
        
        public function estimatePose(
        							p3dx0:Number, p3dy0:Number, p3dz0:Number,
        							p3dx1:Number, p3dy1:Number, p3dz1:Number,
        							p3dx2:Number, p3dy2:Number, p3dz2:Number,
        							
        							p2dx0:Number, p2dy0:Number,
        							p2dx1:Number, p2dy1:Number,
        							p2dx2:Number, p2dy2:Number,
        							
        							Rs:Vector.<Vector.<Number>>,
        							ts:Vector.<Vector.<Number>>
        							):int
        {
        	const Epsilon:Number = 1.0e-5;
        	
        	//Length of edge between control points
			var Rab:Number,Rac:Number,Rbc:Number;

			//Cosine of angles
			var Calb:Number,Calc:Number,Cblc:Number;
			var Clab:Number,Clac:Number;
			
			var math:*;
			__asm(__as3(Math), SetLocal(math));
			
			// Compute Rab Rac Rbc in world frame
			var VAB0:Number = p3dx1 - p3dx0;
			var VAB1:Number = p3dy1 - p3dy0;
			var VAB2:Number = p3dz1 - p3dz0;
			var VAC0:Number = p3dx2 - p3dx0;
			var VAC1:Number = p3dy2 - p3dy0;
			var VAC2:Number = p3dz2 - p3dz0;
			var VBC0:Number = p3dx2 - p3dx1;
			var VBC1:Number = p3dy2 - p3dy1;
			var VBC2:Number = p3dz2 - p3dz1;
			
			__asm(__as3(math), __as3(VAB0*VAB0+VAB1*VAB1+VAB2*VAB2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rab));
			__asm(__as3(math), __as3(VAC0*VAC0+VAC1*VAC1+VAC2*VAC2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rac));
			__asm(__as3(math), __as3(VBC0*VBC0+VBC1*VBC1+VBC2*VBC2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rbc));
			
			// Get norm of each ray in camera frame
			//var CA0:Number = p2dx0 * fx + cx;
			//var CA1:Number = p2dy0 * fy + cy;
			var CA0:Number = (p2dx0 - cx) / fx;
			var CA1:Number = (p2dy0 - cy) / fy;
			var CA2:Number = 1.0;
			//
			//var CB0:Number = p2dx1 * fx + cx;
			//var CB1:Number = p2dy1 * fy + cy;
			var CB0:Number = (p2dx1 - cx) / fx;
			var CB1:Number = (p2dy1 - cy) / fy;
			var CB2:Number = 1.0;
			//
			//var CC0:Number = p2dx2 * fx + cx;
			//var CC1:Number = p2dy2 * fy + cy;
			var CC0:Number = (p2dx2 - cx) / fx;
			var CC1:Number = (p2dy2 - cy) / fy;
			var CC2:Number = 1.0;
			
			var Rab1:Number,Rac1:Number,Rbc1:Number;
			
			__asm(__as3(math), __as3(CA0*CA0+CA1*CA1+CA2*CA2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rab1));
			__asm(__as3(math), __as3(CB0*CB0+CB1*CB1+CB2*CB2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rac1));
			__asm(__as3(math), __as3(CC0*CC0+CC1*CC1+CC2*CC2), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rbc1));
			Rab1 = 1.0 / Rab1;
			CA0 *= Rab1; CA1 *= Rab1; CA2 *= Rab1;
			Rac1 = 1.0 / Rac1;
			CB0 *= Rac1; CB1 *= Rac1; CB2 *= Rac1;
			Rbc1 = 1.0 / Rbc1;
			CC0 *= Rbc1; CC1 *= Rbc1; CC2 *= Rbc1;
			
			var dx:Number = CB0 - CA0;
			var dy:Number = CB1 - CA1;
			var dz:Number = CB2 - CA2;
			__asm(__as3(math), __as3(dx*dx+dy*dy+dz*dz), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rab1));
			dx = CC0 - CA0;
			dy = CC1 - CA1;
			dz = CC2 - CA2;
			__asm(__as3(math), __as3(dx*dx+dy*dy+dz*dz), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rac1));
			dx = CC0 - CB0;
			dy = CC1 - CB1;
			dz = CC2 - CB2;
			__asm(__as3(math), __as3(dx*dx+dy*dy+dz*dz), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rbc1));
			
			// Compute Calb Calc Cblc using Law of Cosine
			Calb = (2-Rab1*Rab1)*0.5;
			Calc = (2-Rac1*Rac1)*0.5;
			Cblc = (2-Rbc1*Rbc1)*0.5;
			
			// Get coefficients of the quartic polynomial equation
			var K1:Number = Rbc*Rbc/(Rac*Rac);
			var K2:Number = Rbc*Rbc/(Rab*Rab);

			var G4:Number =(K1*K2-K1-K2)*(K1*K2-K1-K2)-4*K1*K2*Cblc*Cblc;

			var G3:Number = 4*(K1*K2-K1-K2)*K2*(1-K1)*Calb+
							4*K1*Cblc*((K1*K2+K2-K1)*Calc+2*K2*Calb*Cblc);

			var G2:Number = (2*K2*(1-K1)*Calb)*(2*K2*(1-K1)*Calb)+
							2*(K1*K2+K1-K2)*(K1*K2-K1-K2)+
							4*K1*((K1-K2)*Cblc*Cblc+
							(1-K2)*K1*Calc*Calc-2*K2*(1+K1)*Calb*Calc*Cblc);

			var G1:Number = 4*(K1*K2+K1-K2)*K2*(1-K1)*Calb+
							4*K1*((K1*K2-K1+K2)*Calc*Cblc+2*K1*K2*Calb*Calc*Calc);

			var G0:Number = (K1*K2+K1-K2)*(K1*K2+K1-K2)-4*K1*K1*K2*Calc*Calc;
			
			var roots:Vector.<Number> = new Vector.<Number>(20, true);
			var num_roots:int = poly.solveQuartic(G3/G4, G2/G4, G1/G4, G0/G4, roots); // !!!
			
			var rootxab:Vector.<Number> = new Vector.<Number>(12, true);
			var rootxabN:int = 0;
			
			if(num_roots == 0) return 0;
			
			// Temp roots
			// Format: [[x0 a0 b0] [x1 a1 b1]...]
			for(var i:int = 0; i < num_roots; ++i)
			{
				var x:Number = roots[i];
				var ifadd:Boolean = true;
				for(var j:int = 0; j < rootxabN; ++j)
				{
					if(FastMath.abs(rootxab[__cint(j*3)] - x) < Epsilon)
					{
						ifadd = false;
						break;
					}
				}
				if(ifadd)
				{
					// Compute a b
					var a:Number;
					__asm(__as3(math), __as3(x*x-2*x*Calb+1), CallProperty(__as3(Math.sqrt), 1), SetLocal(a));
					a = Rab / a;
					j = __cint(rootxabN * 3);
					rootxab[j] = x;
					rootxab[__cint(j+1)] = a;
					rootxab[__cint(j+2)] = a*x;
					rootxabN = __cint(rootxabN + 1);
				}
			}
			
			num_roots = 0;
			for(i = 0; i < rootxabN; ++i)
			{
				var delta:Number;
				var m0:Number,m1:Number,p0:Number,p1:Number,q0:Number,q1:Number;
				
				j = __cint(i*3);
				x = rootxab[j];
				a = rootxab[__cint(j+1)];
				var b:Number = rootxab[__cint(j+2)];
				
				m0=1-K1;	p0=2*(K1*Calc-x*Cblc);		q0=x*x-K1;
				m1=1;		p1=-2*x*Cblc;				q1=x*x*(1-K2)+2*x*K2*Calb-K2;

				delta = FastMath.abs(m1*q0-m0*q1);
				if (delta < Epsilon)
				{
					var y_candidate0:Number;
					var y_candidate1:Number;
					__asm(__as3(math), __as3(Calc*Calc+(Rac*Rac-a*a)/(a*a)), CallProperty(__as3(Math.sqrt), 1), SetLocal(y_candidate0));
					y_candidate1 = Calc - y_candidate0;
					y_candidate0 = Calc + y_candidate0;
					
					var c_candidate0:Number = y_candidate0*a;
					var c_candidate1:Number = y_candidate1*a;
					
					// pass 1
					var delta1:Number = FastMath.abs(b*b+c_candidate0*c_candidate0-2*b*c_candidate0*Cblc-Rbc*Rbc);
					if (delta1 < Epsilon)
					{
						j = __cint(num_roots*5);
						roots[j] = a; __asm(IncLocalInt(j));
						roots[j] = b; __asm(IncLocalInt(j));
						roots[j] = c_candidate0; __asm(IncLocalInt(j));
						roots[j] = x; __asm(IncLocalInt(j));
						roots[j] = y_candidate0;
						num_roots = __cint(num_roots + 1);
					}
					// pass 2
					delta1 = FastMath.abs(b*b+c_candidate1*c_candidate1-2*b*c_candidate1*Cblc-Rbc*Rbc);
					if (delta1 < Epsilon)
					{
						j = __cint(num_roots*5);
						roots[j] = a; __asm(IncLocalInt(j));
						roots[j] = b; __asm(IncLocalInt(j));
						roots[j] = c_candidate1; __asm(IncLocalInt(j));
						roots[j] = x; __asm(IncLocalInt(j));
						roots[j] = y_candidate1;
						num_roots = __cint(num_roots + 1);
					}
				}
				else
				{
					var y:Number = (p1*q0-p0*q1)/(m0*q1-m1*q0);
					j = __cint(num_roots*5);
					roots[j] = a; __asm(IncLocalInt(j));
					roots[j] = b; __asm(IncLocalInt(j));
					roots[j] = y*a; __asm(IncLocalInt(j));
					roots[j] = x; __asm(IncLocalInt(j));
					roots[j] = y;
					num_roots = __cint(num_roots + 1);
				}
			}
			
			var invRab:Number = 1.0 / Rab;
			var invRac:Number = 1.0 / Rac;
			var BIGA:Vector.<Number> = new Vector.<Number>(12, true);
			var R1:Vector.<Number> = new Vector.<Number>(9, true);
			var R2:Vector.<Number> = new Vector.<Number>(9, true);
			var R3:Vector.<Number> = new Vector.<Number>(9, true);
			var Rext:Vector.<Number>;
			var text:Vector.<Number>;
			
			// Finally Get Extrinsics!
			for (i = 0; i < num_roots; ++i)
			{
				j = __cint(i * 5);
				a = roots[j];
				b = roots[__cint(j+1)];
				var c:Number = roots[__cint(j+2)];
				
				// Get cosine of the angles
				Clab = (a*a+Rab*Rab-b*b)/(2*a*Rab);
				Clac = (a*a+Rac*Rac-c*c)/(2*a*Rac);
				
				// Get scale along norm vector
				var Raq:Number = a*Clab;
				var Rap:Number = a*Clac;
				
				// Get norm vector of plane P1 P2
				var WQ0:Number = p3dx0 + (Raq * VAB0 * invRab);
				var WQ1:Number = p3dy0 + (Raq * VAB1 * invRab);
				var WQ2:Number = p3dz0 + (Raq * VAB2 * invRab);
				var WP0:Number = p3dx0 + (Rap * VAC0 * invRac);
				var WP1:Number = p3dy0 + (Rap * VAC1 * invRac);
				var WP2:Number = p3dz0 + (Rap * VAC2 * invRac);
				
				var DP1:Number,DP3:Number;
				
				// Compute Plane P1 P2 P3
				var NP1_0:Number = VAB0 * invRab;
				var NP1_1:Number = VAB1 * invRab;
				var NP1_2:Number = VAB2 * invRab;
				DP1 = -(NP1_0 * WQ0 + NP1_1 * WQ1 + NP1_2 * WQ2);
				
				var P1_0:Number = NP1_0;
				var P1_1:Number = NP1_1;
				var P1_2:Number = NP1_2;
				var P1_3:Number = DP1;
				
				NP1_0 = VAC0 * invRac;
				NP1_1 = VAC1 * invRac;
				NP1_2 = VAC2 * invRac;
				DP1 = -(NP1_0 * WP0 + NP1_1 * WP1 + NP1_2 * WP2);
				
				var P2_0:Number = NP1_0;
				var P2_1:Number = NP1_1;
				var P2_2:Number = NP1_2;
				var P2_3:Number = DP1;
				
				// Current we use ACxAB get the norm of P3
				// cross prod
				var NP3_0:Number = VAC1*VAB2 - VAC2*VAB1;
				var NP3_1:Number = VAC2*VAB0 - VAC0*VAB2;
				var NP3_2:Number = VAC0*VAB1 - VAC1*VAB0;
				
				__asm(__as3(math), __as3(NP3_0*NP3_0+NP3_1*NP3_1+NP3_2*NP3_2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				NP3_0 *= dx; NP3_1 *= dx; NP3_2 *= dx;
				DP3 = -(NP3_0 * p3dx0 + NP3_1 * p3dy0 + NP3_2 * p3dz0);
				
				var P3_0:Number = NP3_0;
				var P3_1:Number = NP3_1;
				var P3_2:Number = NP3_2;
				var P3_3:Number = DP3;
				
				BIGA[0] = P1_0; BIGA[1] = P1_1; BIGA[2] = P1_2; BIGA[3] = P1_3;
				BIGA[4] = P2_0; BIGA[5] = P2_1; BIGA[6] = P2_2; BIGA[7] = P2_3;
				BIGA[8] = P3_0; BIGA[9] = P3_1; BIGA[10] = P3_2; BIGA[11] = P3_3;
				
				svd.decompose(BIGA, 3, 4);
				var ns:Vector.<Number> = svd.V; // 4x4
				dx = 1.0 / ns[15];
				var WR0:Number = ns[3] * dx;
				var WR1:Number = ns[7] * dx;
				var WR2:Number = ns[11] * dx;
				
				// Get length of LR
				var Rar:Number,Rlr:Number;
				dx = p3dx0 - WR0;
				dy = p3dy0 - WR1;
				dz = p3dz0 - WR2;
				__asm(__as3(math), __as3(dx*dx+dy*dy+dz*dz), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rar));
				__asm(__as3(math), __as3(a*a-Rar*Rar), CallProperty(__as3(Math.sqrt), 1), SetLocal(Rlr));
				
				// Get Position of L in world frame
				var WL0:Number = WR0 + NP3_0 * Rlr;
				var WL1:Number = WR1 + NP3_1 * Rlr;
				var WL2:Number = WR2 + NP3_2 * Rlr;
				
				// Get unprojection ray of image points
				var VCX0:Number = CB0 - CA0;
				var VCX1:Number = CB1 - CA1;
				var VCX2:Number = CB2 - CA2;
				
				var VCY0:Number = CC0 - CA0;
				var VCY1:Number = CC1 - CA1;
				var VCY2:Number = CC2 - CA2;
				
				var VCZ0:Number = VCX1*VCY2 - VCX2*VCY1;
				var VCZ1:Number = VCX2*VCY0 - VCX0*VCY2;
				var VCZ2:Number = VCX0*VCY1 - VCX1*VCY0;
				
				VCY0 = VCZ1*VCX2 - VCZ2*VCX1;
				VCY1 = VCZ2*VCX0 - VCZ0*VCX2;
				VCY2 = VCZ0*VCX1 - VCZ1*VCX0;
				
				__asm(__as3(math), __as3(VCX0*VCX0+VCX1*VCX1+VCX2*VCX2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				VCX0 *= dx; VCX1 *= dx; VCX2 *= dx;
				
				__asm(__as3(math), __as3(VCY0*VCY0+VCY1*VCY1+VCY2*VCY2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				VCY0 *= dx; VCY1 *= dx; VCY2 *= dx;
				
				__asm(__as3(math), __as3(VCZ0*VCZ0+VCZ1*VCZ1+VCZ2*VCZ2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				VCZ0 *= dx; VCZ1 *= dx; VCZ2 *= dx;
				
				// Get ray in the world frame
				var Vla0:Number = p3dx0 - WL0;
				var Vla1:Number = p3dy0 - WL1;
				var Vla2:Number = p3dz0 - WL2;
				
				var Vlb0:Number = p3dx1 - WL0;
				var Vlb1:Number = p3dy1 - WL1;
				var Vlb2:Number = p3dz1 - WL2;
				
				var Vlc0:Number = p3dx2 - WL0;
				var Vlc1:Number = p3dy2 - WL1;
				var Vlc2:Number = p3dz2 - WL2;
				
				__asm(__as3(math), __as3(Vla0*Vla0+Vla1*Vla1+Vla2*Vla2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				Vla0 *= dx; Vla1 *= dx; Vla2 *= dx;
				
				__asm(__as3(math), __as3(Vlb0*Vlb0+Vlb1*Vlb1+Vlb2*Vlb2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				Vlb0 *= dx; Vlb1 *= dx; Vlb2 *= dx;
				
				__asm(__as3(math), __as3(Vlc0*Vlc0+Vlc1*Vlc1+Vlc2*Vlc2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				Vlc0 *= dx; Vlc1 *= dx; Vlc2 *= dx;
				
				var WA10:Number = WL0 + Vla0;
				var WA11:Number = WL1 + Vla1;
				var WA12:Number = WL2 + Vla2;
				
				var WB10:Number = WL0 + Vlb0;
				var WB11:Number = WL1 + Vlb1;
				var WB12:Number = WL2 + Vlb2;
				
				var WC10:Number = WL0 + Vlc0;
				var WC11:Number = WL1 + Vlc1;
				var WC12:Number = WL2 + Vlc2;
				
				var vcx0:Number = WB10 - WA10;
				var vcx1:Number = WB11 - WA11;
				var vcx2:Number = WB12 - WA12;
				
				var vcy0:Number = WC10 - WA10;
				var vcy1:Number = WC11 - WA11;
				var vcy2:Number = WC12 - WA12;
				
				var vcz0:Number = vcx1*vcy2 - vcx2*vcy1;
				var vcz1:Number = vcx2*vcy0 - vcx0*vcy2;
				var vcz2:Number = vcx0*vcy1 - vcx1*vcy0;
				
				vcy0 = vcz1*vcx2 - vcz2*vcx1;
				vcy1 = vcz2*vcx0 - vcz0*vcx2;
				vcy2 = vcz0*vcx1 - vcz1*vcx0;
				
				__asm(__as3(math), __as3(vcx0*vcx0+vcx1*vcx1+vcx2*vcx2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				vcx0 *= dx; vcx1 *= dx; vcx2 *= dx;
				
				__asm(__as3(math), __as3(vcy0*vcy0+vcy1*vcy1+vcy2*vcy2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				vcy0 *= dx; vcy1 *= dx; vcy2 *= dx;
				
				__asm(__as3(math), __as3(vcz0*vcz0+vcz1*vcz1+vcz2*vcz2), CallProperty(__as3(Math.sqrt), 1), SetLocal(dx));
				dx = 1.0 / dx;
				vcz0 *= dx; vcz1 *= dx; vcz2 *= dx;
				
				R1[0] = VCX0; R1[1] = VCY0; R1[2] = VCZ0;
				R1[3] = VCX1; R1[4] = VCY1; R1[5] = VCZ1;
				R1[6] = VCX2; R1[7] = VCY2; R1[8] = VCZ2;
				
				R2[0] = vcx0; R2[1] = vcy0; R2[2] = vcz0;
				R2[3] = vcx1; R2[4] = vcy1; R2[5] = vcz1;
				R2[6] = vcx2; R2[7] = vcy2; R2[8] = vcz2;
				
				MatrixMath.invert3x3(R2, R3);
				
				MatrixMath.mult3x3Mat(R1, R3, Rs[i]);
				Rext = Rs[i];
				text = ts[i];
				
				text[0] = -Rext[0]*WL0 + -Rext[1]*WL1 + -Rext[2]*WL2;
				text[1] = -Rext[3]*WL0 + -Rext[4]*WL1 + -Rext[5]*WL2;
				text[2] = -Rext[6]*WL0 + -Rext[7]*WL1 + -Rext[8]*WL2;
			}
			
			return num_roots;
        }
	}
}
