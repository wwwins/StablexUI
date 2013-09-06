package ru.stablex.ui.widgets;

import flash.events.Event;
import flash.events.MouseEvent;
import ru.stablex.ui.date.Calendar;
import ru.stablex.ui.date.CalendarDate;


/**
* Simple calendar widget.
*
*/
class Calendars extends ru.stablex.ui.widgets.Widget{

	public var dayWidth:UInt = 60;
	public var dayHeight:UInt = 44;
	
	private var max:UInt = 37;
	private var hHeight:UInt = 55;
	private var wHeight:UInt = 20;

	public var year:UInt;
	public var month:UInt;
	public var todayDate:String;

	private var calendar:Array<CalendarDate>;	
	private var dayList:Array<StateButton>;
	
	private var panelText:Text;
	
	//widget, wich will contain panel
	public var panel:Box;

	/**
	* If you need to do something in constructor, here is how it's done.
	*
	*/
	public function new () : Void {
		super();

		// today
		todayDate = DateTools.format(Date.now(), "%Y%m%d");

		// move to onInitialize
		//initDays();
		// move to onCreate
		//setToday();
	}//function new()

	private function initDays():Void {
		dayList = new Array<StateButton>();
		var day:StateButton;
		for (n in 0...max) {
			day = UIBuilder.create(StateButton, {
				defaults:'Default',
				w:dayWidth,
				h:dayHeight,
				left:((dayWidth + 1) * (n % 7) + 1),
				top:((dayHeight + 1) * Math.floor(n / 7) + hHeight + wHeight + 2),
				order:["none", "sun", "sat", "holiday", "now"]
			});

			day.states.sun.skinName = 'SunColor';
			day.states.sat.skinName = 'SatColor';
			day.states.none.skinName = 'NoneColor';
			day.states.now.skinName = 'NowColor';
			day.states.holiday.skinName = 'HolidayColor';
			
			day.onInitialize();
			day.onCreate();
			
			dayList.push(day);

			this.addChild(day);
		}
	}
	
	/**
	 * create title: Sun--Mon--Tue--Wed--Thu--Fri--Sat
	 */
	private function createTitle():Void {
		var weekdays = Calendar.weekdays;

		var base:Text;
		for (n in 0...weekdays.length) {
			base = UIBuilder.create(Text, {
				defaults:'Default,H6',
				text:Std.string(weekdays[n]),
				mouseEnabled:false,
				mouseChildren:false,
				w:dayWidth,
				h:wHeight,
				left:(dayWidth + 1) * n + 1,
				top: hHeight + 1,
				align:'center,middle',
				skinName:'GrayBox'
			});
			addChild(base);
		}
	}
	
	private function createPanel():Void {
		this.panel = UIBuilder.create(Box, {
			widthPt    : 100,
			autoHeight : true,
			vertical   : false,
			align      : 'center,bottom',
			skinName   : 'WhiteBox'
		});
		this.addChild(this.panel);
		
		var btnPrev:Button = UIBuilder.create(Button, { 
				text:"<<<"
			} );
			btnPrev.addUniqueListener(MouseEvent.CLICK, handlePrev);

			
		panelText = UIBuilder.create(Text, { 
				defaults:'Default',
				text:"2013年9月",
				mouseEnabled:false,
				mouseChildren:false
			} );
			
		var btnNext:Button = UIBuilder.create(Button, { 
				text:">>>"
			} );
		btnNext.addUniqueListener(MouseEvent.CLICK, handleNext);
		
		panel.addChild(btnPrev);
		panel.addChild(panelText);
		panel.addChild(btnNext);
		panel.refresh();
	}
	
	private function handlePrev(e:MouseEvent):Void 
	{
		prevMonth();
		panelText.text = toString();
	}

	private function handleNext(e:MouseEvent):Void 
	{
		nextMonth();
		panelText.text = toString();
	}
	
	private function showDay(day:StateButton, d:CalendarDate = null, now:Bool = false):Void {
		day.visible = true;
		var date:CalendarDate = d;
		var type:Int = Calendar.NONE;
		var holiday = null;
		if (date != null) {
			type = date.weekday;
			holiday = date.holiday;
		}
		if (holiday != null) type = Calendar.HOLI;
		switch (type) {
			case 0 :
				day.set("sun");
			case 6 :
				day.set("sat");
			case 7 :
				day.set("holiday");
			case -1 :
				day.set("none");
			default :
				day.set("none");
		}
		if (now)
			day.set("now");
		if (date != null && date.day > 0) day.text = Std.string(date.day);
	}
	
	private function manage(y:UInt, m:UInt):Void {
		year += y;
		month += m;
		if (month > 12) {
			year += 1;
			month = 1;
		}
		if (month < 1) {
			year -= 1;
			month = 12;
		}
		create(year, month);
	}
	
	public function prevYear():Void {
		manage(-1, 0);
	}

	public function prevMonth():Void {
		manage(0, -1);
	}

	public function setToday():Void {
		year = Date.now().getFullYear();
		month = Date.now().getMonth() + 1;

		create(year, month);
	}
	
	public function nextMonth():Void {
		manage(0, 1);
	}
	
	public function nextYear():Void {
		manage(1, 0);
	}
	
	/**
	 * 
	 * @param	year
	 * @param	month
	 */
	public function create(year:UInt, month:UInt) 
	{
		trace("now:"+year+"/"+month);
		calendar = Calendar.create(year, month);
		
		// 2013年9月3日: CalendarDate = calendar[3];
		var first:UInt = calendar[1].weekday; // 2013年9月1日
		//trace("星期" + first);

		var d:Int;
		var day:StateButton;
		var date:CalendarDate;
		
		for (n in 0...max) 
		{
			d = n - first + 1;
			day = dayList[n];
			day.visible = false;
			if (d > 0) {
				date = calendar[d];
				if (date != null)
				{
					if (date.toString() == todayDate) {
						showDay(day, date, true);
					}
					else {
						showDay(day, date);
					}
				}
			}
		}
	}
	
	override public function toString():String {
		return year + "年" + month + "月";
	}	

	/**
	 * On initialization is complete
	 */
	override public function onInitialize() : Void {
		super.onInitialize();
		// 如果有指定年月
		if (year == 0)
			year = Date.now().getFullYear();
		if (month == 0)
			month = Date.now().getMonth() + 1;
		initDays();
		createTitle();
		createPanel();
	}
	
	/**
	 * On creation is complete, make first tab active
	 */
	override public function onCreate() : Void { 
		super.onCreate();
		create(year, month);
	}

	/**
	* This function is called at least once - on widget creation is complete.
	*/
	override public function refresh () : Void {
		super.refresh();
	}

}