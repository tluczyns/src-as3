//Note points are not drawn by default.  The redraw() function must be called explicitly.

package com.flashandmath.dg.objects {
	
	import flash.display.Sprite;
	
	public class ControlPoint extends Sprite {
		
		private var _color:uint;
		private var _radius:Number;
		private var _fillAlpha:Number;
		
		public function ControlPoint(colo = 0xFF0000, rad = 3, a = 1) {
			super();
			_color = colo;
			_radius = rad;
			_fillAlpha = a;
		}
		
		public function set color(n:uint):void {
			_color = n;
			redraw();
		}
		public function get color():uint {
			return _color;
			redraw();
		}
		public function set radius(n:Number):void {
			_radius = n;
			redraw();
		}
		public function get radius():Number {
			return _radius;
			redraw();
		}
		public function set fillAlpha(n:Number):void {
			_fillAlpha = n;
			redraw();
		}
		public function get fillAlpha():Number {
			return _fillAlpha;
			redraw();
		}
		
		public function redraw():void {
			this.graphics.clear();
			this.graphics.clear();
			//this.graphics.lineStyle(1,_color);
			this.graphics.beginFill(_color, _fillAlpha);
			this.graphics.drawEllipse(-_radius, -_radius, 2*_radius, 2*_radius);
			this.graphics.endFill();
		}
		
	}
	
}
