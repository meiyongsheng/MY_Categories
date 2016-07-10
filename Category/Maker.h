//
//  Maker.h
//  Category
//
//  Created by wh15113030 on 16/6/27.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Maker : NSObject

+ (int)makeCaculator:(void(^)(Maker *maker))caculator;

- (Maker *(^)(int))add;

- (Maker *(^)(int))sub;

- (Maker *(^)(int))muilt;

- (Maker *(^)(int))divide;

@end
