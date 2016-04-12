package base.fireworks {
	import flash.display.Sprite;

	public class Fireworks extends Sprite {
		
		static var dimensionStage: Object = {width : Stage.width, height: Stage.height};
		private var objMarginStageBounds: Object = {top : 20, left: 100, bottom: 400, right: 100};
		public var maxNumPoints: Number = 60;
		private var toleranceNumPoints: Number = 20;
		private var numPoints: Number;
		private var maxSpeed: Number = 10;
		private var toleranceSpeed: Number = 2;
		private var speed: Number;
		private var maxGravity: Number = 5;
		private var toleranceGravity: Number = 2;
		private var gravity: Number;
		private var maxRange: Number = 130;
		private var toleranceRange: Number = 30;
		private var range: Number;
		private var x, y: Number;
		private var indFirework: Number = 0;
		public var numFramesWhenFireworkOccur:Number = 10;
		public var numFrame:Number = 0;

		public function Fireworks() {}
		
		public function getFireworkParameters() {
			this.numPoints = this.maxNumPoints - this.toleranceNumPoints + random(this.toleranceNumPoints * 2)
			this.speed = this.maxSpeed - this.toleranceSpeed + random(this.toleranceSpeed * 2);
			this.gravity = Math.max(this.maxGravity - this.toleranceGravity + random(this.toleranceGravity * 2), 0);
			this.range = Math.max(this.maxRange - this.toleranceRange + random(this.toleranceRange * 2), 30);
			this.x = objMarginStageBounds.left + random(com.tl.fireworks.Fireworks.dimensionStage.width - objMarginStageBounds.left - objMarginStageBounds.right);
			this.y = objMarginStageBounds.top + random(com.tl.fireworks.Fireworks.dimensionStage.height - objMarginStageBounds.top - objMarginStageBounds.bottom);
			return {classFireworks: this, x: this.x, y: this.y, numPoints: this.numPoints, speed: this.speed, gravity: this.gravity, range: this.range};
		}
		
		public function generateFirework() {
			var firework = this.attachMovie("firework", "firework" + String(this.indFirework), 10 + this.indFirework)
			this.initFirework(firework);
		}

		public function initFirework(firework) {
			var firewarkParams: Object = this.getFireworkParameters();
			firework.copyFireworkParameters(firewarkParams)
			firework.soundFirework = new com.tl.types.SoundExt("soundFirework", this.classMain, com.tl.types.SoundExt.createTargetMC(this));
			firework.setFireworkColor();
			firework.addPoints();
			this.indFirework++;
		}
		
		public function onEnterFrameGenerateFireworks() {
			if (this.numFrame % this.numFramesWhenFireworkOccur == 0) {
				this.generateFirework()
			}
			this.numFrame++;
		}
		
	}
	
}