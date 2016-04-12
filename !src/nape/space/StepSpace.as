package nape.space {
	import flash.events.EventDispatcher;
	import base.game.ObjScore;
	import nape.util.BitmapDebug;
	import flash.utils.getTimer;
	
	public class StepSpace extends EventDispatcher {
		
        private var space: Space;
		private var debug: BitmapDebug;
		private var velIterations: int;
        private var posIterations: int;
		private var variableStep: Boolean;
        private var prevTime: ObjScore;
		public var multiplicatorDeltaTime: ObjScore;
		
		public function StepSpace(space: Space, debug: BitmapDebug = null, variableStep: Boolean = false, velIterations: int = 10, posIterations: int = 10): void {
			this.space = space;
			this.debug = debug;
			this.velIterations = velIterations;
			this.posIterations = posIterations;
			this.variableStep = variableStep;
            this.prevTime = new ObjScore(getTimer(), 10);
		}
		
		public function step(): void {
            var curTime:ObjScore = new ObjScore(getTimer(), 10);
            var deltaTime:ObjScore = new ObjScore(curTime.value - this.prevTime.value, 10);
            if (deltaTime.value == 0) {
                return;
            }
            var noStepsNeeded:Boolean = false;
			deltaTime.value = Math.max(deltaTime.value, 1000 / 35);
			this.multiplicatorDeltaTime = new ObjScore(deltaTime.value / (1000 / 35), 5);
            if (this.variableStep) {
                if (this.debug) this.debug.clear();
                //preStep(deltaTime.value * 0.001);
                this.space.step(deltaTime.value * 0.001, this.velIterations, this.posIterations);
                this.prevTime.value = curTime.value;
            }
            else {
                //var stepSize:Number = (1000 / stage.frameRate);
                var stepSize:Number = 1000/35;
                var steps:uint = Math.round(deltaTime.value / stepSize);
                var delta:ObjScore = new ObjScore(Math.round(deltaTime.value - (steps * stepSize)), 10);
                this.prevTime.value = (curTime.value - delta.value);
                steps = Math.min(steps, 4);
                deltaTime.value = steps * stepSize;
                if (steps == 0) noStepsNeeded = true;
                else if (this.debug) this.debug.clear();
                while (steps-- > 0) {
                    //preStep(stepSize * 0.001);
                    this.space.step(stepSize * 0.001, this.velIterations, this.posIterations);
                }
            }

            if ((!noStepsNeeded) && (this.debug)) {
				this.debug.draw(this.space);
                this.debug.flush();
            }
			//if (!noStepsNeeded) postUpdate(deltaTime.value * 0.001);
        }
	}

}