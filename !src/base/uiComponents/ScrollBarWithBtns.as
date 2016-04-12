package base.uiComponents {
	import base.uiComponents.scrollBar.Btn;
	import base.btn.BtnHitEvent;
	
	public class ScrollBarWithBtns extends ScrollBar {
		
		protected var btnUp: Btn;
		protected var btnDown: Btn;
		protected var ratioChangePercent: Number;
		
		public function ScrollBarWithBtns(scrollArea: ScrollArea = null, height: Number = 100): void {
			super(scrollArea, height);
			this.ratioChangePercent = 0.2;
		}
		
		override protected function createElements(): void {
			super.createElements();
			this.btnUp = this.createBtn(0);
			this.btnDown = this.createBtn(1);
		}
		
		protected function createBtn(isUpDown: uint): Btn {
			var btn: Btn = new Btn(this.track.width, isUpDown);
			return btn;
		}
		
		override protected function initElements(): void {
			super.initElements();
			this.initBtns();
		}
		
		private function initBtns(): void {
			this.btnUp.rotation = -90;
			this.btnUp.visible = false;
			this.btnUp.x = this.track.x + (this.track.width - this.btnUp.width) / 2;
			this.btnUp.y = this.btnUp.height;
			this.btnUp.addEventListener(BtnHitEvent.CLICKED, this.onBtnClicked)
			this.addChild(this.btnUp);
			this.btnDown.rotation = 90;
			this.btnDown.visible = false;
			this.btnDown.x = this.btnDown.width + this.track.x + (this.track.width - this.btnDown.width) / 2;
			this.btnDown.addEventListener(BtnHitEvent.CLICKED, this.onBtnClicked)
			this.addChild(this.btnDown);
			ScrollBar.MARGIN_Y_BAR = Math.max(this.btnUp.width, ScrollBar.MARGIN_Y_BAR);
		}
		
		private function onBtnClicked(e: BtnHitEvent): void {
			var isUpDown: uint = uint(e.data);
			//if (this.scrollArea != null) this.ratioChangePercent = Math.min(1 / ((this.scrollArea.area.height - this.scrollArea.height) / this.scrollArea.height), 1);
			var percentBar: Number = Math.min(Math.max(0, this.getPercentBar(this.bar.y + this.bar.height / 2) + this.ratioChangePercent * [-1, 1][isUpDown]), 1);
			this.changePosYFromPercentBar(percentBar);
		}
		
		override protected function changePosYFromPercentBar(percentBar: Number): void {
			super.changePosYFromPercentBar(percentBar)
			if (this.bar.visible) this.checkPercentBarAndBlockUnblockBtnUpDown(percentBar);
		}
		
		private function checkPercentBarAndBlockUnblockBtnUpDown(percentBar: Number): void {
			if ((percentBar <= 0) && (this.btnUp.isEnabled)) this.btnUp.isEnabled = false;
			else if ((percentBar > 0) && (!this.btnUp.isEnabled)) this.btnUp.isEnabled = true;
			if ((percentBar >= 1) && (this.btnDown.isEnabled)) this.btnDown.isEnabled = false;
			else if ((percentBar < 1) && (!this.btnDown.isEnabled)) this.btnDown.isEnabled = true;
		}
		
		override public function addBarEvents(): void {
			if (!this.bar.visible) {
				this.btnUp.visible = true;
				this.btnDown.visible = true;
				this.btnUp.addMouseEvents();
				this.btnDown.addMouseEvents();
			}
			super.addBarEvents();
		}
		
		override protected function removeBarEvents(): void {
			if (this.bar.visible) {
				this.btnUp.removeMouseEvents();
				this.btnDown.removeMouseEvents();
				this.btnUp.visible = false;
				this.btnDown.visible = false;
			}
			super.removeBarEvents();
		}
		
		override public function set height(value: Number): void {
			super.height = value;
			if (this.bar.visible) {
				this.btnDown.y = value - this.btnDown.height;
			}
		}
		
	}

}