package at.imagination.flare {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public interface IFlareTracker {
	
		function getVersion():String;
		function setLogger(obj:Object, logger:Function, level:uint):void;
		function getProjectionMatrix():ByteArray;
		function update(image:BitmapData):uint;
		function getTrackerResults():ByteArray;
		function getTrackerResults2D():ByteArray;
	}
}