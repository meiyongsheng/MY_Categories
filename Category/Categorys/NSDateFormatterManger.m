//
//  NSDateFormatterManger.m
//  CJMobile
//
//  Created by wh15113030 on 16/3/21.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import "NSDateFormatterManger.h"
static NSMutableDictionary *dateFormatterDict;
@implementation NSDateFormatterManger


+(NSDateFormatter *)dateFormatter:(NSString *)formatter{
    if (!dateFormatterDict) {
        dateFormatterDict = [NSMutableDictionary dictionary];
    }
    __block NSDateFormatter *dateFormatter;
    if (dateFormatterDict) {
        
        [dateFormatterDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDateFormatter *obj, BOOL * _Nonnull stop) {
            if ([obj.dateFormat isEqualToString:formatter]) {
                dateFormatter = obj;
                 *stop = YES;
            }
        }];
        
    }
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:formatter];
        [dateFormatterDict setObject:dateFormatter forKey:dateFormatter];
    }
    
    return dateFormatter;
    
}

/**
 *  年月日yyyy_MM_dd
 *
 *  @return 年月日 字符串
 */
+ (NSString *)yyyy_MM_dd_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%d-%02d-%02d", cTime->tm_year + 1900, cTime->tm_mon + 1, cTime->tm_mday];
    return dateAsString;
}


/**
 *  年月日yyyy_MM
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyy_MM_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%d-%02d", cTime->tm_year + 1900, cTime->tm_mon + 1];
    return dateAsString;
}


/**
 *  年月日yyyy.MM
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyyMM_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%d.%02d", cTime->tm_year + 1900, cTime->tm_mon + 1];
    return dateAsString;
}

/**
 *  年月日yyyy-MM-dd HH:mm
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyy_MM_dd_HH_mm_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
     NSString *dateAsString = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d", cTime->tm_year + 1900, cTime->tm_mon + 1, cTime->tm_mday,cTime->tm_hour,cTime->tm_min];
    return dateAsString;
}

/**
 *  年yyyy
 *
 *  @return 年 字符串
 */
+ (NSString *)yyyy_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%d", cTime->tm_year + 1900];
    return dateAsString;
}

/**
 *  月MM
 *
 *  @return 年 字符串
 */
+ (NSString *)mM_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%02d", cTime->tm_mon + 1];
    return dateAsString;
}

/**
 *  日
 *
 *  @return 年 字符串
 */
+ (NSString *)dd_CLocaltime:(NSDate *)date
{
    time_t timeInterval = date.timeIntervalSince1970;
    struct tm *cTime = localtime(&timeInterval);
    NSString *dateAsString = [NSString stringWithFormat:@"%02d", cTime->tm_mday];
    return dateAsString;
}

@end
