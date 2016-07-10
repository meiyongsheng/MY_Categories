//
//  CJNSDataUtils.m
//  SOME
//
//  Created by Allen on 13-7-3.
//  Copyright (c) 2013年 zhouyu. All rights reserved.
//

#import "CJNSDataUtils.h"

@implementation CJNSDataUtils

+ (NSString *)getCurrentSimpleDate
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat : @"yyyyMMdd"];
    
    return [formatter stringFromDate:dateNow];
}

+ (NSString *)getCurrentSimpleTime
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat : @"HH:mm:ss"];
    
    return [formatter stringFromDate:dateNow];
}

+ (NSString *)getCurrentDate
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    /*
     NSTimeZone *timeZone = [NSTimeZone localTimeZone];
     
     [formatter setTimeZone:timeZone];
     */
    [formatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:dateNow];
}
+ (NSString *)getPrevMonth
{
    NSCalendar *localCalendar = [NSCalendar currentCalendar];
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    NSDate *date = [localCalendar dateByAddingComponents:comps toDate:currentDate  options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    NSString *result = [formatter stringFromDate:date];
    return result;
}

+ (NSString *)getCurrentDateEx
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    /*
     NSTimeZone *timeZone = [NSTimeZone localTimeZone];
     
     [formatter setTimeZone:timeZone];
     */
    [formatter setDateFormat : @"yyyy年MM月dd日-HH:mm"];
    
    return [formatter stringFromDate:dateNow];
}
+ (NSString *)getCurrentDateExx
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat : @"yyyy-MM-dd"];
    
    return [formatter stringFromDate:dateNow];
}

+ (NSString *)getCurrentDateExxx
{
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat : @"yyyy-MM-dd cccc HH:mm:ss"];
    
    return [formatter stringFromDate:dateNow];
}

+ (NSString *)getWeekDay
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"cccc"];
    
    return  [format stringFromDate:[NSDate date]];
}


+ (NSString *)getMsgDisplayDate:(NSString *)stringTime
{
    /*
     NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
     
     NSTimeZone *timeZone = [NSTimeZone localTimeZone];
     
     [formatter setTimeZone:timeZone];
     
     [formatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
     
     NSDate *dateTime = [formatter dateFromString:stringTime];
     
     NSDate *dateNow = [NSDate date];
     
     NSTimeInterval secondsBetweenDates= [dateNow timeIntervalSinceDate:dateTime];
     
     CJLog(@"secondsBetweenDates=  %lf",secondsBetweenDates);
     
     if (secondsBetweenDates > 0.0)
     {
     if (secondsBetweenDates < 86400.0)
     {
     NSRange rang = NSMakeRange(11, 5);
     
     return [stringTime substringWithRange:rang];
     
     }
     else if (secondsBetweenDates < 2 *86400.0)
     {
     return @"昨天";
     }
     else
     {
     NSRange rang = NSMakeRange(0, 10);
     
     return [stringTime substringWithRange:rang];
     
     }
     
     }
     
     NSRange rang = NSMakeRange(0, 10);
     
     return [stringTime substringWithRange:rang];
     */
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *fromdate=[format dateFromString:stringTime];
    
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    
    //CJLog(@"fromdate=%@",fromDate);
    
    
    NSDate *date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    //CJLog(@"enddate=%@",localeDate);
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];
    
    NSInteger months = [components month];
    
    NSInteger days = [components day];  //年[components year]
    
    //NSInteger hour = [components hour];
    
    //CJLog(@"month=%d",months);
    //CJLog(@"days=%d",days);
    //CJLog(@"hour=%d",hour);
    
    
    if (months==0&&days==0) {
        
        return [[stringTime substringFromIndex:11] substringToIndex:5];
        
    }else if(months==0&&days==1){
        
        return @"昨天";
        
    }else{
        
        return [stringTime substringToIndex:10];
    }
    
}

+ (NSString *)getMsgChatDisplayDate:(NSString *)stringTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    /*
     NSTimeZone *timeZone = [NSTimeZone localTimeZone];
     
     [formatter setTimeZone:timeZone];
     */
    [formatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateTime = [formatter dateFromString:stringTime];
    
    [formatter setDateFormat : @"yyyy年MM月dd日-HH:mm"];
    
    return [formatter stringFromDate:dateTime];
}

+ (NSString *)getStringByDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return [NSString stringWithFormat:@"%04d%02d%02d",comps.year,comps.month,comps.day];
}

//是今天则返回YES ，否则返回NO
+ (BOOL)checkDateIsToday:(NSString *)stringTime
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *fromdate = [format dateFromString:stringTime];
    //CJLog(@"%@",fromdate);
    
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *endDateString = [format stringFromDate:[NSDate date]];
    NSDate *endDate = [format dateFromString:endDateString];
    //CJLog(@"%@",endDate);
    
    NSTimeInterval interval = [fromdate timeIntervalSinceDate:endDate];
    
    return interval >=0 ? YES : NO;
}

//判断时间是今天还是昨天，还是以前。今天 返回0，昨天返回1，以前返回2
+ (int)checkDate:(NSString *)stringTime
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *fromdate = [format dateFromString:stringTime];
//    [stringTime autorelease];
    //CJLog(@"%@",fromdate);
    
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *endDateString = [format stringFromDate:[NSDate date]];
    NSDate *endDate = [format dateFromString:endDateString];//今天0点的时间
    //CJLog(@"%@",endDate);
    
    NSDate *endDate2 = [endDate dateByAddingTimeInterval:(-1)*60*60*24];//昨天0点的时间
    
    if ([fromdate timeIntervalSinceDate:endDate2]>=0) {
        if ([fromdate timeIntervalSinceDate:endDate] >=0) {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 2;
    }
}

//从yyMMdd 转化为yy-MM-dd cccc
+ (NSString *)changeDate:(NSString *)dateStr
{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *date = [format dateFromString:dateStr];
    [format setDateFormat:@"yyyy-MM-dd cccc"];
    NSString *resultString = [format stringFromDate:date];
    
    return resultString;
}


@end
