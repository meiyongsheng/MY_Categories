//
//  Caculator.h
//  Category
//
//  Created by wh15113030 on 16/6/27.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Caculator : NSObject

+ (int)makeCaculators:(void(^)(Caculator *caculator))caculator;

- (Caculator *(^)(int))add;

@end
