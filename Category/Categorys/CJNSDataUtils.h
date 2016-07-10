//
//  CJNSDataUtils.h
//  SOME
//
//  Created by Allen on 13-7-3.
//  Copyright (c) 2013年 zhouyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJNSDataUtils : NSObject

+ (NSString *)getCurrentSimpleDate;

+ (NSString *)getCurrentSimpleTime;

+ (NSString *)getCurrentDate;

+ (NSString *)getCurrentDateEx;

+ (NSString *)getCurrentDateExx;

+ (NSString *)getCurrentDateExxx;

+ (NSString *)getMsgDisplayDate:(NSString *)stringTime;

+ (NSString *)getMsgChatDisplayDate:(NSString *)stringTime;

+ (NSString *)getStringByDate:(NSDate *)date;

+ (BOOL)checkDateIsToday:(NSString *)stringTime;

+ (int)checkDate:(NSString *)stringTime;

+ (NSString *)getWeekDay;

+ (NSString *)getPrevMonth;

//从yyMMdd 转化为yy-MM-dd
+ (NSString *)changeDate:(NSString *)dateStr;


@end
