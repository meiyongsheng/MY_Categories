//
//  Caculator.m
//  Category
//
//  Created by wh15113030 on 16/6/27.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import "Caculator.h"
@interface  Caculator ()

@property (nonatomic, assign) int isResult;



@end

@implementation Caculator

+ (int)makeCaculators:(void(^)(Caculator *caculator))caculator{
    Caculator *make = [[Caculator alloc] init];
    caculator(make);
    return make.isResult;
}

- (Caculator *(^)(int))add{

    return ^(int value){
        _isResult += value;
        return self;
    };

}








@end
