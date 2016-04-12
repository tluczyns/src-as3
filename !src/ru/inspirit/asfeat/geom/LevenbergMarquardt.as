package ru.inspirit.asfeat.geom {
	import apparat.asm.*;
	import apparat.math.IntMath;

	import ru.inspirit.asfeat.utils.MatrixMath;
	import ru.inspirit.linalg.LU;
	import ru.inspirit.linalg.SVD;
	
	/**
	 * A simple implementation of levenberg marquardt.
	 * 
	 * @author Eugene Zatepyakin
	 */
	
	public final class LevenbergMarquardt
	{
		public static const STATE_STARTED:int = 0;
		public static const STATE_DONE:int = 1;
		public static const STATE_CALC_J:int = 2;
		public static const STATE_CHECK_ERR:int = 3;
		
		public var state:int;
		public var iters:int;
		public var updateErrorNorm:Boolean;
		public var updateJacobian:Boolean;
		
		protected var maxIter:int;
		protected var epsilon:Number;
		
		protected var numParamsSq:int;
		protected var numParams:int;
		protected var numErrors:int;
		
		protected var svd:SVD = new SVD();
		protected var lu:LU = new LU();
		
		public var prevParam:Vector.<Number>;
		public var param:Vector.<Number>;
		public var JtJ:Vector.<Number>;
		public var JtJN:Vector.<Number>;
		public var JtErr:Vector.<Number>;
		public var J:Vector.<Number>;
		public var err:Vector.<Number>;
		
		protected var Jt:Vector.<Number>;
		
		public var errNorm:Number;
		public var prevErrNorm:Number;
		public var lambdaLg10:int;
		
		public function LevenbergMarquardt(numParams:int, numErr:int = 0, maxIter:int = 30, epsilon:Number = 2.2204460492503131E-16):void
		{
			init(numParams, numErr, maxIter, epsilon);
		}
		
		public function init(numParams:int, numErr:int = 0, maxIter:int = 30, epsilon:Number = 2.2204460492503131E-16):void
		{
			prevParam = new Vector.<Number>( numParams, true); // [numParams, 1]
			param = new Vector.<Number>( numParams, true); // [numParams, 1]
			JtJ = new Vector.<Number>( numParams*numParams, true); // [numParams, numParams]
			JtJN = new Vector.<Number>( numParams*numParams, true); // [numParams, numParams]
			JtErr = new Vector.<Number>( numParams, true); // [numParams, 1]
			
			if(numErr > 0)
			{
				J = new Vector.<Number>( numErr*numParams, true); // [numErr, numParams]
				Jt = new Vector.<Number>( numParams*numErr, true); // [numParams, numErr]
				err = new Vector.<Number>( numErr, true); // [numErr, 1]
			} else {
				J = null;
				err = null;
			}
			
			this.numParams = numParams;
			numParamsSq = numParams*numParams;
			numErrors = numErr;

			prevErrNorm = 1.79769313486231e+308;
    		lambdaLg10 = -3;
    		this.maxIter = maxIter;
    		this.epsilon = epsilon*epsilon;

			state = STATE_STARTED;
			iters = 0;
		}
		
		public function reset(maxIter:int = 30, numErr:int = 0, epsilon:Number = 2.2204460492503131E-16):void
		{
			prevErrNorm = 1.79769313486231e+308;
    		lambdaLg10 = -3;
    		this.maxIter = maxIter;
    		numErrors = numErr;
    		this.epsilon = epsilon*epsilon;
    		
			state = STATE_STARTED;
			iters = 0;
		}
		
		public function updateAlt():Boolean
		{
			var change:Number;
			var i:int;
			var tmp:Vector.<Number>;
			
			updateErrorNorm = false;
			updateJacobian = false;

			if (state == STATE_DONE)
			{
				return false;
			}

			if (state == STATE_STARTED)
			{
				for(i = 0; i < numParamsSq; ++i)
				{
					JtJ[i] = 0;
				}
				for(i = 0; i < numParams; ++i)
				{
					JtErr[i] = 0;
				}
				errNorm = 0;
				updateJacobian = true;
				updateErrorNorm = true;
				state = STATE_CALC_J;
				return true;
			}
			
			if (state == STATE_CALC_J)
			{
				tmp = prevParam;
				prevParam = param;
				param = tmp;
				//prevParam = param.concat();
				step();
				prevErrNorm = errNorm;
				errNorm = 0;
				updateErrorNorm = true;
				state = STATE_CHECK_ERR;
        		return true;
			}
			
			if( errNorm > prevErrNorm )
			{
				lambdaLg10++;
				step();
				errNorm = 0;
				updateErrorNorm = true;
				state = STATE_CHECK_ERR;
				return true;
			}

			if ( ++iters >= maxIter )
			{
				state = STATE_DONE;
				return false;
			}
			
			lambdaLg10 = IntMath.max(lambdaLg10-1, -16);
			
			var normDiff:Number = 0.0;
			var norm2:Number = 0.0;
			var val:Number;
			for(i = 0; i < numParams; ++i)
			{
				val = prevParam[i];
				change = param[i] - val;
				normDiff += change * change;
				norm2 += val * val;
			}
			change = normDiff / norm2;
			//change = Math.sqrt(normDiff / norm2);
			if (change < epsilon)
			{
				state = STATE_DONE;
				return false;
			}
			
			prevErrNorm = errNorm;
			for(i = 0; i < numParamsSq; ++i)
			{
				JtJ[i] = 0;
			}
			for(i = 0; i < numParams; ++i)
			{
				JtErr[i] = 0;
			}
			
			updateJacobian = true;
			state = STATE_CALC_J;
			
			return true;
		}
		
		public function update():Boolean
		{
			var change:Number;
			var i:int;
			var errPar:int = __cint( numErrors * numParams );
			var tmp:Vector.<Number>;
			
			updateErrorNorm = false;
			updateJacobian = false;
			
			if (state == STATE_DONE)
			{
				return false;
			}

			if (state == STATE_STARTED)
			{
				for(i = 0; i < errPar; ++i)
				{
					J[i] = 0;
				}
				for (i = 0; i < numErrors; ++i)
				{
					err[i] = 0;
				}
				
				updateJacobian = true;
				state = STATE_CALC_J;
				return true;
			}
			
			if (state == STATE_CALC_J)
			{
				MatrixMath.transposeMat(J, Jt, numErrors, numParams);
				MatrixMath.multMat(Jt, J, JtJ, numParams, numErrors, numParams);
				MatrixMath.multMat(Jt, err, JtErr, numParams, numErrors, 1);
				tmp = prevParam;
				prevParam = param;
				param = tmp;
				//prevParam = param.concat();
				step();
				if (iters == 0)
				{
					prevErrNorm = 0.0;
					for (i = 0; i < numErrors; ++i)
					{
						change = err[i];
						err[i] = 0;
						prevErrNorm += change * change;
					}
				} 
				else 
				{ 
					for (i = 0; i < numErrors; ++i)
					{
						err[i] = 0;
					}
				}
				state = STATE_CHECK_ERR;
        		return true;
			}
			//
			errNorm = 0.0;
			for (i = 0; i < numErrors; ++i)
			{
				change = err[i];
				errNorm += change * change;
			}
			if( errNorm > prevErrNorm )
			{
				lambdaLg10++;
				step();
				//
				for (i = 0; i < numErrors; ++i)
				{
					err[i] = 0;
				}
				//
				state = STATE_CHECK_ERR;
				return true;
			}

			if ( ++iters >= maxIter )
			{
				state = STATE_DONE;
				return false;
			}
			
			lambdaLg10 = IntMath.max(lambdaLg10-1, -16);
			
			var normDiff:Number = 0.0;
			var norm2:Number = 0.0;
			var val:Number;
			for(i = 0; i < numParams; ++i)
			{
				val = prevParam[i];
				change = param[i] - val;
				normDiff += change * change;
				norm2 += val * val;
			}
			change = normDiff / norm2;
			//change = Math.sqrt(normDiff / norm2);
			if (change < epsilon)
			{
				state = STATE_DONE;
				return false;
			}
			
			prevErrNorm = errNorm;
			for(i = 0; i < errPar; ++i)
			{
				J[i] = 0;
			}
			
			state = STATE_CALC_J;
			updateJacobian = true;
			
			return true;
		}
		
		protected function step():void
		{
			var LOG10:Number = 2.302585092994046;
			var lambda:Number = Math.exp(lambdaLg10*LOG10) + 1.0;
			var i:int;
			
			if(null == err)
			{
				MatrixMath.completeSymm(JtJ, numParams, numParams, false);
			}

			var tmp:Vector.<Number> = JtJN;
			JtJN = JtJ;
			JtJ = tmp;
			//JtJN = JtJ.concat();
			
			for( i = 0; i < numParams; ++i )
			{
				JtJN[ __cint((numParams+1)*i)] *= lambda;
			}
			
			//svd.solve(JtJN, numParams, numParams, param, JtErr);
			lu.solve(JtJN, numParams, param, JtErr);

			for (i = 0; i < numParams; ++i)
			{
				param[i] = prevParam[i] - param[i];
			}
		}
	}
}
