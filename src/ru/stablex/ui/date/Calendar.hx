package ru.stablex.ui.date;

enum EWeekDays
{    
    SUN;
    MON;
    TUE;
    WED;
    THU;
    FRI;
    SAT;
}

enum EMonths
{
    JANUARY;
    FEBRUARY;
    MARCH;
    APRIL;
    MAY;
    JUNE;  
    JULY;
    AUGUST;
    SEPTEMBER;
    OCTOBER;
    NOVEMBER;
    DECEMBER;
}

/**
 * 排列出2013年9月的日曆
 * var calendar:Array = Calendar.create(2013, 9);
 * 
 * 取出5日的資料
 * var date:CalendarDate = calendar[5];
 * @year: 2013
 * @month: 9
 * @day: 5
 * @week: 1,2,3..(第幾週)
 * @weekday: 0,1,2,3...6(星期日，一，二，三...六)
 * @holiday: 節日
 */
class Calendar {
	
	static public inline var NONE:Int = -1;
	static public inline var HOLI:Int = 7;
	static public inline var EQUINOX_SPRING:String = "春分";
	static public inline var EQUINOX_AUTUMN:String = "秋分";

	private static var year:UInt;
	private static var month:UInt;
	private static var first:UInt;
	private static var days:UInt;
	private static var calendarList:Map<String, Array<CalendarDate>> = new Map<String, Array<CalendarDate>>();
	private static var calendar:Array<CalendarDate>;
	private static var holidays:Map<String, String> = new Map<String, String>();
	private static var initialized:Bool = init();

	static public var months:Array<EMonths>;
	static public var weekdays:Array<EWeekDays>;

	public function new() {
	}

	private static function init():Bool {
		if (!initialized) initialize();
		return true;
	}
	
	private static function initialize():Void {
		weekdays = Type.allEnums(EWeekDays);
		months = Type.allEnums(EMonths);
		
		// holidays
		holidays.set("1"  + "1",  "元日");
		holidays.set("2"  + "28", "和平日");
		holidays.set("4"  + "4",  "兒童節");
		holidays.set("5"  + "1",  "勞動節");
		holidays.set("9"  + "28", "教師節");
		holidays.set("10" + "10", "國慶日");
		holidays.set("12" + "25", "聖誕節");
	}
	
	// create calendar maps
	public static function create(y:UInt, m:UInt):Array<CalendarDate> {
		year = y;
		month = m;
		if (year < 2009) return null;
		var monthID:String = "m" + year + ("0"+month).substr(-2);
		if (!calendarList.exists(monthID)) {
			calendarList.set(monthID,createDate());
		}
		return calendarList.get(monthID);
	}
	
	private static function createDate():Array<CalendarDate> {
		var last:Date = new Date(year, month, 0, 0, 0, 0);
		days = last.getDate();
		calendar = new Array<CalendarDate>();
		if (month == 3) equinoxSpring(year);
		if (month == 9) equinoxAutumn(year);
		for (n in 0...days) {
			var date:CalendarDate = new CalendarDate(year, month, n+1);
			var holiday:String = getHoliday(date);
			if (holiday != null) date.holiday = holiday;
			calendar[n+1] = date;
		}
		return calendar;
	}
	
	/**
	 * handle holiday
	 * holiday format: "1"+"1" 	"元旦"
	 * @param	date
	 * @return
	 */
	private static function getHoliday(date:CalendarDate):String {
		var holiday:String = holidays.get(Std.string(date.month) + Std.string(date.day));
		if (holiday != null) return holiday;
		return null;
	}
	
	// 春分・秋分
	private static function equinoxSpring(y:UInt):Void {
		var d:UInt = Math.floor(20.8431+0.242194*(y-1980)-Math.floor((y-1980)/4));
		holidays.set("3" + d, Calendar.EQUINOX_SPRING);
	}
	
	private static function equinoxAutumn(y:UInt):Void {
		var d:UInt = Math.floor(23.248 + 0.242194 * (y - 1980) - Math.floor((y - 1980) / 4));
		holidays.set("9"+d, Calendar.EQUINOX_AUTUMN);
	}

}
