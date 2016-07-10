//
//  NSString+Util.h
//  maopao
//
//  Created by Cewei Shi on 11-2-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// 登录名验证：4到15位，数字或英文
#define REG_LOGINNAME_STR   @"^[A-Za-z0-9]{4,15}+$"
// 真实姓名验证：汉字
#define REG_NICKNAME_STR    @"^[u4e00-u9fa5],{0,}$"
// 密码验证：6到15位数字和英文
#define REG_PASSWORD_STR    @"^[A-Za-z0-9]{6,15}+$"
// 邮箱验证
#define REG_MAIL_STR        @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"
// 手机号码验证
//#define REG_PHONENUM_STR    @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9]))\\d{8}$"
#define REG_PHONENUM_STR    @"^(1)\\d{10}$"
// 身份证验证：15或18位
#define REG_IDCARDNUM_STR   @"^(\\d{14}|\\d{17})(\\d|[xX])$"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString(Char)
//获取字符串（或汉字）首字母
- (NSString *)firstCharacterWithString;

@end


@interface NSString(MPUtil)
- (NSString *)base64String;
- (NSString *)urlencodeString;
- (NSString *)md5String; //MD5加密
- (NSString *)AES128EncryptWithKey:(NSString *)key;
- (NSString *)AES128DecryptWithKey:(NSString *)key;
- (NSString *)OrderOnlineEncryptWithUid:(NSString *)uid;
- (NSString *)OrderOnlineDecryptWithUid:(NSString *)uid;
- (NSString *)AES128CEncryptWithKey:(NSString *)key;
- (NSString *)AES128CDecryptWithKey:(NSString *)key;
- (NSString *)encryptWithKey:(NSString *)key ;
- (NSData *)AES128DecryptToDataWithKey:(NSString *)key;
+ (NSString *)guidString;
@end


@interface NSString(MyDraw)

- (CGSize)drawAtPoint_:(CGPoint)point
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
			  fontSize:(CGFloat)fontSize
		 lineBreakMode:(NSLineBreakMode)lineBreakMode
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;

- (CGSize)drawAtPoint_:(CGPoint)point
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
		 lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)drawAtPoint_:(CGPoint)point
              forWidth:(CGFloat)width
              withFont:(UIFont *)font
           minFontSize:(CGFloat)minFontSize
        actualFontSize:(CGFloat *)actualFontSize
         lineBreakMode:(NSLineBreakMode)lineBreakMode
    baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;

- (CGSize)drawAtPoint_:(CGPoint)point withFont:(UIFont *)font;

- (CGSize)drawInRect_:(CGRect)rect
             withFont:(UIFont *)font;

- (CGSize)drawInRect_:(CGRect)rect
             withFont:(UIFont *)font
        lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)drawInRect_:(CGRect)rect
             withFont:(UIFont *)font
        lineBreakMode:(NSLineBreakMode)lineBreakMode
            alignment:(NSTextAlignment)alignment;

- (CGSize)_drawAtPoint:(CGPoint)point
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
			  fontSize:(CGFloat)fontSize
		 lineBreakMode:(NSLineBreakMode)lineBreakMode
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;

- (CGSize)_drawAtPoint:(CGPoint)point
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
		 lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)_drawAtPoint:(CGPoint)point
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
		   minFontSize:(CGFloat)minFontSize
		actualFontSize:(CGFloat *)actualFontSize
		 lineBreakMode:(NSLineBreakMode)lineBreakMode
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment;

- (CGSize)_drawAtPoint:(CGPoint)point withFont:(UIFont *)font;

- (CGSize)_drawInRect:(CGRect)rect
			 withFont:(UIFont *)font;

- (CGSize)_drawInRect:(CGRect)rect
			 withFont:(UIFont *)font
		lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)_drawInRect:(CGRect)rect
			 withFont:(UIFont *)font
		lineBreakMode:(NSLineBreakMode)lineBreakMode
			alignment:(NSTextAlignment)alignment;

@end


@interface NSString(DrawMid)
- (CGSize)drawInRect_mid:(CGRect)rect withFont:(UIFont *)font;
- (CGSize)drawInRect_mid:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

- (CGSize)drawInRect_Bottom:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;
@end



@interface NSString (MobileVerification)
//判断手机号长度11位
+ (BOOL)verificationMobileLength:(NSString *)mobile;
// 手机号
+ (BOOL)verificationMobile:(NSString *)mobile;
// 邮箱
+ (BOOL)validateEmail:(NSString *)email;
// 密码
+ (BOOL)verificationPwd:(NSString *)pwd;
// 云康号  英文字母开头，只含有英文字母、数字和下划线
+ (BOOL)verificationKXID:(NSString *)kxID;
////验证身份证号
//+(BOOL)verificationIDcard:(NSString *)isIDcard;
//身份证校验
+ (BOOL)validateIDCardNumber:(NSString *)value;
+ (BOOL)verificationMobile1:(NSString *)mobile1;//手机验证
+ (BOOL)verificationTel:(NSString *)tel;//电话验证
// 真实姓名验证：汉字
+(BOOL)IsChinese:(NSString *)str;
//校验英文或汉字名字
+ (BOOL)isEnglishLetterOrChinese:(NSString *)str;
//空字符串验证
+(BOOL) isEmpty:(NSString *) str;

@end






//正则表达式 clm + 3.6.5
@interface NSString(RegularEx)
- (NSString *)stringByMatching:(NSString *)pattern;
#if 0
- (BOOL)validateForPattern:(NSString *)pattern;
- (BOOL)validateForPhone;
- (BOOL)validateForPasswd;
- (BOOL)validateForNickName;
#endif
@end;