/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FIVe3D
Flash Interactive Vector-based 3D
Mathieu Badimon  |  five3d@mathieu-badimon.com

http://five3D.mathieu-badimon.com  |  http://five3d.mathieu-badimon.com/archives/  |  http://code.google.com/p/five3d/

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package net.badimon.five3D.utils {
	import net.badimon.five3D.display.Graphics3D;

	import flash.geom.Point;

	/**
	 * The DrawingUtils class contains complex methods for drawing inside a Graphics3D instance.
	 */
	public class DrawingUtils {

		/**
		 * Draws a polygon into the Graphics3D object specified.
		 * 
		 * @param graphics		The Graphics3D to draw into.
		 * @param points		An array of points which form the polygon.
		 * @param color			The color of the fill.
		 * @param alpha			The alpha value of the fill (from 0.0 to 1.0).
		 */
		public static function polygon(graphics:Graphics3D, points:Vector.<Point>, color:uint, alpha:Number = 1.0):void {
			graphics.beginFill(color, alpha);
			tracePolygon(graphics, points);
			graphics.endFill();
		}

		private static function tracePolygon(graphics:Graphics3D, points:Vector.<Point>):void {
			var len:int = points.length;
			if (len > 2) {
				var firstPoint:Point = points[0] as Point;
				graphics.moveTo(firstPoint.x, firstPoint.y);
				var point:Point;
				for (var i:int = 1; i < len; i++) {
					point = points[i] as Point;
					graphics.lineTo(point.x, point.y);
				}
				graphics.lineTo(firstPoint.x, firstPoint.y);
			}
		}

		/**
		 * Draws a star into the Graphics3D object specified.
		 * The center of the star is the registration point of the Graphics3D instance specified.
		 * 
		 * @param graphics		The Graphics3D to draw into.
		 * @param numVertices	The number of vertices which form the star. 
		 * @param radius1		The larger radius of the star (tops distance).
		 * @param radius2		The smaller radius of the star.
		 * @param angle			The rotation angle of the star on its center (in radians).
		 * @param color			The color of the fill.
		 * @param alpha			The alpha value of the fill (from 0.0 to 1.0).
		 * 
		 * @see #starPlace()
		 */
		public static function star(graphics:Graphics3D, numVertices:uint, radius1:Number, radius2:Number, angle:Number, color:uint, alpha:Number = 1.0):void {
			graphics.beginFill(color, alpha);
			traceStar(graphics, 0, 0, numVertices, radius1, radius2, angle);
			graphics.endFill();
		}

		/**
		 * Draws a star into the Graphics3D object specified.
		 * The center of the star is the point specified by the <code>x</code> and <code>y</code> parameters.
		 * 
		 * @param graphics		The Graphics3D to draw into.
		 * @param x				The x coordinate along the x-axis of the center of the star.
		 * @param y				The y coordinate along the y-axis of the center of the star.
		 * @param numVertices	The number of vertices which form the star.
		 * @param radius1		The larger radius of the star (tops distance).
		 * @param radius2		The smaller radius of the star.
		 * @param angle			The rotation angle of the star on its center (in radians).
		 * @param color			The color of the fill.
		 * @param alpha			The alpha value of the fill (from 0.0 to 1.0).
		 * 
		 * @see #star()
		 */
		public static function starPlace(graphics:Graphics3D, x:Number, y:Number, numVertices:uint, radius1:Number, radius2:Number, angle:Number, color:uint, alpha:Number = 1.0):void {
			graphics.beginFill(color, alpha);
			traceStar(graphics, x, y, numVertices, radius1, radius2, angle);
			graphics.endFill();
		}

		private static function traceStar(graphics:Graphics3D, x:Number, y:Number, numVertices:uint, radius1:Number, radius2:Number, angle:Number):void {
			if (numVertices > 1) {
				var firstVertexX:Number = x + Math.cos(angle) * radius1;
				var firstVertexY:Number = y + Math.sin(angle) * radius1;
				graphics.moveTo(firstVertexX, firstVertexY);
				var angleStep:Number = Math.PI / numVertices;
				var len:int = numVertices * 2;
				for (var i:int = 1; i < len; i++) {
					angle += angleStep;
					if (i % 2 == 0) {
						graphics.lineTo(x + Math.cos(angle) * radius1, y + Math.sin(angle) * radius1);
					} else {
						graphics.lineTo(x + Math.cos(angle) * radius2, y + Math.sin(angle) * radius2);
					}
				}
				graphics.lineTo(firstVertexX, firstVertexY);
			}
		}

		/**
		 * Draws a transparent gradient with a plain color.
		 * 
		 * @param graphics		The Graphics3D to draw into.
		 * @param width			The width of the gradient (in pixels).
		 * @param height		The height of the gradient (in pixels).
		 * @param color			The plain color of the transparent gradient.
		 * @param alpha1		The alpha value of the fill on the left side (from 0.0 to 1.0).
		 * @param alpha2		The alpha value of the fill on the right side (from 0.0 to 1.0).
		 * @param numSteps	The number of steps (sub rectangles) used to draw the gradient.
		 * 
		 * @see #gradientHorizontalPlainPlace()
		 */
		public static function gradientHorizontalPlain(graphics:Graphics3D, width:Number, height:Number, color:uint, alpha1:Number, alpha2:Number, numSteps:uint):void {
			var widthStep:Number = width / numSteps;
			var alphaStep:Number = (alpha2 - alpha1) / numSteps;
			for (var i:int = 0;i < numSteps; i++) {
				graphics.beginFill(color, alpha1 + i * alphaStep);
				graphics.drawRect(i * widthStep, 0, widthStep, height);
				graphics.endFill();
			}
		}

		/**
		 * Draws a transparent gradient with a plain color.
		 * The top left corner of the gradient is the point specified by the <code>x</code> and <code>y</code> parameters.
		 * 
		 * @param graphics		The Graphics3D to draw into.
		 * @param x				The x coordinate along the x-axis of the top left corner of the gradient.
		 * @param y				The y coordinate along the y-axis of the top left corner of the gradient.
		 * @param width			The width of the gradient (in pixels).
		 * @param height		The height of the gradient (in pixels).
		 * @param color			The plain color of the transparent gradient.
		 * @param alpha1		The alpha value of the fill on the left side (from 0.0 to 1.0).
		 * @param alpha2		The alpha value of the fill on the right side (from 0.0 to 1.0).
		 * @param numSteps	The number of steps (sub rectangles) used to draw the gradient.
		 * 
		 * @see #gradientHorizontalPlain()
		 */
		public static function gradientHorizontalPlainPlace(graphics:Graphics3D, x:Number, y:Number, width:Number, height:Number, color:uint, alpha1:Number, alpha2:Number, numSteps:uint):void {
			var widthStep:Number = width / numSteps;
			var alphaStep:Number = (alpha2 - alpha1) / numSteps;
			for (var i:int = 0;i < numSteps; i++) {
				graphics.beginFill(color, alpha1 + i * alphaStep);
				graphics.drawRect(x + i * widthStep, y, widthStep, height);
				graphics.endFill();
			}
		}
	}
}