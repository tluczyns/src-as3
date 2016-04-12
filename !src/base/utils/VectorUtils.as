package base.utils {
	
	public class VectorUtils extends Object {
		
		public function VectorUtils(): void {}
			
		public static function generateRandomIndexArray(length: uint): Vector.<uint> {
			var arrRandomIndex: Vector.<uint> = new Vector.<uint>();
			for (var i: uint = 0; i < length; i++) {
				var index: uint;
				do index = Math.floor(Math.random() * length);
				while (arrRandomIndex.indexOf(index) > -1);
				arrRandomIndex.push(index);
			}
			return arrRandomIndex;
		}
		
		public static function generateRandomMixedArray(arrSrc: Vector.<uint>): Vector.<uint> {
			var arrInd: Vector.<uint> = VectorUtils.generateRandomIndexArray(arrSrc.length);
			var arrMix: Vector.<uint> = new Vector.<uint>(arrSrc.length);
			for (var i:uint = 0; i < arrSrc.length; i++) {
				arrMix[i] = arrSrc[arrInd[i]];
			}
			return arrMix;
		}
		
		
	}

}