//
//  NSString+Util.m
//  maopao
//
//  Created by Cewei Shi on 11-2-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Extension.h"
#include "base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "aes.h"
#define kShowDow 1
#define kShadow 0
#define kOrderOnlineKey @"$@()^Yj&J>xeu?:N"


#define RGBA(r,g,b,a)   [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
//定义常用的字符串函数
#define ZYIsNullOrEmpty(str)            ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1)

@implementation NSString(Char)
//获取字符串（或汉字）首字母
- (NSString *)firstCharacterWithString{
    NSMutableString *str = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString * pinyin =[str capitalizedString];
    return [pinyin substringToIndex:1];
}
@end


@implementation NSString(MPUtil)

- (NSString *)base64String{
	const char *szUtf8 = [self UTF8String];
	if ( szUtf8 ) {
		char szBase64[2048];
		memset( szBase64, 0, sizeof(szBase64) );
		Base64Encode( szBase64, (const unsigned char*)szUtf8, strlen(szUtf8) );
		NSString *strBase64 = [NSString stringWithUTF8String:szBase64];
		return strBase64;
	}
	return nil;
}

- (NSString *)urlencodeString {
	
	NSString *strUrlencode =  [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	strUrlencode = [strUrlencode stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	strUrlencode = [strUrlencode stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	return strUrlencode;
}

- (NSString *)md5String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([data bytes], [data length], result); 
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}



- (NSString *)encryptWithKey:(NSString *)key {
	if (key == nil) {
		return @"";
	}
	int lenKey = key.length;
    
	//1.明文转换为utf8
	const char *szUtf8 = [self UTF8String];
	char szPlainText[2048];
	memset(szPlainText, 0, sizeof(szPlainText));
	
	if ( szUtf8 ) {
		Base64Encode( szPlainText, (const unsigned char*)szUtf8, strlen(szUtf8) );
	}
    //	strcpy(szPlainText, szUtf8);
	int lenPlainText = strlen(szPlainText);
	if ( lenPlainText==0 ) {
		return @"";
	}
	
	//2.初始化key的table
	char letters[] = "abcdefghijklmnopqrstuvwxyz";
	char table[26][26];
	for (int i = 0; i < 26; i++) {
		for (int j = 0; j < 26; j++) {
			int index = (i + j) % 26;
			table[i][j] = letters[index];
		}
	}
	
	//3.加密转换
	for (int i = 0; i < lenPlainText; i++) {
		char chKey = (char)[key characterAtIndex:(i % lenKey)];
		char chText = szPlainText[i];
		int row = -1;
		int column = -1;
		
		if ( chKey >='a' && chKey <= 'z' ) {
			row = chKey - 'a';
		}
        
        
		if ( chText >= 'a' && chText <= 'z' ) {
			column = chText - 'a';
		}
        
        
		if (column == -1 || row == -1) {
			//szPlainText[i] 不变 
		} else {
			szPlainText[i] = table[row][column];
		}
	}
	
	//转换为NSString输出
	NSString *strBase64 = [NSString stringWithUTF8String:szPlainText];
	return strBase64;
}



- (NSString *)AES128EncryptWithKey:(NSString *)key {
    
    //设置key字符串 --> szKey
    char szKey[kCCKeySizeAES128+1];
    bzero(szKey, sizeof(szKey));
    const char *utf8Key = [key UTF8String];
    strncpy(szKey, utf8Key, kCCKeySizeAES128);

    //设置明文字符串 --> szPlainText
    const char *szPlainText = [self UTF8String];
    NSUInteger lenPlainText = strlen(szPlainText);

    
    //分配密文数据 --> szEncryptData
    size_t lenEncryptData = lenPlainText + kCCBlockSizeAES128;
    void *szEncryptData = malloc(lenEncryptData);

    //加密
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          szKey, kCCKeySizeAES128,
                                          NULL,
                                          szPlainText, lenPlainText,
                                          szEncryptData, lenEncryptData,
                                          &numBytesEncrypted);
	
 
    if (cryptStatus == kCCSuccess) {
        //分配Base64字符串  -> base64Text
        size_t lenBase64Text = numBytesEncrypted * 2 + 128;
        char *szBase64Text = malloc(lenBase64Text);
        memset( szBase64Text, 0, lenBase64Text );
	
#if 0
		//测试
		for (int i = 0; i < numBytesEncrypted; ++i ) {
			printf("%d ,",*((char *)szEncryptData + i));
		}
#endif

		
        //生成base64
		Base64Encode( szBase64Text, (const unsigned char*)szEncryptData, numBytesEncrypted );
		NSString *strBase64Text = [NSString stringWithUTF8String:szBase64Text];

        
        free(szBase64Text);
        free(szEncryptData);
        
        return strBase64Text;
        
//      return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(szEncryptData);
    return nil;
}



- (NSString *)AES128DecryptWithKey:(NSString *)key {

    //设置key字符串 --> szKey
    char szKey[kCCKeySizeAES128+1];
    bzero(szKey, sizeof(szKey));
    const char *utf8Key = [key UTF8String];
    strncpy(szKey, utf8Key, kCCKeySizeAES128);

    //self --> szBase64Text
    const char *szBase64Text = [self UTF8String];
    
    //szBase64Text --> szEncryptData
    size_t lenEncryptData = strlen(szBase64Text);
    unsigned char *szEncryptData = (unsigned char *)malloc(lenEncryptData);
    int lenEncryptBytes = Base64Decode(szEncryptData, szBase64Text);


    //创建szPlainText
    size_t lenPlainText = lenEncryptBytes + kCCBlockSizeAES128;
    char *szPlainText = (char *)malloc(lenPlainText+1);
    memset(szPlainText, 0, lenPlainText+1);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          szKey, kCCKeySizeAES128,
                                          NULL,
                                          szEncryptData, lenEncryptBytes,
                                          szPlainText, lenPlainText,
                                          &numBytesDecrypted);
    
    NSString *strPlainText = nil;
    if (cryptStatus == kCCSuccess) {
        strPlainText = [NSString stringWithCString:szPlainText encoding:NSUTF8StringEncoding];
    }
    
    free(szEncryptData);
    free(szPlainText);
    return strPlainText;
}

- (NSData *)AES128DecryptToDataWithKey:(NSString *)key {
    //设置key字符串 --> szKey
    char szKey[kCCKeySizeAES128+1];
    bzero(szKey, sizeof(szKey));
    const char *utf8Key = [key UTF8String];
    strncpy(szKey, utf8Key, kCCKeySizeAES128);
    
    //self --> szBase64Text
    const char *szBase64Text = [self UTF8String];
    
    //szBase64Text --> szEncryptData
    size_t lenEncryptData = strlen(szBase64Text);
    unsigned char *szEncryptData = (unsigned char *)malloc(lenEncryptData);
    int lenEncryptBytes = Base64Decode(szEncryptData, szBase64Text);
    
    
    //创建szPlainText
    size_t lenPlainText = lenEncryptBytes + kCCBlockSizeAES128;
    char *szPlainText = (char *)malloc(lenPlainText+1);
    memset(szPlainText, 0, lenPlainText+1);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          szKey, kCCKeySizeAES128,
                                          NULL,
                                          szEncryptData, lenEncryptBytes,
                                          szPlainText, lenPlainText,
                                          &numBytesDecrypted);
    
    NSData *plainData = nil;
    if (cryptStatus == kCCSuccess) {
        plainData = [NSData dataWithBytes:szPlainText length:numBytesDecrypted];
    }
    
    free(szEncryptData);
    free(szPlainText);
    return plainData;
}


- (NSString *)OrderOnlineEncryptWithUid:(NSString *)uid {
    NSString *key = kOrderOnlineKey;
    if ( [uid length] > 5 ) {
        uid = [uid substringFromIndex:[uid length]-5];
    }
    key = [NSString stringWithFormat:@"%@%@", uid, key];
    key = [key substringToIndex:16];
	
    
    NSString *strSystemVersion = [[UIDevice currentDevice] systemVersion];
    if ( [strSystemVersion compare:@"4.2"] == NSOrderedAscending ) {
        return [self AES128CEncryptWithKey:key];
    }
    else {
        return [self AES128EncryptWithKey:key];
    }
}


- (NSString *)OrderOnlineDecryptWithUid:(NSString *)uid {
    NSString *key = kOrderOnlineKey;
    if ( [uid length] > 5 ) {
        uid = [uid substringFromIndex:[uid length]-5];
    }
    key = [NSString stringWithFormat:@"%@%@", uid, key];
    key = [key substringToIndex:16];
    
    NSString *strSystemVersion = [[UIDevice currentDevice] systemVersion];
    if ( [strSystemVersion compare:@"4.2"] == NSOrderedAscending ) {
        return [self AES128CDecryptWithKey:key];
    }
    else {
        return [self AES128DecryptWithKey:key];
    }

}



typedef struct{
	DWORD		ErrorCode;
	BYTE		Message[32];
} ERROR_MESSAGE;

ERROR_MESSAGE	ErrorMessage[] = {
	{CTR_FATAL_ERROR,		"CTR_FATAL_ERROR"},
	{CTR_INVALID_USERKEYLEN,"CTR_INVALID_USERKEYLEN"},
	{CTR_PAD_CHECK_ERROR,	"CTR_PAD_CHECK_ERROR"},
	{CTR_DATA_LEN_ERROR,	"CTR_DATA_LEN_ERROR"},
	{CTR_CIPHER_LEN_ERROR,	"CTR_CIPHER_LEN_ERROR"},
	{0, ""},
};
void	Error(
              DWORD	ErrorCode,
              char	*Message);
void	Error(
              DWORD	ErrorCode,
              char	*Message)
{
	DWORD	i;
    
	for( i=0; ErrorMessage[i].ErrorCode!=0; i++)
		if( ErrorMessage[i].ErrorCode==ErrorCode )	break;
    
	printf("ERROR(%s) :::: %s\n", ErrorMessage[i].Message, Message);
}

- (NSString *)AES128CEncryptWithKey:(NSString *)key {
    
    AES_ALG_INFO	AlgInfo;
    RET_VAL	ret;
    
    //设置key字符串 --> szKey
    unsigned char szKey[kCCKeySizeAES128+1];
    bzero(szKey, sizeof(szKey));
    const char *utf8Key = [key UTF8String];
    memcpy(szKey, utf8Key, kCCKeySizeAES128);

    //设置明文字符串 --> szPlainText
    const char *szPlainText = [self UTF8String];
    NSUInteger lenPlainText = strlen(szPlainText);
    
    
    //分配密文数据 --> szEncryptData
    size_t lenEncryptData = lenPlainText + kCCBlockSizeAES128;
    unsigned char *szEncryptData = malloc(lenEncryptData);

    do {
        AES_SetAlgInfo(AI_ECB, AI_PKCS_PADDING, NULL, &AlgInfo);
        ret = AES_EncKeySchedule(szKey, kCCKeySizeAES128, &AlgInfo);
        if ( ret!=CTR_SUCCESS ) {
            Error(ret, "AES_EncKeySchedule() returns.");
            break;
        }
        
        ret = AES_EncInit(&AlgInfo);
        if( ret!=CTR_SUCCESS ){
            Error(ret, "AES_EncInit() returns.");
            break;
        }
        
        unsigned int nEncryptUpdateLen = lenEncryptData;
        ret = AES_EncUpdate(&AlgInfo, (unsigned char*)szPlainText, lenPlainText, szEncryptData, &nEncryptUpdateLen);
        if( ret!=CTR_SUCCESS || nEncryptUpdateLen>lenEncryptData ){
            Error(ret, "AES_EncUpdate() returns.");
            break;
        }
        
        unsigned int nEncryptFinalLen = lenEncryptData - nEncryptUpdateLen;
        ret = AES_EncFinal(&AlgInfo, szEncryptData+nEncryptUpdateLen, &nEncryptFinalLen);
		if( ret!=CTR_SUCCESS || (nEncryptUpdateLen+nEncryptFinalLen)>lenEncryptData ){
            Error(ret, "AES_EncFinal() returns."); 
            break;
        }
        
        unsigned int numBytesEncrypted = nEncryptUpdateLen + nEncryptFinalLen;
        
        size_t lenBase64Text = numBytesEncrypted * 2 + 128;
        char *szBase64Text = malloc(lenBase64Text);
        memset( szBase64Text, 0, lenBase64Text );
        
        //生成base64
		Base64Encode( szBase64Text, (const unsigned char*)szEncryptData, numBytesEncrypted );
		NSString *strBase64Text = [NSString stringWithUTF8String:szBase64Text];
        
        
        free(szBase64Text);
        free(szEncryptData);
        
        return strBase64Text;
        
    } while (0);
    

    free(szEncryptData);
    return nil;
}

- (NSString *)AES128CDecryptWithKey:(NSString *)key{
    AES_ALG_INFO	AlgInfo;
    RET_VAL	ret;
    
    //设置key字符串 --> szKey
    unsigned char szKey[kCCKeySizeAES128+1];
    bzero(szKey, sizeof(szKey));
    const char *utf8Key = [key UTF8String];
    memcpy(szKey, utf8Key, kCCKeySizeAES128);
    
    //self --> szBase64Text
    const char *szBase64Text = [self UTF8String];
    
    //szBase64Text --> szEncryptData
    size_t lenEncryptData = strlen(szBase64Text);
    unsigned char *szEncryptData = (unsigned char *)malloc(lenEncryptData);
    int lenEncryptBytes = Base64Decode(szEncryptData, szBase64Text);
    
    
    //创建szPlainText
    size_t lenPlainText = lenEncryptBytes + kCCBlockSizeAES128;
    unsigned char *szPlainText = (unsigned char *)malloc(lenPlainText+1);
    memset(szPlainText, 0, lenPlainText+1);

    
    do {
        AES_SetAlgInfo(AI_ECB, AI_PKCS_PADDING, NULL, &AlgInfo);
        ret = AES_DecKeySchedule(szKey, kCCKeySizeAES128, &AlgInfo);
        if ( ret!=CTR_SUCCESS ) {
            Error(ret, "AES_DecKeySchedule() returns.");
            break;
        }
        
        ret = AES_DecInit(&AlgInfo);
        if( ret!=CTR_SUCCESS ){
            Error(ret, "AES_DecInit() returns.");
            break;
        }
        
        unsigned int nDecryptUpdateLen = lenPlainText;
        ret = AES_DecUpdate(&AlgInfo, szEncryptData, lenEncryptBytes, szPlainText, &nDecryptUpdateLen);
        if( ret!=CTR_SUCCESS || nDecryptUpdateLen>lenPlainText ){
            Error(ret, "AES_DecUpdate() returns.");
            break;
        }
        
        unsigned int nDecryptFinalLen = lenPlainText - nDecryptUpdateLen;
        ret = AES_DecFinal(&AlgInfo, szPlainText+nDecryptUpdateLen, &nDecryptFinalLen);
		if( ret!=CTR_SUCCESS || (nDecryptUpdateLen+nDecryptFinalLen)>lenPlainText ){
            Error(ret, "AES_DecFinal() returns."); 
            break;
        }
        szPlainText[nDecryptUpdateLen+nDecryptFinalLen] = '\0';
        
        NSString *strPlainText = [NSString stringWithCString:(char *)szPlainText encoding:NSUTF8StringEncoding];
        
        free(szEncryptData);
        free(szPlainText);
        
        return strPlainText;
        
    } while (0);
    
    
    free(szEncryptData);
    free(szPlainText);
    return nil;

}
+ (NSString *)guidString {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * guid = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    return guid;
}
 
@end



@implementation NSString(MyDraw)


- (CGSize)drawAtPoint_:(CGPoint)point 
			  forWidth:(CGFloat)width 
			  withFont:(UIFont *)font 
			  fontSize:(CGFloat)fontSize 
		 lineBreakMode:(NSLineBreakMode)lineBreakMode 
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
    [RGBA(0xff,0xff,0xff,0.6) set];
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[self drawAtPoint:pt 
			 forWidth:width 
			 withFont:font 
			 fontSize:fontSize 
		lineBreakMode:lineBreakMode 
   baselineAdjustment:baselineAdjustment];
	
	CGContextRestoreGState(context) ;
    return	[self drawAtPoint:point 
                    forWidth:width 
                    withFont:font 
                    fontSize:fontSize 
               lineBreakMode:lineBreakMode 
          baselineAdjustment:baselineAdjustment];
	
	
	
}

- (CGSize)drawAtPoint_:(CGPoint)point 
			  forWidth:(CGFloat)width 
			  withFont:(UIFont *)font
		 lineBreakMode:(NSLineBreakMode)lineBreakMode{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawAtPoint:pt 
			 forWidth:width 
			 withFont:font
		lineBreakMode:lineBreakMode];
	CGContextRestoreGState(context);
	
    return	[self drawAtPoint:point
                    forWidth:width 
                    withFont:font
               lineBreakMode:lineBreakMode];
}


- (CGSize)drawAtPoint_:(CGPoint)point 
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
		   minFontSize:(CGFloat)minFontSize
		actualFontSize:(CGFloat *)actualFontSize 
		 lineBreakMode:(NSLineBreakMode)lineBreakMode 
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawAtPoint:pt 
			 forWidth:width
			 withFont:font
		  minFontSize:minFontSize
	   actualFontSize:actualFontSize 
		lineBreakMode:lineBreakMode 
   baselineAdjustment:baselineAdjustment];
	
    CGContextRestoreGState(context);
	return 	[self drawAtPoint:point 
					 forWidth:width
					 withFont:font
				  minFontSize:minFontSize
			   actualFontSize:actualFontSize 
				lineBreakMode:lineBreakMode 
		   baselineAdjustment:baselineAdjustment];
    
	
}

- (CGSize)drawAtPoint_:(CGPoint)point withFont:(UIFont *)font{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawAtPoint:pt withFont:font];
	
	CGContextRestoreGState(context);
	return  	[self drawAtPoint:point withFont:font];
	
	
	
}

- (CGSize)drawInRect_:(CGRect)rect 
			 withFont:(UIFont *)font{
    CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawInRect: rc withFont:font];
	
    CGContextRestoreGState(context);
	return [self drawInRect: rect withFont:font];
	
	
	
	
	
}

- (CGSize)drawInRect_:(CGRect)rect
			 withFont:(UIFont *)font 
		lineBreakMode:(NSLineBreakMode)lineBreakMode{
    CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawInRect:rc
			withFont:font
	   lineBreakMode:lineBreakMode];
	
    CGContextRestoreGState(context);
    return [self drawInRect:rect
				   withFont:font
			  lineBreakMode:lineBreakMode];
    
	
	
}


- (CGSize)drawInRect_:(CGRect)rect 
			 withFont:(UIFont *)font
		lineBreakMode:(NSLineBreakMode)lineBreakMode
			alignment:(NSTextAlignment)alignment{
    CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0xff,0xff,0xff,0.6) set];
	[self drawInRect:rc 
			withFont:font
	   lineBreakMode:lineBreakMode
		   alignment:alignment];
	
    CGContextRestoreGState(context);
    return	[self drawInRect:rect 
                   withFont:font
              lineBreakMode:lineBreakMode
                  alignment:alignment];
	
    
    
}





///黑色背景
- (CGSize)_drawAtPoint:(CGPoint)point 
			  forWidth:(CGFloat)width 
			  withFont:(UIFont *)font 
			  fontSize:(CGFloat)fontSize 
		 lineBreakMode:(NSLineBreakMode)lineBreakMode 
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	[RGBA(0,0,0,0.60) set];
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[self drawAtPoint:pt 
			 forWidth:width 
			 withFont:font 
			 fontSize:fontSize 
		lineBreakMode:lineBreakMode 
   baselineAdjustment:baselineAdjustment];
	
	CGContextRestoreGState(context) ;
	return	[self drawAtPoint:point 
					forWidth:width 
					withFont:font 
					fontSize:fontSize 
			   lineBreakMode:lineBreakMode 
		  baselineAdjustment:baselineAdjustment];
	
	
	
}

- (CGSize)_drawAtPoint:(CGPoint)point 
			  forWidth:(CGFloat)width 
			  withFont:(UIFont *)font
		 lineBreakMode:(NSLineBreakMode)lineBreakMode{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawAtPoint:pt 
			 forWidth:width 
			 withFont:font
		lineBreakMode:lineBreakMode];
	CGContextRestoreGState(context);
	
	return	[self drawAtPoint:point
					forWidth:width 
					withFont:font
			   lineBreakMode:lineBreakMode];
}

- (CGSize)_drawAtPoint:(CGPoint)point 
			  forWidth:(CGFloat)width
			  withFont:(UIFont *)font
		   minFontSize:(CGFloat)minFontSize
		actualFontSize:(CGFloat *)actualFontSize 
		 lineBreakMode:(NSLineBreakMode)lineBreakMode 
	baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawAtPoint:pt 
			 forWidth:width
			 withFont:font
		  minFontSize:minFontSize
	   actualFontSize:actualFontSize 
		lineBreakMode:lineBreakMode 
   baselineAdjustment:baselineAdjustment];
	
	CGContextRestoreGState(context);
	return 	[self drawAtPoint:point 
					 forWidth:width
					 withFont:font
				  minFontSize:minFontSize
			   actualFontSize:actualFontSize 
				lineBreakMode:lineBreakMode 
		   baselineAdjustment:baselineAdjustment];
	
	
}

- (CGSize)_drawAtPoint:(CGPoint)point withFont:(UIFont *)font{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint pt=point;
	pt.x+=kShadow,pt.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawAtPoint:pt withFont:font];
	
	CGContextRestoreGState(context);
	return  [self drawAtPoint:point withFont:font];
	
	
	
}

- (CGSize)_drawInRect:(CGRect)rect 
			 withFont:(UIFont *)font{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawInRect: rc withFont:font];
	
	CGContextRestoreGState(context);
	return [self drawInRect: rect withFont:font];
	
	
	
	
	
}

- (CGSize)_drawInRect:(CGRect)rect
			 withFont:(UIFont *)font 
		lineBreakMode:(NSLineBreakMode)lineBreakMode{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawInRect:rc
			withFont:font
	   lineBreakMode:lineBreakMode];
	
	CGContextRestoreGState(context);
	return [self drawInRect:rect
				   withFont:font
			  lineBreakMode:lineBreakMode];
	
	
	
}


- (CGSize)_drawInRect:(CGRect)rect 
			 withFont:(UIFont *)font
		lineBreakMode:(NSLineBreakMode)lineBreakMode
			alignment:(NSTextAlignment)alignment{
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGRect rc=rect;
	rc.origin.x+=kShadow,rc.origin.y+=kShowDow;
	[RGBA(0,0,0,0.60) set];
	[self drawInRect:rc 
			withFont:font
	   lineBreakMode:lineBreakMode
		   alignment:alignment];
	
	CGContextRestoreGState(context);
	return	[self drawInRect:rect 
				   withFont:font
			  lineBreakMode:lineBreakMode
				  alignment:alignment];
	
	
	
}

@end


 

@implementation NSString(DrawMid)
- (CGSize)drawInRect_mid:(CGRect)rect withFont:(UIFont *)font{
	CGSize sz = [self  sizeWithFont: font constrainedToSize:rect.size];
	
	if (sz.width<=rect.size.width ) { //只有一行 那么就居中
		
		rect.origin.y += (rect.size.height - sz.height)/2;
	}
	
	[self drawInRect:rect withFont:font lineBreakMode:0 alignment:NSTextAlignmentCenter];
	return sz;
}

- (CGSize)drawInRect_mid:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment{
	CGSize sz = [self sizeWithFont:font constrainedToSize:rect.size lineBreakMode:lineBreakMode];
	if (sz.width<=rect.size.width ) { //只有一行 那么就居中
		rect.origin.y += (rect.size.height - sz.height)/2;
	}
	[self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
	
	return sz;
}


- (CGSize)drawInRect_Bottom:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment{
	CGSize sz = [self sizeWithFont:font constrainedToSize:rect.size lineBreakMode:lineBreakMode];
	if (sz.height < rect.size.height) {
		rect.origin.y += (rect.size.height - sz.height);
	}
	[self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
//	[self drawAtPoint:rect.origin forWidth:rect.size.width withFont:font fontSize:font.pointSize lineBreakMode:UILineBreakModeCharacterWrap baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	return sz;
}
@end


@implementation NSString(RegularEx)

- (NSString *)stringByMatching:(NSString *)pattern
{
	if(self == nil || self.length == 0)
	{
		return  nil;
	}
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];
	NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	
	if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
		NSString *substringForFirstMatch = [self substringWithRange:rangeOfFirstMatch];
		return substringForFirstMatch;
	}

	return  nil;
}

- (BOOL)validateForPattern:(NSString *)pattern
{
    if(self == nil || self.length == 0)
	{
		return  NO;
	}
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];
	NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	
	if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
		
		return YES;
	}
    return NO;
}

- (BOOL)validateForPhone
{
    if (ZYIsNullOrEmpty(self) || self.length != 11 ||![self validateForPattern:@"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[0-9]))\\d{8}$"]) {
        return NO;
    }
    return YES;
}
- (BOOL)validateForPasswd
{
    if (ZYIsNullOrEmpty(self) || self.length<6 || self.length>10 ||![self validateForPattern:@"^[a-zA-Z0-9_]{6,10}$"]) {
        return NO;
    }
    return YES;
}
- (BOOL)validateForNickName
{
    if (ZYIsNullOrEmpty(self) || self.length > 8 ||![self validateForPattern:@"^[\u4E00-\u9FA5a-zA-Z0-9_]+$"]) {
        return NO;
    }
    return YES;
}
@end

@implementation NSString (MobileVerification)
//判断手机号长度
+ (BOOL)verificationMobileLength:(NSString *)mobile{
    if (mobile.length != 11 || ![self isPureNumandCharacters:mobile]) {
        NSLog(@"手机号格式错误，请确认您的手机号。");
        return NO;
    }else {
        return YES;
    }
}
//判断是否为纯数字
+ (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if(string.length > 0)
    {
        
        return NO;
        
    }
    return YES;
    
}

+ (BOOL)verificationMobile:(NSString *)mobile{
    NSString *regex = @"^((13[0-9])|(147)|(177)|(15[0-3|5-9])|(18([0-3]|[5-9])))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:mobile];
    
    if (!isMatch) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入正确的手机号码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [al show];
        return NO;
    }else{
        return YES;
    }
}

//邮箱
+ (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isMatch = [emailTest evaluateWithObject:email];
    
    if (!isMatch) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入正确的邮箱！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [al show];
        return NO;
    } else {
        return YES;
    }
}

//密码格式
+ (BOOL)verificationPwd:(NSString *)pwd
{
    NSString *psdRegex = @"^[A-Za-z0-9]{6,16}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", psdRegex];
    BOOL isMatch = [pred evaluateWithObject:pwd];
    if (!isMatch) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"密码格式不符！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [al show];
        return NO;
    } else {
        return YES;
    }
    
    
}

// 云康号  英文字母开头，只含有英文字母、数字和下划线
+ (BOOL)verificationKXID:(NSString *)kxID
{
    NSString *psdRegex = @"^[a-zA-Z][a-zA-Z0-9_]{5,19}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", psdRegex];
    BOOL isMatch = [pred evaluateWithObject:kxID];
    if (!isMatch) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"云康号格式不符！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [al show];
        return NO;
    } else {
        return YES;
    }
    
    
    
}

//身份证校验
+ (BOOL)validateIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
    
    NSInteger length =0;
    if (!value) {
        return NO;
    }else {
        length = value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    if (length==15) {
        
    }
    switch (length) {
        case15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            
            if (numberofMatch>0) {
                return YES;
            }else{
                return NO;
            }
            
        default:
            return YES;
    }
}
//手机验证
+ (BOOL)verificationMobile1:(NSString *)mobile1{
    NSString *regex = @"^((13[0-9])|(147)|(177)|(15[0-3|5-9])|(18(0|2|3|[5-9])))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:mobile1];
    
    if (!isMatch) {
        
        return NO;
    }else{
        return YES;
    }
}
//电话号码验证
+ (BOOL)verificationTel:(NSString *)tel{
    NSString *regex = @"^(0[0-9]{2,3}/-)?([2-9][0-9]{6,7})+(/-[0-9]{1,4})?$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:tel];
    
    if (!isMatch) {
        
        return NO;
    }else{
        return YES;
    }
}
//// 真实姓名验证：汉字
+(BOOL)IsChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
        
    }
    return NO;
}
//校验英文名字
+ (BOOL)isEnglishLetterOrChinese:(NSString *)str{
    NSString *regex = @"^[A-z]+$|^[\u4E00-\u9FA5]+$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:str];
    
    if (!isMatch) {
        
        return NO;
    }else{
        return YES;
    }
}
//空字符串
+(BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
@end

