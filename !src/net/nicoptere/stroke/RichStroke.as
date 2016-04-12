package net.nicoptere.stroke
{
	import flash.display.Graphics;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * @author nicoptere
	 */
	public class RichStroke
	{
		private var quads:Vector.<Quad>;
		
		private var vertices:Vector.<Number>;
		private var indices:Vector.<int>;
		private var uvs:Vector.<Number>;
		
		private var bd:BitmapData;
		
		private var width:int;
		private var height:int;
		
		public var debug:int = 0;
		
		
		public function RichStroke( bd:BitmapData = null ) 
		{
			
			if( bd !=null )bitmapData = bd;
			
		}
		
		/**
		 * turns the given Point Vector into a set of quads
		 * @param	vectors set of points typically a simplified curve
		 * @param	constantPath a Boolean to tell wether the width of the stroke is constant or not 
		 * @param	graphics a Graphics object for debug purpose
		 * @return a vector of Quad Objects
		 */
		public function fromCurve( vectors:Vector.<Point>, constantPath:Boolean = true, graphics:Graphics = null ):Vector.<Quad> 
		{
			
			if ( graphics == null ) debug = 0;
			
			var p:Point, np:Point, ln:Point = new Point(), rn:Point = new Point(), ln1:Point, rn1:Point;
			var a:Number = 0, h_2:Number = height * .5, dist:Number, totalDistance:Number = 0;
			var corners:Vector.<Point> = new Vector.<Point>();
			var ratios:Vector.<Number> = new Vector.<Number>();
			
			var i:int, total:int = vectors.length - 1;
			
			for ( i = -1; i < total; i++ )
			{
				//special case: the first point
				if ( i == -1 )
				{
					
					p = vectors[ 1 ];
					np = vectors[ 0 ];
					a = angle( p, np );
					dist = distance( p, np );
					if( !constantPath ) h_2 = dist / 4;
					
					//current point normals
					ln.x = np.x - Math.cos( a - Math.PI / 2 ) * h_2;
					ln.y = np.y - Math.sin( a - Math.PI / 2 ) * h_2;
					
					//next point normals
					rn.x = np.x - Math.cos( a + Math.PI / 2 ) * h_2;
					rn.y = np.y - Math.sin( a + Math.PI / 2 ) * h_2;
					
				}
				else 
				{
					p = vectors[ i ];
					np = vectors[ i + 1 ];
					a = angle( p, np );
					dist = distance( p, np );
					if ( !constantPath ) h_2 = dist / 2;
					
					//current point normals
					ln.x = np.x + Math.cos( a - Math.PI / 2 ) * h_2;
					ln.y = np.y + Math.sin( a - Math.PI / 2 ) * h_2;
					
					//next point normals
					rn.x = np.x + Math.cos( a + Math.PI / 2 ) * h_2;
					rn.y = np.y + Math.sin( a + Math.PI / 2 ) * h_2;
				
				}
				
				//collects the normals coordinates
				corners.push( ln.clone(), rn.clone() );
				
				//collects the relative length of the segment against the curve's length
				
				totalDistance += dist;
				ratios.push( totalDistance );
				
				if ( debug == 1 )
				{ 
					
					graphics.lineStyle( 0, 0x66CC00 );
					graphics.moveTo( np.x, np.y );
					graphics.lineTo( p.x, p.y );
					graphics.lineStyle( 0, 0x0000CC );
					graphics.moveTo( np.x, np.y );
					graphics.lineTo( rn.x, rn.y );
					graphics.lineStyle( 0, 0xFFCC00 );
					graphics.moveTo( np.x, np.y );
					graphics.lineTo( ln.x, ln.y );
					
				}
				
			}
			//associates the corners to create a quad
			var quad:Quad;
			var u0:Number = 0;
			var quadList:Vector.<Quad> = new Vector.<Quad>();
			
			total = corners.length;
			for ( i = 2; i < total; i+=2 )
			{
				
				ln = corners[ i-2 ];
				rn = corners[ i-1 ];
				ln1 = corners[ i ];
				rn1 = corners[ i + 1 ];
				
				quad = new Quad( ln, ln1, rn1, rn );
				
				quad.u0 = u0;
				u0 = ratios[ (i / 2) ] / totalDistance;
				quad.u1 = u0;
				
				quadList.push( quad );
				
				if ( debug == 1 )
				{
					graphics.lineStyle( 0, 0xCC0000, 1 );
					graphics.moveTo( ln.x, ln.y );
					graphics.lineTo( ln1.x, ln1.y );
					
					graphics.moveTo( rn.x, rn.y );
					graphics.lineTo( rn1.x, rn1.y );
					graphics.lineTo( ln.x, ln.y );
				}
				
			}
			
			return quadList;
			
		}
		
		
		public function setQuads ( quads:Vector.<Quad> ):void
		{
			
			this.quads = new Vector.<Quad>()
			this.quads = quads.concat();
			
			vertices = new Vector.<Number>();
			indices = new Vector.<int>();
			uvs = new Vector.<Number>();
			
			var quad:Quad;
			var v0:Point;
			var v1:Point;
			var v2:Point;
			var v3:Point;
			
			var i:int;
			var indice:int = 0;
			var total:int = quads.length;
			
			var u0:Number = 0, u1:Number = 0, ratio:Number;
			
			for ( i = 0; i < total; i++ )
			{
				//for each quad
				quad = quads[ i ];
				
				
				//sets the uvs
				u0 = quad.u0;
				u1 = quad.u1;
				
				//the uvs
				uvs.push( 	u0, 0,
							u1, 0,
							u1, 1,
							u0, 1 );
				
				
				//grabs the corners
				v0 = quad.vectors[ 0 ];
				v1 = quad.vectors[ 1 ];
				v2 = quad.vectors[ 2 ];
				v3 = quad.vectors[ 3 ];
				
				
				//stores the vertices
				vertices.push( 	v0.x, v0.y, 
								v1.x, v1.y, 
								v2.x, v2.y,
								v3.x, v3.y );
				
				//then the indices for both triangles of th quad
				//first triangle
				indices.push( indice, indice + 1, indice + 2 );
				
				//second triangle
				indices.push( indice, indice + 2, indice + 3);
				
				indice += 4;
			}
		}
		
		
		private function distance( p0:Point, p1:Point ):Number
		{
			var dx:Number = ( p1.x - p0.x );
			var dy:Number = ( p1.y - p0.y );
			return Math.sqrt( dx*dx+dy*dy );
		}
		private function angle( p0:Point, p1:Point ):Number
		{
			return Math.atan2( p1.y - p0.y, p1.x - p0.x );
		}
		
		public function set bitmapData( src:BitmapData ):void
		{
			bd = src.clone();
			width = bd.width;
			height = bd.height;
		}
		public function get bitmapData( ):BitmapData { return bd; }
		
		
		public function dispose():void
		{
			bd.dispose();
			quads = null;
			vertices = null;
			indices = null;
			uvs = null;
		}
		
		
		/********************************************************************************************/
		
		
		/**
		 * drawing method to render the triangles
		 * addapt here or extend + override with your own method
		 * @param	graphics a Graphics object to draw to
		 * @param	smooth should the bitmapbe smoothed
		 */
		public function draw( graphics:Graphics, smooth:Boolean = false ):void
		{
			
			graphics.beginBitmapFill( bd, null, false, smooth );
			graphics.drawTriangles( vertices, indices, uvs );
			graphics.endFill();
			
		}
	}
}