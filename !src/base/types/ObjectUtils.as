package base.types {
	import base.types.Singleton;
	
	public class ObjectUtils extends Singleton{
		
		static public function cloneObj(objSrc: Object): Object {
			var objClone: Object = {};
			for (var prop: String in objSrc) {
				if (typeof(objSrc[prop]) == "object") objClone[prop] = ObjectUtils.cloneObj(objSrc[prop]);
				else objClone[prop] = objSrc[prop];
			}
			return objClone;
		}
		
		static public function populateObj(objSrc: Object, objPopulate: Object): Object {
			for (var prop: String in objSrc) {
				if (typeof(objSrc[prop]) == "object") {
					if (objSrc[prop] is Array) {
						if (!objPopulate[prop]) objPopulate[prop] = [];
						else if (!(objPopulate[prop] is Array)) objPopulate[prop] = [objPopulate[prop]];
						for (var i: uint = 0; i < objSrc[prop].length; i++) {
							if (objPopulate[prop].indexOf(objSrc[prop][i]) == -1) objPopulate[prop].push(objSrc[prop][i]);
						}
					} else objPopulate[prop] = ObjectUtils.populateObj(objSrc[prop], objPopulate[prop] || {});
				} else objPopulate[prop] = objSrc[prop];
				
			}
			return objPopulate;
		}
		
	}
	
}