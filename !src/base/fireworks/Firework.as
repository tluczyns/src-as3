class com.tl.fireworks.Firework extends com.tl.McOef {
	private var classFireworks: com.tl.fireworks.Fireworks
	public var numPoints, maxNumPoints: Number;
	private var speed: Number;
	private var gravity: Number;
	private var range: Number;
	private var objColorFirework: Object;
	public var arrFireworkLines: Array;	
	private var soundFirework: com.tl.types.SoundExt;
	
	function Firework(firewarkParams: Array) {
		this.copyFireworkParameters(firewarkParams);
		this.setFireworkColor();
	}
	
	private function setFireworkColor() {
		this.objColorFirework = new Color(this);
		var colorComposition = 0;
		var r:Number = 155 + random(100);//random(255);//255
		var g:Number = random(50);//255 - r//random(7)*51
		var b:Number = random(50);//random(255);//0;
		this.objColorFirework.setRGB(r<<16|g<<8|b);
		var clrFirework:Number = this.objColorFirework.getRGB();
	}
	
	private function copyFireworkParameters(firewarkParams) {
		this._x = firewarkParams.x;
		this._y = firewarkParams.y;
		this.classFireworks = firewarkParams.classFireworks;
		this.numPoints = firewarkParams.numPoints;
		this.maxNumPoints = firewarkParams.numPoints; 
		this.speed = firewarkParams.speed;
		this.gravity = firewarkParams.gravity;
		this.range = firewarkParams.range;
	}

	public function onEnterFrame() {
		if (this.numPoints < 1) {
			this.soundFirework.del();
			this.removePoints();
			//this.classFireworks.initFirework(this);
			this.removeMovieClip();
			delete this;
		} else {
			/*
			var maxClr:Number = 65535//16777215;
			var clrFirework:Number = this.objColorFirework.getRGB();
			var clrDiff:Number = (maxClr - clrFirework) / this.speed;
			var targetClrFirework:Number = clrFirework + clrDiff;
			if (targetClrFirework >= maxClr) {
				targetClrFirework = maxClr;
			}
			this.objColorFirework.setRGB(targetClrFirework)
			*/
		}
	}
	
	public function addPoints() {
		this.arrFireworkLines = [];
		for (var i = 0; i < this.maxNumPoints; i++) {
			var fireworkPoint = this.attachMovie("fireworkPoint", "fireworkPoint" + String(i), 10 + i)
			fireworkPoint.init(this, i, this.speed, this.gravity, this.range);
		}
	}
	
	public function removePoints() {
		for (var i = 0; i < this.maxNumPoints; i++) {
			var fireworkPoint = this["fireworkPoint" + String(i)];
			if (fireworkPoint) {
				fireworkPoint._visible = false;
				fireworkPoint.removeMovieClip();
				delete fireworkPoint;
			}
		}
		for (var i = 0; i < this.arrFireworkLines.length; i++) {
			var fireworkLine = this["fireworkLine" + String(i)];
			if (fireworkLine) {
				fireworkLine._visible = false;
				fireworkLine.removeMovieClip();
			}
		}
	}
}