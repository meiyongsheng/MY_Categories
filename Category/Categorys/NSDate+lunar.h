//
//  NSDate+lunar.h
//  RCGJ
//
//  Created by kindy_imac on 11-12-2.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDate+string.h"

typedef struct _LunarDay
{
	int year; //农历年
	int month;//农历月
	int day;//农历日
	int leap; //是否是闰年
}LunarDay;


@interface NSDate(Festival) 

//month，day：农历月日
+ (NSString *)getLunarFestival:(int)year month:(int)month day:(int)day;

//year, month, day :公历年月日
+ (NSString *)getSolarFestival:(int)year month:(int)month day:(int)day;


//year, month, day :阳历年月日
//获取节气
+(NSString	*)getSolarTerm:(int)year month:(int)month day:(int)day;


+ (NSString *)getWeekFestival:(int)year month:(int)month day:(int)day;

// ===== 某年的第n个节气为几日(从0小寒起算)
+(int)sTerm:(int)year termIndex:(int)termIndex;


//year , month ,day  公历， lunarday:农历
+(NSString	*)getFestival:(int)year month:(int)month day:(int)day  lunday:(LunarDay *)lunarDay;

+(NSString *)getFestival:(NSDate *)date;


+(NSDate *)dateFromString:(NSString *)dateString formatString:(NSString *)formatString;

//昨天今天明天
+(NSString *)getDayString:(NSDate *)date;
//



@end


//-----------------------------------------------------------------------------------
//
//
// 农历 主要计算 农历日期
//
//
//-----------------------------------------------------------------------------------
@interface NSDate(lunar)

//农历 y年的总天数
+ (int)yearDays:(int)year;

//农历 y年闰月的天数
+ (int)leapDay:(int)year;

//农历 y年闰哪个月 1－12 没闰传回 0
+ (int)leapMonth:(int)year;

//农历 y年m月的总天数
+ (int)monthDays:(int)year month:(int)month;

//农历 y年的生肖
+ (NSString *)animalYear:(int)year;

//====== 传入 月日的offset 传回干支, 0=甲子
+ (NSString *)cyclicalm:(int)num;

// 传入 offset 传回干支, 0=甲子
+ (NSString *)cyclical:(int)year;


//获取农历 d天的名称
+ (NSString *)getChinaDayString:(int)day;


//阳历转换成农历
+ (void)traslateSolarToLunar:(LunarDay *)lunarDay SolarDate:(NSDate *)solarDate;


+ (void)traslateSolarToLunar:(LunarDay *)lunarDay year:(int)year month:(int)month day:(int)day;


@end

