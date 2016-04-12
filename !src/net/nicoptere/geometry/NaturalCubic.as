package net.nicoptere.geometry 
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * ported from http://www.cse.unsw.edu.au/~lambert/splines/NatCubic.java
	 * htt://en.nicoptere.net/
	 * @author nicoptere
	 */
	public class NaturalCubic
	{
		private var _steps:int = 4;
		private var _controlPoints:Vector.<Point>;
		private var _closed:Boolean;
		private var _points:Vector.<Number>;
		
		public function NaturalCubic( controlPoints:Vector.<Point> = null, closed:Boolean = true )
		{
			if( controlPoints != null ) _controlPoints = controlPoints.concat();
			_closed = closed;
		}
		
		
		private function calcNaturalCubic( n:int, x:Vector.<Number> ) :Vector.<Cubic>
		{
			var i:int;
			var gamma:Vector.<Number> = new Vector.<Number>( n + 1 );;
			var delta:Vector.<Number> = new Vector.<Number>( n + 1 );
			var D:Vector.<Number> = new Vector.<Number>( n+1 );
			
			gamma[0] = 1.0/2.0;
			for ( i = 1; i < n; i++) 
			{
				gamma[i] = 1 / (4 - gamma[i - 1]);
			}
			gamma[n] = 1 / (2 - gamma[n - 1]);
			
			delta[0] = 3 * (x[1] - x[0]) * gamma[0];
			
			
			for ( i = 1; i < n; i++) 
			{
				delta[i] = (3 * (x[i + 1] - x[i - 1]) - delta[i - 1]) * gamma[i];
			}
			delta[n] = (3 * (x[n] - x[n - 1]) - delta[n - 1]) * gamma[n];
			
			
			D[n] = delta[n];
			
			for ( i = n - 1; i >= 0; i--) 
			{
			  
				D[i] = delta[i] - gamma[i] * D[i + 1];
			  
			}

			/* now compute the coefficients of the cubics */
			var C:Vector.<Cubic> = new Vector.<Cubic>( n );
			
			for ( i = 0; i < n; i++) 
			{
			  C[i] = new Cubic(
								x[i], 
								D[i], 
								3 * (x[i + 1] - x[i]) - 2 * D[i] - D[i + 1],
								2 * (x[i] - x[i + 1]) + D[i] + D[i + 1]
								);
			}
			return C;
		}
		
		
		
		private function calcClosedNaturalCubic( n:int, x:Vector.<Number>):Vector.<Cubic>
		{
			
			var w:Vector.<Number> = new Vector.<Number>( n+1 );
			var v:Vector.<Number> = new Vector.<Number>( n+1 );
			var y:Vector.<Number> = new Vector.<Number>( n+1 );
			var D:Vector.<Number> = new Vector.<Number>( n+1 );
			var z:Number, F:Number, G:Number, H:Number;
			var k:int;
			
			w[1] = v[1] = z = 1 / 4;
			y[0] = z * 3 * (x[1] - x[n]);
			H = 4;
			F = 3 * (x[0] - x[n - 1]);
			G = 1;
			for ( k = 1; k < n; k++) 
			{
			  
				v[k + 1] = z = 1 / (4 - v[k]);
				w[k + 1] = -z * w[k];
				y[k] = z * (3 * (x[k + 1] - x[k - 1]) - y[k - 1]);
				H = H - G * w[k];
				F = F - G * y[k - 1];
				G = -v[k] * G;
			  
			}
			H = H - (G + 1) * (v[n] + w[n]);
			y[n] = F - (G + 1) * y[n - 1];
			

			D[n] = y[n] / H;
			
			/* This equation is WRONG! in my copy of Spath */
			D[n - 1] = y[n - 1] - (v[n] + w[n]) * D[n];
			for ( k = n - 2; k >= 0; k--) 
			{
				D[k] = y[k] - v[k + 1] * D[k + 1] - w[k + 1] * D[n];
			}


			/* now compute the coefficients of the cubics */
			var C:Vector.<Cubic> = new Vector.<Cubic>( n+1 );
			for ( k = 0; k < n; k++) 
			{
				C[k] = new Cubic( 
								x[k], 
								D[k], 
								3 * (x[k + 1] - x[k]) - 2 * D[k] - D[k + 1], 
								2 * (x[k] - x[k + 1]) + D[k] + D[k + 1]
								);
				
			}
			C[n] = new Cubic( 
							x[n], 
							D[n], 
							3 * (x[0] - x[n]) - 2 * D[n] - D[0], 
							2 * (x[n] - x[0]) + D[n] + D[0]
							);
			return C;
		}
		
		
		/**
		 * performs the natural cubic slipne transformation
		 * @param	controlPoints a Vector.<Point> of the control points
		 * @param	closed a boolean to tell wether the curve is opened or closed
		 * @return a Vector.<Number> of the x/y couple values of the cubic spline
		 */
		public function compute( controlPoints:Vector.<Point> = null, closed:Boolean = true ):Vector.<Number>
		{
			
			if ( controlPoints == null ) controlPoints = _controlPoints;
			
			if ( controlPoints.length >= 2) 
			{
				
				var i:int = 0;
				var j:Number = 0;
				
				var xpoints:Vector.<Number> = new Vector.<Number>();
				var ypoints:Vector.<Number> = new Vector.<Number>();
				
				for ( i = 0; i < controlPoints.length; i++ )
				{
					xpoints.push( controlPoints[ i ].x );
					ypoints.push( controlPoints[ i ].y );
				}
				
				var X:Vector.<Cubic>;
				var Y:Vector.<Cubic>;
				
				if ( closed )
				{
					
					X = calcClosedNaturalCubic(	controlPoints.length - 1, xpoints );
					Y = calcClosedNaturalCubic(	controlPoints.length - 1, ypoints );
					
				}else {
					
					X = calcNaturalCubic(	controlPoints.length - 1, xpoints );
					Y = calcNaturalCubic(	controlPoints.length - 1, ypoints );
				}
				
				
				/* very crude technique - just break each segment up into _steps lines */
				var p:Vector.<Number> = new Vector.<Number>();
				
				p.push( X[0].eval(0), Y[0].eval(0) );
				
				for ( i = 0; i < X.length; i++) 
				{
					for ( j = 1; j <= _steps; j++) 
					{
						var u:Number = j / _steps;
						p.push( Math.round(X[i].eval(u)), Math.round(Y[i].eval(u)) );
					}
				}
				return p;
			}
			return null;
		}
		
		/**
		 * draws the cubic spline onto the given graphics
		 * @param	g
		 */ 
		public function paint( g:Graphics ):void
		{
			
			if ( _controlPoints == null || _controlPoints.length < 2 ) return ;
			
			_points = compute( controlPoints, closed );
			
			var i:int;
			g.moveTo( _points[0], _points[1] );
			for ( i = 0; i  < _points.length; i+=2 )
			{
				g.lineTo( _points[i], _points[i+1] )
			}
			
		}
		
		/*
		 * ACCESSORS
		*/
		
		/**
		 * sets the control points of the curve
		 */
		public function set controlPoints( controlPoints:Vector.<Point> ):void 
		{
			_controlPoints = controlPoints.concat();
		}
		/**
		 * gets the control points of the curve
		 */
		public function get controlPoints( ):Vector.<Point> { return _controlPoints; }
		
		/**
		 * specifies if the curve is closed
		 */
		public function set closed( boolean:Boolean ):void 
		{
			_closed = boolean;
		}
		/**
		 * true if the curve is closed
		 */
		public function get closed():Boolean { return _closed; }
		
		
		/**
		 * retrieves the curve as a Vector.<Point>
		 */
		public function get curveAsPoints():Vector.<Point> 
		{ 
		
			if ( _controlPoints == null || _controlPoints.length < 2 ) return null;
			
			_points = compute( controlPoints, closed );
			
			var i:int = 0;
			var p:Vector.<Point> = new Vector.<Point>();
			for ( i = 0; i < _points.length; i+=2 )
			{
				p.push( new Point( _points[i], _points[i + 1] ) );
			}
			return p; 
		}
		
		
		/**
		 * retrieves the curve as a Vector.<Number> set of x/y couple values
		 */
		public function get curveAsValues( ):Vector.<Number>
		{
			if ( _controlPoints == null || _controlPoints.length < 2 ) return null;
			
			if ( _points.length == _controlPoints.length ) _points = compute( controlPoints, closed );
			
			return _points;
		}
		
		/**
		 * the number of steps between the control points
		 */
		public function set steps( stepsNum:int ):void 
		{
			stepsNum = ( stepsNum <= 0 ) ? 1 : stepsNum;
			_steps = stepsNum;
		}
		/**
		 * the number of steps between the control points
		 */
		public function get steps():int { return _steps; }
	}
}