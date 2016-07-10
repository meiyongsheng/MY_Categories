//
//  NSDate+Format.m
//  CJMobile
//
//  Created by 徐飞 on 15/4/7.
//  Copyright (c) 2015年 zhouyu. All rights reserved.
//

#import "NSDate+Format.h"

@implementation  NSDate (Format)


+(NSString *)prettyDateWithReference:(NSDate *)reference {
    NSString *suffix = @"前";
    
    float different = [reference timeIntervalSinceDate:[NSDate new]];
    if (different < 0) {
        different = -different;
        suffix = @"前";
    }
    
    // days = different / (24 * 60 * 60), take the floor value
    float dayDifferent = floor(different / 86400);
    
    int days   = (int)dayDifferent;
    int weeks  = (int)ceil(dayDifferent / 7);
    int months = (int)ceil(dayDifferent / 30);
    int years  = (int)ceil(dayDifferent / 365);
    
    // It belongs to today
    if (dayDifferent <= 0) {
        // lower than 60 seconds
        if (different < 60) {
            return @"1分钟内";
        }
        
        // lower than 120 seconds => one minute and lower than 60 seconds
        if (different < 120) {
            return [NSString stringWithFormat:@"1分钟%@", suffix];
        }
        
        
        // lower than 60 minutes
        if (different < 66 * 60) {
            return [NSString stringWithFormat:@"%d 分钟 %@", (int)floor(different / 60), suffix];
        }
        
        // lower than 60 * 2 minutes => one hour and lower than 60 minutes
        if (different < 7200) {
            return [NSString stringWithFormat:@"1 小时 %@", suffix];
        }
        
        // lower than one day
        if (different < 86400) {
            return [NSString stringWithFormat:@"%d 小时 %@", (int)floor(different / 3600), suffix];
        }
    }
    // lower than one week
    else if (days < 7) {
        return [NSString stringWithFormat:@"%d 天%@ %@", days, days == 1 ? @"" : @"", suffix];
    }
    // lager than one week but lower than a month
    else if (weeks < 4) {
        return [NSString stringWithFormat:@"%d 星期%@ %@", weeks, weeks == 1 ? @"" : @"", suffix];
    }
    // lager than a month and lower than a year
    else if (months < 12) {
        return [NSString stringWithFormat:@"%d 月%@ %@", months, months == 1 ? @"" : @"", suffix];
    }
    // lager than a year
    else {
        return [NSString stringWithFormat:@"%d 年%@ %@", years, years == 1 ? @"" : @"", suffix];
    }
    
    return @"无";
}

@end
