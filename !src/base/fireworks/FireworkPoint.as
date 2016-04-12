class com.tl.fireworks.FireworkPoint extends com.tl.McOef {
	private var classFirework: com.tl.fireworks.Firework;
	private var numPoint: Number;
	private var speed: Number;
	private var gravity: Number;
	private var range: Number;
	private var newX, newY: Number;	
	private var finalX, finalY: Number;
	private var numLines, maxNumLines: Number;

	public function init(classFirework: com.tl.fireworks.Firework, numPoint: Number, speed: Number, gravity: Number, range: Number) {
		this._x = this._y = 0;
		this.classFirework = classFirework;
		this.numPoint = numPoint;
		this.speed = speed;
		this.gravity = gravity;
		this.range = range;
		this.newX = this.newY = 0;
		this.finalX = -this.range + random(this.range * 2);
		this.finalY = -this.range + random(this.range * 2);
		this.numLines = 0;
		this.maxNumLines = 100;		
	}

	public function onEnterFrame() {
		var diffX:Number = (this.finalX - this._x) / this.speed;
		var diffY:Number = (this.finalY - this._y) / this.speed;
		this.finalY += this.gravity;
		var oldX:Number = this.newX;
		var oldY:Number = this.newY;
		this._x += diffX;
		this._y += diffY;
		if (Math.abs(diffX) <= 1) {
			this.classFirework.numPoints--;
			this.removeMovieClip();
			delete this;
		}
		if ((this.numLines < this.maxNumLines) && (this._alpha > 20)) {
			var fireworkLineDepth:Number = 10 + this.classFirework.maxNumPoints + this.maxNumLines * this.numPoint + this.numLines;
			var fireworkLine:MovieClip = this.classFirework.attachMovie("fireworkLine", "fireworkLine" + String(fireworkLineDepth) , fireworkLineDepth);
			fireworkLine._x = oldX;
			fireworkLine._y = oldY;
			fireworkLine._xscale = this._x - oldX;
			fireworkLine._yscale = this._y - oldY;
			fireworkLine.onEnterFrame = function() {
				this._alpha -= (10 + random(10));
				if (this._alpha <= 0) {
					this.removeMovieClip()
					delete this;
				}
			}
			this.classFirework.arrFireworkLines.push(fireworkLine);
			this.numLines++;
		}
		this.newX = this._x;
		this.newY = this._y;
		this._alpha -= 3;
	}

}