//
//  NSDateFormatterManger.h
//  CJMobile
//
//  Created by wh15113030 on 16/3/21.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatterManger : NSObject



/**获取格式化NSDateFormatter对象*/
/**获取格式化NSDateFormatter对象*/
/**获取格式化NSDateFormatter对象*/



+(NSDateFormatter *)dateFormatter:(NSString *)formatter;

/**
 *  年月日yyyy_MM_dd
 *
 *  @return 年月日 字符串
 */
+ (NSString *)yyyy_MM_dd_CLocaltime:(NSDate *)date;


/**
 *  年月日yyyy_MM
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyy_MM_CLocaltime:(NSDate *)date;

/**
 *  年月日yyyy.MM
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyyMM_CLocaltime:(NSDate *)date;

/**
 *  年月日yyyy-MM-dd HH:mm
 *
 *  @return 年月 字符串
 */
+ (NSString *)yyyy_MM_dd_HH_mm_CLocaltime:(NSDate *)date;

/**
 *  年yyyy
 *
 *  @return 年 字符串
 */
+ (NSString *)yyyy_CLocaltime:(NSDate *)date;

/**
 *  月MM
 *
 *  @return 年 字符串
 */
+ (NSString *)mM_CLocaltime:(NSDate *)date;

/**
 *  日
 *
 *  @return 年 字符串
 */
+ (NSString *)dd_CLocaltime:(NSDate *)date;
@end
