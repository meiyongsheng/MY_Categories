//
//  NSDate+Extension.m
//  CalendarTest1
//
//  Created by wh15113030 on 16/1/22.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

#import "NSDate+Extension.h"
#import "NSDateFormatterManger.h"


@implementation NSDate (Extension)

/**将时间转换为标准时间(正常时间有8个小时的时差)*/
- (NSDate *)transformDateByTimezone{
//    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:self];
    NSDate *localeDate = [self  dateByAddingTimeInterval: interval];
    return localeDate;
}

+ (NSDate *)transformDateByTimezone{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

/*计算这个月有多少天*/
- (NSUInteger)numberOfDaysInCurrentMonth
{
    // 频繁调用 [NSCalendar currentCalendar] 可能存在性能问题
    return [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length;
}


//获取这个月有多少周是周几
- (NSUInteger)numberOfWeeksInCurrentMonth
{
    //计算这个月的第一天
    NSUInteger weekday = [[self firstDayOfCurrentMonth] weeklyOrdinality];
    NSUInteger days = [self numberOfDaysInCurrentMonth];
    NSUInteger weeks = 0;
    
    if (weekday > 1) {
        weeks += 1, days -= (7 - weekday + 1);
    }
    
    weeks += days / 7;
    weeks += (days % 7 > 0) ? 1 : 0;
    
    return weeks;
}



/*根据对应的日期获取对应的星期几*/
- (NSUInteger)weeklyOrdinality
{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:self];
}


//计算这个月最开始的一天
- (NSDate *)firstDayOfCurrentMonth
{
    NSDate *startDate = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:self];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return startDate;
}

//获取这个月最开始的那天是星期几
- (NSUInteger)firstWeekOfCurrentMonth{
    
    NSLog(@"%@-------%s",[self firstDayOfCurrentMonth],__func__);
     NSLog(@"%ld-------%s",(unsigned long)[[self firstDayOfCurrentMonth] weeklyOrdinality],__func__);
 
    return [[self firstDayOfCurrentMonth] weeklyOrdinality];
    
}

//获取这个月的最后的一天
- (NSDate *)lastDayOfCurrentMonth
{
    NSCalendarUnit calendarUnit = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnit fromDate:self];
    dateComponents.day = [self numberOfDaysInCurrentMonth];
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

//上一个月
- (NSDate *)dayInThePreviousMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//下一个月
- (NSDate *)dayInTheFollowingMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//上一个星期
- (NSDate *)dayInThePreviousWeekDay
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.weekday -= 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//下一个星期
- (NSDate *)dayInTheFollowingWeekDay
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.weekday = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//上一年
- (NSDate *)dayInThePreviousYear{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year -= 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//下一年
- (NSDate *)dayInTheFollowingYear{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}


//获取当前日期之后的几个月
- (NSDate *)dayInTheFollowingMonth:(int)month
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = month;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSString *)toYYYY{
    NSDateFormatter *dateFormatter = [NSDateFormatterManger dateFormatter:@"yyyy"];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy"];
    
   return [dateFormatter stringFromDate:self];
}

- (NSString *)toMM{
    NSDateFormatter *dateFormatter = [NSDateFormatterManger dateFormatter:@"MM"];

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)toDD{
    NSDateFormatter *dateFormatter = [NSDateFormatterManger dateFormatter:@"dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)toYYYYMM{
    NSDateFormatter *dateFormatter = [NSDateFormatterManger dateFormatter:@"yyyy-MM"];

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)toHHmm{
    NSDateFormatter *dateFormatter = [NSDateFormatterManger dateFormatter:@"HH:mm"];

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm"];
    
    return [dateFormatter stringFromDate:self];
}


- (NSString *)toYYYYMMDDHHMM {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format_YYYYMMDDHHMM];
    NSString *str = [dateFormatter stringFromDate:self];
    
    return str;
}

- (NSString *)toHHMMSS {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format_Time];
    NSString *str = [dateFormatter stringFromDate:self];
    
    return str;
}

/**获取当前日期之后的几个星期*/ 
- (NSDate *)dayInTheFollowingWeek:(int)week
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.weekday = week;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//获取当前日期之后的几天
- (NSDate *)dayInTheFollowingDay:(int)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = day;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

//获取年月日对象
- (NSDateComponents *)YMDComponents
{
    return [[NSCalendar currentCalendar] components:
            NSYearCalendarUnit|
            NSMonthCalendarUnit|
            NSDayCalendarUnit|
            NSWeekdayCalendarUnit fromDate:self];
    
    
}


//-----------------------------------------
//
//NSString转NSDate
- (NSDate *)dateFromString:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}


//NSDate转NSString
- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}


+ (int)getDayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//日历控件对象
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:today toDate:beforday options:0];

    NSInteger day = [components day];//两个日历之间相差多少天//    NSInteger days = [components day];//两个之间相差几天
    return day;
}


//周日是“1”，周一是“2”...
-(int)getWeekIntValueWithDate
{
    int weekIntValue;
    
    //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps= [calendar components:(NSYearCalendarUnit |
                                                   NSMonthCalendarUnit |
                                                   NSDayCalendarUnit |
                                                   NSWeekdayCalendarUnit) fromDate:self];
    return weekIntValue = [comps weekday];
    
  
}




//判断日期是今天,明天,后天,周几
-(NSString *)compareIfTodayWithDate
{
    NSDate *todate = [NSDate date];//今天
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDateComponents *comps_today= [calendar components:(NSYearCalendarUnit |
                                                         NSMonthCalendarUnit |
                                                         NSDayCalendarUnit |
                                                         NSWeekdayCalendarUnit) fromDate:todate];
    
    
    NSDateComponents *comps_other= [calendar components:(NSYearCalendarUnit |
                                                         NSMonthCalendarUnit |
                                                         NSDayCalendarUnit |
                                                         NSWeekdayCalendarUnit) fromDate:self];
    
    
    //获取星期对应的数字
    int weekIntValue = [self getWeekIntValueWithDate];
    
    if (comps_today.year == comps_other.year &&
        comps_today.month == comps_other.month &&
        comps_today.day == comps_other.day) {
        return @"今天";
        
    }else if (comps_today.year == comps_other.year &&
              comps_today.month == comps_other.month &&
              (comps_today.day - comps_other.day) == -1){
        return @"明天";
        
    }else if (comps_today.year == comps_other.year &&
              comps_today.month == comps_other.month &&
              (comps_today.day - comps_other.day) == -2){
        return @"后天";
        
    }else{
        //直接返回当时日期的字符串(这里让它返回空)
        
        return [NSDate getWeekStringFromInteger:weekIntValue];//周几
    }
}



//通过数字返回星期几
+(NSString *)getWeekStringFromInteger:(int)week
{
    NSString *str_week;
    
    switch (week) {
        case 1:
            str_week = @"周日";
            break;
        case 2:
            str_week = @"周一";
            break;
        case 3:
            str_week = @"周二";
            break;
        case 4:
            str_week = @"周三";
            break;
        case 5:
            str_week = @"周四";
            break;
        case 6:
            str_week = @"周五";
            break;
        case 7:
            str_week = @"周六";
            break;
    }
    return str_week;
}

+ (int)getNumWeek:(NSDate *)oneDay otherDay:(NSDate *)otherDate{
    
   int interVal = [NSDate getDayNumbertoDay:oneDay beforDay:otherDate];
    
   int weekOne = [oneDay getWeekIntValueWithDate];
   int weekOther = [otherDate getWeekIntValueWithDate];
    int compareDay;
    if ([oneDay compare:otherDate]) {
        if (weekOne > weekOther) {
            compareDay = weekOne - weekOther;
            interVal = interVal - compareDay;
            interVal = interVal / 7;
            
        }else{
            compareDay = weekOne - weekOther;
            interVal = interVal + compareDay;
             interVal = interVal / 7;
        }
    }else{
    }
    return   interVal ;
}

- (NSDate *) dateWithDaysFromNow: (NSUInteger) days
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateTomorrow
{
    return [self dateWithDaysFromNow:1];
}

- (NSDate *) dateYesterday
{
    return [self dateWithDaysBeforeNow:1];
}

- (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}



@end
