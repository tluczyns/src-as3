package base.sprite {
	import flash.display.Sprite;
	import com.nuke.utils.Draw;
	
	public class DashedLine extends Sprite {
		
		private var color: uint;
		
		public function DashedLine(color: uint): void {
			this.color = color;
		}
		
		override public function set width(value: Number): void {
			this.graphics.clear();
			Draw.dotLine(this, 0, 0, value, 0, this.color, 1, 1, 2);
		}
		
	}

}