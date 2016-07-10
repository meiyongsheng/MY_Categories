//
//  NSMutableArray+Extension.m
//  Category
//
//  Created by wh15113030 on 16/6/24.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import "NSMutableArray+Extension.h"


@implementation NSMutableArray (Extension)

//获取字符串（或汉字）首字母
- (NSString *)firstCharacterWithString:(NSString *)charStr{
    NSMutableString *str = [NSMutableString stringWithString:charStr];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString * pinyin =[str capitalizedString];
    return [pinyin substringToIndex:1];
}

/*
 * 将汉字拼音首字母进行排序
 */
-(NSArray *)firstCharcterSortingOfChinese
{
    NSMutableSet *firstArr = [[NSMutableSet alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *chars = [self firstCharacterWithString:self[idx]];
          [firstArr addObject:chars];
    }];
    
    NSArray *newArray = [[firstArr allObjects] sortedArrayUsingSelector:@selector(compare:)];
    return newArray;
}

/*
 * 汉字按照拼音首字母排序存入字典中
 */
-(NSMutableDictionary *)chineseCharacterSorting
{
    __block NSArray *keyArray = [self firstCharcterSortingOfChinese];
    
    NSLog(@"%@",keyArray);
    
    __block NSMutableDictionary *sectionDic = [NSMutableDictionary dictionary];
    [keyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
        __block  NSMutableArray *arr = [NSMutableArray array];
          [self enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
              __block NSString *first = [self firstCharacterWithString:obj1];

              if ([first isEqualToString:obj]) {
                  [arr addObject:obj1];
              }
              
          }];
        
        [sectionDic setObject:arr forKey:obj];
    }];
    
    
    return sectionDic;
}

//- (NSComparisonResult)compare:(NSString *)otherObject {
//    return [self compare:otherObject];
//}


-(NSMutableDictionary *)chineseCharacterSorting:(NSMutableArray *)array KeyArray:(NSArray *)keyArray
{
    NSMutableDictionary *sectionDic = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < keyArray.count; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int j = 0; j < array.count; j++) {
             NSString *first = [self firstCharacterWithString:array[j]];
            if ([first isEqualToString:keyArray[i]]) {
                [arr addObject:array[j]];
            }
        }
        [sectionDic setObject:arr forKey:keyArray[i]];
    }
    return sectionDic;
    
}


- (NSDictionary *)dictionaryOrderByCharactorWithOriginalArray{
    if (!self.count) {
        return nil;
    }
    for (id obj in self) {
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
    for (int i = 0 ; i < self.count; i ++) {
        NSInteger  index = [indexedCollation sectionForObject:self[i] collationStringSelector:@selector(uppercaseString)];
        [[objects objectAtIndex:index] addObject:self[i]];
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
    NSString *key;
    for (NSMutableArray *obj in objects) {
        NSString *str = obj[0];
        key = [self firstCharacterWithString:str];
        [keys addObject:key];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:objects forKey:key];
    
    NSLog(@"%@-----------",dic);
    
    return dic;
}





@end
