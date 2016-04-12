package base.utils {
	import base.types.Singleton;
	import base.math.MathExt;
    	
	public class DatePrinterPL extends Object {
		
		private var date: Date;
		private var isNominativeGenitive: uint;
		
		public static var ARR_MONTH_NOMINATIVE: Array = ["styczeń", "luty", "marzec", "kwiecień", "maj", "czerwiec", "lipiec", "sierpień", "wrzesień", "październik", "listopad", "grudzień"];
        public static var ARR_MONTH_GENITIVE:  Array = ["stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca", "lipca", "sierpnia", "września", "października", "listopada", "grudnia"];
        public static var ARR_DAY_NOMINATIVE: Array = ["niedziela", "poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota"];
        public static var ARR_DAY_GENITIVE: Array = ["niedzieli", "poniedziałek", "wtorku", "środy", "czwartku", "piątku", "soboty"];
		public static var LABEL_YEAR_NOMINATIVE: String = "rok"
		public static var LABEL_YEAR_GENITIVE: String = "roku"
		
		public function DatePrinterPL(date: Date = null, isNominativeGenitive: uint = 0): void {
			this.date = date || new Date();
			this.isNominativeGenitive = isNominativeGenitive;
		}
		
		public function getDayWeekCurrent(isNominativeGenitive: int = -1): String {
			isNominativeGenitive = (isNominativeGenitive == -1) ? this.isNominativeGenitive : isNominativeGenitive;
            return DatePrinterPL["ARR_DAY_" + ["NOMINATIVE", "GENITIVE"][isNominativeGenitive]][this.date.getDay()];
        }
		
        public function getDayMonthCurrent(): String {
            return String(this.date.getDate());
        }
		
        public function getMonthNameCurrent(isNominativeGenitive: int = -1): String {
            isNominativeGenitive = (isNominativeGenitive == -1) ? this.isNominativeGenitive : isNominativeGenitive;
			return DatePrinterPL["ARR_MONTH_" + ["NOMINATIVE", "GENITIVE"][isNominativeGenitive]][this.date.getMonth()];
        }
		
        public function getYearCurrent(isNominativeGenitive: int = -1): String {
			isNominativeGenitive = (isNominativeGenitive == -1) ? this.isNominativeGenitive : isNominativeGenitive;
            return String(this.date.getFullYear()) + " " + DatePrinterPL["LABEL_YEAR_" + ["NOMINATIVE", "GENITIVE"][isNominativeGenitive]];
        }

        public function getDateCurrent(isNominativeGenitive: int = -1): String {
			isNominativeGenitive = (isNominativeGenitive == -1) ? this.isNominativeGenitive : isNominativeGenitive;
            return this.getDayWeekCurrent(isNominativeGenitive) + " " + this.getDayMonthCurrent() + " " + this.getMonthNameCurrent(isNominativeGenitive) + " " + this.getYearCurrent(isNominativeGenitive);
        }
		
		public function getDateCurrentShort(separator: String = "."): String {
			return String(this.date.getFullYear()) + separator + MathExt.addZerosBeforeNumberAndReturnString(this.date.getMonth() + 1, 2) + separator + MathExt.addZerosBeforeNumberAndReturnString(this.getDayMonthCurrent(), 2);
		}
		
		public function getTimeCurrent(): String {
			var time: Number = this.date.getTime();
			return MathExt.addZerosBeforeNumberAndReturnString(Math.floor(time / 1000 / 60 / 60) % 24, 2) + ":" +
				MathExt.addZerosBeforeNumberAndReturnString(Math.floor(time / 1000 / 60) % 60, 2);
		}
		
	}
	
}