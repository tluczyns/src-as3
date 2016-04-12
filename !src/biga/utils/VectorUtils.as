package biga.utils 
{
	import adobe.utils.CustomActions;
	import flash.utils.ByteArray;
	/**
	 * @author Nicolas Barradeau
	 * http://en.nicoptere.net
	 */
	public class VectorUtils 
	{
		/**
		 * gets the average value of 
		 * @param	values
		 * @param	start
		 * @param	valuesPerFrame
		 * @param	windowSize
		 * @return
		 */
		static public function backwardsAverageWindow( values:Vector.<Number>, start:uint, valuesPerFrame:uint = 1024, windowSize:uint = 43 ):Vector.<Number>
		{
			if ( windowSize == 1 ) return values;
			
			var tmp:Vector.<Number> = new Vector.<Number>( valuesPerFrame );
			
			var startPos:uint = Math.max( 0, ( start  * valuesPerFrame ) - ( valuesPerFrame * windowSize ) );
			var endPos:uint = Math.min( values.length-valuesPerFrame, start * valuesPerFrame );
			
			var sum:Number;
			var min:int, max:int;
			for (var i:int = startPos; i < endPos; i+= valuesPerFrame ) 
			{
				
				for (var j:int = 0; j < valuesPerFrame; j++) 
				{
					tmp[ j ] += values[ i + j ] / windowSize;
				}
				
			}
			
			return tmp;
		}
		
		static public function byteArrayToVector( ba:ByteArray, minMax:Array = null ):Vector.<Number>
		{
			
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			ba.position = 0;
			
			while ( ba.bytesAvailable > 0 )
			{
				if ( minMax == null ) tmp.push( ba.readFloat() );
				else tmp.push( map( ba.readFloat(), -1, 1, minMax[ 0 ], minMax[ 1 ] ) );
			}
			ba.position = 0;
			
			return tmp;
		}
		
		static public function averageWindow( values:Vector.<Number>, windowSize:uint ):Vector.<Number>
		{
			if ( windowSize == 1 ) return values;
			var tmp:Vector.<Number> = values.concat();
			
			if ( windowSize % 2 == 0 ) windowSize++;
			
			var halfWindow:uint = ( windowSize - 1 ) / 2;
			var sum:Number;
			var min:int, max:int;
			
			for (var i:int = 0; i < values.length; i++) 
			{
				tmp[ i ] = 0;
				min = Math.max( 0, ( i - halfWindow ) );
				max = Math.min( values.length - 1, ( i + halfWindow ) );
				for (var j:int = min; j <= max; j++) 
				{
					tmp[ i ] += values[ j ] / windowSize;
				}
			}
			
			return tmp;
		}
		
		static public function createBins( values:Vector.<Number>, binSize:uint ):Vector.<Vector.<Number>>
		{
			var bin:Vector.<Number>;
			var tmp:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			
			for (var i:int = 0; i < ( values.length / binSize ); i++) 
			{
				
				bin = new Vector.<Number>();
				for (var j:int = i * binSize; j < ( i + 1 ) * binSize; j++) 
				{
					if ( j < values.length )
					{
						bin.push( values[ j ] );
					}
					else
					{
						if( bin.length > 0 ) tmp.push( bin );
						return tmp;
					}
				}
				tmp.push( bin );
				
			}
			
			return tmp;
		}
		
		
		static public function toFixed( values:Vector.<Number>, fixedValue:int = 2 ):Vector.<Number>
		{
			for (var i:int = 0; i < values.length; i++) 
			{
				values[ i ] = Number( values[ i ].toFixed( fixedValue ) )
			}
			return values;
		}
		
		static public function sum( values:Vector.<Number> ):Number
		{
			
			var sum:Number = 0;
			for each (var n:Number in values) 
			{
				sum += n;
			}
			return sum;
			
		}
		
		static public function rootMeanSquare( values:Vector.<Number> ):Number
		{
			
			var sum:Number = 0;
			for each (var n:Number in values) 
			{
				sum += n * n;
			}
			return Math.sqrt(sum / values.length);
			
		}
		
		static public function median( values:Vector.<Number> ):Number
		{
			if ( values.length == 0 ) return NaN;
			values.sort( medianSort );
			var mid:int = values.length * .5;
			if ( values.length % 2 == 1 )
			{
				return values[ mid ];
			}
			else
			{
				return ( values[ mid - 1 ] + values[ mid ] ) * .5;
			}
		}
		
		static private function medianSort( a:Number, b:Number ):Number
		{
			return ( a - b );
		}
		
		
		static public function averageSum( values:Vector.<Number>, length:Number = 1 ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			var binSum:Number;
			
			if ( length == 1 )
			{
				binSum = sum( values );
				tmp.push( binSum / values.length );
			}
			else
			{
				var bins:Vector.<Vector.<Number>> = createBins( values, length );
				for each( var bin:Vector.<Number> in bins )
				{
					binSum = sum( bin );
					tmp.push( binSum / bin.length );
				}
			}
			return tmp;
		}
		
		static public function averageRms( values:Vector.<Number>, length:Number = 1 ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			var binSum:Number;
			
			if ( length == 1 )
			{
				binSum = rootMeanSquare( values );
				tmp.push( binSum / values.length );
			}
			else
			{
				var bins:Vector.<Vector.<Number>> = createBins( values, length );
				for each( var bin:Vector.<Number> in bins )
				{
					binSum = rootMeanSquare( bin );
					tmp.push( binSum / bin.length );
				}
			}
			return tmp;
		}
		
		static public function normallizeMinMax( values:Vector.<Number> ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			var min:Number = Number.POSITIVE_INFINITY;
			var max:Number = Number.NEGATIVE_INFINITY;
			for (var i:int = 0; i < values.length; i++) 
			{
				if( values[ i ] < min ) min = values[ i ];
				if( values[ i ] > max ) max = values[ i ];
			}
			
			for ( i = 0; i < values.length; i++) 
			{
				tmp.push( map( values[ i ], min, max, 0, 1 ) );
			}
			return tmp;
		}
		
		static public function normallizeAbsolute( values:Vector.<Number> ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			var sum:Number = 0;
			for (var i:int = 0; i < values.length; i++) 
			{
				sum += values[ i ];
			}
			
			var div:Number = 1 / sum;
			for ( i = 0; i < values.length; i++) 
			{
				tmp.push( values[ i ] * div );
			}
			return tmp;
		}
		
		static public function localMaximum( values:Vector.<Number> ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			var max:Number = max( values );
			
			var div:Number = 1 / max;
			for ( var i:int = 0; i < values.length; i++) 
			{
				tmp.push( values[ i ] * div );
			}
			
			return tmp;
		}
		
		static public function max( values:Vector.<Number> ):Number
		{
			
			var max:Number = Number.NEGATIVE_INFINITY;
			for (var i:int = 0; i < values.length; i++) 
			{
				if( values[ i ] > max ) max = values[ i ];
			}
			return max;
			
		}
		static public function min( values:Vector.<Number> ):Number
		{
			
			var min:Number = Number.POSITIVE_INFINITY;
			for (var i:int = 0; i < values.length; i++) 
			{
				if( values[ i ] < min ) min = values[ i ];
			}
			return min;
			
		}
        
		
		/**
		 * shrinks a Vector.<Number> down to a given length
		 * @param	values original vector of values
		 * @param	length the desired length
		 * @return a vector of values matching the desired length
		 */
		static public function compress( values:Vector.<Number>, length:uint ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			var i:Number;
			if ( values.length == 1 )
			{
				i = length;
				while ( i-- ) tmp.push( values[0] );
				return tmp;
			}
			
			var inputLength:uint = values.length - 2;
			var outputLength:uint = length - 2;
			tmp.push( values[ 0 ] );
			i = 0;
			var j:int = 0;
			while (j < inputLength) 
			{
				var diff:uint = ( i + 1 ) * inputLength - ( j + 1 ) * outputLength;
				if (diff < inputLength / 2 ) 
				{
					i++;
					tmp.push( values[ j++ ] );
				}
				else j++;
			}
			tmp.push( values[ inputLength + 1 ] );
			return tmp;
		}
		
		/**
		 * compresses 2 vectors of numbers
		 * @param	u first set of vectors to compress
		 * @param	v second set of vectors to compress
		 * @param	length0 the desired length for vector u
		 * @param	length1 the desired length for vector v
		 * @return a Vector.<Number> of doublets (x,y) of the given length interpolating the original values
		 */
		static public function compress2D( u:Vector.<Number>, v:Vector.<Number>, length0:uint, length1:uint ):Vector.<Number>
		{
			
			var _u:Vector.<Number> = compress( u, length0 );
			var _v:Vector.<Number> = compress( v, length1 );
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			for (var i:int = 0; i < length0; i++) 
			{
				for (var j:int = 0; j < length1; j++) 
				{
					
					tmp.push( _u[ i ], _v[ j ] );
					
				}
			}
			
			return tmp;
			
		}
		
		/**
		 * compresses 3 vectors of numbers
		 * @param	u first set of vectors to compress
		 * @param	v second set of vectors to compress
		 * @param	w second set of vectors to compress
		 * @param	length0 the desired length for vector u
		 * @param	length1 the desired length for vector v
		 * @param	length2 the desired length for vector w
		 * @return a Vector.<Number> of triplets (x,y,z) of the given length interpolating the original values
		 */
		static public function compress3D( u:Vector.<Number>, v:Vector.<Number>, w:Vector.<Number>, length0:uint, length1:uint, length2:uint ):Vector.<Number>
		{
			
			var _u:Vector.<Number> = compress( u, length0 );
			var _v:Vector.<Number> = compress( v, length1 );
			var _w:Vector.<Number> = compress( w, length2 );
			
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			for (var i:int = 0; i < length0; i++) 
			{
				for (var j:int = 0; j < length1; j++) 
				{
					for (var k:int = 0; k < length2; k++) 
					{
						
						tmp.push( _u[ i ], _v[ j ], _w[ k ] );
						
					}
				}
			}
			
			return tmp;
			
		}
		
		/**
		 * expands the content of a vector.<Number> to match a given length
		 * @param	values original vector of values
		 * @param	length the desired length of the new Vector
		 * @return a Vector.<Number> of the given length interpolating the original values
		 */
		static public function expandColors( values:Vector.<uint>, length:uint, loop:Boolean = false ):Vector.<uint>
		{
			var tmp:Vector.<uint> = new Vector.<uint>();
			var i:Number;
			if ( values.length == 1 )
			{
				i = length;
				while ( i-- ) tmp.push( values[0] );
				return tmp;
			}
			if ( loop ) values.push( values[0] );
			
			var step:Number = 1 / ( ( values.length-1 ) / length );
			for ( i = 0; i < length - 1; i+= step ) 
			{
				var val0:Number = values[ int( i / step ) ];
				
				//var max:int = ;
				//if ( max > values.length - 1 ) max = values.length - 1;
				var val1:Number = values[ ( int( i / step ) + 1 ) ];
				
				var delta:Number = ( i + step > length ) ? ( length - i ) : step;
				
				for (var j:Number = 0; j < delta; j++) 
				{ 
					
					
					tmp.push( 	0xFF<<24 |
								lrp( j / delta, val0 >> 16	& 0xFF, val1 >> 16 & 0xFF	) << 16 |
								lrp( j / delta, val0 >> 8 	& 0xFF, val1 >> 8  & 0xFF	) << 8  |
								lrp( j / delta, val0 		& 0xFF, val1  	 & 0xFF	)
								);
					
					//_trace( j / delta, int( i / step ), int( i / step ) + 1);
					//_trace( '->', val0>>8, val1>>8, ':', interpolateColorsCompact( j / delta, int( val0 >> 24 ), int( val1>>24 ) ) );
					//tmp.push( 0xFF<<24 | interpolateColorsCompact( j / delta, int( val0 ), int( val1 ) ) );
				}
			}
			while ( tmp.length < length ) tmp.push( values[ values.length - 1 ] );
			
			if ( loop ) values.pop();
			return tmp;
			
		}
		/**
		 * expands the content of a vector.<Number> to match a given length
		 * @param	values original vector of values
		 * @param	length the desired length of the new Vector
		 * @return a Vector.<Number> of the given length interpolating the original values
		 */
		static public function expand( values:Vector.<Number>, length:uint, lerp:Boolean = true ):Vector.<Number>
		{
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			var i:Number;
			if ( values.length == 1 )
			{
				i = length;
				while ( i-- ) tmp.push( values[0] );
				return tmp;
			}
			
			var step:Number = 1 / length;
			tmp.push( values[ 0 ] );
			var id0:int, id1:int;
			var _t:Number, delta:Number;
			
			for ( var t:Number = step; t < ( 1 - step ); t += step ) 
			{
				if ( lerp )
				{
					
					id0 = int( ( values.length - 1 ) * t );
					id1 = id0 + 1;
					delta = 1 / ( values.length - 1 );
					_t = ( t - ( id0 * delta ) ) / delta;
					tmp.push( lrp( _t, values[ id0 ], values[ id1 ]) );
					
				}
				else
				{
					
					id0 = int( values.length * t );
					tmp.push( values[ id0 ] );
					
				}
				
			}
			tmp.push( values[ values.length - 1 ] );
			
			return tmp;
			
		}
		
		/**
		 * expands 2 vectors of numbers and combines them together
		 * @param	u first set of vectors to expand
		 * @param	v second set of vectors to expand
		 * @param	length0 the desired length for vector u
		 * @param	length1 the desired length for vector v
		 * @return a Vector.<Number> of doublets (x,y) of the given length interpolating the original values
		 */
		static public function expand2D( u:Vector.<Number>, v:Vector.<Number>, length0:uint, length1:uint ):Vector.<Number>
		{
			
			var _u:Vector.<Number> = expand( u, length0 );
			var _v:Vector.<Number> = expand( v, length1 );
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			for (var i:int = 0; i < length0; i++) 
			{
				for (var j:int = 0; j < length1; j++) 
				{
					tmp.push( _u[ i ], _v[ j ] );
				}
			}
			return tmp;
			
		}
		
		/**
		 * expands 3 vectors of numbers
		 * @param	u first set of vectors to expand
		 * @param	v second set of vectors to expand
		 * @param	w second set of vectors to expand
		 * @param	length0 the desired length for vector u
		 * @param	length1 the desired length for vector v
		 * @param	length2 the desired length for vector w
		 * @return a Vector.<Number> of triplets (x,y,z) of the given length interpolating the original values
		 */
		static public function expand3D( u:Vector.<Number>, v:Vector.<Number>, w:Vector.<Number>, length0:uint, length1:uint, length2:uint ):Vector.<Number>
		{
			
			var _u:Vector.<Number> = expand( u, length0 );
			var _v:Vector.<Number> = expand( v, length1 );
			var _w:Vector.<Number> = expand( w, length2 );
			
			var tmp:Vector.<Number> = new Vector.<Number>();
			
			for (var i:int = 0; i < length0; i++) 
			{
				for (var j:int = 0; j < length1; j++) 
				{
					for (var k:int = 0; k < length2; k++) 
					{
						tmp.push( _u[ i ], _v[ j ], _w[ k ] );
					}
				}
			}
			return tmp;
			
		}
		
		
		static public function nrm( t:Number, min:Number, max:Number):Number
		{
			return ( t - min ) / ( max - min );
		}
		static public function lrp( t:Number, min:Number, max:Number):Number
		{
			return min + ( max - min ) * t;
		}
		static public function map( t:Number, mi0:Number, ma0:Number, mi1:Number, ma1:Number ):Number
		{
			return lrp( nrm( t, mi0, ma0 ), mi1, ma1 );
		}
		
		/*
		 * http://wonderfl.net/c/eYx0
		 * This alternative method uses less local variables and less operators to achieve the same result:
		*/
		static private function interpolateColorsCompact( a:int, b:int, lerp:Number ):int
		{ 
			var MASK1:int = 0xff00ff; 
			var MASK2:int = 0x00ff00; 

			var f2:int = 256 * lerp;
			var f1:int = 256 - f2;

			return ((((( a & MASK1 ) * f1 ) + ( ( b & MASK1 ) * f2 )) >> 8 ) & MASK1 ) | ((((( a & MASK2 ) * f1 ) + ( ( b & MASK2 ) * f2 )) >> 8 ) & MASK2 );

		}
		
	}
}