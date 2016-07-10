//
//  MyLog.h
//  HotelPro
//
//  Created by openet on 12-4-24.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DICTIONARY_LOG
#define Tap 10
void ArrLog(NSArray* arr,int lftSpace, int level);        // 打印中文
void DicLog(NSDictionary* dic,int lftSpace ,int level);  // 打印中文
void v_subview(UIView *v );               //显示所有子控件
void ALog(NSArray* arr);
void DLog(NSDictionary* dic);
void t_Log_(id a);
#define Log(a) {NSLog(@"%s\n%s =",__FUNCTION__,#a);t_Log_(a);}
#define subview(a) {NSLog(@"%s\n%s =",__FUNCTION__,#a);v_subview(a);}
#endif

#ifdef DEBUG
#define CJLog(format, ...) NSLog(format, ##__VA_ARGS__)

#else
#define CJLog(format, ...)
#define CJTrace(format, ...)
#endif
