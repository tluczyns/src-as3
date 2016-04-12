package base.service {
	
	public class DescriptionCall extends Object {
		
		public var isUrlLoaderServiceAmfExternalInterface: uint;
		public var strUrlOrMethod: String;
		public var serviceAmf: * //ServiceAmf;
		public var authorizationDataForUrlLoader: String;
		
		public function DescriptionCall(isUrlLoaderServiceAmfExternalInterface: uint, strUrlOrMethod: String, serviceAmf: * = null, authorizationDataForUrlLoader: String = ""): void { //authorizationDataForUrlLoader to String w format login:password
			this.isUrlLoaderServiceAmfExternalInterface = isUrlLoaderServiceAmfExternalInterface;
			this.strUrlOrMethod = strUrlOrMethod;
			this.serviceAmf = serviceAmf;
			this.authorizationDataForUrlLoader = authorizationDataForUrlLoader;
		}
		
	}

}