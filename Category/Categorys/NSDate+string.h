//
//  NSDate+string.h
//  hbgj
//
//  Created by zhanglin on 12-8-29.
//
//

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

#define kDateFormat_YYYY_MM_DD_HH_MM_SS_SSS @"yyyy-MM-dd HH:mm:ss.SSS"
#define kDateFormat_MM_SS @"HH:mm"
#define kDateFormat_YYYY_MM_DD_HH_MM  @"yyyy-MM-dd HH:mm"
#define kDataFormat_DateTime       @"yyyy-MM-dd HH:mm:ss"
#define kDataFormat_Date           @"yyyy-MM-dd"
#define kDataFormat_Time           @"HH:mm:ss"
#define kDataFormat_YYYYMMDD        @"yyyyMMdd"
#define kDataFormat_YYYYMMDDHHMMSS  @"yyyyMMddHHmmss"
#define kDataFormat_YYYYMMDDHHMMSSSSS @"yyyyMMddHHmmssSSS"

@interface NSDate (ext_string)

- (NSString *) xingqiString;   //星期
- (NSString *) zhouString;  //周
- (NSString *) dayString;

+ (NSDate *) dateWithString:(NSString *)dateString format:(NSString *)format;

- (NSComparisonResult)compareDate:(NSDate *)anotherDate; //只比较日期上的大小

-(NSString *)toMonthDay;
- (NSString *)toMonthDayWeek;
- (NSString *)toYYYYMMDD;
- (NSString *)toYYYY_MM_DD;
- (NSString *)toYYYYMMDDHHMMSS;
- (NSString *)toYYYYMMDDHHMMSSSSS;
-(NSString *)toYYYY_MM_DD_HH_MM;
-(NSString *)toYYYY_MM_DD_HH_MM_SS_SSS;
-(NSString *)toMM_SS;
- (NSString *)toYYYY_MM_DD_HH_MM_SS;

+ (NSDate *)dateWithYYYYMMDD:(NSString *)strDate;
+ (NSDate *)dateWithYYYYMMDDHHMMSS:(NSString *)strDate;
+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate;
+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate HH_MM:(NSString *)strTime;

+ (NSDate *) dateWithBeijingTime:(NSString *)str;
- (NSString *) beijingTime;

//标准化一个date， 将h=1 minute=0;second=0;
+ (NSDate *)formatDate:(NSDate *)sourceDate;

//2个时间之间的天数间隔
+ (int)dayInterval:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
@interface NSDate (Utilities)

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;
- (NSString *)yyyymmdd;

// Relative dates from the current date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;
- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;
- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;

// Adjusting dates
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateAtStartOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;
@end

void ParseDate(NSDate *date, int *year, int *month, int* day);
void ParseDateWeek(NSDate *date, int *year, int *month, int* day, int *week);