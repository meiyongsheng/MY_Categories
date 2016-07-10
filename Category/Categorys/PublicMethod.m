//
//  PublicMethod.m
//  NIM
//
//  Created by WH-1512028 on 16/6/24.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "PublicMethod.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@implementation PublicMethod

/*!
 *       @brief 获取磁盘总空间
 *
 *       @return 磁盘总空间
 */
+ (CGFloat)diskOfAllSizeMByes{
    CGFloat size = 0.0;
    NSError *error;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"error: %@",error.localizedDescription);
#endif
    }else{
        NSNumber *number =[dic objectForKey:NSFileSystemSize];
        size = [number floatValue]/1024/1024;
    }
    return size;
}

/*!
 *       @brief 磁盘剩余空间
 *
 *       @return 磁盘剩余空间
 */

+ (CGFloat)diskOfFreeSizeMByes{
    CGFloat size = 0.0;
    NSError *error;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"error: %@",error.localizedDescription);
#endif
    }else{
        NSNumber *number =[dic objectForKey:NSFileSystemFreeSize];
        size = [number floatValue]/1024/1024;
    }
    return size;
}



/*!
 *       @brief 获取文件大小
 *
 *       @param filePath
 *
 *       @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)filePath{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return 0;
    }else{
        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
}



/*!
 *       @brief 获取文件夹下所有文件大小
 *
 *       @param folderPath 文件夹
 *
 *       @return 文件夹下所有文件大小
 */
+ (long long)folderSizeAtPath:(NSString *)folderPath{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        return 0;
    }else{
        NSEnumerator *fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
        NSString *fileName;
        long long  folderSize = 0.0;
        while ((fileName = [fileEnumerator nextObject]) != nil) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:filePath];
        }
        return folderSize;
    }
}



/*!
 *       @brief 获取字符串（或汉字）首字母
 *
 *       @param string 字符串
 *
 *       @return 字符串（或汉字）首字母
 */
+ (NSString *)firstCharacterWithString:(NSString *)string{
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString * pinyin =[str capitalizedString];
    return [pinyin substringToIndex:1];

}


/*!
 *       @brief 将字符串数组按照元素首字母顺序进行排序分组
 *
 *       @param array 字符串数组
 *
 *       @return 拍好序的字典
 */
+ (NSDictionary *)dictionaryOrderByCharactorWithOriginalArray:(NSArray *)array{
    if (!array.count) {
        return nil;
    }
    for (id obj in array) {
        if (![obj isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    UILocalizedIndexedCollation *indexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:indexedCollation.sectionTitles.count];
    //创建27个分组数组
    for (int i = 0 ; i < indexedCollation.sectionTitles.count; i++) {
        NSMutableArray *obj = [NSMutableArray array];
        [objects addObject:obj];
    }
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:objects.count];
    //按字母顺序进行分组
    NSInteger lastIndex = -1;
    for (int i = 0 ; i<array.count; i ++) {
        NSInteger  index = [indexedCollation sectionForObject:array[i] collationStringSelector:@selector(uppercaseString)];
        [[objects objectAtIndex:index] addObject:array[i]];
        lastIndex = index;
    }
    //去掉空数组
    for (int i = 0; i<objects.count; i++) {
        NSMutableArray *obj = objects[i];
        if (obj.count == 0) {
            [objects removeObject:obj];
        }
    }
    //获取索引字母
    for (NSMutableArray *obj in objects) {
        NSString *str = obj[0];
        NSString *key = [self firstCharacterWithString:str];
        [keys addObject:key];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:objects forKey:keys];
    return dic;
}

//获取当前时间
+ (NSString *)currentDateWithFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[NSDate date]];
}



/*!
 *       @brief 计算上次日期距离现在多久，如xx小时前、xx分钟前
 *
 *       @param lastTime    上次日期（需要和格式对应）
 *       @param format1     上次日期格式（yyyy年MM月dd日HH:mm）
 *       @param currentTime 当前日期（需要和格式对应）
 *       @param format2     上次日期格式（yyyy年MM月dd日HH:mm）
 *
 *       @return NSString（多久之前）
 */
+ (NSString *)timeintevalFromLastTime:(NSString *)lastTime
                      lastTimeFormat:(NSString *)format1
                       toCurrentTime:(NSString *)currentTime
                   currentTimeFormat:(NSString *)format2{
    //上次时间
    NSDateFormatter *dateFormattter1 = [[NSDateFormatter alloc] init];
    dateFormattter1.dateFormat = format1;
    NSDate *lastDate = [dateFormattter1 dateFromString:lastTime];
    //当前时间
    NSDateFormatter *dateFormattter2 = [[NSDateFormatter alloc] init];
    dateFormattter1.dateFormat = format2;
    NSDate *currentDate = [dateFormattter2 dateFromString:currentTime];
    return [self timeIntervalFromLastTime:lastDate toCurrentTime:currentDate];
}


+ (NSString *)timeIntervalFromLastTime:(NSDate *)lastTime toCurrentTime:(NSDate *)currentTime{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    //上次时间
    NSDate *lastDate = [lastTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:lastTime]];
    //当前时间
    NSDate *currentDate = [lastTime dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:currentTime]];
    //时间间隔
    NSInteger intevalTime = [currentDate timeIntervalSinceReferenceDate]-[lastDate timeIntervalSinceReferenceDate];
    //秒，分，小时，天，月，年
    NSInteger minutes = intevalTime/60;
    NSInteger hours = intevalTime/60;
    NSInteger day = intevalTime/60;
    NSInteger month = intevalTime/60;
    NSInteger year = intevalTime/60;
    if (minutes <= 10) {
        return @"刚刚";
    }else if (minutes < 60){
        return [NSString stringWithFormat:@"%ld分钟前",(long)minutes];
    }else if (hours <24){
        return [NSString stringWithFormat:@"%ld小时前",(long)minutes];
    }else if (day < 30){
        return [NSString stringWithFormat:@"%ld分钟前",(long)minutes];
    }else if (month < 12){
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"M月d日";
        NSString *time = [df stringFromDate:lastDate];
        return time;
    }else if (year >= 1){
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyy年M月d日";
        NSString *time = [df stringFromDate:lastDate];
        return time;
    } else{
    return @"";
    }
}


/*!
 *       @brief 截取View生成一张图片
 *
 *       @param view View
 *
 *       @return 图片
 */
+ (UIImage *)shotWithView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    return image;
}




/*!
 *       @brief 截取View中某个区域生成一张图片
 *
 *       @param view  View
 *       @param scope View中某个区域
 *
 *       @return 图片
 */
+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self shotWithView:view].CGImage, scope);
    UIGraphicsBeginImageContext(scope.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, scope.size.width, scope.size.height);
    CGContextTranslateCTM(context, 0, rect.size.height);//下移
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, rect, imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    CGContextRelease(context);
    return  image;
}



/*!
 *       @brief 压缩图片到指定尺寸大小
 *
 *       @param image 要压缩的图片
 *       @param size  要压缩的大小
 *
 *       @return      图片
 */
+ (UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage *resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsEndImageContext();
    return  resultImage;
}



/*!
 *       @brief  压缩图片到指定文件大小
 *
 *       @param image 要压缩的图片
 *       @param size  要压缩的大小
 *
 *       @return data
 */
+ (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    while (dataKBytes > size && maxQuality>0.01f) {
        maxQuality  = maxQuality-0.01f;
        data = UIImageJPEGRepresentation(image, maxQuality);
        dataKBytes = data.length/1000.0;
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    return data;
}



/*!
 *       @brief 判断字符串是否含有某个字符串
 *
 *       @param string1 要判断是否存在的字符
 *       @param string2 要判断的字符
 *
 *       @return YES（存在）NO（不存在）
 */
+ (BOOL)isHaveString:(NSString *)string1 InString:(NSString *)string2{
    NSRange range = [string2 rangeOfString:string1];
    if (range.location != NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}



/*!
 *       @brief 绘制虚线
 *
 *       @param lineFrame 虚线的Frame
 *       @param length    虚线的长度
 *       @param spacing   虚线中短线之间的距离
 *       @param color     虚线的颜色
 *
 *       @return view
 */

+ (UIView *)creatDasheLineWithFrame:(CGRect)lineFrame
                        lineLength:(float)length
                       lineSpacing:(float)spacing
                         lineColor:(UIColor *)color{
    UIView *dasheLine = [[UIView alloc]initWithFrame:lineFrame];
    dasheLine.backgroundColor = [UIColor clearColor];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:dasheLine.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(dasheLine.frame)/2, CGRectGetHeight(dasheLine.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:CGRectGetHeight(dasheLine.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:length],[NSNumber numberWithFloat:spacing], nil]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetWidth(dasheLine.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    [dasheLine.layer addSublayer:shapeLayer];
    return dasheLine;
}

/*!
 *       @brief 获取设备IP地址
 *
 *       @return IP地址
 */
+ (NSString *)getIPAddress{
NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
@end
