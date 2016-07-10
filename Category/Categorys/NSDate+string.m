//
//  NSDate+string.m
//  hbgj
//
//  Created by zhanglin on 12-8-29.
//
//

#import "NSDate+string.h"
#import "NSDate+lunar.h"


NSString *g_strXingqi[] = {
    @"星期日",
    @"星期一",
    @"星期二",
    @"星期三",
    @"星期四",
    @"星期五",
    @"星期六"
};

NSString *g_strZhou[] = {
	@"周日",
	@"周一",
	@"周二",
	@"周三",
	@"周四",
	@"周五",
	@"周六"
};






@implementation NSDate (ext_string)


- (NSString *) xingqiString {
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitWeekday|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    
    if ( comps.weekday > 0 && comps.weekday <= 7) {
        return g_strXingqi[comps.weekday-1];
    }
    else {
        return @"";
    }
}

- (NSString *) zhouString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitWeekday|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    if ( comps.weekday > 0 && comps.weekday <= 7) {
        return g_strZhou[comps.weekday-1];
    }
    else {
        return @"";
    }
}

- (NSString *)dayString {
    int days = [NSDate dayInterval:[NSDate date] endDate:self];
    if ( days==0 ) {
        return @"今天";
    }
    else if ( days==1 ) {
        return @"明天";
    }
    return nil;

}

+ (NSDate *) dateWithString:(NSString *)dateString format:(NSString *)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSDate *t_date = [dateFormatter dateFromString:dateString];
	return t_date;
}

- (NSString *)toMonthDayWeek {
	int year, month, day;
	ParseDate(self, &year, &month, &day);
    NSString *strDay = [NSDate getDayString:self];
	return [NSString stringWithFormat:@"%d月%d日 %@", month, day, strDay ? strDay : [self xingqiString]];
    
}

- (NSString *)toMonthDay {
	int year, month, day;
	ParseDate(self, &year, &month, &day);
	return [NSString stringWithFormat:@"%d月%d日", month, day];
}

- (NSString *)toYYYYMMDD
{
	int year, month, day;
	ParseDate(self, &year, &month, &day);
	return [NSString stringWithFormat:@"%04d%02d%02d", year, month, day];
}

- (NSString *)toYYYY_MM_DD {
	int year, month, day;
	ParseDate(self, &year, &month, &day);
	return [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];    
}


- (NSString *)toYYYYMMDDHHMMSS {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDataFormat_YYYYMMDDHHMMSS];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}
- (NSString *)toYYYYMMDDHHMMSSSSS
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDataFormat_YYYYMMDDHHMMSSSSS];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}

-(NSString *)toYYYY_MM_DD_HH_MM{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDateFormat_YYYY_MM_DD_HH_MM];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}

-(NSString *)toYYYY_MM_DD_HH_MM_SS_SSS{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDateFormat_YYYY_MM_DD_HH_MM_SS_SSS];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}

-(NSString *)toMM_SS{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDateFormat_MM_SS];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}

- (NSString *)toYYYY_MM_DD_HH_MM_SS
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kDataFormat_DateTime];
	NSString *str = [dateFormatter stringFromDate:self];
	
	return str;
}
//只比较日期上的大小
- (NSComparisonResult)compareDate:(NSDate *)anotherDate {
    NSString *str1 = [self toYYYYMMDD];
    NSString *str2 = [anotherDate toYYYYMMDD];
    return [str1 compare:str2];
}


+ (NSDate *)dateWithYYYYMMDD:(NSString *)strDate {
    if ( strDate.length!=8 )
		return nil;
	int n = [strDate intValue];
	int year = n/10000;
	int month = (n/100) % 100;
	int day = n % 100;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	NSDate *date = [calendar dateFromComponents:comps];
	
	return date;
}

+ (NSDate *)dateWithYYYYMMDDHHMMSS:(NSString *)strDate {
    if ( strDate.length != 14 ){
        return nil;
    }
    long long n = [strDate longLongValue];
    int year = n/10000000000;
    int month = (n/100000000) % 100;
    int day = (n / 1000000) % 100;
    int hour = (n / 10000) % 100;
    int minute = (n / 100) % 100;
    int second = n % 100;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    [comps setHour:hour];
    [comps setMinute:minute];
    [comps setSecond:second];
    NSDate *date = [calendar dateFromComponents:comps];
    
    return date;
}

+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate {
    
    NSArray *arr = [strDate componentsSeparatedByString:@"-"];
	if ( arr.count == 3 ) {
		int year = [[arr objectAtIndex:0] intValue];
		int month = [[arr objectAtIndex:1] intValue];
		int day = [[arr objectAtIndex:2] intValue];
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setYear:year];
		[comps setMonth:month];
		[comps setDay:day];
		NSDate *date = [calendar dateFromComponents:comps];
		
		return date;
	}
	return nil;
}

+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate HH_MM:(NSString *)strTime {
    if ( strTime.length == 0 ) {
        strTime = @"00:00";
    }
    
    NSArray *arrDate = [strDate componentsSeparatedByString:@"-"];
	NSArray *arrTime = [strTime componentsSeparatedByString:@":"];
    
	if ( arrDate.count == 3 && arrTime.count == 2) {
		int year = [[arrDate objectAtIndex:0] intValue];
		int month = [[arrDate objectAtIndex:1] intValue];
		int day = [[arrDate objectAtIndex:2] intValue];
		int hour = [[arrTime objectAtIndex:0] intValue];
		int min = [[arrTime objectAtIndex:1] intValue];
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[NSDateComponents alloc] init];
		[comps setYear:year];
		[comps setMonth:month];
		[comps setDay:day];
		[comps setHour:hour];
		[comps setMinute:min];
		NSDate *date = [calendar dateFromComponents:comps];
		
		return date;
	}
	return nil;
}



+ (NSDate *) dateWithBeijingTime:(NSString *)str {
    
    if ( str.length > 19 ) {
		str = [str substringToIndex:19];
	}
    
    return [NSDate dateWithString:str format:kDataFormat_DateTime];
}


- (NSString *) beijingTime {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:self];
	
	NSString *str = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
					 comps.year, comps.month, comps.day, comps.hour, comps.minute, comps.second];
	return str;
}



//标准化一个date， 将h=1 minute=0;second=0;
+ (NSDate *)formatDate:(NSDate *)sourceDate
{
	if(sourceDate == nil)
		return  nil;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:sourceDate];
	[comps setHour:1];
	[comps setMinute:0];
	[comps setSecond:0];
	NSDate *dateResult = [calendar dateFromComponents:comps];
	return  dateResult;
}


+ (int)dayInterval:(NSDate *)startDate endDate:(NSDate *)endDate
{
	if(startDate  == nil || endDate == nil)
		return 0;
	
	NSDate *sDate = [NSDate formatDate:startDate];
	NSDate *eDate = [NSDate formatDate:endDate];
	return (int)[eDate timeIntervalSinceDate:sDate] / (3600*24);
}


@end

 

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Utilities)


+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    NSDate *date = [calendar dateFromComponents:comps];
    
    return date;
}


- (NSString *)yyyymmdd {
    NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
	NSInteger year = comps.year;
	NSInteger month = comps.month;
	NSInteger day = comps.day;
    
    NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    
    return strDate;
}


#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return (([components1 year] == [components2 year]) &&
			([components1 month] == [components2 month]) &&
			([components1 day] == [components2 day]));
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if ([components1 week] != [components2 week]) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return ([components1 year] == [components2 year]);
}

- (BOOL) isThisYear
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 year] == ([components2 year] + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return ([components1 year] == ([components2 year] - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self earlierDate:aDate] == self);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self laterDate:aDate] == self);
}


#pragma mark Adjusting Dates

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
	return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
	return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
	return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
 
	
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *rDateStart = [formatter dateFromString :[NSString stringWithFormat:@"%04d-%02d-%02d", self.year, self.month, self.day]];
	NSDate *rDateEnd = [formatter dateFromString :[NSString stringWithFormat:@"%04d-%02d-%02d", aDate.year, aDate.month, aDate.day]];
	// return (int)[rDateEnd timeIntervalSinceDate:rDateStart] / (3600*24);
	
	NSTimeInterval ti = [rDateStart timeIntervalSinceDate:rDateEnd];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
	//NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return [aDate daysAfterDate: self  ];//(NSInteger) (ti / D_DAY);
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return [components hour];
}

- (NSInteger) hour
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components hour];
}

- (NSInteger) minute
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components minute];
}

- (NSInteger) seconds
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components second];
}

- (NSInteger) day
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components day];
}

- (NSInteger) month
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components month];
}

- (NSInteger) week
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components week];
}

- (NSInteger) weekday
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekday];
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekdayOrdinal];
}
- (NSInteger) year
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components year];
}
@end

void ParseDate(NSDate *date, int *year, int *month, int* day)
{
    *year = *month = *day = 0;
    if ( date ) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *comps = [calendar components:NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
        *year = comps.year;
        *month = comps.month;
        *day = comps.day;
    }
    
}

void ParseDateWeek(NSDate *date, int *year, int *month, int* day, int *week)
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps = [calendar components:NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit |NSWeekdayCalendarUnit fromDate:date];
	*year = comps.year;
	*month = comps.month;
	*day = comps.day;
	*week = comps.weekday;

}


