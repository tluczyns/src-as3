package base.loader.show {
	import flash.text.TextField;
	import flash.display.Sprite;
	
	public class LoaderProgressPie extends LoaderProgress {
		
		private var colorPie: uint;
		private var radiusPie: Number;
		private var radiusStroke: Number;
		private var bg: Sprite;
		private var pie: Sprite;
		private var maskPie: Sprite;

		public function LoaderProgressPie(colorPie: uint, radiusPie: Number = 60, radiusStroke: Number = 10, tfPercent: TextField = null, isTLOrCenterAnchorPointWhenCenterOnStage: uint = 0, timeFramesTweenPercent: Number = 0.2): void {
			this.colorPie = colorPie;
			this.radiusPie = radiusPie;
			this.radiusStroke = radiusStroke;
			this.createElements()
			super(tfPercent, isTLOrCenterAnchorPointWhenCenterOnStage, timeFramesTweenPercent);
			if (this.tfPercent != null) this.tfPercent.y = (this.radiusPie - this.tfPercent.height) / 2;
		}
		
		private function createElements():void {
			this.bg = new Sprite();
			this.bg.graphics.beginFill(this.colorPie, 1);
			this.bg.graphics.drawEllipse(0, 0, this.radiusPie, this.radiusPie);
			this.bg.graphics.drawEllipse(this.radiusStroke / 2, this.radiusStroke / 2, this.radiusPie - this.radiusStroke, this.radiusPie - this.radiusStroke);
			this.bg.graphics.endFill();
			this.addChild(this.bg);
			
			this.pie = new Sprite();
			this.pie.graphics.copyFrom(this.bg.graphics);
			this.addChild(this.pie);
			
			this.maskPie = new Sprite()
			this.maskPie.x = this.maskPie.y = this.radiusPie / 2;
			addChild(this.maskPie);
			this.pie.mask = this.maskPie;
			
			this.bg.x = this.pie.x = (this.radiusPie -this.bg.width) / 2;
			this.bg.y = this.pie.y = (this.radiusPie -this.bg.height) / 2;
			this.bg.alpha = 0.2;
		}
		
		private function redrawMaskPie(): void {
			this.maskPie.graphics.clear();
			this.maskPie.graphics.beginFill(0x000000, 1);
			var radiusPercent: uint = Math.round(this.ratioProgress * 100 * 3.6);
			for (var i: uint = 0; i <= radiusPercent; i++) {
				this.maskPie.graphics.lineTo(this.radiusPie / 2 * Math.sin(i * (Math.PI / 180)), -this.radiusPie / 2 * Math.cos(i * (Math.PI / 180)));
			}
		}
		
		override protected function update(): void {
			super.update();
			this.redrawMaskPie();
			if (this.tfPercent != null) this.tfPercent.x = (this.radiusPie - this.tfPercent.width) / 2;
		}
		
		override public function destroy():void {
			this.maskPie.graphics.clear();
			this.removeChild(this.maskPie)
			this.bg.graphics.clear();
			this.removeChild(this.bg)
			this.pie.graphics.clear();
			this.removeChild(this.pie)
		}
		
	}
	
}