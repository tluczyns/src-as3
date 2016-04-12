package base.videoPlayer {
	import flash.net.NetStream;
	import flash.net.NetConnection;
	
	public dynamic class DynamicNetStream extends NetStream {
		
		public function DynamicNetStream(connection: NetConnection, peerID: String = "connectToFMS"): void {
			super(connection, peerID);
		}
		
	}

}