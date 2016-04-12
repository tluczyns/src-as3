import base.sharedObjects.SharedObjectExpireInstance;

this.checkValue = function(classMain) {
	trace(classMain.so.getPropValue("aaa"))
}

this.so = new SharedObjectExpireInstance("bbb", 10000);
this.so.setPropValueWithExpire("aaa", "bbb");

setInterval(this.checkValue, 400, this)