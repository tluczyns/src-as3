package base.bitmap {
	import base.types.Singleton;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.display.Shape;
	import flash.display.GradientType;
	import flash.display.BlendMode;
	import flash.display.Bitmap;
	import base.bitmap.BitmapExt;
	
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.geom.Point;
	
	import flash.filters.GradientGlowFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;

	public class BitmapUtils extends Singleton {

		static public const TO_RADIANS: Number = Math.PI / 180;
		
		static public function checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc: IBitmapDrawable, isBoundToTLAnchor: Boolean = true): BitmapData {
			var bmpDataResult: BitmapData;
			if (bmpDrawableSrc is DisplayObject) {
				var dspObjectSrc: DisplayObject = DisplayObject(bmpDrawableSrc);
				var boundsDspObjectSrc: Rectangle = dspObjectSrc.getBounds(dspObjectSrc);
				var mrxForBounds: Matrix = new Matrix();
				if (isBoundToTLAnchor)
					mrxForBounds.translate(-boundsDspObjectSrc.x, -boundsDspObjectSrc.y);
				mrxForBounds.scale(dspObjectSrc.scaleX, dspObjectSrc.scaleY);
				var widthBmpDataResult: uint = dspObjectSrc.width;
				var heightBmpDataResult: uint = dspObjectSrc.height;
				if (!isBoundToTLAnchor) {
					widthBmpDataResult += dspObjectSrc.x;
					heightBmpDataResult += dspObjectSrc.y;
				}
				bmpDataResult = new BitmapData(Math.ceil(widthBmpDataResult), Math.ceil(heightBmpDataResult), true, 0x00000000);
				bmpDataResult.draw(dspObjectSrc, mrxForBounds, null, null, null, true);		
			} else bmpDataResult = BitmapData(bmpDrawableSrc);
			return bmpDataResult;
		}
		
		static private function drawEraseGradientToBmpData(bmpDataToDrawEraseGradient: BitmapData, rotationGradient: Number, arrAlpha: Array = null, arrRatio: Array = null): void {
			var arrColor: Array = [];
			for (var i: uint = 0; i < arrAlpha.length; i++) arrColor.push(0);
			var mrxGradient: Matrix = new Matrix();
			mrxGradient.createGradientBox(bmpDataToDrawEraseGradient.width, bmpDataToDrawEraseGradient.height, rotationGradient * BitmapUtils.TO_RADIANS);
			var maskGradient: Shape = new Shape();
			maskGradient.graphics.beginGradientFill(GradientType.LINEAR, arrColor, arrAlpha, arrRatio, mrxGradient)
			maskGradient.graphics.drawRect(0, 0, bmpDataToDrawEraseGradient.width, bmpDataToDrawEraseGradient.height);
			maskGradient.graphics.endFill();
			bmpDataToDrawEraseGradient.draw(maskGradient, null, null, BlendMode.ALPHA);
		}
		
		static public function drawReflectionToBitmap(dspObjToDrawReflection: DisplayObject, alphas: Array = null, ratios: Array = null): Bitmap {
			var bmpDataReflection: BitmapData = BitmapUtils.drawReflection(dspObjToDrawReflection, alphas, ratios);
			var bmpReflection: Bitmap = new BitmapExt(bmpDataReflection, "auto", true);
			var boundsDspObjectSrc: Rectangle = dspObjToDrawReflection.getBounds(dspObjToDrawReflection);
			bmpReflection.x = boundsDspObjectSrc.x + dspObjToDrawReflection.x;
			bmpReflection.y = boundsDspObjectSrc.y + dspObjToDrawReflection.y + dspObjToDrawReflection.height;
			if (dspObjToDrawReflection.parent) dspObjToDrawReflection.parent.addChild(bmpReflection);
			return bmpReflection;
		}
		
		static public function drawReflection(bmpDrawableSrc: IBitmapDrawable, arrAlpha: Array = null, arrRatio: Array = null): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var mrxReflection: Matrix = new Matrix();
			mrxReflection.scale(1, -1);
			mrxReflection.translate(0, bmpDataSrc.height);
			var bmpDataReflection: BitmapData = new BitmapData(bmpDataSrc.width, bmpDataSrc.height, true, 0x00ffffff)
			bmpDataReflection.draw(bmpDataSrc, mrxReflection, null, null, null, true);
			BitmapUtils.drawEraseGradientToBmpData(bmpDataReflection, 270, arrAlpha || [0, 0.7], arrRatio || [0x33, 0xFF]);
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataReflection;
		}
		
		static public function drawWithGradientToTransparent(bmpDrawableSrc: IBitmapDrawable, isXY: uint = 0, isStartEnd: uint = 1, ratioDimensionGradientToTransparent: Number = 0.8): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var bmpDataWithGradientToTransparent: BitmapData = new BitmapData(bmpDataSrc.width, bmpDataSrc.height, true, 0x00ffffff)
			bmpDataWithGradientToTransparent.draw(bmpDataSrc, null, null, null, null, true);
			var dimensionGradientToTransparent: Number = Math.round(ratioDimensionGradientToTransparent * 255);
			BitmapUtils.drawEraseGradientToBmpData(bmpDataWithGradientToTransparent, [0, 90][isXY], [isStartEnd, 1 - isStartEnd], [[dimensionGradientToTransparent, 255 - dimensionGradientToTransparent][isStartEnd], 255]);
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataWithGradientToTransparent;
		}
		
		static public function drawMiniature(bmpDrawableSrc: IBitmapDrawable, dimensionMiniature: Rectangle, isCropEmptySpace: uint = 0, parentBmp: Bitmap = null, stage: Stage = null): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var ratioWidthToHeightDimensionMiniature: Number = dimensionMiniature.width / dimensionMiniature.height;
			var ratioWidthToHeightBmpDataSrc: Number = bmpDataSrc.width / bmpDataSrc.height;
			var scale: Number;
			var translateX: Number;
			var translateY: Number;
			if (uint(ratioWidthToHeightDimensionMiniature > ratioWidthToHeightBmpDataSrc) == isCropEmptySpace) {
				scale = dimensionMiniature.height / bmpDataSrc.height;
				translateX = -(bmpDataSrc.width * scale - dimensionMiniature.width) / 2;
				translateY = 0;
			} else {
				scale = dimensionMiniature.width / bmpDataSrc.width;
				translateX = 0;
				translateY = -(bmpDataSrc.height * scale - dimensionMiniature.height) / 2;
			}
			var bmpDataMiniature: BitmapData;
			if (parentBmp) {
				if (parentBmp.bitmapData == bmpDataSrc) {
					parentBmp.scaleX = parentBmp.scaleY = scale;
					parentBmp.x = translateX;
					parentBmp.y = translateY;
					bmpDataMiniature = bmpDataSrc;
				}
			} else {
				var mrxScaleTranslateBmpDataMiniature: Matrix = new Matrix();
				mrxScaleTranslateBmpDataMiniature.scale(scale, scale);
				mrxScaleTranslateBmpDataMiniature.translate(translateX, translateY);
				bmpDataMiniature = new BitmapData(dimensionMiniature.width, dimensionMiniature.height, true, 0x00FFFFFF);
				if (stage) stage.quality = StageQuality.BEST;
				bmpDataMiniature.draw(bmpDataSrc, mrxScaleTranslateBmpDataMiniature, null, null, null, true);
				if (stage) stage.quality = StageQuality.HIGH;
			}
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataMiniature;
		}
		
		static public function drawScaled(bmpDrawableSrc: IBitmapDrawable, scale: Number): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var mrxScaleBmpDataScaled: Matrix = new Matrix();
			mrxScaleBmpDataScaled.scale(scale, scale);
			var bmpDataScaled: BitmapData = new BitmapData(Math.round(bmpDataSrc.width * scale), Math.round(bmpDataSrc.height * scale), true, 0x00FFFFFF);
			bmpDataScaled.draw(bmpDataSrc, mrxScaleBmpDataScaled, null, null, null, true);
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataScaled;
		}
		
		static public function drawPixelate(bmpDrawableSrc: IBitmapDrawable, sizePixel: uint): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var bmpDataSmall: BitmapData = new BitmapData(Math.round(bmpDataSrc.width / sizePixel), Math.round(bmpDataSrc.height / sizePixel), true, 0x00FFFFFF);
			var bmpPixelate: Bitmap = new Bitmap(bmpDataPixelate);
			var mrxScaleTranslate: Matrix = new Matrix();
			mrxScaleTranslate.scale(1 / sizePixel, 1 / sizePixel);
			bmpDataSmall.draw(bmpDataSrc, mrxScaleTranslate, null, null, null, true);
			var bmpDataPixelate: BitmapData = new BitmapData(bmpDataSrc.width, bmpDataSrc.height, true, 0x00FFFFFF);
			mrxScaleTranslate = new Matrix();
			mrxScaleTranslate.scale(sizePixel, sizePixel);
			bmpDataPixelate.draw(bmpDataSmall, mrxScaleTranslate);
			bmpDataSmall.dispose();
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataPixelate;
		}
		
		static public function drawCrop(bmpDrawableSrc: IBitmapDrawable, rectCrop: Rectangle, isCentered: Boolean = true): BitmapData {
			var bmpDataSrc: BitmapData = BitmapUtils.checkAndDrawBitmapDrawableToBitmapData(bmpDrawableSrc);
			var bmpDataCrop: BitmapData = new BitmapData(rectCrop.width, rectCrop.height, true, 0xFFFFFF);
			bmpDataCrop.copyPixels(bmpDataSrc, new Rectangle([rectCrop.x, (bmpDataSrc.width - rectCrop.width) / 2][uint(isCentered)], [rectCrop.y, (bmpDataSrc.height - rectCrop.height) / 2][uint(isCentered)], rectCrop.width, rectCrop.height), new Point(0, 0));
			if (bmpDataSrc != bmpDrawableSrc) {
				bmpDataSrc.dispose();
				bmpDataSrc = null;
			}
			return bmpDataCrop;
		}
		
		static public function floodFillSmooth(bmpDataSrc: BitmapData, x: int, y: int, color: uint): void {
			var bmpDataSrcClone: BitmapData = bmpDataSrc.clone();
			bmpDataSrcClone.floodFill(x, y, color);
			var objBmpDataFill: Object =  bmpDataSrcClone.compare(bmpDataSrc);
			if (objBmpDataFill) {
				var bmpDataFill: BitmapData = BitmapData(objBmpDataFill);
				bmpDataFill.applyFilter(bmpDataFill, bmpDataFill.rect, new Point(0, 0), new GradientGlowFilter(0, 90, [color, color], [0, 1], [0, 255], 2, 2, 5, BitmapFilterQuality.LOW, BitmapFilterType.FULL, true));
				bmpDataSrc.copyPixels(bmpDataFill, bmpDataFill.rect, new Point(0, 0));
				bmpDataFill.dispose();
			}
			bmpDataSrcClone.dispose();
			
		}
		
	}
	
}