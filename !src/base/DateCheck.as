package base {
	
	public class DateCheck extends Singleton {
		
		public function DateCheck(): void {}
		
		public static function checkIsProperDate(year: int, month: int, day: int, isMustBeLessThanNow: Boolean = false): Boolean {
			var dateToCheck: Date = new Date(year, month, day);
			var currentDate: Date = new Date();
			return ((dateToCheck.getDate() == day) && (dateToCheck.getMonth() == month) && (dateToCheck.getFullYear() == year) && ((!isMustBeLessThanNow) || ((isMustBeLessThanNow) && (dateToCheck.getTime() < currentDate.getTime()))));
		}
		
		/**
		* Checks whether the user's age is permissible or not.  The month and day can be passed in with leading zeros or not.
		* The year should be passed in as the full year (ex: 1983).
		*
		* @param ageToCheck The age you want to test against
		* @param userDay The user's input day
		* @param userMonth The user's input month
		* @param userYear The user's input year
		* @return A boolean value that states whether the age check has passed or not.
		*/
		public static function checkAge(ageToCheck: int, userDay: int, userMonth: int, userYear: int): Boolean {
			var todayDate:Date = new Date();
			var currentMonth:int = (todayDate.getMonth() + 1);
			var currentDay:int = todayDate.getDate();
			var currentYear:int = todayDate.getFullYear();
			var yearDiff:int = (currentYear - userYear);
			if (yearDiff == ageToCheck) {
				var monthDiff: int = (currentMonth - userMonth);
				if (monthDiff == 0) {
					var dayDiff: int = currentDay - userDay;
					if (dayDiff>= 0) return true;
					else return false;
				} else if (monthDiff < 0) return false;
				else return true;
			} else if (yearDiff < ageToCheck) return false;
			else return true;
		}
		
	}

}