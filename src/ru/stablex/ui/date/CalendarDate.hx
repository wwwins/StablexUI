package ru.stablex.ui.date;

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
class CalendarDate {
	private var _year:UInt;
	private var _month:UInt;
	private var _day:UInt;
	private var _week:UInt;
	private var _weekday:UInt;
	private var _holiday:String;

	/**
	 * 日期
	 * @param	y:year
	 * @param	m:month
	 * @param	d:day
	 */
	public function new(y:UInt, m:UInt, d:UInt) {
		_year = y;
		_month = m;
		_day = d;
		init();
	}

	private function init():Void {
		_week = Math.floor((_day - 1) / 7) + 1;
		var date:Date = new Date(year, month - 1, day, 0, 0, 0);
		_weekday = date.getDay();
	}
	
	// getter/setter
	public var year(get_year, null):UInt;
	function get_year():UInt { return _year; }

	public var month(get_month, null):UInt;
	function get_month():UInt { return _month; }

	public var day(get_day, null):UInt;
	function get_day():UInt { return _day; }

	public var week(get_week, null):UInt;
	function get_week():UInt { return _week; }

	public var weekday(get_weekday, null):UInt;
	function get_weekday():UInt { return _weekday; }

	public var holiday(get_holiday, set_holiday):String;
	function get_holiday():String { return _holiday; }
	function set_holiday(value:String):String { return _holiday = value; }

	public function toString():String {
		return _year + ("0" + _month).substr(-2) + ("0" + _day).substr(-2);
	}

}
