package base.btn {
	import flash.display.MovieClip;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.FramePlugin;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.greensock.TweenLite;

	public class BtnIcon extends BtnHitAndBlockWithEvents {
		
		public var icon: MovieClip;
		private var _typeIcon: uint;
		
		public function BtnIcon(icon: MovieClip, hit: Sprite, typeIcon: uint = 0): void {
			TweenPlugin.activate([FramePlugin]);
			if ((this.icon == null) && (icon != null)) {
				this.addChild(icon);
				this.icon = icon;
			}
			super(hit);
			this.typeIcon = typeIcon;
			this.hit.width = this.icon.x + this.icon.width + this.icon.x;
			this.isEnabled = true;
		}
		
		override protected function onClickHandler(event: MouseEvent): void {
			this.dispatchEvent(new BtnHitEvent(BtnHitEvent.CLICKED, this.typeIcon));
		}
		
		override public function get width(): Number {
			return this.hit ? this.hit.width : super.width;
		}
		
		protected function get typeIcon(): uint {
			return this._typeIcon;
		}
		
		protected function set typeIcon(value: uint): void {
			this._typeIcon = value;
			//this.icon.stop();
			//this.icon.gotoAndStop(value + 1);
			TweenLite.to(this.icon, this.icon.totalFrames - (value + 1), {frame: value + 1, useFrames: true});
		}
		
		private function removeIcon(): void {
			this.removeChild(this.icon);
			this.icon = null;
		}
		
		override public function destroy(): void {
			this.removeIcon();
			super.destroy();
		}
		
	}

}