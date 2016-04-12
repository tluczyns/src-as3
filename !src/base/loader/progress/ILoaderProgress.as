package base.loader.progress {
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	
	public interface ILoaderProgress {
		function addWeightContent(weight: Number): void;
		function initNextLoad(): void;
		function onLoadProgress(event: ProgressEvent): void;
		function setLoadProgress(ratioLoaded: Number): void;
		
	}
	
}