//
//  NSMutableArray+Extension.h
//  Category
//
//  Created by wh15113030 on 16/6/24.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableArray (Extension)

/*
 * 将汉字拼音首字母进行排序
 */
-(NSArray *)firstCharcterSortingOfChinese;

/*
 * 汉字按照拼音首字母排序存入字典中
 */
-(NSMutableDictionary *)chineseCharacterSorting;

-(NSMutableDictionary *)chineseCharacterSorting:(NSMutableArray *)array KeyArray:(NSArray *)keyArray;

- (NSDictionary *)dictionaryOrderByCharactorWithOriginalArray;
@end
