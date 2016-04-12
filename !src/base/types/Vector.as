package base.types {
	
	public class Vector {
		
		public var x:Number;
		public var y:Number;
	
	
		public function Vector(px:Number = 0, py:Number = 0) {
			x = px;
			y = py;
		}
		
		
		public function setTo(px:Number, py:Number):void {
			x = px;
			y = py;
		}
		
		
		public function copy(v:Vector):void {
			x = v.x;
			y = v.y;
		}
	
	
		public function dot(v:Vector):Number {
			return x * v.x + y * v.y;
		}
		
		
		public function cross(v:Vector):Number {
			return x * v.y - y * v.x;
		}
		
	
		public function plus(v:Vector):Vector {
			return new Vector(x + v.x, y + v.y); 
		}
	
		
		public function plusEquals(v:Vector):Vector {
			x += v.x;
			y += v.y;
			return this;
		}
		
		
		public function minus(v:Vector):Vector {
			return new Vector(x - v.x, y - v.y);    
		}
	
	
		public function minusEquals(v:Vector):Vector {
			x -= v.x;
			y -= v.y;
			return this;
		}
	
	
		public function mult(s:Number):Vector {
			return new Vector(x * s, y * s);
		}
	
	
		public function multEquals(s:Number):Vector {
			x *= s;
			y *= s;
			return this;
		}
	
	
		public function times(v:Vector):Vector {
			return new Vector(x * v.x, y * v.y);
		}
		
		
		public function divEquals(s:Number):Vector {
			if (s == 0) s = 0.0001;
			x /= s;
			y /= s;
			return this;
		}
		
		
		public function magnitude():Number {
			return Math.sqrt(x * x + y * y);
		}

		
		public function distance(v:Vector):Number {
			var delta:Vector = this.minus(v);
			return delta.magnitude();
		}

	
		public function normalize():Vector {
			 var m:Number = magnitude();
			 if (m == 0) m = 0.0001;
			 return mult(1 / m);
		}
		
    	public function normalizeEquals():Vector {
    	   var m:Number = magnitude();
		   if (m == 0) m = 0.0001;
		   return multEquals(1 / m);
    	}	
				
		public function toString():String {
			return (x + " : " + y);
		}
    
	   	public function traceVector():void {
    		trace("x:" + this.x + ", y:" + this.y);
    	}
        
        /**
    	 * projects this vector onto b
    	 */
    	public function project(b:Vector):Vector {
    		var adotb:Number = this.dot(b);
    		var len:Number = (b.x * b.x + b.y * b.y);
    		
    		var proj:Vector = new Vector(0,0);
    		proj.x = (adotb / len) * b.x;
    		proj.y = (adotb / len) * b.y;
    		return proj;
    	}	
    }
}