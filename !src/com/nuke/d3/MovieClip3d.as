package com.nuke.d3
{
	import flash.display.MovieClip;
	import flash.filters.BlurFilter;
	
	/**
	 * ...
	 * @author Bartłomiej JERZY
	 */
	public class MovieClip3d extends MovieClip
	{
		private var _xx:Number;
		private var _yy:Number;
		private var _zz:Number;
		private var _scale:Number;
		private var _fov:Number; 

		private var _dof:Boolean;
		private var _fStop:Number;
		private var _fDist:Number;
		
		public function MovieClip3d($fov:Number = 300,$dof:Boolean = false) {
			_fov = $fov
			_scale = 1;
			_dof = $dof
		}
		
		public function get xx() {	return _xx;	}
		public function set xx(value:Number) {
			if (_xx != value) {
				_xx = value;
				render();
			}
		}
		public function get yy() { return _yy; }
		public function set yy(value:Number) {
			if (_yy != value) {
				_yy = value;
				render();
			}
		}
		public function get fov() {	return _fov;}
		public function set fov(f:Number) {
			
			if (_fov != f) {
				
				_fov = f;
				render();
			}
		}
		public function get zz():Number { return _zz; }
		public function set zz(value:Number):void 
		{
			if (value != _zz) {
				_zz = value;
				render();
			}
		}
		public function setBlur(fstop:Number, fdist:Number) {
			_fStop = fstop;
			_fDist = fdist;
			_dof = true
			addDof();
		}
		public function resetBlur() {
			filters = [];
			_dof = false;
		}
		private function addDof() {
			var __b = Math.abs((_zz+_fDist)/_fStop);
			var __blur = new BlurFilter(__b, __b, 2);
			filters = [__blur];
			//alpha = 500-_zz
		}
		private function render() {
			var p:Number = _fov/(_zz+_fov);
			x = _xx*p;
			y = _yy*p;
			scaleX = scaleY = _scale*p;
			if (_dof) {
				addDof();
			}
		}
		
	}
	
}