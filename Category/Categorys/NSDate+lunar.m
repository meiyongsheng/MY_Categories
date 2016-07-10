//
//  NSDate+lunar.m
//  RCGJ
//
//  Created by kindy_imac on 11-12-2.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//







#import "NSDate+lunar.h"

NSString *arrLunarFestival[] =  { @"0101 春节", @"0115 元宵节", @"0505 端午节", @"0707 七夕",
    @"0815 中秋节", @"0909 重阳节", @"1208 腊八", @"1223 小年", @"0100 除夕" };

NSString *arrSolarFestival[] = { @"0101 元旦", @"0214 情人节",
    @"0308 妇女节", @"0401 愚人节",  @"0501 劳动节", @"0504 青年节",
    @"0601 儿童节", @"0701 建党节",  @"0801 建军节",@"1001 国庆节",
    @"1225 圣诞节"};

NSString *arrSolarTerm[] = { @"小寒", @"大寒", @"立春", @"雨水",
    @"惊蛰", @"春分", @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至", @"小暑", @"大暑", @"立秋",
    @"处暑", @"白露", @"秋分", @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至" };

long STermInfo[] = { 0, 21208, 42467, 63836, 85337,
    107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343,
    285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795,
    462224, 483532, 504758 };

NSString *wFev[] = { @"0521 母亲节", @"0631 父亲节" };// 每年6月第3个星期日是父亲节,5月的第2个星期日是母亲节

//extern    	arrLunarFestival;
@implementation NSDate(Festival)




//month，day：农历月日
+ (NSString *)getLunarFestival:(int)year month:(int)month day:(int)day
{
	NSString *strLunarFestival = nil;
	int count = sizeof(arrLunarFestival) / sizeof(arrLunarFestival[0]);
	for(int i = 0; i < count; i++)
	{
		NSString *t_str = arrLunarFestival[i];
		
		if([t_str intValue] == (month * 100 + day))
		{
			strLunarFestival = [t_str substringFromIndex:5];
	        break;
		}
	}
	return strLunarFestival;
}

//year, month, day :公历年月日
+ (NSString *)getSolarFestival:(int)year month:(int)month day:(int)day
{
	NSString *strSolarFestival = nil;
	int count = sizeof(arrSolarFestival) / sizeof(arrSolarFestival[0]);
	for(int i = 0; i < count; i++)
	{
		NSString *t_str = arrSolarFestival[i];
		if([t_str intValue] == (month * 100 + day))
		{
			strSolarFestival = [t_str substringFromIndex:5];
	        break;
		}
	}
	return strSolarFestival;
}

//year, month, day :阳历年月日
//获取节气
+(NSString	*)getSolarTerm:(int)year month:(int)m day:(int)d
{
	NSString *strSolarTerm = nil;
	
	if(d == [NSDate sTerm:year termIndex:(m - 1) * 2])
		strSolarTerm = arrSolarTerm[(m - 1) * 2];
	else if(d == [NSDate sTerm:year termIndex:(m - 1) * 2 + 1])
		strSolarTerm = arrSolarTerm[(m - 1) * 2 + 1];
	else {
		strSolarTerm = nil;
	}
	
	return strSolarTerm;
}

+ (NSString *)getWeekFestival:(int)year month:(int)month day:(int)day
{
	NSString *strWeekFestival = nil;
	int count = sizeof(wFev) / sizeof(wFev[0]);
	for(int i = 0; i < count; i++)
	{
		NSString *t_str = wFev[i];
		int t_month = [t_str intValue]  / 100;
		int t_weekIndex = [t_str intValue] % 100 / 10;
		int t_weekDay = [t_str intValue] % 10;
		
		//计算这个月的
		NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setYear:year];
		[components setMonth:t_month];
		[components setHour:4];
		//[components setWeek:t_weekIndex];
		[components setWeekdayOrdinal:t_weekIndex];//设置第几个星期
		[components setWeekday:t_weekDay];
		
		//目标日期
		NSDate *t_date = [calender dateFromComponents:components];
	    components = nil;
		components = [calender components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:t_date];
		
		int tt_month = [components month];
		int tt_day = [components day];
		
		if(month == tt_month && tt_day == day)
		{
			strWeekFestival = [t_str substringFromIndex:5];
		}
	}
	
	return strWeekFestival;
}

// ===== 某年的第n个节气为几日(从0小寒起算)
+(int)sTerm:(int)year termIndex:(int)termIndex
{
	
	//1900/1/6 02:05:00 小寒  
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];

	[components setYear:1900];
	[components setMonth:1];
	[components setDay:6];
	[components setHour:2];
	[components setMinute:5];
	[components setSecond:0];
	
	
	NSDate *t_date = [calender dateFromComponents:components];
	double timeInterval =(double) ([t_date timeIntervalSince1970]);
	
	double  t_interval = (double) ((31556925.9747 * (year - 1900)  + STermInfo[termIndex] * 60L)  + timeInterval);
	
	
	//CJLog(@"timeInterval = %f, t_interval = %f", timeInterval, t_interval);

	NSDate *tt_date = [NSDate dateWithTimeIntervalSince1970:(double)((double)t_interval) ];

	
	components = [calender components:NSDayCalendarUnit fromDate:tt_date];

	return [components day];
}

+(NSString	*)getFestival:(int)year month:(int)month day:(int)day   lunday:(LunarDay *)lunarDay
{
	//clm 2012-12-25+
	if(year < 1900 || year > 2050)
		return  nil;
	
	
	NSString *strFestival = [NSDate getSolarFestival:year month:month day:day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	strFestival = [NSDate getLunarFestival:lunarDay->year	month:lunarDay->month day:lunarDay->day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	strFestival = [NSDate getSolarTerm:year month:month day:day];
	if(strFestival.length >0)
	{
		return strFestival;
	}
	
	strFestival = [NSDate getWeekFestival:year month:month day:day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	
	//农历初几
	strFestival = [NSDate getChinaDayString:lunarDay->day];
	
	return strFestival;
}

+(NSString *)getFestival:(NSDate *)date
{
	if(date == nil)
		return nil;
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calender components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:date];

	
	int year = components.year;
	int month = components.month;
	int day = components.day;
	
	//阳历节日
	NSString *strFestival = [NSDate getSolarFestival:year month:month day:day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	LunarDay lunarDay_;
	memset(&lunarDay_, 0,sizeof(LunarDay));
    [NSDate traslateSolarToLunar:&lunarDay_ year:components.year month:components.month day:components.day];
	LunarDay *lunarDay = &lunarDay_;
	
	//农历节日
	strFestival = [NSDate getLunarFestival:lunarDay->year	month:lunarDay->month day:lunarDay->day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	//节气
	strFestival = [NSDate getSolarTerm:year month:month day:day];
	if(strFestival.length >0)
	{
		return strFestival;
	}
	
	//星期节日
	strFestival = [NSDate getWeekFestival:year month:month day:day];
	if(strFestival.length > 0)
	{
		return strFestival;
	}
	
	return strFestival;
}

+(NSDate *)dateFromString:(NSString *)dateString formatString:(NSString *)formatString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formatString];
	NSDate *t_date = [dateFormatter dateFromString:dateString];
	
	return t_date;
}

+(NSString *)getDayString:(NSDate *)date
{
	if(date == nil)
	{
		return  nil;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy_MM_dd"];
	NSString *sourceStr = [dateFormatter stringFromDate:date];
	NSString *strToday = [dateFormatter stringFromDate:[NSDate date]];
	
	if([sourceStr isEqualToString:strToday])
	{
		return  @"今天";
	}
	
	if([sourceStr isEqualToString:[dateFormatter stringFromDate:[[NSDate alloc] initWithTimeInterval:24 * 3600 sinceDate:[NSDate date]]]])
	{
		return  @"明天";
	}
	
	if([sourceStr isEqualToString:[dateFormatter stringFromDate:[[NSDate alloc] initWithTimeInterval:24 * 3600 * 2 sinceDate:[NSDate date]]]])
	{
		return  @"后天";
	}
	
	return  nil;
}

/*
+(NSString	*)getFestival:(int)month day:(int)day
{
	NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calender components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return [self getFestival:[components year] month:month day:day];
}
 */

@end
 



//-----------------------------------------------------------------------------------
//
//
// 农历 主要计算 农历日期
//
//
//-----------------------------------------------------------------------------------

NSString *arrAnimal[] =  { @"鼠", @"牛", @"虎", @"兔", @"龙", @"蛇",@"马", @"羊", @"猴", @"鸡", @"狗", @"猪" };
NSString *arrGan[] = { @"甲", @"乙", @"丙", @"丁", @"戊", @"己", @"庚", @"辛", @"壬", @"癸" };
NSString *arrZhi[] = { @"子", @"丑", @"寅", @"卯", @"辰", @"巳", @"午", @"未", @"申", @"酉", @"戌", @"亥" };
NSString *ArrChineseTen[] = { @"初", @"十", @"廿", @"卅" };
NSString *arrChineseNumber[] = { @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十", @"十一", @"十二" };
	
/*
 
 //clm
 从1900年开始 0x04bd8：是1900年的数据 8：代表1900年闰月是8月
 
 
 //各位bit的含义（从0开始算起）
  0~4:闰月的月份 
  4～ 16：分别代表12月份的大小 
  16:代表闰月是否是大月： 1：大月 0：小月

 */

//150年的数据
long lunarInfo[] = { 0x04bd8, 0x04ae0, 0x0a570,
	0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
	0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0,
	0x0ada2, 0x095b0, 0x14977, 0x04970, 0x0a4b0, 0x0b4b5, 0x06a50,
	0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970, 0x06566,
	0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0,
	0x1c8d7, 0x0c950, 0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4,
	0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557, 0x06ca0, 0x0b550,
	0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950,
	0x06aa0, 0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260,
	0x0f263, 0x0d950, 0x05b57, 0x056a0, 0x096d0, 0x04dd5, 0x04ad0,
	0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6,
	0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40,
	0x0af46, 0x0ab60, 0x09570, 0x04af5, 0x04970, 0x064b0, 0x074a3,
	0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0, 0x0c960,
	0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0,
	0x092d0, 0x0cab5, 0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9,
	0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930, 0x07954, 0x06aa0,
	0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65,
	0x0d530, 0x05aa0, 0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0,
	0x1d0b6, 0x0d250, 0x0d520, 0x0dd45, 0x0b5a0, 0x056d0, 0x055b2,
	0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0 };
	
	




@implementation NSDate(lunar)

//农历 y年的总天数
+ (int)yearDays:(int)y
{
	int i, sum = 348; // 12 * 29 每个月都是小月的话
	for (i = 0x8000; i > 0x8; i >>= 1) {
		if ((lunarInfo[y - 1900] & i) != 0)
			sum += 1;
	}
	return (sum + [NSDate leapDay:y]);
}

//农历 y年闰月的天数
+ (int)leapDay:(int)year
{
	if([NSDate leapMonth:year] != 0)
	{
		if((lunarInfo[year - 1900] & 0x10000) != 0)
			return 30;
		else {
			return 29;
		}
	}
	
	else
	{
		return 0;
	}
}

//农历 y年闰哪个月 1－12 没闰传回 0
+ (int)leapMonth:(int)year
{
	return (int)(lunarInfo[year - 1900] & 0xf);
}

//农历 y年m月的总天数 (农历只分大月和小月）
+ (int)monthDays:(int)year month:(int)m
{
	if((lunarInfo[year - 1900] & (0x10000 >> m)) == 0)
		return 29;
	else {
		return 30;
	}
}

//农历 y年的生肖
+ (NSString *)animalYear:(int)year
{
	return arrAnimal[(year - 4) % 12];
}

//====== 传入 year 与 1864的偏差d的offset 传回干支, 0=甲子

+ (NSString *)cyclicalm:(int)num
{
	int t_num = num;
	
	//天干地支 60年以循环
	if(num	 < 0)
	{
		t_num = 60 + num;
	}
	return [NSString stringWithFormat:@"%@%@", arrGan[t_num % 10], arrZhi[t_num	 % 12]];
}


//1864年1月0日十农历葵亥年，(注意1864年是甲子年） 所以用year减去1864 用10除得的余数作为年份天干的， 用12除得的余数作为年份的地支，
+ (NSString *)cyclical:(int)year
{
	return [NSDate  cyclicalm:year - 1864];
}

//获取农历 d天的名称
+ (NSString *)getChinaDayString:(int)day
{
	int n = day % 10 == 0 ? 9 : day % 10 -1;
	if(day > 30)
	{
		return nil;
	}
	
	if(day == 10)
	{
		return @"初十";
	}
	else if(day == 20) {
		return @"二十";
	}
	
	else if(day == 30) {
	 return @"三十";
	}

	else {
		return [NSString stringWithFormat:@"%@%@", ArrChineseTen[day / 10], arrChineseNumber[n]];
	}
}

//阳历转换成农历
+ (void)traslateSolarToLunar:(LunarDay *)lunarDay SolarDate:(NSDate *)solarDate
{
	
	//农历年月日
	int year=0; 
	int month =0;
	int day =0;
	BOOL leap = NO;
	
	int  /*yearCyl,*/ monCyl/*, dayCyl*/;
	int leapMonth = 0;
	
	
	NSCalendar *calender = [NSCalendar currentCalendar]; // [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
	[components setYear:1900];
	[components setMonth:1];
	[components setDay:31];
	[components setHour:1];
	[components setMinute:1];
	[components setSecond:1];

	
	NSDate  *baseDate = [calender dateFromComponents:components];
	//[calender release];
	

	//int offset = ([solarDate timeIntervalSince1970] - [baseDate timeIntervalSince1970]) / 86400l;
	//CJLog(@"%@, %@", solarDate, baseDate);
	//int offset = ([solarDate timeIntervalSinceDate:baseDate]) / 86400l;
	
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:baseDate toDate:solarDate options:0];
	int offset = comp.day;
	
//	CJLog(@"offset = %d %d", offset);
	//dayCyl = offset + 40;
	monCyl = 14;
	
	// 用offset减去每农历年的天数
	// 计算当天是农历第几天
	// i最终结果是农历的年份
	// offset是当年的第几天
	int iYear, daysOfYear = 0;
	for (iYear = 1900; iYear < 2050 && offset > 0; iYear++) {
		daysOfYear = [NSDate yearDays:iYear];
		offset -= daysOfYear;
		monCyl += 12;
	}
	if (offset < 0) {
		offset += daysOfYear;
		iYear--;
		monCyl -= 12;
	}
	
	// 农历年份
	year = iYear;
	//yearCyl = iYear - 1864;
	leapMonth = [NSDate leapMonth:iYear]; // 闰哪个月,1-12
	leap = false;
	
	
	// 用当年的天数offset,逐个减去每月（农历）的天数，求出当天是本月的第几天
	int iMonth, daysOfMonth = 0;
	for (iMonth = 1; iMonth < 13 && offset > 0; iMonth++) 
	{
		// 闰月
		if (leapMonth > 0 && iMonth == (leapMonth + 1) && !leap) {
			--iMonth;
			leap = true;
			daysOfMonth = [NSDate leapDay:year];
		} else
			daysOfMonth = [NSDate monthDays:year month:iMonth];
		
		offset -= daysOfMonth;
		// 解除闰月
		if (leap && iMonth == (leapMonth + 1))
			leap = false;
		if (!leap)
			monCyl++;
	}
	
	// offset为0时，并且刚才计算的月份是闰月，要校正
	if (offset == 0 && leapMonth > 0 && iMonth == leapMonth + 1) 
	{
		if (leap) {
			leap = false;
		} else {
			leap = true;
			--iMonth;
			--monCyl;
		}
	}
	// offset小于0时，也要校正
	if (offset < 0) {
		offset += daysOfMonth;
		--iMonth;
		--monCyl;
	}
	month = iMonth;
	day = offset + 1;
	
	lunarDay->year = year;
	lunarDay->month = month;
	lunarDay->day = day;
	lunarDay->leap = leap;
}

+ (void)traslateSolarToLunar:(LunarDay *)lunarDay year:(int)year month:(int)month day:(int)day
{
	NSCalendar *calender = [NSCalendar currentCalendar]; // [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]]; //设置成北京时区
	[components setYear:year];
	[components setMonth:month];
	[components setDay:day];
	[components setHour:1];
	[components setMinute:1];
	[components setSecond:1];

	NSDate *t_date = [calender dateFromComponents:components];
	
	//clm 2012-12-25+
	if(year < 1900 || year > 2050)
		return;
	
	[NSDate traslateSolarToLunar:lunarDay SolarDate:t_date];
}
@end


