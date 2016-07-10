//
//  Maker.m
//  Category
//
//  Created by wh15113030 on 16/6/27.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import "Maker.h"
@interface Maker()

@property (nonatomic, assign) __block int isResult;

@end


@implementation Maker
+ (int)makeCaculator:(void(^)(Maker *maker))caculator;
{
    Maker *maker = [[Maker alloc] init];
    caculator(maker);
    return maker.isResult;
}


- (Maker *(^)(int))add{
    return ^(int value){
        _isResult += value;
        return self;
    };
}

- (Maker *(^)(int))sub{
    
    return ^(int value){
        _isResult -= value;
        return self;
    };
    
    
}

- (Maker *(^)(int))muilt{
    return ^(int value){
        _isResult = value * _isResult;
        return self;
    };
}

- (Maker *(^)(int))divide{
    return ^(int value){
        _isResult = value / _isResult;
        return self;
    };
}







@end
