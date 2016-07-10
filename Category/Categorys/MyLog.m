//
//  MyLog.m
//  HotelPro
//
//  Created by openet on 12-4-24.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#ifdef DICTIONARY_LOG
#import "MyLog.h"
void add2Dic(NSMutableDictionary * dic ,UIView *v , int iterator );
void v_subview(UIView *v ){
	NSMutableDictionary *subViews = [NSMutableDictionary dictionaryWithCapacity:20];
	int j = 0 ;
	for (UIView * sub in v.subviews) {
		add2Dic(subViews , sub, j ++ );
	}
	DLog(subViews);
}

void add2Dic(NSMutableDictionary * dic ,UIView *v , int iterator ){
	if (v.subviews.count) {
		NSMutableDictionary * dicS = [NSMutableDictionary dictionaryWithCapacity:20];
		[dic safe_setObject: dicS  forKey:[NSString stringWithFormat:@"%@ %d", [v class],iterator]];
		for (int i = 0 ; i < v.subviews.count ; ++ i) {
			UIView *subView = [v.subviews objectAtIndex:i];
			add2Dic(dicS, subView, i);
		}
	}
	else{
		[dic safe_setObject:@"leaf" forKey:[NSString stringWithFormat:@"%@ %d", [v class],iterator]];
	}
}
 
void ArrLog(NSArray* arr,int lftSpace, int level){
	printf("(");
	for (id itm in arr) {
		if ([itm isKindOfClass:[NSArray class]]) {
			ArrLog((NSArray*) itm,lftSpace /*+Tap*/ ,level);
		}
		else if ([itm isKindOfClass:[NSDictionary class]]) {
			DicLog((NSDictionary*) itm,lftSpace /*+Tap*/ ,level);
		}
		else if ([itm isKindOfClass:[NSString class]]){
			printf("%s",[(NSString*)itm UTF8String]);
			
		}
		else if([itm isKindOfClass:[NSNumber class]]){
			printf("%s", [[(NSNumber*)itm  stringValue] UTF8String]);
			
			
		}

			
		
		else {
			printf("%s" ,object_getClassName(itm));
		}
		printf("%*s%*s",lftSpace ,",\n",lftSpace ,"");		
	}
	printf("%*s)",lftSpace,"");
}
void DicLog(NSDictionary* dic,int lftSpace,int level){
	printf("\n%*s{\n",lftSpace,"");
	NSArray*keys=[dic allKeys];
	id itm;
	int maxSpace = 0;
 
	NSString * str ;
	for (NSString * strLen  in keys ) {
		maxSpace =	maxSpace >= strLen.length ?maxSpace:strLen.length;
	}
	for (int i = 0;i<keys.count ;++i) {
		
		str = [keys objectAtIndex:i];
	 

		printf("%*s =%i= ",maxSpace +lftSpace,[str UTF8String],level);
		itm=[dic objectForKey:str];
		if ([itm isKindOfClass:[NSArray class]]) {
			ArrLog((NSArray*) itm,lftSpace + maxSpace ,level+1);
		}
		else if ([itm isKindOfClass:[NSDictionary class]]) {
			DicLog((NSDictionary*) itm,lftSpace +maxSpace  ,level+1);
		}
		else if ([itm isKindOfClass:[NSString class]]){
			printf("%s",[(NSString*)itm UTF8String]);
			
		}
		else if([itm isKindOfClass:[NSNumber class]]){
			printf("%s", [[(NSNumber*)itm  stringValue] UTF8String]);
		}
		
		else {
			printf("%s  %s", object_getClassName(itm) ,[[NSString stringWithFormat:@"%@",itm] UTF8String]);
		}
		printf("\n");
	}
	printf("%*s}\n",lftSpace,"");
}
void ALog(NSArray* arr){
    ArrLog(arr, 10,0);
}
void DLog(NSDictionary* dic){
    DicLog(dic, 10,0);
}
void t_Log_(id a){
 
    if ([a isKindOfClass:[NSArray class]]) {
        ALog(a);
    }
    else if([a isKindOfClass:[NSDictionary class]]){
        DLog(a);
    }
    else if([a isKindOfClass:[NSString class]]){
       
		printf("%s ", [[NSString stringWithFormat:@"%@",a] UTF8String]);
    }
    else {
//        CJLog(@" class %@  : %@",[a class],a);
		printf("%s  %s", object_getClassName(a) ,[[NSString stringWithFormat:@"%@",a] UTF8String]);
    }
	printf("\n\n");
}





#endif

