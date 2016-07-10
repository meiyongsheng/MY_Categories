//
//  NSDate+Extension.h
//  CalendarTest1
//
//  Created by wh15113030 on 16/1/22.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#define format_YYYYMMDDHHMM  @"yyyyMMddHHmm"
#define  format_Time           @"HH:mm:ss"

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
 
/**将时间转换为标准时间(正常时间有8个小时的时差)*/
- (NSDate *)transformDateByTimezone;
+ (NSDate *)transformDateByTimezone;

/*计算这个月有多少天*/
- (NSUInteger)numberOfDaysInCurrentMonth;

/**获取这个月有多少周*/
- (NSUInteger)numberOfWeeksInCurrentMonth;

/**根据对应的日期获取对应的星期几*/
- (NSUInteger)weeklyOrdinality;

/**计算这个月最开始的一天*/
- (NSDate *)firstDayOfCurrentMonth;

/**获取这个月最开始的那天是星期几*/
- (NSUInteger)firstWeekOfCurrentMonth;

/**获取这个月最后的一天*/
- (NSDate *)lastDayOfCurrentMonth;

/**上个月*/
- (NSDate *)dayInThePreviousMonth;

/**下个月*/
- (NSDate *)dayInTheFollowingMonth;

/**上个星期*/
- (NSDate *)dayInThePreviousWeekDay;

/**下个星期*/
- (NSDate *)dayInTheFollowingWeekDay;

/**上年*/
- (NSDate *)dayInThePreviousYear;

/**下年*/
- (NSDate *)dayInTheFollowingYear;
/**获取当前日期之后的几个月*/

- (NSDate *)dayInTheFollowingMonth:(int)month;

/**获取当前日期之后的几个星期*/
- (NSDate *)dayInTheFollowingWeek:(int)week;

/**获取当前日期之后的几个天*/
- (NSDate *)dayInTheFollowingDay:(int)day;

/**获取年月日对象*/
- (NSDateComponents *)YMDComponents;

/**NSString转NSDate*/
- (NSDate *)dateFromString:(NSString *)dateString;

/**NSDate转NSString*/
- (NSString *)stringFromDate:(NSDate *)date;

/**两个日历之间相差几天*/
+ (int)getDayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;
+ (int)getNumWeek:(NSDate *)oneDay otherDay:(NSDate *)otherDate;
/**判断今天是周几*/
-(int)getWeekIntValueWithDate;

/**判断日期是今天,明天,后天,周几*/
-(NSString *)compareIfTodayWithDate;

/**通过数字返回星期几*/
+(NSString *)getWeekStringFromInteger:(int)week;

- (NSString *)toYYYYMMDDHHMM;
/**转换成  时分秒   */
- (NSString *)toHHMMSS;

- (NSString *)toYYYY;
- (NSString *)toMM;
- (NSString *)toDD;
- (NSString *)toYYYYMM;
- (NSString *)toHHmm;

- (NSDate *) dateTomorrow;
- (NSDate *) dateYesterday;
- (NSDate *) dateWithDaysFromNow: (NSUInteger) days;
- (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days;
- (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours;
- (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours;
- (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes;
- (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes;


@end
