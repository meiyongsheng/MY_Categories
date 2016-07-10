//
//  PublicMethod.h
//  NIM
//
//  Created by WH-1512028 on 16/6/24.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PublicMethod : NSObject


/*!
 *       @brief 获取磁盘总空间
 *
 *       @return 磁盘总空间
 */
+ (CGFloat)diskOfAllSizeMByes;


/*!
 *       @brief 磁盘剩余空间
 *
 *       @return 磁盘剩余空间
 */

+ (CGFloat)diskOfFreeSizeMByes;


/*!
 *       @brief 获取文件大小
 *
 *       @param filePath
 *
 *       @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)filePath;



/*!
 *       @brief 获取文件夹下所有文件大小
 *
 *       @param folderPath 文件夹
 *
 *       @return 文件夹下所有文件大小
 */
+ (long long)folderSizeAtPath:(NSString *)folderPath;




/*!
 *       @brief 获取字符串（或汉字）首字母
 *
 *       @param string 字符串
 *
 *       @return 字符串（或汉字）首字母
 */
+ (NSString *)firstCharacterWithString:(NSString *)string;



/*!
 *       @brief 将字符串数组按照元素首字母顺序进行排序分组
 *
 *       @param array 字符串数组
 *
 *       @return 拍好序的字典
 */
+ (NSDictionary *)dictionaryOrderByCharactorWithOriginalArray:(NSArray *)array;



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
                    currentTimeFormat:(NSString *)format2;



/*!
 *       @brief 截取View生成一张图片
 *
 *       @param view View
 *
 *       @return 图片
 */
+ (UIImage *)shotWithView:(UIView *)view;



/*!
 *       @brief 截取View中某个区域生成一张图片
 *
 *       @param view  View
 *       @param scope View中某个区域
 *
 *       @return 图片
 */
+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope;



/*!
 *       @brief 压缩图片到指定尺寸大小
 *
 *       @param image 要压缩的图片
 *       @param size  要压缩的大小
 *
 *       @return      图片
 */
+ (UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size;


/*!
 *       @brief  压缩图片到指定文件大小
 *
 *       @param image 要压缩的图片
 *       @param size  要压缩的大小
 *
 *       @return data
 */
+ (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size;


/*!
 *       @brief 判断字符串是否含有某个字符串
 *
 *       @param string1 要判断是否存在的字符
 *       @param string2 要判断的字符
 *
 *       @return YES（存在）NO（不存在）
 */
+ (BOOL)isHaveString:(NSString *)string1 InString:(NSString *)string2;


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
                          lineColor:(UIColor *)color;


/*!
 *       @brief 获取设备IP地址
 *
 *       @return IP地址
 */
+ (NSString *)getIPAddress;
@end
