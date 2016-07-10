//
//  ViewController.m
//  Category
//
//  Created by wh15113030 on 16/6/24.
//  Copyright © 2016年 wh15113030. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+Extension.h"
#import "Maker.h"
#import "Caculator.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //iOS----- 链式编程
    int result = [Maker makeCaculator:^(Maker *maker) {
        maker.add(1).add(20).add(30);
    }];
    
     int result1 =  [Caculator makeCaculators:^(Caculator *caculator) {
           NSLog(@"%@-------%s",caculator.add(10),__func__);
    }];

    
    
    //获取汉字的首字母并排序
    NSArray *arr1 = @[@"啊",@"比",@"次",@"梅永盛2",@"梅永盛1",@"刘超1",@"刘超2",@"刘超3",@"朱敏",@"朱敏1"];
    NSLog(@"%@",[arr1.mutableCopy dictionaryOrderByCharactorWithOriginalArray]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
